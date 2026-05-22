import { Router } from 'express';
import {
    createDiagnosis,
    getDiagnosisById,
    getPatientDiagnoses,
    updateDiagnosis,
    getDiagnosesWithPrescriptions
} from '../controllers/diagnosis.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';
import { diagnosisLimiter } from '../middleware/rate-limiter';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/diagnosis/prescriptions
 * @desc    Get all diagnoses with prescriptions (for pharmacists)
 * @access  Private (Pharmacist, Health Worker, Admin)
 */
router.get('/prescriptions', getDiagnosesWithPrescriptions);

/**
 * @route   GET /api/v1/diagnosis/patients/:patientId/diagnoses
 * @desc    Get all diagnoses for a patient
 * @access  Private
 * NOTE: Must be registered BEFORE /:id to avoid Express matching "patients" as an id
 */
router.get('/patients/:patientId/diagnoses', getPatientDiagnoses);

/**
 * @route   POST /api/v1/diagnosis
 * @desc    Create AI diagnosis
 * @access  Private (Health Worker, Admin)
 */
router.post(
    '/',
    diagnosisLimiter,
    authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN),
    createDiagnosis
);

/**
 * @route   GET /api/v1/diagnosis/:id
 * @desc    Get diagnosis by ID
 * @access  Private
 */
router.get('/:id', getDiagnosisById);

/**
 * @route   PUT /api/v1/diagnosis/:id
 * @desc    Update diagnosis
 * @access  Private (Health Worker, Admin)
 */
router.put(
    '/:id',
    authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN),
    updateDiagnosis
);

export default router;
