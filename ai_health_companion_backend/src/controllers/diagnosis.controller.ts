import { Response, NextFunction } from 'express';
import { Diagnosis } from '../models/Diagnosis';
import { Patient } from '../models/Patient';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { AIService } from '../services/ai.service';
import { recommendationEngineService } from '../services/recommendation-engine.service';
import { diagnosisHistoryService } from '../services/diagnosis-history.service';

const aiService = new AIService();
const diagnosisRepository = AppDataSource.getRepository(Diagnosis);
const patientRepository = AppDataSource.getRepository(Patient);

/**
 * @swagger
 * /diagnosis:
 *   post:
 *     summary: Create AI diagnosis with pharmacy and clinic recommendations
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
 *         description: Diagnosis created successfully with recommendations
 */
export const createDiagnosis = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId, symptoms, vitalSigns, medicalHistory, notes, latitude, longitude } = req.body;

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
        logger.info('Calling AI service for predictions...');
        let aiPredictions;
        try {
            aiPredictions = await aiService.predictDisease(aiInput);
            logger.info(`AI predictions received: ${JSON.stringify(aiPredictions).substring(0, 300)}`);
        } catch (aiError: any) {
            logger.error('❌ AI service error:', aiError);
            logger.error('❌ AI error message:', aiError.message);
            logger.error('❌ AI error stack:', aiError.stack);
            throw new AppError(aiError.message || 'AI prediction failed', 500);
        }

        // Auto-generate prescriptions from the primary prediction's medication list
        // (Flask provides these; they can be refined by the clinician later)
        const primaryPrediction = aiPredictions[0];
        logger.info(`Primary prediction: ${primaryPrediction?.disease}, medications: ${primaryPrediction?.medications?.length || 0}`);
        
        const autoPrescriptions = primaryPrediction?.medications?.map((med: string) => ({
            medication: med,
            dosage: 'As directed',
            frequency: 'As directed',
            duration: 'As directed by physician',
        })) ?? [];
        
        logger.info(`Auto-generated ${autoPrescriptions.length} prescriptions`);

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
            prescriptions: autoPrescriptions.length > 0 ? autoPrescriptions : undefined,
            notes,
            diagnosisDate: new Date()
        });

        await diagnosisRepository.save(diagnosis);

        // Update patient's last visit
        patient.lastVisit = new Date();
        await patientRepository.save(patient);

        logger.info(`New diagnosis created: ${diagnosis.diagnosisId} for patient ${patient.patientId}`);

        // Get comprehensive recommendations (pharmacies + clinics)
        let recommendations;
        let patternAnalysis;
        let clinicRecommendationReason;
        
        try {
            const diseaseName = primaryPrediction?.disease || '';
            const medications = primaryPrediction?.medications || [];

            // Call recommendation engine
            const recommendationResult = await recommendationEngineService.getRecommendations({
                diagnosisId: diagnosis.id,
                patientId: diagnosis.patientId,
                diseaseName,
                medications,
                latitude,
                longitude,
            });

            recommendations = {
                pharmacies: recommendationResult.pharmacies || [],
                clinics: recommendationResult.clinics,
                clinicRecommendationReason: recommendationResult.clinicRecommendationReason,
            };

            patternAnalysis = recommendationResult.patternAnalysis;
            clinicRecommendationReason = recommendationResult.clinicRecommendationReason;

            logger.info(`Recommendations generated: ${recommendations.pharmacies.length} pharmacies, ${recommendations.clinics?.length ?? 'null'} clinics`);
            logger.info(`Clinic recommendation triggered: ${recommendations.clinics !== undefined}, reason: ${clinicRecommendationReason || 'none'}`);
        } catch (recError) {
            logger.error('❌ Recommendation engine error (graceful degradation):', recError);
            // Graceful degradation: return diagnosis without recommendations
            recommendations = { pharmacies: [] };
        }

        // Build response with optional clinic fields (backward compatibility)
        const response: any = {
            success: true,
            message: 'Diagnosis created successfully',
            data: {
                diagnosis,
                recommendations,
            },
        };

        // Add pattern analysis if available
        if (patternAnalysis && (patternAnalysis.isRecurring || patternAnalysis.isPersistent || patternAnalysis.matchesChronicCondition)) {
            response.data.patternAnalysis = patternAnalysis;
        }

        res.status(201).json(response);
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
 * Get all diagnoses with prescriptions (for pharmacists)
 */
export const getDiagnosesWithPrescriptions = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const search = req.query.search as string;
        const skip = (page - 1) * limit;

        const qb = diagnosisRepository
            .createQueryBuilder('diagnosis')
            .leftJoinAndSelect('diagnosis.patient', 'patient')
            .leftJoinAndSelect('diagnosis.performedBy', 'performedBy')
            .where("diagnosis.prescriptions IS NOT NULL")
            .andWhere("jsonb_array_length(diagnosis.prescriptions) > 0");

        // Search by patient name OR phone number
        if (search) {
            qb.andWhere(
                "(LOWER(patient.firstName) LIKE :search OR LOWER(patient.lastName) LIKE :search OR patient.phoneNumber LIKE :phoneSearch)",
                { 
                    search: `%${search.toLowerCase()}%`,
                    phoneSearch: `%${search}%`
                }
            );
        }

        qb.orderBy('diagnosis.diagnosisDate', 'DESC')
            .skip(skip)
            .take(limit);

        const [diagnoses, total] = await qb.getManyAndCount();

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
