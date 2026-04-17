import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { Appointment } from '../models/Appointment';
import { LabOrder } from '../models/LabOrder';
import { Prescription } from '../models/Prescription';
import { AppDataSource } from '../database/data-source';
import { Between } from 'typeorm';

const patientRepository = AppDataSource.getRepository(Patient);
const diagnosisRepository = AppDataSource.getRepository(Diagnosis);
const appointmentRepository = AppDataSource.getRepository(Appointment);
const labOrderRepository = AppDataSource.getRepository(LabOrder);
const prescriptionRepository = AppDataSource.getRepository(Prescription);

export const getMOHReport = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { month, year } = req.query;
        const startDate = new Date(Number(year), Number(month) - 1, 1);
        const endDate = new Date(Number(year), Number(month), 0, 23, 59, 59);

        const totalPatients = await patientRepository.count({ where: { clinicId: req.user?.clinicId } });
        const newPatients = await patientRepository.count({
            where: { clinicId: req.user?.clinicId, createdAt: Between(startDate, endDate) }
        });

        const totalDiagnoses = await diagnosisRepository.count({
            where: { clinicId: req.user?.clinicId, diagnosisDate: Between(startDate, endDate) }
        });

        const diagnoses = await diagnosisRepository.find({
            where: { clinicId: req.user?.clinicId, diagnosisDate: Between(startDate, endDate) }
        });

        const diseaseBreakdown: Record<string, number> = {};
        diagnoses.forEach(d => {
            const disease = d.selectedDiagnosis?.disease || d.aiPredictions[0]?.disease || 'Unknown';
            diseaseBreakdown[disease] = (diseaseBreakdown[disease] || 0) + 1;
        });

        const report = {
            period: { month, year },
            summary: { totalPatients, newPatients, totalDiagnoses },
            diseaseBreakdown,
            generatedAt: new Date(),
            generatedBy: req.user?.email
        };

        res.status(200).json({ success: true, data: { report } });
    } catch (error) {
        next(error);
    }
};

export const getSurveillanceReport = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { startDate, endDate } = req.query;
        const start = new Date(startDate as string);
        const end = new Date(endDate as string);

        const diagnoses = await diagnosisRepository.find({
            where: { clinicId: req.user?.clinicId, diagnosisDate: Between(start, end) }
        });

        const diseaseCount: Record<string, { count: number; trend: string }> = {};
        diagnoses.forEach(d => {
            const disease = d.selectedDiagnosis?.disease || d.aiPredictions[0]?.disease || 'Unknown';
            diseaseCount[disease] = diseaseCount[disease] || { count: 0, trend: 'stable' };
            diseaseCount[disease].count++;
        });

        const report = {
            period: { startDate, endDate },
            diseaseCount,
            alerts: Object.entries(diseaseCount)
                .filter(([_, data]) => data.count > 10)
                .map(([disease, data]) => ({ disease, count: data.count, severity: 'high' })),
            generatedAt: new Date()
        };

        res.status(200).json({ success: true, data: { report } });
    } catch (error) {
        next(error);
    }
};

export const getClinicPerformance = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { startDate, endDate } = req.query;
        const start = new Date(startDate as string);
        const end = new Date(endDate as string);

        const totalAppointments = await appointmentRepository.count({
            where: { clinicId: req.user?.clinicId, appointmentDate: Between(start, end) }
        });

        const completedAppointments = await appointmentRepository.count({
            where: { clinicId: req.user?.clinicId, appointmentDate: Between(start, end), status: 'completed' as any }
        });

        const totalLabOrders = await labOrderRepository.count({
            where: { clinicId: req.user?.clinicId, orderDate: Between(start, end) }
        });

        const totalPrescriptions = await prescriptionRepository.count({
            where: { clinicId: req.user?.clinicId, prescriptionDate: Between(start, end) }
        });

        const report = {
            period: { startDate, endDate },
            metrics: {
                appointments: { total: totalAppointments, completed: completedAppointments, completionRate: (completedAppointments / totalAppointments * 100).toFixed(2) + '%' },
                labOrders: totalLabOrders,
                prescriptions: totalPrescriptions
            },
            generatedAt: new Date()
        };

        res.status(200).json({ success: true, data: { report } });
    } catch (error) {
        next(error);
    }
};
