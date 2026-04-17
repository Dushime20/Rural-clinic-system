import { Router } from 'express';
import { Response, NextFunction } from 'express';
import { AuthRequest, authenticate } from '../middleware/auth';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { AppDataSource } from '../database/data-source';
import { MoreThanOrEqual } from 'typeorm';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @swagger
 * /analytics/dashboard:
 *   get:
 *     summary: Get dashboard statistics
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics
 */
router.get('/dashboard', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const clinicId = req.user?.clinicId;
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // Get repositories
        const patientRepo = AppDataSource.getRepository(Patient);
        const diagnosisRepo = AppDataSource.getRepository(Diagnosis);

        // Get total counts
        const totalPatients = await patientRepo.count({
            where: { clinicId, isActive: true }
        });
        const totalDiagnoses = await diagnosisRepo.count({
            where: { clinicId }
        });

        // Get recent counts (last 30 days)
        const recentPatients = await patientRepo.count({
            where: {
                clinicId,
                createdAt: MoreThanOrEqual(thirtyDaysAgo)
            }
        });

        const recentDiagnoses = await diagnosisRepo.count({
            where: {
                clinicId,
                diagnosisDate: MoreThanOrEqual(thirtyDaysAgo)
            }
        });

        // Get average confidence score
        const diagnosesWithConfidence = await diagnosisRepo
            .createQueryBuilder('diagnosis')
            .where('diagnosis.clinicId = :clinicId', { clinicId })
            .andWhere("jsonb_array_length(diagnosis.aiPredictions) > 0")
            .getMany();

        const avgConfidence = diagnosesWithConfidence.length > 0
            ? diagnosesWithConfidence.reduce((sum, d) => sum + (d.aiPredictions[0]?.confidence || 0), 0) / diagnosesWithConfidence.length
            : 0;

        res.status(200).json({
            success: true,
            data: {
                overview: {
                    totalPatients,
                    totalDiagnoses,
                    recentPatients,
                    recentDiagnoses,
                    averageAIConfidence: Math.round(avgConfidence * 100)
                }
            }
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @swagger
 * /analytics/diagnoses:
 *   get:
 *     summary: Get diagnosis trends and statistics
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Diagnosis analytics
 */
router.get('/diagnoses', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const clinicId = req.user?.clinicId;

        // Get repositories
        const diagnosisRepo = AppDataSource.getRepository(Diagnosis);

        // Get disease distribution
        const diagnoses = await diagnosisRepo.find({ where: { clinicId } });
        const diseaseCount: Record<string, number> = {};

        diagnoses.forEach(d => {
            if (d.selectedDiagnosis?.disease) {
                diseaseCount[d.selectedDiagnosis.disease] = (diseaseCount[d.selectedDiagnosis.disease] || 0) + 1;
            } else if (d.aiPredictions.length > 0) {
                const topDisease = d.aiPredictions[0].disease;
                diseaseCount[topDisease] = (diseaseCount[topDisease] || 0) + 1;
            }
        });

        const diseaseDistribution = Object.entries(diseaseCount)
            .map(([disease, count]) => ({ disease, count }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 10);

        res.status(200).json({
            success: true,
            data: {
                diseaseDistribution,
                totalDiagnoses: diagnoses.length
            }
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @swagger
 * /analytics/patients:
 *   get:
 *     summary: Get patient demographics
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Patient demographics
 */
router.get('/patients', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const clinicId = req.user?.clinicId;

        // Get repositories
        const patientRepo = AppDataSource.getRepository(Patient);
        const patients = await patientRepo.find({ where: { clinicId, isActive: true } });

        // Gender distribution
        const genderDistribution = {
            male: patients.filter(p => p.gender === 'male').length,
            female: patients.filter(p => p.gender === 'female').length,
            other: patients.filter(p => p.gender === 'other').length
        };

        // Age distribution
        const ageGroups = {
            '0-18': 0,
            '19-35': 0,
            '36-50': 0,
            '51-65': 0,
            '65+': 0
        };

        patients.forEach(p => {
            const age = p.getAge();
            if (age <= 18) ageGroups['0-18']++;
            else if (age <= 35) ageGroups['19-35']++;
            else if (age <= 50) ageGroups['36-50']++;
            else if (age <= 65) ageGroups['51-65']++;
            else ageGroups['65+']++;
        });

        res.status(200).json({
            success: true,
            data: {
                totalPatients: patients.length,
                genderDistribution,
                ageDistribution: ageGroups
            }
        });
    } catch (error) {
        next(error);
    }
});

export default router;
