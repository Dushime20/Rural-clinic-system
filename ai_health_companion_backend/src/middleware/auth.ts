import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { AppError } from './error-handler';
import { User, UserRole } from '../models/User';
import { AppDataSource } from '../database/data-source';

export interface AuthRequest extends Request {
    body: any;
    user?: {
        id: string;
        email: string;
        role: UserRole;
        clinicId?: string;
    };
}

export const authenticate = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        // Get token from header
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new AppError('No token provided', 401);
        }

        const token = authHeader.split(' ')[1];

        // Verify token
        const decoded = jwt.verify(token, config.jwtSecret) as {
            id: string;
            email: string;
            role: UserRole;
            clinicId?: string;
        };

        // Check if user still exists
        const userRepository = AppDataSource.getRepository(User);
        const user = await userRepository.findOneBy({ id: decoded.id });

        if (!user || !user.isActive) {
            throw new AppError('User no longer exists or is inactive', 401);
        }

        // Attach user to request
        req.user = {
            id: decoded.id,
            email: decoded.email,
            role: decoded.role,
            clinicId: decoded.clinicId
        };

        next();
    } catch (error) {
        if (error instanceof jwt.JsonWebTokenError) {
            next(new AppError('Invalid token', 401));
        } else if (error instanceof jwt.TokenExpiredError) {
            next(new AppError('Token expired', 401));
        } else {
            next(error);
        }
    }
};

export const authorize = (...roles: UserRole[]) => {
    return (req: AuthRequest, res: Response, next: NextFunction): void => {
        if (!req.user) {
            return next(new AppError('User not authenticated', 401));
        }

        if (!roles.includes(req.user.role)) {
            return next(
                new AppError('You do not have permission to perform this action', 403)
            );
        }

        next();
    };
};
