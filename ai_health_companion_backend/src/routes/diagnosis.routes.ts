import { Router } from 'express';
import {
    createDiagnosis,
    getDiagnosisById,
    getPatientDiagnoses,
    updateDiagnosis,
    getDiagnosesWithPrescriptions
} from '../controllers/diagnosis.controller';
import {
    translateDiagnosisReport,
    translateText,
    getTranslationServiceStatus
} from '../controllers/translation.controller';
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
 * @route   GET /api/v1/diagnosis/translation/status
 * @desc    Check translation service status
 * @access  Private
 */
router.get('/translation/status', getTranslationServiceStatus);

/**
 * @route   POST /api/v1/diagnosis/translation/text
 * @desc    Translate arbitrary text to Kinyarwanda
 * @access  Private
 */
router.post('/translation/text', translateText);

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
 * @route   GET /api/v1/diagnosis/:id/translate
 * @desc    Translate diagnosis report to Kinyarwanda
 * @access  Private
 */
router.get('/:id/translate', translateDiagnosisReport);

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

/**
 * @route   GET /api/v1/patients/:patientId/diagnoses
 * @desc    Get all diagnoses for a patient
 * @access  Private
 */
router.get('/patients/:patientId/diagnoses', getPatientDiagnoses);

export default router;
