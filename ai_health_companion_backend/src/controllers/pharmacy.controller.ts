import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { elmisService } from '../services/elmis.service';
import { logger } from '../utils/logger';

export const checkAvailability = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { medication, facilityId, maxDistance } = req.query;
        if (!medication) {
            res.status(400).json({ success: false, message: 'Medication name is required' });
            return;
        }

        const availability = await elmisService.checkAvailability(
            medication as string,
            facilityId as string,
            maxDistance ? Number(maxDistance) : undefined
        );

        res.status(200).json({ success: true, data: { availability, count: availability.length } });
    } catch (error) {
        next(error);
    }
};

export const searchMedications = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { query } = req.query;
        if (!query) {
            res.status(400).json({ success: false, message: 'Search query is required' });
            return;
        }

        const medications = await elmisService.searchMedications(query as string);
        res.status(200).json({ success: true, data: { medications, count: medications.length } });
    } catch (error) {
        next(error);
    }
};

export const getAlternatives = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { medicationId } = req.params;
        const alternatives = await elmisService.getAlternatives(medicationId);
        res.status(200).json({ success: true, data: { alternatives, count: alternatives.length } });
    } catch (error) {
        next(error);
    }
};

export const findNearbyFacilities = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { latitude, longitude, radius } = req.query;
        if (!latitude || !longitude) {
            res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
            return;
        }

        const facilities = await elmisService.findNearbyFacilities(
            Number(latitude),
            Number(longitude),
            radius ? Number(radius) : undefined
        );

        res.status(200).json({ success: true, data: { facilities, count: facilities.length } });
    } catch (error) {
        next(error);
    }
};

export const reserveStock = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { medicationId, facilityId, quantity, patientId } = req.body;
        
        const reservation = await elmisService.reserveStock(medicationId, facilityId, quantity, patientId);
        
        logger.info(`Stock reserved: ${reservation.reservationId} for patient ${patientId}`);
        res.status(201).json({ success: true, message: 'Stock reserved successfully', data: { reservation } });
    } catch (error) {
        next(error);
    }
};
