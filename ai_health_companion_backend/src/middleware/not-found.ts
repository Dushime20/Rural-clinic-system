import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export const notFoundHandler = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    logger.warn(`404 - Route not found: ${req.method} ${req.originalUrl}`);

    res.status(404).json({
        success: false,
        message: `Cannot ${req.method} ${req.originalUrl}`,
        error: 'Route not found'
    });
};
