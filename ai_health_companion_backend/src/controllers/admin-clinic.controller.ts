/**
 * Admin Clinic Controller
 * Handles admin operations for clinic management
 */

import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { clinicService } from '../services/clinic.service';
import { emailService } from '../services/email.service';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/error-handler';
import { MedicalSpecialty } from '../models/ClinicSpecialty';
import { body, query, validationResult } from 'express-validator';

/**
 * Validation middleware for clinic creation
 */
export const validateCreateClinic = [
    body('name').trim().notEmpty().withMessage('Clinic name is required'),
    body('managerName').trim().notEmpty().withMessage('Manager name is required'),
    body('email').isEmail().withMessage('Valid email is required'),
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
    body('specialties')
        .optional()
        .isArray({ min: 1 })
        .withMessage('At least one specialty is required if provided'),
    body('specialties.*')
        .optional()
        .isIn(Object.values(MedicalSpecialty))
        .withMessage('Invalid specialty'),
    body('openingHours').optional().isObject(),
    body('sendEmail').optional().isBoolean(),
];

/**
 * Validation middleware for clinic listing
 */
export const validateListClinics = [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
    query('search').optional().isString(),
    query('specialty').optional().isIn(Object.values(MedicalSpecialty)),
    query('isActive').optional().isBoolean(),
];

/**
 * Validation middleware for status update
 */
export const validateUpdateStatus = [
    body('isActive').isBoolean().withMessage('isActive must be a boolean'),
];

/**
 * POST /api/admin/clinics
 * Create new clinic user with profile
 */
export const createClinic = async (
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
            name,
            managerName,
            email,
            phoneNumber,
            address,
            city,
            district,
            country,
            latitude,
            longitude,
            openingHours,
            specialties,
            sendEmail = true,
        } = req.body;

        logger.info(`Admin creating clinic: ${name} (${email})`);

        // Apply defaults for incomplete profiles
        const clinicData = {
            name,
            managerName,
            email,
            phoneNumber,
            address,
            city,
            district,
            country,
            latitude: latitude ? parseFloat(latitude) : 0, // Default to 0 if not provided
            longitude: longitude ? parseFloat(longitude) : 0, // Default to 0 if not provided
            openingHours,
            specialties: specialties && specialties.length > 0 ? specialties : ['General_Medicine'], // Default specialty
        };

        // Create clinic with user account
        const result = await clinicService.createClinic(clinicData);

        // Send credentials email
        let emailSent = false;
        if (sendEmail) {
            try {
                const dashboardUrl = process.env.CLINIC_DASHBOARD_URL || 'http://localhost:5175';
                emailSent = await emailService.sendClinicCredentialsEmail({
                    email: result.user.email,
                    clinicName: name,
                    temporaryPassword: result.temporaryPassword,
                    loginUrl: dashboardUrl,
                });

                if (emailSent) {
                    logger.info(`Clinic credentials email sent to: ${email}`);
                } else {
                    logger.warn(`Failed to send credentials email to: ${email}`);
                }
            } catch (emailError) {
                logger.error(`Error sending credentials email to ${email}:`, emailError);
                // Don't fail the request if email fails
            }
        }

        res.status(201).json({
            success: true,
            message: 'Clinic created successfully',
            data: {
                user: {
                    id: result.user.id,
                    email: result.user.email,
                    role: result.user.role,
                    firstName: result.user.firstName,
                    lastName: result.user.lastName,
                },
                clinic: {
                    id: result.clinic.id,
                    name: result.clinic.name,
                    managerId: result.clinic.managerId,
                    phoneNumber: result.clinic.phoneNumber,
                    address: result.clinic.address,
                    city: result.clinic.city,
                    district: result.clinic.district,
                    country: result.clinic.country,
                    latitude: result.clinic.latitude,
                    longitude: result.clinic.longitude,
                    isActive: result.clinic.isActive,
                    specialties: result.clinic.specialties?.map(s => s.specialty) || [],
                    createdAt: result.clinic.createdAt,
                },
                temporaryPassword: result.temporaryPassword, // Return for admin display
                emailSent,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * GET /api/admin/clinics
 * List all clinics with pagination, search, and filters
 */
export const listClinics = async (
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
            page = 1,
            limit = 20,
            search,
            specialty,
            isActive,
        } = req.query;

        const result = await clinicService.listClinics({
            page: Number(page),
            limit: Number(limit),
            search: search as string,
            specialty: specialty as MedicalSpecialty,
            isActive: isActive === 'true' ? true : isActive === 'false' ? false : undefined,
        });

        // Format response with user email information
        const clinicsWithDetails = await Promise.all(
            result.clinics.map(async (clinic) => {
                // Get user email from the user associated with this clinic
                const { AppDataSource } = await import('../database/data-source');
                const { User } = await import('../models/User');
                const userRepo = AppDataSource.getRepository(User);
                const user = await userRepo.findOne({
                    where: { id: clinic.managerId },
                    select: ['email'],
                });

                return {
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
                    specialties: clinic.specialties?.map(s => s.specialty) || [],
                    createdAt: clinic.createdAt,
                };
            })
        );

        res.status(200).json({
            success: true,
            data: {
                clinics: clinicsWithDetails,
                pagination: result.pagination,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * GET /api/admin/clinics/:id
 * Get detailed clinic information by ID
 */
export const getClinicById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;

        const clinic = await clinicService.getClinicById(id);

        if (!clinic) {
            throw new AppError('Clinic not found', 404);
        }

        // Get user email
        const { AppDataSource } = await import('../database/data-source');
        const { User } = await import('../models/User');
        const userRepo = AppDataSource.getRepository(User);
        const user = await userRepo.findOne({
            where: { id: clinic.managerId },
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
 * PUT /api/admin/clinics/:id/status
 * Update clinic active status (activate/deactivate)
 */
export const updateClinicStatus = async (
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
        const { isActive } = req.body;

        const clinic = await clinicService.updateClinicStatus(id, isActive);

        logger.info(`Clinic ${id} status updated to ${isActive ? 'active' : 'inactive'} by admin ${req.user!.id}`);

        res.status(200).json({
            success: true,
            message: `Clinic ${isActive ? 'activated' : 'deactivated'} successfully`,
            data: {
                clinic: {
                    id: clinic.id,
                    name: clinic.name,
                    isActive: clinic.isActive,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};
