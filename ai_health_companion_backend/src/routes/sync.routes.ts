import { Router } from 'express';
import { Response, NextFunction } from 'express';
import { AuthRequest, authenticate } from '../middleware/auth';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { AppError } from '../middleware/error-handler';
import { logger } from '../utils/logger';
import { AppDataSource } from '../database/data-source';
import { MoreThan } from 'typeorm';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @swagger
 * /sync/push:
 *   post:
 *     summary: Push local changes to server
 *     tags: [Sync]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               patients:
 *                 type: array
 *               diagnoses:
 *                 type: array
 *     responses:
 *       200:
 *         description: Data synchronized successfully
 */
router.post('/push', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const { patients = [], diagnoses = [] } = req.body;
        const results = {
            patients: { created: 0, updated: 0, failed: 0 },
            diagnoses: { created: 0, updated: 0, failed: 0 }
        };

        const patientRepository = AppDataSource.getRepository(Patient);
        const diagnosisRepository = AppDataSource.getRepository(Diagnosis);

        // Sync patients
        for (const patientData of patients) {
            try {
                const existing = await patientRepository.findOne({ 
                    where: { patientId: patientData.patientId } 
                });

                if (existing) {
                    // Update if server version is older
                    if (!existing.syncStatus ||
                        (patientData.syncStatus?.syncVersion || 0) > (existing.syncStatus?.syncVersion || 0)) {
                        await patientRepository.update(existing.id, {
                            ...patientData,
                            syncStatus: {
                                ...patientData.syncStatus,
                                lastSynced: new Date(),
                                pendingSync: false
                            }
                        });
                        results.patients.updated++;
                    }
                } else {
                    const newPatient = patientRepository.create({
                        ...patientData,
                        createdById: req.user?.id,
                        clinicId: req.user?.clinicId,
                        syncStatus: {
                            ...patientData.syncStatus,
                            lastSynced: new Date(),
                            pendingSync: false
                        }
                    });
                    await patientRepository.save(newPatient);
                    results.patients.created++;
                }
            } catch (error) {
                logger.error('Failed to sync patient:', error);
                results.patients.failed++;
            }
        }

        // Sync diagnoses
        for (const diagnosisData of diagnoses) {
            try {
                const existing = await diagnosisRepository.findOne({ 
                    where: { diagnosisId: diagnosisData.diagnosisId } 
                });

                if (existing) {
                    if (!existing.syncStatus ||
                        (diagnosisData.syncStatus?.syncVersion || 0) > (existing.syncStatus?.syncVersion || 0)) {
                        await diagnosisRepository.update(existing.id, {
                            ...diagnosisData,
                            syncStatus: {
                                ...diagnosisData.syncStatus,
                                lastSynced: new Date(),
                                pendingSync: false
                            }
                        });
                        results.diagnoses.updated++;
                    }
                } else {
                    const newDiagnosis = diagnosisRepository.create({
                        ...diagnosisData,
                        performedById: req.user?.id,
                        clinicId: req.user?.clinicId,
                        syncStatus: {
                            ...diagnosisData.syncStatus,
                            lastSynced: new Date(),
                            pendingSync: false
                        }
                    });
                    await diagnosisRepository.save(newDiagnosis);
                    results.diagnoses.created++;
                }
            } catch (error) {
                logger.error('Failed to sync diagnosis:', error);
                results.diagnoses.failed++;
            }
        }

        logger.info(`Sync push completed for user ${req.user?.email}:`, results);

        res.status(200).json({
            success: true,
            message: 'Data synchronized successfully',
            data: results
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @swagger
 * /sync/pull:
 *   get:
 *     summary: Pull server changes
 *     tags: [Sync]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: lastSync
 *         schema:
 *           type: string
 *           format: date-time
 *     responses:
 *       200:
 *         description: Data retrieved successfully
 */
router.get('/pull', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const lastSync = req.query.lastSync ? new Date(req.query.lastSync as string) : new Date(0);
        const clinicId = req.user?.clinicId;

        const patientRepository = AppDataSource.getRepository(Patient);
        const diagnosisRepository = AppDataSource.getRepository(Diagnosis);

        // Get updated patients
        const patients = await patientRepository.find({
            where: {
                clinicId,
                updatedAt: MoreThan(lastSync)
            },
            take: 100
        });

        // Get updated diagnoses
        const diagnoses = await diagnosisRepository.find({
            where: {
                clinicId,
                updatedAt: MoreThan(lastSync)
            },
            take: 100
        });

        res.status(200).json({
            success: true,
            data: {
                patients,
                diagnoses,
                syncTimestamp: new Date()
            }
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @swagger
 * /sync/status:
 *   get:
 *     summary: Get sync status
 *     tags: [Sync]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Sync status retrieved
 */
router.get('/status', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const clinicId = req.user?.clinicId;

        const patientRepository = AppDataSource.getRepository(Patient);
        const diagnosisRepository = AppDataSource.getRepository(Diagnosis);

        // Note: TypeORM with PostgreSQL doesn't support querying JSONB fields as easily as MongoDB
        // This is a simplified version - you may need to use raw queries for complex JSONB queries
        const allPatients = await patientRepository.find({ where: { clinicId } });
        const pendingPatients = allPatients.filter(p => p.syncStatus?.pendingSync === true).length;

        const allDiagnoses = await diagnosisRepository.find({ where: { clinicId } });
        const pendingDiagnoses = allDiagnoses.filter(d => d.syncStatus?.pendingSync === true).length;

        res.status(200).json({
            success: true,
            data: {
                pendingSync: {
                    patients: pendingPatients,
                    diagnoses: pendingDiagnoses,
                    total: pendingPatients + pendingDiagnoses
                },
                lastChecked: new Date()
            }
        });
    } catch (error) {
        next(error);
    }
});

export default router;
