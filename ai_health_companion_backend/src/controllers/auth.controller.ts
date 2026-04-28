import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { User, UserRole } from '../models/User';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { config } from '../config';
import { logger } from '../utils/logger';
import { emailService } from '../services/email.service';

const userRepository = AppDataSource.getRepository(User);

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               role:
 *                 type: string
 *               clinicId:
 *                 type: string
 *     responses:
 *       201:
 *         description: User registered successfully
 *       400:
 *         description: Invalid input
 */
export const register = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { email, password, firstName, lastName, role, clinicId, phoneNumber } = req.body;

        // Check if user already exists
        const existingUser = await userRepository.findOne({ where: { email } });
        if (existingUser) {
            throw new AppError('User with this email already exists', 400);
        }

        // Create new user
        const user = userRepository.create({
            email,
            password,
            firstName,
            lastName,
            role: role || UserRole.HEALTH_WORKER,
            clinicId,
            phoneNumber
        });

        await userRepository.save(user);

        // Generate tokens
        const accessToken = generateAccessToken(user);
        const refreshToken = generateRefreshToken(user);

        // Save refresh token
        user.refreshToken = refreshToken;
        await userRepository.save(user);

        logger.info(`New user registered: ${user.email}`);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId
                },
                accessToken,
                refreshToken
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
export const login = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { email, password } = req.body;

        logger.info(`[LOGIN] Attempt for email: ${email}`);
        logger.info(`[LOGIN] Password received (length: ${password?.length}, first3: ${password?.substring(0, 3)}***)`);

        // Find user and include password
        const user = await userRepository.findOne({
            where: { email },
            select: ['id', 'email', 'password', 'firstName', 'lastName', 'role', 'clinicId', 'isActive', 'mustChangePassword', 'createdAt', 'updatedAt']
        });

        if (!user) {
            logger.warn(`[LOGIN] No user found with email: ${email}`);
            throw new AppError('No account found with this email address. Please check your email and try again.', 401);
        }

        logger.info(`[LOGIN] User found: ${user.email}, isActive: ${user.isActive}`);
        logger.info(`[LOGIN] Stored hashed password (first20): ${user.password?.substring(0, 20)}...`);
        logger.info(`[LOGIN] Password field present: ${!!user.password}, length: ${user.password?.length}`);

        // Check if user is active
        if (!user.isActive) {
            logger.warn(`[LOGIN] Account deactivated for: ${email}`);
            throw new AppError('Your account has been deactivated. Please contact your administrator.', 401);
        }

        // Verify password
        logger.info(`[LOGIN] Running bcrypt.compare...`);
        const isPasswordValid = await user.comparePassword(password);
        logger.info(`[LOGIN] Password valid: ${isPasswordValid}`);

        if (!isPasswordValid) {
            logger.warn(`[LOGIN] Password mismatch for: ${email}`);
            throw new AppError('Incorrect password. Please check your password and try again. If you forgot it, use "Forgot Password".', 401);
        }

        // Generate tokens
        const accessToken = generateAccessToken(user);
        const refreshToken = generateRefreshToken(user);

        // Update user
        user.refreshToken = refreshToken;
        user.lastLogin = new Date();
        await userRepository.save(user);

        logger.info(`User logged in: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: user.role,
                    clinicId: user.clinicId,
                    mustChangePassword: user.mustChangePassword
                },
                accessToken,
                refreshToken
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Refresh access token
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *     responses:
 *       200:
 *         description: Token refreshed successfully
 *       401:
 *         description: Invalid refresh token
 */
export const refreshToken = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { refreshToken: token } = req.body;

        if (!token) {
            throw new AppError('Refresh token is required', 400);
        }

        // Verify refresh token
        const decoded = jwt.verify(token, config.jwtRefreshSecret) as {
            id: string;
        };

        // Find user
        const user = await userRepository.findOne({
            where: { id: decoded.id },
            select: ['id', 'email', 'firstName', 'lastName', 'role', 'clinicId', 'refreshToken', 'createdAt', 'updatedAt']
        });

        if (!user || user.refreshToken !== token) {
            throw new AppError('Invalid refresh token', 401);
        }

        // Generate new tokens
        const newAccessToken = generateAccessToken(user);
        const newRefreshToken = generateRefreshToken(user);

        // Update refresh token
        user.refreshToken = newRefreshToken;
        await userRepository.save(user);

        res.status(200).json({
            success: true,
            message: 'Token refreshed successfully',
            data: {
                accessToken: newAccessToken,
                refreshToken: newRefreshToken
            }
        });
    } catch (error) {
        if (error instanceof jwt.JsonWebTokenError) {
            next(new AppError('Invalid refresh token', 401));
        } else {
            next(error);
        }
    }
};

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logout successful
 */
export const logout = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        if (!req.user) {
            throw new AppError('User not authenticated', 401);
        }

        // Clear refresh token
        await userRepository.update({ id: req.user.id }, { refreshToken: undefined });

        logger.info(`User logged out: ${req.user.email}`);

        res.status(200).json({
            success: true,
            message: 'Logout successful'
        });
    } catch (error) {
        next(error);
    }
};

// Helper functions
const generateAccessToken = (user: User): string => {
    return jwt.sign(
        {
            id: user.id,
            email: user.email,
            role: user.role,
            clinicId: user.clinicId
        },
        config.jwtSecret,
        { expiresIn: config.jwtExpiresIn }
    );
};

const generateRefreshToken = (user: User): string => {
    return jwt.sign(
        { id: user.id },
        config.jwtRefreshSecret,
        { expiresIn: config.jwtRefreshExpiresIn }
    );
};


/**
 * @swagger
 * /auth/forgot-password:
 *   post:
 *     summary: Request password reset
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password reset email sent
 *       404:
 *         description: User not found
 */
export const forgotPassword = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { email } = req.body;

        if (!email) {
            throw new AppError('Email is required', 400);
        }

        // Find user
        const user = await userRepository.findOne({ where: { email } });

        // Always return success to prevent email enumeration
        if (!user) {
            logger.warn(`Password reset requested for non-existent email: ${email}`);
            res.status(200).json({
                success: true,
                message: 'If an account with that email exists, a password reset link has been sent'
            });
            return;
        }

        // Generate reset token
        const resetToken = crypto.randomBytes(32).toString('hex');
        const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

        // Set token and expiry (1 hour)
        user.passwordResetToken = hashedToken;
        user.passwordResetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
        await userRepository.save(user);

        // Send email
        try {
            await emailService.sendPasswordResetEmail(user.email, resetToken, user.firstName);
            logger.info(`Password reset email sent to: ${user.email}`);
        } catch (emailError) {
            logger.error('Failed to send password reset email:', emailError);
            // Clear reset token if email fails
            user.passwordResetToken = undefined;
            user.passwordResetExpires = undefined;
            await userRepository.save(user);
            throw new AppError('Failed to send password reset email. Please try again later.', 500);
        }

        res.status(200).json({
            success: true,
            message: 'If an account with that email exists, a password reset link has been sent'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /auth/reset-password:
 *   post:
 *     summary: Reset password with token
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - newPassword
 *             properties:
 *               token:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password reset successful
 *       400:
 *         description: Invalid or expired token
 */
export const resetPassword = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { token, newPassword } = req.body;

        if (!token || !newPassword) {
            throw new AppError('Token and new password are required', 400);
        }

        if (newPassword.length < 8) {
            throw new AppError('Password must be at least 8 characters long', 400);
        }

        // Hash the token to compare with stored hash
        const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

        // Find user with valid reset token
        const user = await userRepository.findOne({
            where: { passwordResetToken: hashedToken },
            select: ['id', 'email', 'firstName', 'lastName', 'role', 'clinicId', 'passwordResetToken', 'passwordResetExpires', 'createdAt', 'updatedAt']
        });

        if (!user || !user.passwordResetExpires || user.passwordResetExpires < new Date()) {
            throw new AppError('Invalid or expired reset token', 400);
        }

        // Update password
        user.password = newPassword;
        user.passwordResetToken = undefined;
        user.passwordResetExpires = undefined;
        user.mustChangePassword = false; // User has set their own password
        user.refreshToken = undefined; // Invalidate all sessions
        await userRepository.save(user);

        logger.info(`Password reset successful for: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Password reset successful. Please login with your new password.'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * @swagger
 * /auth/change-password:
 *   post:
 *     summary: Change password (for first-time users or authenticated users)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - currentPassword
 *               - newPassword
 *             properties:
 *               currentPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password changed successfully
 *       400:
 *         description: Invalid current password
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

        if (newPassword.length < 8) {
            throw new AppError('New password must be at least 8 characters long', 400);
        }

        if (currentPassword === newPassword) {
            throw new AppError('New password must be different from current password', 400);
        }

        // Find user with password
        const user = await userRepository.findOne({
            where: { id: req.user.id },
            select: ['id', 'email', 'password', 'firstName', 'lastName', 'role', 'clinicId', 'mustChangePassword', 'createdAt', 'updatedAt']
        });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Verify current password
        const isPasswordValid = await user.comparePassword(currentPassword);

        if (!isPasswordValid) {
            throw new AppError('Current password is incorrect', 400);
        }

        // Update password
        user.password = newPassword;
        user.mustChangePassword = false; // User has changed their password
        await userRepository.save(user);

        logger.info(`Password changed for: ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Password changed successfully'
        });
    } catch (error) {
        next(error);
    }
};
