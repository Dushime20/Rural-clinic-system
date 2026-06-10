/**
 * Admin Clinic Routes
 * Routes for admin management of clinics
 */

import { Router } from 'express';
import {
    createClinic,
    listClinics,
    getClinicById,
    updateClinicStatus,
    validateCreateClinic,
    validateListClinics,
    validateUpdateStatus,
} from '../controllers/admin-clinic.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';
import { clinicCreationLimiter, adminLimiter } from '../middleware/rate-limiter';

const router = Router();

// All routes require authentication and admin role
router.use(authenticate);
router.use(authorize(UserRole.ADMIN));

// Apply general admin rate limiter to all routes
router.use(adminLimiter);

/**
 * @route   POST /api/admin/clinics
 * @desc    Create new clinic user with profile
 * @access  Private (Admin only)
 */
router.post('/', clinicCreationLimiter, validateCreateClinic, createClinic);

/**
 * @route   GET /api/admin/clinics
 * @desc    List all clinics with pagination, search, and filters
 * @access  Private (Admin only)
 */
router.get('/', validateListClinics, listClinics);

/**
 * @route   GET /api/admin/clinics/:id
 * @desc    Get detailed clinic information by ID
 * @access  Private (Admin only)
 */
router.get('/:id', getClinicById);

/**
 * @route   PUT /api/admin/clinics/:id/status
 * @desc    Update clinic active status (activate/deactivate)
 * @access  Private (Admin only)
 */
router.put('/:id/status', validateUpdateStatus, updateClinicStatus);

export default router;
