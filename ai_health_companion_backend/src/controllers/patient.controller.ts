import { Response, NextFunction } from 'express';
import { ILike } from 'typeorm';
import { Patient } from '../models/Patient';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';

const patientRepository = AppDataSource.getRepository(Patient);

/**
 * @swagger
 * /patients:
 *   get:
 *     summary: Get all patients
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of patients
 */
export const getAllPatients = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const search = req.query.search as string;
        const skip = (page - 1) * limit;

        // Build query
        const where: any = { isActive: true };

        if (req.user?.clinicId) {
            where.clinicId = req.user.clinicId;
        }

        if (search) {
            where.firstName = ILike(`%${search}%`);
        }

        // Get patients
        const [patients, total] = await patientRepository.findAndCount({
            where,
            relations: ['createdBy'],
            order: { createdAt: 'DESC' },
            skip,
            take: limit
        });

        res.status(200).json({
            success: true,
            data: {
                patients,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit)
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /patients/{id}:
 *   get:
 *     summary: Get patient by ID
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Patient details
 *       404:
 *         description: Patient not found
 */
export const getPatientById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const patient = await patientRepository.findOne({
            where: { id: req.params.id },
            relations: ['createdBy']
        });

        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        res.status(200).json({
            success: true,
            data: { patient }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /patients:
 *   post:
 *     summary: Create new patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       201:
 *         description: Patient created successfully
 */
export const createPatient = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Ensure DB is connected (handles Neon cold starts)
        if (!AppDataSource.isInitialized) {
            await AppDataSource.initialize();
        }

        const patientData = {
            ...req.body,
            patientId: `PAT-${uuidv4().slice(0, 8).toUpperCase()}`,
            clinicId: req.user?.clinicId,
            createdById: req.user?.id
        };
        
        const patient = patientRepository.create(patientData) as unknown as Patient;

        await patientRepository.save(patient);

        logger.info(`New patient created: ${patient.patientId} by user ${req.user?.email}`);

        res.status(201).json({
            success: true,
            message: 'Patient created successfully',
            data: { patient }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /patients/{id}:
 *   put:
 *     summary: Update patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Patient updated successfully
 */
export const updatePatient = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const patient = await patientRepository.findOne({ where: { id: req.params.id } });

        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        // Update patient
        Object.assign(patient, req.body);

        // Update sync status
        if (!patient.syncStatus) {
            patient.syncStatus = { pendingSync: true, syncVersion: 1 };
        } else {
            patient.syncStatus.pendingSync = true;
            patient.syncStatus.syncVersion = (patient.syncStatus.syncVersion || 0) + 1;
        }

        await patientRepository.save(patient);

        logger.info(`Patient updated: ${patient.patientId} by user ${req.user?.email}`);

        res.status(200).json({
            success: true,
            message: 'Patient updated successfully',
            data: { patient }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /patients/{id}:
 *   delete:
 *     summary: Delete patient (soft delete)
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Patient deleted successfully
 */
export const deletePatient = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const patient = await patientRepository.findOne({ where: { id: req.params.id } });

        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        patient.isActive = false;
        await patientRepository.save(patient);

        logger.info(`Patient deleted: ${patient.patientId} by user ${req.user?.email}`);

        res.status(200).json({
            success: true,
            message: 'Patient deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};
