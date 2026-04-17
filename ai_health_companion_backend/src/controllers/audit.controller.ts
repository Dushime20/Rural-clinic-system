import { Response, NextFunction } from 'express';
import { AuditLog } from '../models/AuditLog';
import { AppDataSource } from '../database/data-source';
import { AuthRequest } from '../middleware/auth';
import { Between } from 'typeorm';
import { UserRole } from '../models/User';

const auditLogRepository = AppDataSource.getRepository(AuditLog);

export const getAuditLogs = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        // Only admins can view audit logs
        if (req.user?.role !== UserRole.ADMIN) {
            res.status(403).json({ success: false, message: 'Access denied' });
            return;
        }

        const { userId, action, resource, startDate, endDate, page = 1, limit = 100 } = req.query;
        const skip = (Number(page) - 1) * Number(limit);

        const where: any = {};
        if (userId) where.userId = userId;
        if (action) where.action = action;
        if (resource) where.resource = resource;
        if (startDate && endDate) {
            where.timestamp = Between(new Date(startDate as string), new Date(endDate as string));
        }

        const [logs, total] = await auditLogRepository.findAndCount({
            where,
            order: { timestamp: 'DESC' },
            skip,
            take: Number(limit)
        });

        res.status(200).json({
            success: true,
            data: { logs, pagination: { page: Number(page), limit: Number(limit), total, pages: Math.ceil(total / Number(limit)) } }
        });
    } catch (error) {
        next(error);
    }
};

export const getUserActivity = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { userId } = req.params;
        const { startDate, endDate } = req.query;

        const where: any = { userId };
        if (startDate && endDate) {
            where.timestamp = Between(new Date(startDate as string), new Date(endDate as string));
        }

        const logs = await auditLogRepository.find({
            where,
            order: { timestamp: 'DESC' },
            take: 100
        });

        res.status(200).json({ success: true, data: { logs, count: logs.length } });
    } catch (error) {
        next(error);
    }
};

export const getResourceHistory = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { resource, resourceId } = req.params;

        const logs = await auditLogRepository.find({
            where: { resource: resource as any, resourceId },
            order: { timestamp: 'DESC' }
        });

        res.status(200).json({ success: true, data: { logs, count: logs.length } });
    } catch (error) {
        next(error);
    }
};
