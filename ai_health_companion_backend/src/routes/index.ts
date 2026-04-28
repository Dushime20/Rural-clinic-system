import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import patientRoutes from './patient.routes';
import diagnosisRoutes from './diagnosis.routes';
import syncRoutes from './sync.routes';
import analyticsRoutes from './analytics.routes';
import appointmentRoutes from './appointment.routes';
import labRoutes from './lab.routes';
import prescriptionRoutes from './prescription.routes';
import medicationRoutes from './medication.routes';
import pharmacyRoutes from './pharmacy.routes';
import fhirRoutes from './fhir.routes';
import notificationRoutes from './notification.routes';
import auditRoutes from './audit.routes';
import reportRoutes from './report.routes';

const router = Router();

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/patients', patientRoutes);
router.use('/diagnosis', diagnosisRoutes);
router.use('/sync', syncRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/appointments', appointmentRoutes);
router.use('/lab', labRoutes);
router.use('/prescriptions', prescriptionRoutes);
router.use('/medications', medicationRoutes);
router.use('/pharmacy', pharmacyRoutes);
router.use('/fhir', fhirRoutes);
router.use('/notifications', notificationRoutes);
router.use('/audit', auditRoutes);
router.use('/reports', reportRoutes);

export default router;
