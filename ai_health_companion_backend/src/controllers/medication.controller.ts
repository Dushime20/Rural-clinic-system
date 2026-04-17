import { Response, NextFunction } from 'express';
import { Medication } from '../models/Medication';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { ILike } from 'typeorm';

const medicationRepository = AppDataSource.getRepository(Medication);

export const getAllMedications = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { search, category, page = 1, limit = 50 } = req.query;
        const skip = (Number(page) - 1) * Number(limit);

        const where: any = { clinicId: req.user?.clinicId };
        if (search) where.genericName = ILike(`%${search}%`);
        if (category) where.category = category;

        const [medications, total] = await medicationRepository.findAndCount({
            where,
            skip,
            take: Number(limit),
            order: { genericName: 'ASC' }
        });

        res.status(200).json({
            success: true,
            data: { medications, pagination: { page: Number(page), limit: Number(limit), total, pages: Math.ceil(total / Number(limit)) } }
        });
    } catch (error) {
        next(error);
    }
};

export const getMedicationById = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const medication = await medicationRepository.findOne({ where: { id: req.params.id } });
        if (!medication) throw new AppError('Medication not found', 404);
        res.status(200).json({ success: true, data: { medication } });
    } catch (error) {
        next(error);
    }
};

export const createMedication = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const newMedication = medicationRepository.create({
            ...req.body,
            medicationCode: `MED-${uuidv4().slice(0, 8).toUpperCase()}`,
            clinicId: req.user?.clinicId!
        });
        await medicationRepository.save(newMedication);
        logger.info('Medication created successfully');
        res.status(201).json({ success: true, message: 'Medication created successfully', data: { medication: newMedication } });
    } catch (error) {
        next(error);
    }
};

export const updateMedication = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const medication = await medicationRepository.findOne({ where: { id: req.params.id } });
        if (!medication) throw new AppError('Medication not found', 404);
        Object.assign(medication, req.body);
        await medicationRepository.save(medication);
        res.status(200).json({ success: true, message: 'Medication updated successfully', data: { medication } });
    } catch (error) {
        next(error);
    }
};

export const updateStock = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { quantity, expiryDate, batchNumber } = req.body;
        const medication = await medicationRepository.findOne({ where: { id: req.params.id } });
        if (!medication) throw new AppError('Medication not found', 404);
        
        medication.stockInfo = {
            ...medication.stockInfo,
            quantity,
            expiryDate: expiryDate ? new Date(expiryDate) : medication.stockInfo?.expiryDate,
            batchNumber: batchNumber || medication.stockInfo?.batchNumber,
            reorderLevel: medication.stockInfo?.reorderLevel || 10
        };
        medication.isAvailable = quantity > 0;
        
        await medicationRepository.save(medication);
        logger.info(`Stock updated for ${medication.genericName}: ${quantity} units`);
        res.status(200).json({ success: true, message: 'Stock updated successfully', data: { medication } });
    } catch (error) {
        next(error);
    }
};

export const getLowStockMedications = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
        const medications = await medicationRepository
            .createQueryBuilder('medication')
            .where('medication.clinicId = :clinicId', { clinicId: req.user?.clinicId })
            .andWhere("(medication.stockInfo->>'quantity')::int <= (medication.stockInfo->>'reorderLevel')::int")
            .getMany();

        res.status(200).json({ success: true, data: { medications, count: medications.length } });
    } catch (error) {
        next(error);
    }
};
