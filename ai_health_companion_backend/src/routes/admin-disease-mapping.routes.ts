/**
 * Admin Disease Mapping Routes
 * Routes for admin management of disease-specialty mappings
 */

import { Router } from 'express';
import {
    listMappings,
    createMapping,
    updateMapping,
    validateCreateMapping,
    validateUpdateMapping,
} from '../controllers/admin-disease-mapping.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();

// All routes require authentication and admin role
router.use(authenticate);
router.use(authorize(UserRole.ADMIN));

/**
 * @route   GET /api/admin/disease-mappings
 * @desc    List all disease-specialty mappings
 * @access  Private (Admin only)
 */
router.get('/', listMappings);

/**
 * @route   POST /api/admin/disease-mappings
 * @desc    Create new disease-specialty mapping
 * @access  Private (Admin only)
 */
router.post('/', validateCreateMapping, createMapping);

/**
 * @route   PUT /api/admin/disease-mappings/:id
 * @desc    Update disease-specialty mapping
 * @access  Private (Admin only)
 */
router.put('/:id', validateUpdateMapping, updateMapping);

export default router;
