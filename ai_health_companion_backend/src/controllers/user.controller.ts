/**
 * User Controller
 * Handles user management operations (admin only)
 */

import { Response, NextFunction } from 'express';
import { User, UserRole } from '../models/User';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { emailService } from '../services/email.service';
import crypto from 'crypto';

const userRepository = AppDataSource.getRepository(User);

/**
 * Generate random password
 */
function generateRandomPassword(): string {
    const length = 12;
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
    let password = '';
    
    // Ensure at least one of each type
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 26)]; // Uppercase
    password += 'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)]; // Lowercase
    password += '0123456789'[Math.floor(Math.random() * 10)]; // Number
    password += '!@#$%^&*'[Math.floor(Math.random() * 8)]; // Special char
    
    // Fill the rest
    for (let i = password.length; i < length; i++) {
        password += charset[Math.floor(Math.random() * charset.length)];
    }
    
    // Shuffle
    return password.split('').sort(() => Math.random() - 0.5).join('');
}

/**
 * Create new user (Admin only)
 */
export const createUser = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { email, firstName, lastName, role, clinicId, phoneNumber, sendEmail } = req.body;

        // Validate required fields
        if (!email || !firstName || !lastName || !role) {
            throw new AppError('Email, firstName, lastName, and role are required', 400);
        }

        // Check if user already exists
        const existingUser = await userRepository.findOne({ where: { email } });
        if (existingUser) {
            throw new AppError('User with this email already exists', 400);
        }

        // Generate random password
        const temporaryPassword = generateRandomPassword();

        // Create new user
        const user = userRepository.create({
            email,
            password: temporaryPassword, // Will be hashed by User entity
            firstName,
            lastName,
            role: role as UserRole,
            clinicId,
            phoneNumber,
            isActive: true,
            isEmailVerified: false
        });

        await userRepository.save(user);

        logger.info(`New user created by admin: ${user.email}`);

        // Send welcome email with credentials
        if (sendEmail !== false) { // Default to true
            try {
                const emailSent = await emailService.sendWelcomeEmail({
                    email: user.email,
                    password: temporaryPassword,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role
                });

                if (emailSent) {
                    logger.info(`Welcome email sent to: ${user.email}`);
                } else {
                    logger.warn(`Failed to send welcome email to: ${user.email}`);
                }
            } catch (emailError) {
                logger.error(`Error sending welcome email to ${user.email}:`, emailError);
                // Don't fail the request if email fails
            }
        }

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    phoneNumber: user.phoneNumber,
                    isActive: user.isActive
                },
                temporaryPassword: temporaryPassword, // Return password for admin to see
                emailSent: sendEmail !== false
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all users (Admin only)
 */
export const getAllUsers = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { role, clinicId, isActive, page = 1, limit = 20 } = req.query;

        const queryBuilder = userRepository.createQueryBuilder('user');

        // Apply filters
        if (role) {
            queryBuilder.andWhere('user.role = :role', { role });
        }
        if (clinicId) {
            queryBuilder.andWhere('user.clinicId = :clinicId', { clinicId });
        }
        if (isActive !== undefined) {
            queryBuilder.andWhere('user.isActive = :isActive', { isActive: isActive === 'true' });
        }

        // Pagination
        const skip = (Number(page) - 1) * Number(limit);
        queryBuilder.skip(skip).take(Number(limit));

        // Order by creation date
        queryBuilder.orderBy('user.createdAt', 'DESC');

        const [users, total] = await queryBuilder.getManyAndCount();

        res.status(200).json({
            success: true,
            data: {
                users: users.map(user => ({
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    phoneNumber: user.phoneNumber,
                    isActive: user.isActive,
                    isEmailVerified: user.isEmailVerified,
                    lastLogin: user.lastLogin,
                    createdAt: user.createdAt
                })),
                pagination: {
                    page: Number(page),
                    limit: Number(limit),
                    total,
                    totalPages: Math.ceil(total / Number(limit))
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user by ID (Admin only)
 */
export const getUserById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;

        const user = await userRepository.findOne({ where: { id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        res.status(200).json({
            success: true,
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    phoneNumber: user.phoneNumber,
                    isActive: user.isActive,
                    isEmailVerified: user.isEmailVerified,
                    lastLogin: user.lastLogin,
                    createdAt: user.createdAt,
                    updatedAt: user.updatedAt
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update user (Admin only)
 */
export const updateUser = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;
        const { firstName, lastName, role, clinicId, phoneNumber, isActive } = req.body;

        const user = await userRepository.findOne({ where: { id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Update fields
        if (firstName) user.firstName = firstName;
        if (lastName) user.lastName = lastName;
        if (role) user.role = role as UserRole;
        if (clinicId !== undefined) user.clinicId = clinicId;
        if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
        if (isActive !== undefined) user.isActive = isActive;

        await userRepository.save(user);

        logger.info(`User updated by admin: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'User updated successfully',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    phoneNumber: user.phoneNumber,
                    isActive: user.isActive
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete user (Admin only)
 */
export const deleteUser = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;

        const user = await userRepository.findOne({ where: { id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Prevent deleting yourself
        if (req.user?.id === id) {
            throw new AppError('You cannot delete your own account', 400);
        }

        await userRepository.remove(user);

        logger.info(`User deleted by admin: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'User deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Reset user password (Admin only)
 */
export const resetUserPassword = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;
        const { sendEmail } = req.body;

        const user = await userRepository.findOne({ where: { id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Generate new random password
        const newPassword = generateRandomPassword();

        // Update password
        user.password = newPassword; // Will be hashed by User entity
        await userRepository.save(user);

        logger.info(`Password reset by admin for user: ${user.email}`);

        // Send email with new password
        if (sendEmail !== false) {
            try {
                const emailSent = await emailService.sendWelcomeEmail({
                    email: user.email,
                    password: newPassword,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role
                });

                if (emailSent) {
                    logger.info(`Password reset email sent to: ${user.email}`);
                }
            } catch (emailError) {
                logger.error(`Error sending password reset email to ${user.email}:`, emailError);
            }
        }

        res.status(200).json({
            success: true,
            message: 'Password reset successfully',
            data: {
                newPassword: newPassword, // Return password for admin
                emailSent: sendEmail !== false
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get current user profile
 */
export const getCurrentUser = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        if (!req.user) {
            throw new AppError('User not authenticated', 401);
        }

        const user = await userRepository.findOne({ where: { id: req.user.id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        res.status(200).json({
            success: true,
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    phoneNumber: user.phoneNumber,
                    isActive: user.isActive,
                    isEmailVerified: user.isEmailVerified,
                    lastLogin: user.lastLogin,
                    createdAt: user.createdAt
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update current user profile
 */
export const updateCurrentUser = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        if (!req.user) {
            throw new AppError('User not authenticated', 401);
        }

        const { firstName, lastName, phoneNumber } = req.body;

        const user = await userRepository.findOne({ where: { id: req.user.id } });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Update allowed fields
        if (firstName) user.firstName = firstName;
        if (lastName) user.lastName = lastName;
        if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;

        await userRepository.save(user);

        logger.info(`User profile updated: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    phoneNumber: user.phoneNumber
                }
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Change password
 */
export const changePassword = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        if (!req.user) {
            throw new AppError('User not authenticated', 401);
        }

        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            throw new AppError('Current password and new password are required', 400);
        }

        const user = await userRepository.findOne({
            where: { id: req.user.id },
            select: ['id', 'email', 'password', 'firstName', 'lastName', 'role', 'createdAt', 'updatedAt']
        });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Verify current password
        const isPasswordValid = await user.comparePassword(currentPassword);

        if (!isPasswordValid) {
            throw new AppError('Current password is incorrect', 401);
        }

        // Update password
        user.password = newPassword; // Will be hashed by User entity
        await userRepository.save(user);

        logger.info(`Password changed for user: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Password changed successfully'
        });
    } catch (error) {
        next(error);
    }
};
