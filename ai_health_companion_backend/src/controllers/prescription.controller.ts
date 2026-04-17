import { Response, NextFunction } from 'express';
import { Prescription, PrescriptionStatus } from '../models/Prescription';
import { Patient } from '../models/Patient';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { createAuditLog } from '../middleware/audit';
import { AuditAction, AuditResource } from '../models/AuditLog';
import { elmisService } from '../services/elmis.service';

const prescriptionRepository = AppDataSource.getRepository(Prescription);
const patientRepository = AppDataSource.getRepository(Patient);

/**
 * Create prescription
 */
export const createPrescription = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId, diagnosisId, medications, notes, pharmacyInstructions, expiryDate } = req.body;

        const patient = await patientRepository.findOne({ where: { id: patientId } });
        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        // Check medication availability via e-LMIS
        const availabilityChecks = await Promise.all(
            medications.map(async (med: any) => {
                try {
                    const availability = await elmisService.checkAvailability(
                        med.medicationName,
                        req.user?.clinicId
                    );
                    return {
                        medication: med.medicationName,
                        available: availability.some(a => a.isAvailable),
                        alternatives: availability.length > 0 ? availability : []
                    };
                } catch (error) {
                    logger.warn(`Failed to check availability for ${med.medicationName}`);
                    return { medication: med.medicationName, available: true, alternatives: [] };
                }
            })
        );

        const prescription = prescriptionRepository.create({
            prescriptionId: `RX-${uuidv4().slice(0, 8).toUpperCase()}`,
            patientId,
            prescriberId: req.user?.id!,
            diagnosisId,
            clinicId: req.user?.clinicId!,
            medications: medications.map((med: any) => ({
                ...med,
                refillsRemaining: med.refillsAllowed || 0
            })),
            notes,
            pharmacyInstructions,
            expiryDate: expiryDate ? new Date(expiryDate) : undefined,
            status: PrescriptionStatus.ACTIVE
        });

        await prescriptionRepository.save(prescription);

        await createAuditLog(req, {
            action: AuditAction.CREATE,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Created prescription for patient ${patient.getFullName()}`
        }, undefined, prescription);

        logger.info(`Prescription created: ${prescription.prescriptionId}`);

        res.status(201).json({
            success: true,
            message: 'Prescription created successfully',
            data: { 
                prescription,
                availabilityChecks
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get prescription by ID
 */
export const getPrescriptionById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const prescription = await prescriptionRepository.findOne({
            where: { id: req.params.id },
            relations: ['patient', 'prescriber', 'diagnosis']
        });

        if (!prescription) {
            throw new AppError('Prescription not found', 404);
        }

        await createAuditLog(req, {
            action: AuditAction.READ,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Viewed prescription ${prescription.prescriptionId}`
        });

        res.status(200).json({
            success: true,
            data: { prescription }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get patient prescriptions
 */
export const getPatientPrescriptions = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId } = req.params;
        const { status } = req.query;

        const where: any = { patientId };
        if (status) {
            where.status = status;
        }

        const prescriptions = await prescriptionRepository.find({
            where,
            relations: ['prescriber'],
            order: { prescriptionDate: 'DESC' }
        });

        res.status(200).json({
            success: true,
            data: { prescriptions, count: prescriptions.length }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Dispense prescription
 */
export const dispensePrescription = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { pharmacyId } = req.body;
        const prescription = await prescriptionRepository.findOne({ where: { id: req.params.id } });

        if (!prescription) {
            throw new AppError('Prescription not found', 404);
        }

        if (prescription.isDispensed) {
            throw new AppError('Prescription already dispensed', 400);
        }

        prescription.isDispensed = true;
        prescription.dispensedAt = new Date();
        prescription.dispensedBy = req.user?.id;
        prescription.pharmacyId = pharmacyId;

        await prescriptionRepository.save(prescription);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Dispensed prescription ${prescription.prescriptionId}`
        });

        logger.info(`Prescription dispensed: ${prescription.prescriptionId}`);

        res.status(200).json({
            success: true,
            message: 'Prescription dispensed successfully',
            data: { prescription }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update prescription status
 */
export const updatePrescriptionStatus = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { status } = req.body;
        const prescription = await prescriptionRepository.findOne({ where: { id: req.params.id } });

        if (!prescription) {
            throw new AppError('Prescription not found', 404);
        }

        const oldStatus = prescription.status;
        prescription.status = status;

        await prescriptionRepository.save(prescription);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Updated prescription status from ${oldStatus} to ${status}`
        }, { status: oldStatus }, { status });

        res.status(200).json({
            success: true,
            message: 'Prescription status updated successfully',
            data: { prescription }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Request refill
 */
export const requestRefill = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { medicationIndex } = req.body;
        const prescription = await prescriptionRepository.findOne({ where: { id: req.params.id } });

        if (!prescription) {
            throw new AppError('Prescription not found', 404);
        }

        if (prescription.status !== PrescriptionStatus.ACTIVE) {
            throw new AppError('Prescription is not active', 400);
        }

        const medication = prescription.medications[medicationIndex];
        if (!medication) {
            throw new AppError('Medication not found in prescription', 404);
        }

        if (medication.refillsRemaining <= 0) {
            throw new AppError('No refills remaining', 400);
        }

        medication.refillsRemaining--;
        prescription.medications[medicationIndex] = medication;

        await prescriptionRepository.save(prescription);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Refill requested for ${medication.medicationName}`
        });

        logger.info(`Refill requested for prescription: ${prescription.prescriptionId}`);

        res.status(200).json({
            success: true,
            message: 'Refill requested successfully',
            data: { prescription }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Cancel prescription
 */
export const cancelPrescription = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { reason } = req.body;
        const prescription = await prescriptionRepository.findOne({ where: { id: req.params.id } });

        if (!prescription) {
            throw new AppError('Prescription not found', 404);
        }

        if (prescription.status === PrescriptionStatus.COMPLETED) {
            throw new AppError('Cannot cancel completed prescription', 400);
        }

        prescription.status = PrescriptionStatus.CANCELLED;
        if (reason) {
            prescription.notes = `${prescription.notes || ''}\nCancellation reason: ${reason}`;
        }

        await prescriptionRepository.save(prescription);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.PRESCRIPTION,
            resourceId: prescription.id,
            description: `Cancelled prescription: ${reason}`
        });

        logger.info(`Prescription cancelled: ${prescription.prescriptionId}`);

        res.status(200).json({
            success: true,
            message: 'Prescription cancelled successfully',
            data: { prescription }
        });
    } catch (error) {
        next(error);
    }
};
