import rateLimit from 'express-rate-limit';
import { config } from '../config';

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
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 requests per window
    message: {
        success: false,
        message: 'Too many authentication attempts, please try again later'
    },
    skipSuccessfulRequests: true
});

// AI diagnosis rate limiter
export const diagnosisLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 10, // 10 diagnoses per minute
    message: {
        success: false,
        message: 'Too many diagnosis requests, please slow down'
    }
});
