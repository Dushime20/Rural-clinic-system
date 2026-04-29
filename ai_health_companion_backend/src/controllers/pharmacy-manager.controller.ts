/**
 * Pharmacy Manager Controller
 * Handles pharmacy profile setup and medicine management for pharmacist users
 */

import { Response, NextFunction } from 'express';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { Pharmacy } from '../models/Pharmacy';
import { PharmacyMedicine } from '../models/PharmacyMedicine';

// Lazy getters — called inside handlers after DB is initialized
const pharmacyRepo = () => AppDataSource.getRepository(Pharmacy);
const medicineRepo = () => AppDataSource.getRepository(PharmacyMedicine);

// ─── Pharmacy Profile ─────────────────────────────────────────────────────────

/**
 * Get the pharmacy profile for the logged-in pharmacist
 */
export const getMyPharmacy = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({
            where: { managerId: req.user!.id },
            relations: ['medicines'],
        });

        res.status(200).json({
            success: true,
            data: { pharmacy: pharmacy || null },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Register pharmacy profile (first-time setup by pharmacist)
 */
export const registerPharmacy = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const existing = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (existing) {
            throw new AppError('You already have a pharmacy registered. Use update instead.', 400);
        }

        const {
            name, phoneNumber, address, latitude, longitude,
            city, district, country, openingHours,
        } = req.body;

        if (!name || latitude === undefined || longitude === undefined) {
            throw new AppError('Pharmacy name and GPS coordinates (latitude, longitude) are required', 400);
        }

        const pharmacy = pharmacyRepo().create({
            managerId: req.user!.id,
            managerName: `${(req.user as any).firstName ?? ''} ${(req.user as any).lastName ?? ''}`.trim(),
            name,
            phoneNumber,
            address,
            latitude: parseFloat(latitude),
            longitude: parseFloat(longitude),
            city,
            district,
            country,
            openingHours,
            isActive: true,
        });

        await pharmacyRepo().save(pharmacy);
        logger.info(`Pharmacy registered: ${pharmacy.name} by user ${req.user!.id}`);

        res.status(201).json({
            success: true,
            message: 'Pharmacy registered successfully',
            data: { pharmacy },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update pharmacy profile
 */
export const updatePharmacy = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (!pharmacy) {
            throw new AppError('Pharmacy not found. Please register your pharmacy first.', 404);
        }

        const {
            name, phoneNumber, address, latitude, longitude,
            city, district, country, openingHours,
        } = req.body;

        if (name) pharmacy.name = name;
        if (phoneNumber !== undefined) pharmacy.phoneNumber = phoneNumber;
        if (address !== undefined) pharmacy.address = address;
        if (latitude !== undefined) pharmacy.latitude = parseFloat(latitude);
        if (longitude !== undefined) pharmacy.longitude = parseFloat(longitude);
        if (city !== undefined) pharmacy.city = city;
        if (district !== undefined) pharmacy.district = district;
        if (country !== undefined) pharmacy.country = country;
        if (openingHours !== undefined) pharmacy.openingHours = openingHours;

        await pharmacyRepo().save(pharmacy);
        logger.info(`Pharmacy updated: ${pharmacy.id}`);

        res.status(200).json({
            success: true,
            message: 'Pharmacy updated successfully',
            data: { pharmacy },
        });
    } catch (error) {
        next(error);
    }
};

// ─── Medicine Management ──────────────────────────────────────────────────────

/**
 * Get all medicines for the pharmacist's pharmacy
 */
export const getMedicines = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (!pharmacy) {
            throw new AppError('Please register your pharmacy first', 404);
        }

        const { search, isAvailable, page = 1, limit = 20 } = req.query;

        const qb = medicineRepo().createQueryBuilder('m')
            .where('m.pharmacyId = :pharmacyId', { pharmacyId: pharmacy.id });

        if (search) {
            qb.andWhere(
                '(LOWER(m.medicationName) LIKE :s OR LOWER(m.genericName) LIKE :s OR LOWER(m.brandName) LIKE :s)',
                { s: `%${String(search).toLowerCase()}%` }
            );
        }
        if (isAvailable !== undefined) {
            qb.andWhere('m.isAvailable = :isAvailable', { isAvailable: isAvailable === 'true' });
        }

        qb.orderBy('m.medicationName', 'ASC')
            .skip((Number(page) - 1) * Number(limit))
            .take(Number(limit));

        const [medicines, total] = await qb.getManyAndCount();

        res.status(200).json({
            success: true,
            data: {
                medicines,
                pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Add a medicine to the pharmacy
 */
export const addMedicine = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (!pharmacy) {
            throw new AppError('Please register your pharmacy first', 404);
        }

        const {
            medicationName, genericName, brandName, strength, form,
            category, price, currency, stockQuantity, isAvailable, notes,
        } = req.body;

        if (!medicationName || price === undefined) {
            throw new AppError('Medicine name and price are required', 400);
        }

        const medicine = medicineRepo().create({
            pharmacyId: pharmacy.id,
            medicationName,
            genericName,
            brandName,
            strength,
            form,
            category,
            price: parseFloat(price),
            currency: currency || 'RWF',
            stockQuantity: stockQuantity !== undefined ? parseInt(stockQuantity) : 0,
            isAvailable: isAvailable !== false,
            notes,
        });

        await medicineRepo().save(medicine);
        logger.info(`Medicine added: ${medicine.medicationName} to pharmacy ${pharmacy.id}`);

        res.status(201).json({
            success: true,
            message: 'Medicine added successfully',
            data: { medicine },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update a medicine
 */
export const updateMedicine = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (!pharmacy) throw new AppError('Pharmacy not found', 404);

        const medicine = await medicineRepo().findOne({
            where: { id: req.params.id, pharmacyId: pharmacy.id },
        });
        if (!medicine) throw new AppError('Medicine not found', 404);

        const {
            medicationName, genericName, brandName, strength, form,
            category, price, currency, stockQuantity, isAvailable, notes,
        } = req.body;

        if (medicationName) medicine.medicationName = medicationName;
        if (genericName !== undefined) medicine.genericName = genericName;
        if (brandName !== undefined) medicine.brandName = brandName;
        if (strength !== undefined) medicine.strength = strength;
        if (form !== undefined) medicine.form = form;
        if (category !== undefined) medicine.category = category;
        if (price !== undefined) medicine.price = parseFloat(price);
        if (currency !== undefined) medicine.currency = currency;
        if (stockQuantity !== undefined) medicine.stockQuantity = parseInt(stockQuantity);
        if (isAvailable !== undefined) medicine.isAvailable = isAvailable;
        if (notes !== undefined) medicine.notes = notes;

        await medicineRepo().save(medicine);

        res.status(200).json({
            success: true,
            message: 'Medicine updated successfully',
            data: { medicine },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a medicine
 */
export const deleteMedicine = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacy = await pharmacyRepo().findOne({ where: { managerId: req.user!.id } });
        if (!pharmacy) throw new AppError('Pharmacy not found', 404);

        const medicine = await medicineRepo().findOne({
            where: { id: req.params.id, pharmacyId: pharmacy.id },
        });
        if (!medicine) throw new AppError('Medicine not found', 404);

        await medicineRepo().remove(medicine);

        res.status(200).json({ success: true, message: 'Medicine removed successfully' });
    } catch (error) {
        next(error);
    }
};

// ─── Public / Health Worker APIs ─────────────────────────────────────────────

/**
 * Find nearby pharmacies that have a specific medicine
 * Used by health workers after AI diagnosis
 */
export const findNearbyPharmaciesWithMedicine = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { latitude, longitude, medicineName, radius = 50 } = req.query;

        if (!latitude || !longitude || !medicineName) {
            throw new AppError('latitude, longitude, and medicineName are required', 400);
        }

        const lat = parseFloat(latitude as string);
        const lng = parseFloat(longitude as string);
        const radiusKm = parseFloat(radius as string);

        // Haversine formula in SQL to find pharmacies within radius
        const results = await pharmacyRepo()
            .createQueryBuilder('p')
            .innerJoinAndSelect(
                'p.medicines', 'm',
                'LOWER(m.medicationName) LIKE :med OR LOWER(m.genericName) LIKE :med',
                { med: `%${String(medicineName).toLowerCase()}%` }
            )
            .where('p.isActive = true')
            .andWhere('m.isAvailable = true')
            .andWhere(
                `(6371 * acos(
                    cos(radians(:lat)) * cos(radians(CAST(p.latitude AS float))) *
                    cos(radians(CAST(p.longitude AS float)) - radians(:lng)) +
                    sin(radians(:lat)) * sin(radians(CAST(p.latitude AS float)))
                )) <= :radius`,
                { lat, lng, radius: radiusKm }
            )
            .addSelect(
                `(6371 * acos(
                    cos(radians(${lat})) * cos(radians(CAST(p.latitude AS float))) *
                    cos(radians(CAST(p.longitude AS float)) - radians(${lng})) +
                    sin(radians(${lat})) * sin(radians(CAST(p.latitude AS float)))
                ))`,
                'distance_km'
            )
            .orderBy('distance_km', 'ASC')
            .limit(10)
            .getMany();

        res.status(200).json({
            success: true,
            data: { pharmacies: results, count: results.length },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all active pharmacies (for map view)
 */
export const getAllPharmacies = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const pharmacies = await pharmacyRepo().find({
            where: { isActive: true },
            select: ['id', 'name', 'address', 'latitude', 'longitude', 'city', 'district', 'phoneNumber', 'openingHours'],
        });

        res.status(200).json({
            success: true,
            data: { pharmacies, count: pharmacies.length },
        });
    } catch (error) {
        next(error);
    }
};
