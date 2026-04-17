import { Router } from 'express';
import {
    getAllPatients,
    getPatientById,
    createPatient,
    updatePatient,
    deletePatient
} from '../controllers/patient.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/patients
 * @desc    Get all patients
 * @access  Private
 */
router.get('/', getAllPatients);

/**
 * @route   POST /api/v1/patients
 * @desc    Create new patient
 * @access  Private (Health Worker, Clinic Staff, Admin)
 */
router.post(
    '/',
    authorize(UserRole.HEALTH_WORKER, UserRole.CLINIC_STAFF, UserRole.ADMIN),
    createPatient
);

/**
 * @route   GET /api/v1/patients/:id
 * @desc    Get patient by ID
 * @access  Private
 */
router.get('/:id', getPatientById);

/**
 * @route   PUT /api/v1/patients/:id
 * @desc    Update patient
 * @access  Private (Health Worker, Clinic Staff, Admin)
 */
router.put(
    '/:id',
    authorize(UserRole.HEALTH_WORKER, UserRole.CLINIC_STAFF, UserRole.ADMIN),
    updatePatient
);

/**
 * @route   DELETE /api/v1/patients/:id
 * @desc    Delete patient (soft delete)
 * @access  Private (Admin only)
 */
router.delete('/:id', authorize(UserRole.ADMIN), deletePatient);

export default router;
