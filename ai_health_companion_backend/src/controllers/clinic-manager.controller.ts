/**
 * Clinic Manager Controller
 * Handles clinic user profile management operations
 */

import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { clinicService } from '../services/clinic.service';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error-handler';
import { MedicalSpecialty } from '../models/ClinicSpecialty';
import { body, validationResult } from 'express-validator';
import { AppDataSource } from '../database/data-source';
import { User } from '../models/User';

/**
 * Validation middleware for profile update
 */
export const validateUpdateProfile = [
    body('name').optional().trim().notEmpty().withMessage('Clinic name cannot be empty'),
    body('managerName').optional().trim().notEmpty().withMessage('Manager name cannot be empty'),
    body('phoneNumber').optional().isString(),
    body('address').optional().isString(),
    body('city').optional().isString(),
    body('district').optional().isString(),
    body('country').optional().isString(),
    body('latitude')
        .optional()
        .isFloat({ min: -90, max: 90 })
        .withMessage('Latitude must be between -90 and 90'),
    body('longitude')
        .optional()
        .isFloat({ min: -180, max: 180 })
        .withMessage('Longitude must be between -180 and 180'),
    body('openingHours').optional().isObject(),
];

/**
 * Validation middleware for specialties update
 */
export const validateUpdateSpecialties = [
    body('specialties')
        .isArray({ min: 1 })
        .withMessage('At least one specialty is required'),
    body('specialties.*')
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid specialty'),
];

/**
 * GET /api/clinic-manager/my
 * Get authenticated clinic user's profile
 */
export const getMyProfile = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        if (!req.user || !req.user.id) {
            throw new AppError('User not authenticated', 401);
        }

        // Get clinic by manager ID
        const clinic = await clinicService.getClinicByManagerId(req.user.id);

        if (!clinic) {
            throw new AppError('Clinic profile not found', 404);
        }

        // Get user email
        const userRepo = AppDataSource.getRepository(User);
        const user = await userRepo.findOne({
            where: { id: req.user.id },
            select: ['email'],
        });

        res.status(200).json({
            success: true,
            data: {
                clinic: {
                    id: clinic.id,
                    name: clinic.name,
                    managerName: clinic.managerName,
                    email: user?.email || null,
                    phoneNumber: clinic.phoneNumber,
                    address: clinic.address,
                    city: clinic.city,
                    district: clinic.district,
                    country: clinic.country,
                    latitude: clinic.latitude,
                    longitude: clinic.longitude,
                    isActive: clinic.isActive,
                    openingHours: clinic.openingHours,
                    specialties: clinic.specialties?.map(s => s.specialty) || [],
                    createdAt: clinic.createdAt,
                    updatedAt: clinic.updatedAt,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * PUT /api/clinic-manager/my/profile
 * Update clinic profile
 */
export const updateMyProfile = async (
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

        if (!req.user || !req.user.id) {
            throw new AppError('User not authenticated', 401);
        }

        // Get clinic by manager ID
        const clinic = await clinicService.getClinicByManagerId(req.user.id);

        if (!clinic) {
            throw new AppError('Clinic profile not found', 404);
        }

        const {
            name,
            managerName,
            phoneNumber,
            address,
            city,
            district,
            country,
            latitude,
            longitude,
            openingHours,
        } = req.body;

        logger.info(`Clinic ${clinic.id} updating profile`);

        // Update clinic
        const updatedClinic = await clinicService.updateClinic(clinic.id, {
            name,
            managerName,
            phoneNumber,
            address,
            city,
            district,
            country,
            latitude: latitude !== undefined ? parseFloat(latitude) : undefined,
            longitude: longitude !== undefined ? parseFloat(longitude) : undefined,
            openingHours,
        });

        // Get user email
        const userRepo = AppDataSource.getRepository(User);
        const user = await userRepo.findOne({
            where: { id: req.user.id },
            select: ['email'],
        });

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: {
                clinic: {
                    id: updatedClinic.id,
                    name: updatedClinic.name,
                    managerName: updatedClinic.managerName,
                    email: user?.email || null,
                    phoneNumber: updatedClinic.phoneNumber,
                    address: updatedClinic.address,
                    city: updatedClinic.city,
                    district: updatedClinic.district,
                    country: updatedClinic.country,
                    latitude: updatedClinic.latitude,
                    longitude: updatedClinic.longitude,
                    isActive: updatedClinic.isActive,
                    openingHours: updatedClinic.openingHours,
                    specialties: updatedClinic.specialties?.map(s => s.specialty) || [],
                    updatedAt: updatedClinic.updatedAt,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * PUT /api/clinic-manager/my/specialties
 * Update clinic specialties
 */
export const updateMySpecialties = async (
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

        if (!req.user || !req.user.id) {
            throw new AppError('User not authenticated', 401);
        }

        // Get clinic by manager ID
        const clinic = await clinicService.getClinicByManagerId(req.user.id);

        if (!clinic) {
            throw new AppError('Clinic profile not found', 404);
        }

        const { specialties } = req.body;

        logger.info(`Clinic ${clinic.id} updating specialties`);

        // Update clinic specialties
        const updatedClinic = await clinicService.updateClinicSpecialties(
            clinic.id,
            specialties
        );

        res.status(200).json({
            success: true,
            message: 'Specialties updated successfully',
            data: {
                clinic: {
                    id: updatedClinic.id,
                    name: updatedClinic.name,
                    specialties: updatedClinic.specialties?.map(s => s.specialty) || [],
                    updatedAt: updatedClinic.updatedAt,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};
