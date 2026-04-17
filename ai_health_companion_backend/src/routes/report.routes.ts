import { Router } from 'express';
import * as reportController from '../controllers/report.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);
router.use(authorize(UserRole.ADMIN, UserRole.SUPERVISOR)); // Only admins and supervisors

router.get('/moh', reportController.getMOHReport);
router.get('/surveillance', reportController.getSurveillanceReport);
router.get('/performance', reportController.getClinicPerformance);

export default router;
