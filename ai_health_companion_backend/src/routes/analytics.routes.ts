import { Router } from 'express';
import { Response, NextFunction } from 'express';
import { AuthRequest, authenticate } from '../middleware/auth';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { User } from '../models/User';
import { Appointment, AppointmentStatus } from '../models/Appointment';
import { Medication } from '../models/Medication';
import { Prescription } from '../models/Prescription';
import { LabResult } from '../models/LabResult';
import { AppDataSource } from '../database/data-source';
import { MoreThanOrEqual, Between } from 'typeorm';

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
        const userRole = req.user?.role;
        const isAdmin = userRole === 'admin';
        
        const now = new Date();
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);
        const todayEnd = new Date();
        todayEnd.setHours(23, 59, 59, 999);

        // Get repositories
        const userRepo = AppDataSource.getRepository(User);
        const patientRepo = AppDataSource.getRepository(Patient);
        const diagnosisRepo = AppDataSource.getRepository(Diagnosis);
        const appointmentRepo = AppDataSource.getRepository(Appointment);
        const medicationRepo = AppDataSource.getRepository(Medication);
        const prescriptionRepo = AppDataSource.getRepository(Prescription);
        const labResultRepo = AppDataSource.getRepository(LabResult);

        // Build where clauses - admins see all data, others see only their clinic
        const clinicWhere = isAdmin ? {} : { clinicId };
        const patientWhere = isAdmin ? { isActive: true } : { clinicId, isActive: true };

        // Basic counts
        const totalUsers = await userRepo.count();
        const activeUsers = await userRepo.count({ where: { isActive: true } });
        const totalPatients = await patientRepo.count({ where: patientWhere });
        const totalDiagnoses = await diagnosisRepo.count({ where: clinicWhere });
        const totalAppointments = await appointmentRepo.count({ where: clinicWhere });
        const todayAppointments = await appointmentRepo.count({ 
            where: { 
                ...clinicWhere,
                appointmentDate: Between(todayStart, todayEnd) 
            } 
        });
        const totalMedications = await medicationRepo.count({ where: clinicWhere });
        
        // Low stock alerts
        const medications = await medicationRepo.find({ where: clinicWhere });
        const lowStockCount = medications.filter(m => 
            m.stockInfo && m.stockInfo.quantity <= m.stockInfo.reorderLevel
        ).length;

        // Pending prescriptions (Active but not dispensed)
        const pendingPrescriptions = await prescriptionRepo.count({
            where: { ...clinicWhere, isDispensed: false }
        });

        // Critical lab results (Not yet reviewed)
        const criticalLabResults = await labResultRepo.count({
            where: { 
                hasCriticalValues: true,
                reviewedAt: undefined as any // TypeORM way to check null
            }
        });

        // Disease distribution (Top 3 diseases over time)
        const allDiagnoses = await diagnosisRepo.find({ where: clinicWhere });
        const diseaseFreq: Record<string, number> = {};
        allDiagnoses.forEach(d => {
            const disease = d.selectedDiagnosis?.disease || (d.aiPredictions[0]?.disease) || 'Unknown';
            diseaseFreq[disease] = (diseaseFreq[disease] || 0) + 1;
        });
        const top3Diseases = Object.entries(diseaseFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 3)
            .map(d => d[0]);

        const diseaseTrends: any[] = [];
        for (let i = 5; i >= 0; i--) {
            const d = new Date();
            d.setMonth(d.getMonth() - i);
            const monthName = d.toLocaleDateString('en-US', { month: 'short' });
            const monthStart = new Date(d.getFullYear(), d.getMonth(), 1);
            const monthEnd = new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59, 999);
            
            const monthDiagnoses = await diagnosisRepo.find({
                where: { ...clinicWhere, diagnosisDate: Between(monthStart, monthEnd) }
            });
            
            const trendEntry: any = { month: monthName };
            top3Diseases.forEach(disease => {
                trendEntry[disease.toLowerCase().replace(/\s+/g, '_')] = monthDiagnoses.filter(diag => {
                    const dName = diag.selectedDiagnosis?.disease || (diag.aiPredictions[0]?.disease) || 'Unknown';
                    return dName === disease;
                }).length;
            });
            diseaseTrends.push(trendEntry);
        }

        // Role distribution
        const users = await userRepo.find();
        const roleCounts: Record<string, number> = {};
        const ROLE_MAP: Record<string, string> = {
            'admin': 'Admins',
            'health_worker': 'Health Workers',
            'clinic_staff': 'Clinic Staff',
            'supervisor': 'Supervisors'
        };
        users.forEach(u => {
            const label = ROLE_MAP[u.role] || u.role;
            roleCounts[label] = (roleCounts[label] || 0) + 1;
        });
        const roleDistribution = Object.entries(roleCounts).map(([name, value]) => ({
            name,
            value,
            color: name === 'Admins' ? '#8b5cf6' : name === 'Health Workers' ? '#3b82f6' : name === 'Clinic Staff' ? '#10b981' : '#f59e0b'
        }));

        // Appointment stats for last 7 days
        const last7Days: any[] = [];
        for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            const start = new Date(d);
            start.setHours(0, 0, 0, 0);
            const end = new Date(d);
            end.setHours(23, 59, 59, 999);
            
            const dayName = d.toLocaleDateString('en-US', { weekday: 'short' });
            const counts = await appointmentRepo.find({
                where: { ...clinicWhere, appointmentDate: Between(start, end) }
            });
            
            last7Days.push({
                day: dayName,
                scheduled: counts.filter(a => a.status === AppointmentStatus.SCHEDULED).length,
                completed: counts.filter(a => a.status === AppointmentStatus.COMPLETED).length,
                cancelled: counts.filter(a => a.status === AppointmentStatus.CANCELLED).length
            });
        }

        // Recent diagnoses (last 5)
        const recentDiagnoses = await diagnosisRepo.find({
            where: clinicWhere,
            order: { createdAt: 'DESC' },
            take: 5,
        });

        // Recent patients (last 5)
        const recentPatients = await patientRepo.find({
            where: patientWhere,
            order: { createdAt: 'DESC' },
            take: 5,
        });

        res.status(200).json({
            success: true,
            data: {
                totalUsers,
                activeUsers,
                totalPatients,
                totalDiagnoses,
                totalAppointments,
                todayAppointments,
                totalMedications,
                lowStockCount,
                pendingPrescriptions,
                criticalLabResults,
                diseaseTrends,
                topDiseases: top3Diseases.map(d => ({ name: d, key: d.toLowerCase().replace(/\s+/g, '_') })),
                roleDistribution,
                appointmentTrends: last7Days,
                recentDiagnoses: recentDiagnoses.map(d => ({
                    disease: d.selectedDiagnosis?.disease || d.aiPredictions?.[0]?.disease || 'Unknown',
                    diagnosisDate: d.diagnosisDate,
                    createdAt: d.createdAt,
                })),
                recentPatients: recentPatients.map(p => ({
                    firstName: p.firstName,
                    lastName: p.lastName,
                    createdAt: p.createdAt,
                })),
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
        const userRole = req.user?.role;
        const isAdmin = userRole === 'admin';
        const clinicWhere = isAdmin ? {} : { clinicId };

        // Get repositories
        const diagnosisRepo = AppDataSource.getRepository(Diagnosis);

        // Get disease distribution
        const diagnoses = await diagnosisRepo.find({ where: clinicWhere });
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
        const userRole = req.user?.role;
        const isAdmin = userRole === 'admin';
        const patientWhere = isAdmin ? { isActive: true } : { clinicId, isActive: true };

        // Get repositories
        const patientRepo = AppDataSource.getRepository(Patient);
        const patients = await patientRepo.find({ where: patientWhere });

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
