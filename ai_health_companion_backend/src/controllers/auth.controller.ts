import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User, UserRole } from '../models/User';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { config } from '../config';
import { logger } from '../utils/logger';

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

        // Find user and include password
        const user = await userRepository.findOne({
            where: { email },
            select: ['id', 'email', 'password', 'firstName', 'lastName', 'role', 'clinicId', 'isActive', 'createdAt', 'updatedAt']
        });

        if (!user) {
            throw new AppError('Invalid email or password', 401);
        }

        // Check if user is active
        if (!user.isActive) {
            throw new AppError('Your account has been deactivated', 401);
        }

        // Verify password
        const isPasswordValid = await user.comparePassword(password);

        if (!isPasswordValid) {
            throw new AppError('Invalid email or password', 401);
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
