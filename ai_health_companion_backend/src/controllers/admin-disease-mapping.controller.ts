/**
 * Admin Disease Mapping Controller
 * Handles admin operations for disease-specialty mappings
 */

import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error-handler';
import { MedicalSpecialty } from '../models/ClinicSpecialty';
import { body, validationResult } from 'express-validator';
import { AppDataSource } from '../database/data-source';
import { DiseaseSpecialtyMapping } from '../models/DiseaseSpecialtyMapping';

/**
 * Validation middleware for creating disease mapping
 */
export const validateCreateMapping = [
    body('diseaseName').trim().notEmpty().withMessage('Disease name is required'),
    body('primarySpecialty')
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid primary specialty'),
    body('secondarySpecialties')
        .optional()
        .isArray()
        .withMessage('Secondary specialties must be an array'),
    body('secondarySpecialties.*')
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid secondary specialty'),
    body('priority')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Priority must be between 1 and 100'),
];

/**
 * Validation middleware for updating disease mapping
 */
export const validateUpdateMapping = [
    body('diseaseName')
        .optional()
        .trim()
        .notEmpty()
        .withMessage('Disease name cannot be empty'),
    body('primarySpecialty')
        .optional()
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid primary specialty'),
    body('secondarySpecialties')
        .optional()
        .isArray()
        .withMessage('Secondary specialties must be an array'),
    body('secondarySpecialties.*')
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid secondary specialty'),
    body('priority')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Priority must be between 1 and 100'),
];

/**
 * GET /api/admin/disease-mappings
 * List all disease-specialty mappings
 */
export const listMappings = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const mappingRepository = AppDataSource.getRepository(DiseaseSpecialtyMapping);

        const mappings = await mappingRepository.find({
            order: { priority: 'DESC', diseaseName: 'ASC' },
        });

        const formatted = mappings.map(mapping => ({
            id: mapping.id,
            diseaseName: mapping.diseaseName,
            primarySpecialty: mapping.primarySpecialty,
            secondarySpecialties: mapping.secondarySpecialties,
            allSpecialties: mapping.getAllSpecialties(),
            priority: mapping.priority,
            createdAt: mapping.createdAt,
            updatedAt: mapping.updatedAt,
        }));

        res.status(200).json({
            success: true,
            data: {
                mappings: formatted,
                total: formatted.length,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * POST /api/admin/disease-mappings
 * Create new disease-specialty mapping
 */
export const createMapping = async (
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
            primarySpecialty,
            secondarySpecialties = [],
            priority = 1,
        } = req.body;

        logger.info(`Admin creating disease mapping: ${diseaseName} -> ${primarySpecialty}`);

        const mappingRepository = AppDataSource.getRepository(DiseaseSpecialtyMapping);

        // Check if mapping already exists
        const existing = await mappingRepository.findOne({
            where: { diseaseName },
        });

        if (existing) {
            throw new AppError('Disease mapping already exists for this disease', 400);
        }

        // Create mapping
        const mapping = mappingRepository.create({
            diseaseName,
            primarySpecialty,
            secondarySpecialties,
            priority,
        });

        await mappingRepository.save(mapping);

        logger.info(`Disease mapping created: ${mapping.id}`);

        res.status(201).json({
            success: true,
            message: 'Disease mapping created successfully',
            data: {
                mapping: {
                    id: mapping.id,
                    diseaseName: mapping.diseaseName,
                    primarySpecialty: mapping.primarySpecialty,
                    secondarySpecialties: mapping.secondarySpecialties,
                    allSpecialties: mapping.getAllSpecialties(),
                    priority: mapping.priority,
                    createdAt: mapping.createdAt,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * PUT /api/admin/disease-mappings/:id
 * Update disease-specialty mapping
 */
export const updateMapping = async (
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

        const { id } = req.params;
        const {
            diseaseName,
            primarySpecialty,
            secondarySpecialties,
            priority,
        } = req.body;

        const mappingRepository = AppDataSource.getRepository(DiseaseSpecialtyMapping);

        // Find mapping
        const mapping = await mappingRepository.findOne({
            where: { id },
        });

        if (!mapping) {
            throw new AppError('Disease mapping not found', 404);
        }

        logger.info(`Admin updating disease mapping: ${id}`);

        // Update fields
        if (diseaseName !== undefined) mapping.diseaseName = diseaseName;
        if (primarySpecialty !== undefined) mapping.primarySpecialty = primarySpecialty;
        if (secondarySpecialties !== undefined) mapping.secondarySpecialties = secondarySpecialties;
        if (priority !== undefined) mapping.priority = priority;

        await mappingRepository.save(mapping);

        logger.info(`Disease mapping updated: ${id}`);

        res.status(200).json({
            success: true,
            message: 'Disease mapping updated successfully',
            data: {
                mapping: {
                    id: mapping.id,
                    diseaseName: mapping.diseaseName,
                    primarySpecialty: mapping.primarySpecialty,
                    secondarySpecialties: mapping.secondarySpecialties,
                    allSpecialties: mapping.getAllSpecialties(),
                    priority: mapping.priority,
                    updatedAt: mapping.updatedAt,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};
