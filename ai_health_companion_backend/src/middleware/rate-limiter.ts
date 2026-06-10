import rateLimit from 'express-rate-limit';
import { Request, Response } from 'express';
import { config } from '../config';

/**
 * Rate Limiting Middleware Configuration
 * 
 * Implements rate limiting for different API endpoints to prevent abuse
 * and ensure system stability.
 */

// Extend Express Request to include rateLimit property
declare global {
    namespace Express {
        interface Request {
            rateLimit?: {
                limit: number;
                current: number;
                remaining: number;
                resetTime: Date;
            };
        }
    }
}

// General API rate limiter
export const apiLimiter = rateLimit({
    windowMs: config.rateLimitWindowMs,
    max: config.rateLimitMaxRequests,
    message: {
        success: false,
        message: 'Too many requests from this IP, please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false
});

// Strict rate limiter for authentication endpoints
// 5 failed login attempts per 15 minutes per IP
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 requests per window
    message: {
        success: false,
        message: 'Too many authentication attempts, please try again later'
    },
    skipSuccessfulRequests: true,
    standardHeaders: true,
    legacyHeaders: false
});

// AI diagnosis rate limiter
// 20 diagnoses per hour per user (changed from 10 per minute for better UX)
export const diagnosisLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 20, // 20 diagnoses per hour
    message: {
        success: false,
        message: 'You have reached the maximum number of diagnoses for this hour. Please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req: Request) => {
        return (req as any).user?.id || req.ip;
    },
    handler: (req: Request, res: Response) => {
        res.status(429).json({
            success: false,
            error: 'Rate limit exceeded',
            message: 'You have reached the maximum number of diagnoses for this hour. Please try again later.',
            retryAfter: req.rateLimit?.resetTime
        });
    }
});

/**
 * Clinic search rate limiter
 * 100 requests per minute per IP
 * Used for: POST /api/clinics/search
 */
export const clinicSearchLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 100, // Limit each IP to 100 requests per minute
    message: {
        success: false,
        error: 'Too many clinic search requests, please slow down.',
        retryAfter: '1 minute'
    },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: false,
    handler: (req: Request, res: Response) => {
        res.status(429).json({
            success: false,
            error: 'Rate limit exceeded',
            message: 'Too many clinic search requests. Please wait before trying again.',
            retryAfter: req.rateLimit?.resetTime
        });
    }
});

/**
 * Admin clinic creation rate limiter
 * 10 requests per minute per admin user
 * Used for: POST /api/admin/clinics
 */
export const clinicCreationLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 10, // Limit to 10 clinic creations per minute
    message: {
        success: false,
        error: 'Too many clinic creation requests.',
        retryAfter: '1 minute'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req: Request) => {
        return (req as any).user?.id || req.ip;
    },
    handler: (req: Request, res: Response) => {
        res.status(429).json({
            success: false,
            error: 'Rate limit exceeded',
            message: 'You are creating clinics too quickly. Please wait before creating more.',
            retryAfter: req.rateLimit?.resetTime
        });
    }
});

/**
 * Password change rate limiter
 * 3 attempts per 15 minutes per user
 * Used for: POST /api/auth/change-password
 */
export const passwordChangeLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 3, // Allow 3 password change attempts
    message: {
        success: false,
        error: 'Too many password change attempts.',
        retryAfter: '15 minutes'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req: Request) => {
        return (req as any).user?.id || req.ip;
    },
    handler: (req: Request, res: Response) => {
        res.status(429).json({
            success: false,
            error: 'Rate limit exceeded',
            message: 'Too many password change attempts. Please try again later.',
            retryAfter: req.rateLimit?.resetTime
        });
    }
});

/**
 * Admin operations rate limiter
 * 200 requests per 15 minutes per admin user
 * Used for general admin operations
 */
export const adminLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200, // Limit to 200 admin operations
    message: {
        success: false,
        error: 'Too many admin requests.',
        retryAfter: '15 minutes'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req: Request) => {
        return (req as any).user?.id || req.ip;
    },
    handler: (req: Request, res: Response) => {
        res.status(429).json({
            success: false,
            error: 'Rate limit exceeded',
            message: 'Too many admin operations. Please slow down.',
            retryAfter: req.rateLimit?.resetTime
        });
    }
});
