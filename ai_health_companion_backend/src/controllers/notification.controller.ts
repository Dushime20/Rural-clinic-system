import { Response, NextFunction } from 'express';
import { Notification, NotificationStatus } from '../models/Notification';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { MoreThan } from 'typeorm';

const notificationRepository = AppDataSource.getRepository(Notification);

export const getNotifications = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { status, limit = 50 } = req.query;
        const where: any = { userId: req.user?.id };
        if (status) where.status = status;

        const notifications = await notificationRepository.find({
            where,
            order: { createdAt: 'DESC' },
            take: Number(limit)
        });

        const unreadCount = await notificationRepository.count({
            where: { userId: req.user?.id, status: NotificationStatus.SENT }
        });

        res.status(200).json({ success: true, data: { notifications, unreadCount } });
    } catch (error) {
        next(error);
    }
};

export const markAsRead = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const notification = await notificationRepository.findOne({ where: { id: req.params.id, userId: req.user?.id } });
        if (!notification) throw new AppError('Notification not found', 404);

        notification.status = NotificationStatus.READ;
        notification.readAt = new Date();
        await notificationRepository.save(notification);

        res.status(200).json({ success: true, message: 'Notification marked as read' });
    } catch (error) {
        next(error);
    }
};

export const markAllAsRead = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        await notificationRepository.update(
            { userId: req.user?.id, status: NotificationStatus.SENT },
            { status: NotificationStatus.READ, readAt: new Date() }
        );

        res.status(200).json({ success: true, message: 'All notifications marked as read' });
    } catch (error) {
        next(error);
    }
};

export const deleteNotification = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const result = await notificationRepository.delete({ id: req.params.id, userId: req.user?.id });
        if (result.affected === 0) throw new AppError('Notification not found', 404);

        res.status(200).json({ success: true, message: 'Notification deleted successfully' });
    } catch (error) {
        next(error);
    }
};
