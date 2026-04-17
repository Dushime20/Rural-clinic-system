import { Response, NextFunction } from 'express';
import { LabOrder, LabOrderStatus } from '../models/LabOrder';
import { LabResult, ResultStatus } from '../models/LabResult';
import { Patient } from '../models/Patient';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import { createAuditLog } from '../middleware/audit';
import { AuditAction, AuditResource } from '../models/AuditLog';

const labOrderRepository = AppDataSource.getRepository(LabOrder);
const labResultRepository = AppDataSource.getRepository(LabResult);
const patientRepository = AppDataSource.getRepository(Patient);

/**
 * Create lab order
 */
export const createLabOrder = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId, diagnosisId, tests, priority, clinicalNotes, specialInstructions, isFasting } = req.body;

        const patient = await patientRepository.findOne({ where: { id: patientId } });
        if (!patient) {
            throw new AppError('Patient not found', 404);
        }

        const labOrder = labOrderRepository.create({
            orderId: `LAB-${uuidv4().slice(0, 8).toUpperCase()}`,
            patientId,
            orderingProviderId: req.user?.id!,
            diagnosisId,
            clinicId: req.user?.clinicId!,
            tests,
            priority: priority || 'routine',
            clinicalNotes,
            specialInstructions,
            isFasting: isFasting || false,
            status: LabOrderStatus.PENDING
        });

        await labOrderRepository.save(labOrder);

        await createAuditLog(req, {
            action: AuditAction.CREATE,
            resource: AuditResource.LAB_ORDER,
            resourceId: labOrder.id,
            description: `Created lab order for patient ${patient.getFullName()}`
        }, undefined, labOrder);

        logger.info(`Lab order created: ${labOrder.orderId}`);

        res.status(201).json({
            success: true,
            message: 'Lab order created successfully',
            data: { labOrder }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get lab order by ID
 */
export const getLabOrderById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const labOrder = await labOrderRepository.findOne({
            where: { id: req.params.id },
            relations: ['patient', 'orderingProvider']
        });

        if (!labOrder) {
            throw new AppError('Lab order not found', 404);
        }

        res.status(200).json({
            success: true,
            data: { labOrder }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get patient lab orders
 */
export const getPatientLabOrders = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { patientId } = req.params;

        const labOrders = await labOrderRepository.find({
            where: { patientId },
            relations: ['orderingProvider'],
            order: { orderDate: 'DESC' }
        });

        res.status(200).json({
            success: true,
            data: { labOrders, count: labOrders.length }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update lab order status
 */
export const updateLabOrderStatus = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { status } = req.body;
        const labOrder = await labOrderRepository.findOne({ where: { id: req.params.id } });

        if (!labOrder) {
            throw new AppError('Lab order not found', 404);
        }

        const oldStatus = labOrder.status;
        labOrder.status = status;

        if (status === LabOrderStatus.COLLECTED) {
            labOrder.collectedAt = new Date();
            labOrder.collectedBy = req.user?.id;
        }

        await labOrderRepository.save(labOrder);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.LAB_ORDER,
            resourceId: labOrder.id,
            description: `Updated lab order status from ${oldStatus} to ${status}`
        }, { status: oldStatus }, { status });

        res.status(200).json({
            success: true,
            message: 'Lab order status updated successfully',
            data: { labOrder }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Create lab result
 */
export const createLabResult = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { labOrderId, results, interpretation, technicalNotes } = req.body;

        const labOrder = await labOrderRepository.findOne({ where: { id: labOrderId } });
        if (!labOrder) {
            throw new AppError('Lab order not found', 404);
        }

        // Check for critical values
        const hasCriticalValues = results.some((r: any) => 
            r.abnormalFlag === 'critical_low' || r.abnormalFlag === 'critical_high'
        );

        const labResult = labResultRepository.create({
            resultId: `RES-${uuidv4().slice(0, 8).toUpperCase()}`,
            labOrderId,
            results,
            status: ResultStatus.PRELIMINARY,
            performedBy: req.user?.id,
            interpretation,
            technicalNotes,
            hasCriticalValues
        });

        await labResultRepository.save(labResult);

        // Update lab order status
        labOrder.status = LabOrderStatus.COMPLETED;
        await labOrderRepository.save(labOrder);

        await createAuditLog(req, {
            action: AuditAction.CREATE,
            resource: AuditResource.LAB_RESULT,
            resourceId: labResult.id,
            description: `Created lab result for order ${labOrder.orderId}`
        }, undefined, labResult);

        logger.info(`Lab result created: ${labResult.resultId}${hasCriticalValues ? ' (CRITICAL VALUES)' : ''}`);

        res.status(201).json({
            success: true,
            message: 'Lab result created successfully',
            data: { labResult }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get lab result by ID
 */
export const getLabResultById = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const labResult = await labResultRepository.findOne({
            where: { id: req.params.id },
            relations: ['labOrder', 'labOrder.patient', 'reviewer']
        });

        if (!labResult) {
            throw new AppError('Lab result not found', 404);
        }

        await createAuditLog(req, {
            action: AuditAction.READ,
            resource: AuditResource.LAB_RESULT,
            resourceId: labResult.id,
            description: `Viewed lab result ${labResult.resultId}`
        });

        res.status(200).json({
            success: true,
            data: { labResult }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get lab results by order ID
 */
export const getLabResultsByOrderId = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { orderId } = req.params;

        const labResults = await labResultRepository.find({
            where: { labOrderId: orderId },
            relations: ['reviewer'],
            order: { resultDate: 'DESC' }
        });

        res.status(200).json({
            success: true,
            data: { labResults, count: labResults.length }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Review and finalize lab result
 */
export const reviewLabResult = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { interpretation } = req.body;
        const labResult = await labResultRepository.findOne({ where: { id: req.params.id } });

        if (!labResult) {
            throw new AppError('Lab result not found', 404);
        }

        labResult.status = ResultStatus.FINAL;
        labResult.reviewedBy = req.user?.id;
        labResult.reviewedAt = new Date();
        if (interpretation) {
            labResult.interpretation = interpretation;
        }

        await labResultRepository.save(labResult);

        await createAuditLog(req, {
            action: AuditAction.UPDATE,
            resource: AuditResource.LAB_RESULT,
            resourceId: labResult.id,
            description: `Reviewed and finalized lab result ${labResult.resultId}`
        });

        logger.info(`Lab result reviewed: ${labResult.resultId}`);

        res.status(200).json({
            success: true,
            message: 'Lab result reviewed successfully',
            data: { labResult }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get pending lab orders
 */
export const getPendingLabOrders = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const labOrders = await labOrderRepository.find({
            where: {
                clinicId: req.user?.clinicId,
                status: LabOrderStatus.PENDING
            },
            relations: ['patient', 'orderingProvider'],
            order: { orderDate: 'ASC' }
        });

        res.status(200).json({
            success: true,
            data: { labOrders, count: labOrders.length }
        });
    } catch (error) {
        next(error);
    }
};
