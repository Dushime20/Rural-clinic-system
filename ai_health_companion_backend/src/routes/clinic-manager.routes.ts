/**
 * Clinic Manager Routes
 * Routes for clinic user profile management
 */

import { Router } from 'express';
import {
    getMyProfile,
    updateMyProfile,
    updateMySpecialties,
    validateUpdateProfile,
    validateUpdateSpecialties,
} from '../controllers/clinic-manager.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();

// All routes require authentication and clinic role
router.use(authenticate);
router.use(authorize(UserRole.CLINIC));

/**
 * @route   GET /api/clinic-manager/my
 * @desc    Get authenticated clinic user's profile
 * @access  Private (Clinic only)
 */
router.get('/my', getMyProfile);

/**
 * @route   PUT /api/clinic-manager/my/profile
 * @desc    Update clinic profile
 * @access  Private (Clinic only)
 */
router.put('/my/profile', validateUpdateProfile, updateMyProfile);

/**
 * @route   PUT /api/clinic-manager/my/specialties
 * @desc    Update clinic specialties
 * @access  Private (Clinic only)
 */
router.put('/my/specialties', validateUpdateSpecialties, updateMySpecialties);

export default router;
