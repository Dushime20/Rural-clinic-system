/**
 * Clinics Routes
 * Routes for public/internal clinic search
 */

import { Router } from 'express';
import {
    searchClinics,
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

export default router;
