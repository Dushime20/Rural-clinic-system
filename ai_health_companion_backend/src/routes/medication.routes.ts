import { Router } from 'express';
import * as medicationController from '../controllers/medication.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);

router.get('/', medicationController.getAllMedications);
router.get('/low-stock', medicationController.getLowStockMedications);
router.get('/:id', medicationController.getMedicationById);
router.post('/', authorize(UserRole.ADMIN, UserRole.CLINIC_STAFF), medicationController.createMedication);
router.put('/:id', authorize(UserRole.ADMIN, UserRole.CLINIC_STAFF), medicationController.updateMedication);
router.put('/:id/stock', authorize(UserRole.ADMIN, UserRole.CLINIC_STAFF), medicationController.updateStock);

export default router;
