import { Response, NextFunction } from 'express';
import { Appointment, AppointmentStatus } from '../models/Appointment';
import { Patient } from '../models/Patient';
import { User } from '../models/User';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { createAuditLog } from '../middleware/audit';
import { AuditAction, AuditResource } from '../models/AuditLog';

const appointmentRepository = AppDataSource.getRepository(Appointment);
const patientRepository = AppDataSource.getRepository(Patient);
const userRepository = AppDataSource.getRepository(User);

/**
 * Create new appointment
 */
export const createAppointment = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId, providerId, appointmentDate, durationMinutes, appointmentType, reason, notes } = req.body;

        // Verify patient exists
        const patient = await patientRepository.findOne({ where: { id: patientId } });
        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        // Verify provider exists
        const provider = await userRepository.findOne({ where: { id: providerId } });
        if (!provider) {
            throw new AppError('Provider not found', 404);
        }

        // Check for scheduling conflicts
        const appointmentStart = new Date(appointmentDate);
        const appointmentEnd = new Date(appointmentStart);
        appointmentEnd.setMinutes(appointmentEnd.getMinutes() + durationMinutes);

        const conflicts = await appointmentRepository.count({
            where: {
                providerId,
                appointmentDate: Between(appointmentStart, appointmentEnd),
                status: AppointmentStatus.SCHEDULED
            }
        });

        if (conflicts > 0) {
            throw new AppError('Provider has conflicting appointment at this time', 409);
        }

        // Create appointment
        const appointment = appointmentRepository.create({
            appointmentId: `APT-${uuidv4().slice(0, 8).toUpperCase()}`,
            patientId,
            providerId,
            clinicId: req.user?.clinicId || '',
            appointmentDate: appointmentStart,
            durationMinutes,
            appointmentType,
            reason,
            notes,
            status: AppointmentStatus.SCHEDULED,
            reminderSettings: {
                sms: true,
                email: true,
                reminderSent: false
            }
        });

        await appointmentRepository.save(appointment);

        await createAuditLog(req, {
            action: AuditAction.CREATE,
            resource: AuditResource.APPOINTMENT,
            resourceId: appointment.id,
            description: `Created appointment for patient ${patient.getFullName()}`
        }, undefined, appointment);

        logger.info(`Appointment created: ${appointment.appointmentId}`);

        res.status(201).json({
            success: true,
            message: 'Appointment created successfully',
            data: { appointment }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get appointment by ID
 */
export const getAppointmentById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const appointment = await appointmentRepository.findOne({
            where: { id: req.params.id },
            relations: ['patient', 'provider']
        });

        if (!appointment) {
            throw new AppError('Appointment not found', 404);
        }

        res.status(200).json({
            success: true,
            data: { appointment }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get appointments by date range
 */
export const getAppointmentsByDateRange = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { startDate, endDate, providerId, status } = req.query;

        const where: any = {
            clinicId: req.user?.clinicId
        };

        if (startDate && endDate) {
            where.appointmentDate = Between(new Date(startDate as string), new Date(endDate as string));
        }

        if (providerId) {
            where.providerId = providerId;
        }

        if (status) {
            where.status = status;
        }

        const appointments = await appointmentRepository.find({
            where,
            relations: ['patient', 'provider'],
            order: { appointmentDate: 'ASC' }
        });

        res.status(200).json({
            success: true,
            data: { appointments, count: appointments.length }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get available time slots
 */
export const getAvailableSlots = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { providerId, date } = req.query;

        if (!providerId || !date) {
            throw new AppError('Provider ID and date are required', 400);
        }

        const targetDate = new Date(date as string);
        const startOfDay = new Date(targetDate);
        startOfDay.setHours(8, 0, 0, 0);
        const endOfDay = new Date(targetDate);
        endOfDay.setHours(17, 0, 0, 0);

        // Get all appointments for the provider on that day
        const appointments = await appointmentRepository.find({
            where: {
                providerId: providerId as string,
                appointmentDate: Between(startOfDay, endOfDay),
                status: AppointmentStatus.SCHEDULED
            },
            order: { appointmentDate: 'ASC' }
        });

        // Generate available slots (30-minute intervals)
        const slots: Array<{ start: Date; end: Date; available: boolean }> = [];
        const currentTime = new Date(startOfDay);

        while (currentTime < endOfDay) {
            const slotEnd = new Date(currentTime);
            slotEnd.setMinutes(slotEnd.getMinutes() + 30);

            const isBooked = appointments.some(apt => {
                const aptEnd = new Date(apt.appointmentDate);
                aptEnd.setMinutes(aptEnd.getMinutes() + apt.durationMinutes);
                return currentTime < aptEnd && slotEnd > apt.appointmentDate;
            });

            slots.push({
                start: new Date(currentTime),
                end: new Date(slotEnd),
                available: !isBooked
            });

            currentTime.setMinutes(currentTime.getMinutes() + 30);
        }

        res.status(200).json({
            success: true,
            data: { slots }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update appointment status
 */
export const updateAppointmentStatus = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { status, notes } = req.body;
        const appointment = await appointmentRepository.findOne({ where: { id: req.params.id } });

        if (!appointment) {
            throw new AppError('Appointment not found', 404);
        }

        const oldStatus = appointment.status;
        appointment.status = status;

        if (status === AppointmentStatus.CHECKED_IN) {
            appointment.checkedInAt = new Date();
        } else if (status === AppointmentStatus.COMPLETED) {
            appointment.completedAt = new Date();
        } else if (status === AppointmentStatus.CANCELLED) {
            appointment.cancelledAt = new Date();
            appointment.cancelledBy = req.user?.id;
            appointment.cancellationReason = notes;
        }

        if (notes) {
            appointment.notes = notes;
        }

        await appointmentRepository.save(appointment);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.APPOINTMENT,
            resourceId: appointment.id,
            description: `Updated appointment status from ${oldStatus} to ${status}`
        }, { status: oldStatus }, { status });

        logger.info(`Appointment ${appointment.appointmentId} status updated to ${status}`);

        res.status(200).json({
            success: true,
            message: 'Appointment status updated successfully',
            data: { appointment }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Cancel appointment
 */
export const cancelAppointment = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { reason } = req.body;
        const appointment = await appointmentRepository.findOne({ where: { id: req.params.id } });

        if (!appointment) {
            throw new AppError('Appointment not found', 404);
        }

        if (appointment.status === AppointmentStatus.COMPLETED) {
            throw new AppError('Cannot cancel completed appointment', 400);
        }

        appointment.status = AppointmentStatus.CANCELLED;
        appointment.cancelledAt = new Date();
        appointment.cancelledBy = req.user?.id;
        appointment.cancellationReason = reason;

        await appointmentRepository.save(appointment);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.APPOINTMENT,
            resourceId: appointment.id,
            description: `Cancelled appointment: ${reason}`
        });

        logger.info(`Appointment ${appointment.appointmentId} cancelled`);

        res.status(200).json({
            success: true,
            message: 'Appointment cancelled successfully',
            data: { appointment }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Reschedule appointment
 */
export const rescheduleAppointment = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { newDate, newProviderId } = req.body;
        const oldAppointment = await appointmentRepository.findOne({ where: { id: req.params.id } });

        if (!oldAppointment) {
            throw new AppError('Appointment not found', 404);
        }

        // Mark old appointment as rescheduled
        oldAppointment.status = AppointmentStatus.RESCHEDULED;
        await appointmentRepository.save(oldAppointment);

        // Create new appointment
        const newAppointment = appointmentRepository.create({
            ...oldAppointment,
            id: undefined,
            appointmentId: `APT-${uuidv4().slice(0, 8).toUpperCase()}`,
            appointmentDate: new Date(newDate),
            providerId: newProviderId || oldAppointment.providerId,
            status: AppointmentStatus.SCHEDULED,
            rescheduledFrom: oldAppointment.id,
            createdAt: new Date(),
            updatedAt: new Date()
        });

        await appointmentRepository.save(newAppointment);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.APPOINTMENT,
            resourceId: newAppointment.id,
            description: `Rescheduled appointment from ${oldAppointment.appointmentDate} to ${newDate}`
        });

        logger.info(`Appointment ${oldAppointment.appointmentId} rescheduled to ${newAppointment.appointmentId}`);

        res.status(200).json({
            success: true,
            message: 'Appointment rescheduled successfully',
            data: { appointment: newAppointment }
        });
    } catch (error) {
        next(error);
    }
};
