/**
 * Clinics Controller
 * Handles public/internal clinic search operations
 */

import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { clinicSearchService } from '../services/clinic-search.service';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error-handler';
import { body, query, validationResult } from 'express-validator';
import { AppDataSource } from '../database/data-source';
import { DiseaseSpecialtyMapping } from '../models/DiseaseSpecialtyMapping';
import { Like } from 'typeorm';

/**
 * Validation middleware for clinic search
 */
export const validateClinicSearch = [
    body('diseaseName').trim().notEmpty().withMessage('Disease name is required'),
    body('latitude').optional().isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
    body('longitude').optional().isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
    body('radiusKm').optional().isInt({ min: 1, max: 500 }).withMessage('Radius must be between 1 and 500 km'),
    body('onlyOpen').optional().isBoolean().withMessage('onlyOpen must be a boolean'),
    body('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
];

/**
 * Validation middleware for disease mapping search
 */
export const validateDiseaseMappingSearch = [
    query('disease').trim().notEmpty().withMessage('Disease query parameter is required'),
];

/**
 * POST /api/clinics/search
 * Search clinics by disease and location
 */
export const searchClinics = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate request
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            throw new AppError('Validation failed', 400, errors.array());
        }

        const {
            diseaseName,
            latitude,
            longitude,
            radiusKm,
            onlyOpen = false,
            limit = 10,
        } = req.body;

        // Log search request (without user ID for privacy)
        logger.info(`Clinic search requested for disease: ${diseaseName}`);

        // Validate location parameters together
        const hasLocation = latitude !== undefined || longitude !== undefined;
        if (hasLocation && (latitude === undefined || longitude === undefined)) {
            throw new AppError('Both latitude and longitude must be provided together', 400);
        }

        // Perform search
        const result = await clinicSearchService.searchByDisease({
            diseaseName,
            latitude: latitude !== undefined ? parseFloat(latitude) : undefined,
            longitude: longitude !== undefined ? parseFloat(longitude) : undefined,
            radiusKm: radiusKm ? parseInt(radiusKm) : undefined,
            onlyOpen,
            limit: parseInt(limit),
        });

        // Format response
        const clinicsFormatted = result.clinics.map(clinic => ({
            id: clinic.id,
            name: clinic.name,
            phoneNumber: clinic.phoneNumber,
            address: clinic.address,
            city: clinic.city,
            district: clinic.district,
            country: clinic.country,
            latitude: clinic.latitude,
            longitude: clinic.longitude,
            distance: clinic.distance,
            isOpenNow: clinic.isOpenNow,
            openingHours: clinic.openingHours,
            specialties: clinic.specialties?.map((s: any) => s.specialty) || [],
        }));

        res.status(200).json({
            success: true,
            data: {
                clinics: clinicsFormatted,
                mappedSpecialties: result.mappedSpecialties,
                totalFound: result.totalFound,
                searchParams: {
                    diseaseName,
                    hasLocation,
                    radiusKm: radiusKm || 100,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * GET /api/disease-mappings/search
 * Get specialties for a disease
 */
export const searchDiseaseMapping = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Validate request
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            throw new AppError('Validation failed', 400, errors.array());
        }

        const { disease } = req.query;

        if (!disease || typeof disease !== 'string') {
            throw new AppError('Disease query parameter is required', 400);
        }

        logger.info(`Disease mapping search for: ${disease}`);

        // Query disease-specialty mappings
        const mappingRepository = AppDataSource.getRepository(DiseaseSpecialtyMapping);
        const mappings = await mappingRepository.find({
            where: { diseaseName: Like(`%${disease}%`) },
            order: { priority: 'DESC' },
            take: 10,
        });

        // Format response
        const results = mappings.map(mapping => ({
            id: mapping.id,
            diseaseName: mapping.diseaseName,
            primarySpecialty: mapping.primarySpecialty,
            secondarySpecialties: mapping.secondarySpecialties,
            allSpecialties: mapping.getAllSpecialties(),
            priority: mapping.priority,
        }));

        res.status(200).json({
            success: true,
            data: {
                mappings: results,
                totalFound: results.length,
            },
        });
    } catch (error) {
        next(error);
    }
};
