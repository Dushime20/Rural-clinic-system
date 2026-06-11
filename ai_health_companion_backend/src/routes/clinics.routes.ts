/**
 * Clinics Routes
 * Routes for public/internal clinic search
 */

import { Router } from 'express';
import {
    searchClinics,
    getAllClinics,
    getClinicById,
    validateClinicSearch,
} from '../controllers/clinics.controller';
import { authenticate } from '../middleware/auth';
import { clinicSearchLimiter } from '../middleware/rate-limiter';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/clinics/search
 * @desc    Search clinics by disease and location
 * @access  Private (Authenticated users)
 */
router.post('/search', clinicSearchLimiter, validateClinicSearch, searchClinics);

/**
 * @route   GET /api/clinics/map
 * @desc    Get all active clinics (for map view)
 * @access  Private (Authenticated users)
 */
router.get('/map', getAllClinics);

/**
 * @route   GET /api/clinics/:id
 * @desc    Get clinic details by ID
 * @access  Private (Authenticated users)
 */
router.get('/:id', getClinicById);

export default router;
