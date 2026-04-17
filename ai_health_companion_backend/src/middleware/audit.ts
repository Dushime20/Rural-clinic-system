import { Request, Response, NextFunction } from 'express';
import { AuditLog, AuditAction, AuditResource } from '../models/AuditLog';
import { AppDataSource } from '../database/data-source';
import { AuthRequest } from './auth';
import { logger } from '../utils/logger';

const auditLogRepository = AppDataSource.getRepository(AuditLog);

/**
 * Audit logging middleware
 * Automatically logs all user actions for compliance and security
 */

export interface AuditOptions {
    action: AuditAction;
    resource: AuditResource;
    resourceId?: string;
    description?: string;
}

/**
 * Create audit log entry
 */
export async function createAuditLog(
    req: AuthRequest,
    options: AuditOptions,
    oldValue?: any,
    newValue?: any,
    success: boolean = true,
    errorMessage?: string
): Promise<void> {
    try {
        const auditLog = auditLogRepository.create({
            userId: req.user?.id,
            userEmail: req.user?.email,
            action: options.action,
            resource: options.resource,
            resourceId: options.resourceId,
            oldValue,
            newValue,
            ipAddress: getClientIp(req),
            userAgent: req.get('user-agent'),
            clinicId: req.user?.clinicId,
            description: options.description,
            success,
            errorMessage
        });

        await auditLogRepository.save(auditLog);
    } catch (error) {
        logger.error('Failed to create audit log:', error);
        // Don't throw error - audit logging should not break the main flow
    }
}

/**
 * Middleware to audit specific actions
 */
export function auditMiddleware(options: AuditOptions) {
    return async (req: AuthRequest, res: Response, next: NextFunction) => {
        // Store original json method
        const originalJson = res.json.bind(res);

        // Override json method to capture response
        res.json = function (body: any) {
            // Create audit log after response
            setImmediate(async () => {
                try {
                    const success = res.statusCode >= 200 && res.statusCode < 300;
                    const resourceId = options.resourceId || req.params.id || body?.data?.id;

                    await createAuditLog(
                        req,
                        {
                            ...options,
                            resourceId
                        },
                        undefined, // oldValue - can be captured in controller
                        body?.data, // newValue
                        success,
                        success ? undefined : body?.message
                    );
                } catch (error) {
                    logger.error('Audit middleware error:', error);
                }
            });

            return originalJson(body);
        };

        next();
    };
}

/**
 * Audit login attempts
 */
export async function auditLogin(
    req: Request,
    email: string,
    success: boolean,
    errorMessage?: string
): Promise<void> {
    try {
        const auditLog = auditLogRepository.create({
            userEmail: email,
            action: AuditAction.LOGIN,
            resource: AuditResource.USER,
            ipAddress: getClientIp(req),
            userAgent: req.get('user-agent'),
            description: success ? 'User logged in successfully' : 'Failed login attempt',
            success,
            errorMessage
        });

        await auditLogRepository.save(auditLog);
    } catch (error) {
        logger.error('Failed to audit login:', error);
    }
}

/**
 * Audit logout
 */
export async function auditLogout(req: AuthRequest): Promise<void> {
    try {
        const auditLog = auditLogRepository.create({
            userId: req.user?.id,
            userEmail: req.user?.email,
            action: AuditAction.LOGOUT,
            resource: AuditResource.USER,
            ipAddress: getClientIp(req),
            userAgent: req.get('user-agent'),
            clinicId: req.user?.clinicId,
            description: 'User logged out',
            success: true
        });

        await auditLogRepository.save(auditLog);
    } catch (error) {
        logger.error('Failed to audit logout:', error);
    }
}

/**
 * Get client IP address
 */
function getClientIp(req: Request): string {
    const forwarded = req.headers['x-forwarded-for'];
    if (typeof forwarded === 'string') {
        return forwarded.split(',')[0].trim();
    }
    return req.socket.remoteAddress || 'unknown';
}

/**
 * Audit data export
 */
export async function auditExport(
    req: AuthRequest,
    resource: AuditResource,
    description: string
): Promise<void> {
    try {
        const auditLog = auditLogRepository.create({
            userId: req.user?.id,
            userEmail: req.user?.email,
            action: AuditAction.EXPORT,
            resource,
            ipAddress: getClientIp(req),
            userAgent: req.get('user-agent'),
            clinicId: req.user?.clinicId,
            description,
            success: true
        });

        await auditLogRepository.save(auditLog);
    } catch (error) {
        logger.error('Failed to audit export:', error);
    }
}

/**
 * Audit data access (read operations)
 */
export async function auditRead(
    req: AuthRequest,
    resource: AuditResource,
    resourceId: string,
    description?: string
): Promise<void> {
    try {
        const auditLog = auditLogRepository.create({
            userId: req.user?.id,
            userEmail: req.user?.email,
            action: AuditAction.READ,
            resource,
            resourceId,
            ipAddress: getClientIp(req),
            userAgent: req.get('user-agent'),
            clinicId: req.user?.clinicId,
            description: description || `Accessed ${resource} ${resourceId}`,
            success: true
        });

        await auditLogRepository.save(auditLog);
    } catch (error) {
        logger.error('Failed to audit read:', error);
    }
}
