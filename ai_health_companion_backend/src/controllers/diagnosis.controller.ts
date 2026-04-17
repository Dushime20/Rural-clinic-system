import { Response, NextFunction } from 'express';
import { Diagnosis } from '../models/Diagnosis';
import { Patient } from '../models/Patient';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { AIService } from '../services/ai.service';

const aiService = new AIService();
const diagnosisRepository = AppDataSource.getRepository(Diagnosis);
const patientRepository = AppDataSource.getRepository(Patient);

/**
 * @swagger
 * /diagnosis:
 *   post:
 *     summary: Create AI diagnosis
 *     tags: [Diagnosis]
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
 *         description: Diagnosis created successfully
 */
export const createDiagnosis = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId, symptoms, vitalSigns, medicalHistory, notes } = req.body;

        // Verify patient exists
        const patient = await patientRepository.findOne({ where: { id: patientId } });
        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        // Prepare AI input data
        const aiInput = {
            symptoms,
            vitalSigns,
            age: patient.getAge(),
            gender: patient.gender,
            medicalHistory: medicalHistory || patient.chronicConditions || []
        };

        // Get AI predictions
        const aiPredictions = await aiService.predictDisease(aiInput);

        // Create diagnosis
        const diagnosis = diagnosisRepository.create({
            diagnosisId: `DX-${uuidv4().slice(0, 8).toUpperCase()}`,
            patientId,
            performedById: req.user?.id,
            clinicId: req.user?.clinicId,
            symptoms,
            vitalSigns,
            patientAge: patient.getAge(),
            patientGender: patient.gender,
            medicalHistory: medicalHistory || patient.chronicConditions,
            aiPredictions,
            notes,
            diagnosisDate: new Date()
        });

        await diagnosisRepository.save(diagnosis);

        // Update patient's last visit
        patient.lastVisit = new Date();
        await patientRepository.save(patient);

        logger.info(`New diagnosis created: ${diagnosis.diagnosisId} for patient ${patient.patientId}`);

        res.status(201).json({
            success: true,
            message: 'Diagnosis created successfully',
            data: { diagnosis }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /diagnosis/{id}:
 *   get:
 *     summary: Get diagnosis by ID
 *     tags: [Diagnosis]
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
 *         description: Diagnosis details
 */
export const getDiagnosisById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const diagnosis = await diagnosisRepository.findOne({
            where: { id: req.params.id },
            relations: ['patient', 'performedBy']
        });

        if (!diagnosis) {
            throw new AppError('Diagnosis not found', 404);
        }

        res.status(200).json({
            success: true,
            data: { diagnosis }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /patients/{patientId}/diagnoses:
 *   get:
 *     summary: Get all diagnoses for a patient
 *     tags: [Diagnosis]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: patientId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of patient diagnoses
 */
export const getPatientDiagnoses = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId } = req.params;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const skip = (page - 1) * limit;

        const [diagnoses, total] = await diagnosisRepository.findAndCount({
            where: { patientId },
            relations: ['performedBy'],
            order: { diagnosisDate: 'DESC' },
            skip,
            take: limit
        });

        res.status(200).json({
            success: true,
            data: {
                diagnoses,
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
 * /diagnosis/{id}:
 *   put:
 *     summary: Update diagnosis
 *     tags: [Diagnosis]
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
 *         description: Diagnosis updated successfully
 */
export const updateDiagnosis = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const diagnosis = await diagnosisRepository.findOne({ where: { id: req.params.id } });

        if (!diagnosis) {
            throw new AppError('Diagnosis not found', 404);
        }

        // Update diagnosis
        Object.assign(diagnosis, req.body);

        // Update sync status
        if (!diagnosis.syncStatus) {
            diagnosis.syncStatus = { pendingSync: true, syncVersion: 1 };
        } else {
            diagnosis.syncStatus.pendingSync = true;
            diagnosis.syncStatus.syncVersion = (diagnosis.syncStatus.syncVersion || 0) + 1;
        }

        await diagnosisRepository.save(diagnosis);

        logger.info(`Diagnosis updated: ${diagnosis.diagnosisId} by user ${req.user?.email}`);

        res.status(200).json({
            success: true,
            message: 'Diagnosis updated successfully',
            data: { diagnosis }
        });
    } catch (error) {
        next(error);
    }
};
