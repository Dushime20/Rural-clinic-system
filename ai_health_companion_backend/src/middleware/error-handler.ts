import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export class AppError extends Error {
    statusCode: number;
    isOperational: boolean;
    details?: any;

    constructor(message: string, statusCode: number, details?: any) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;
        this.details = details;

        Error.captureStackTrace(this, this.constructor);
    }
}

export const errorHandler = (
    err: Error | AppError,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    let statusCode = 500;
    let message = 'Internal Server Error';
    let isOperational = false;
    let details: any = undefined;

    if (err instanceof AppError) {
        statusCode = err.statusCode;
        message = err.message;
        isOperational = err.isOperational;
        details = err.details;
    }

    // Log error
    if (!isOperational || statusCode === 500) {
        logger.error('Error:', {
            message: err.message,
            stack: err.stack,
            url: req.url,
            method: req.method,
            ip: req.ip,
            userId: (req as any).user?.id
        });
    }

    // Send error response
    res.status(statusCode).json({
        success: false,
        message,
        ...(details && { details }),
        ...(process.env.NODE_ENV === 'development' && {
            error: err.message,
            stack: err.stack
        })
    });
};

export const notFoundHandler = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    const error = new AppError(`Route ${req.originalUrl} not found`, 404);
    next(error);
};
