import { Router } from 'express';
import * as labController from '../controllers/lab.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);

router.post('/orders', authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN), labController.createLabOrder);
router.get('/orders/pending', labController.getPendingLabOrders);
router.get('/orders/:id', labController.getLabOrderById);
router.get('/orders/patient/:patientId', labController.getPatientLabOrders);
router.put('/orders/:id/status', labController.updateLabOrderStatus);

router.post('/results', authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN), labController.createLabResult);
router.get('/results/:id', labController.getLabResultById);
router.get('/results/order/:orderId', labController.getLabResultsByOrderId);
router.put('/results/:id/review', authorize(UserRole.ADMIN, UserRole.SUPERVISOR), labController.reviewLabResult);

export default router;
