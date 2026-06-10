/**
 * Disease Mappings Routes
 * Routes for disease-specialty mapping queries
 */

import { Router } from 'express';
import {
    searchDiseaseMapping,
    validateDiseaseMappingSearch,
} from '../controllers/clinics.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/disease-mappings/search
 * @desc    Get specialties for a disease
 * @access  Private (Authenticated users)
 */
router.get('/search', validateDiseaseMappingSearch, searchDiseaseMapping);

export default router;
