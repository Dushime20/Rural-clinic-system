import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { Prescription } from '../models/Prescription';
import { Appointment } from '../models/Appointment';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { fhirService } from '../services/fhir.service';

const patientRepository = AppDataSource.getRepository(Patient);
const diagnosisRepository = AppDataSource.getRepository(Diagnosis);
const prescriptionRepository = AppDataSource.getRepository(Prescription);
const appointmentRepository = AppDataSource.getRepository(Appointment);

export const getFHIRPatient = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const patient = await patientRepository.findOne({ where: { id: req.params.id } });
        if (!patient) throw new AppError('Patient not found', 404);
        const fhirPatient = fhirService.patientToFHIR(patient);
        res.status(200).json(fhirPatient);
    } catch (error) {
        next(error);
    }
};

export const createFHIRPatient = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const patientData = fhirService.fhirToPatient(req.body);
        const patient = patientRepository.create({
            ...patientData,
            clinicId: req.user?.clinicId!,
            createdById: req.user?.id!
        });
        await patientRepository.save(patient);
        res.status(201).json(fhirService.patientToFHIR(patient));
    } catch (error) {
        next(error);
    }
};

export const updateFHIRPatient = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const patient = await patientRepository.findOne({ where: { id: req.params.id } });
        if (!patient) throw new AppError('Patient not found', 404);
        const patientData = fhirService.fhirToPatient(req.body);
        Object.assign(patient, patientData);
        await patientRepository.save(patient);
        res.status(200).json(fhirService.patientToFHIR(patient));
    } catch (error) {
        next(error);
    }
};

export const getFHIRObservations = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { patient: patientId } = req.query;
        if (!patientId) throw new AppError('Patient parameter is required', 400);
        
        const diagnoses = await diagnosisRepository.find({ where: { patientId: patientId as string } });
        const observations = diagnoses.flatMap(d => fhirService.vitalSignsToFHIRObservations(d.vitalSigns, d.patientId));
        
        res.status(200).json({ resourceType: 'Bundle', type: 'searchset', total: observations.length, entry: observations.map(o => ({ resource: o })) });
    } catch (error) {
        next(error);
    }
};

export const getFHIRConditions = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { patient: patientId } = req.query;
        if (!patientId) throw new AppError('Patient parameter is required', 400);
        
        const diagnoses = await diagnosisRepository.find({ where: { patientId: patientId as string } });
        const conditions = diagnoses.map(d => fhirService.diagnosisToFHIRCondition(d));
        
        res.status(200).json({ resourceType: 'Bundle', type: 'searchset', total: conditions.length, entry: conditions.map(c => ({ resource: c })) });
    } catch (error) {
        next(error);
    }
};

export const getFHIRMedicationRequests = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { patient: patientId } = req.query;
        if (!patientId) throw new AppError('Patient parameter is required', 400);
        
        const prescriptions = await prescriptionRepository.find({ where: { patientId: patientId as string } });
        const medicationRequests = prescriptions.flatMap(p => fhirService.prescriptionToFHIRMedicationRequest(p));
        
        res.status(200).json({ resourceType: 'Bundle', type: 'searchset', total: medicationRequests.length, entry: medicationRequests.map(m => ({ resource: m })) });
    } catch (error) {
        next(error);
    }
};

export const getFHIRAppointments = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { patient: patientId } = req.query;
        if (!patientId) throw new AppError('Patient parameter is required', 400);
        
        const appointments = await appointmentRepository.find({ where: { patientId: patientId as string } });
        const fhirAppointments = appointments.map(a => fhirService.appointmentToFHIRAppointment(a));
        
        res.status(200).json({ resourceType: 'Bundle', type: 'searchset', total: fhirAppointments.length, entry: fhirAppointments.map(a => ({ resource: a })) });
    } catch (error) {
        next(error);
    }
};
