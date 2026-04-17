import { Router } from 'express';
import * as prescriptionController from '../controllers/prescription.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);

router.post('/', authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN), prescriptionController.createPrescription);
router.get('/:id', prescriptionController.getPrescriptionById);
router.get('/patient/:patientId', prescriptionController.getPatientPrescriptions);
router.put('/:id/dispense', authorize(UserRole.CLINIC_STAFF, UserRole.ADMIN), prescriptionController.dispensePrescription);
router.put('/:id/status', authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN), prescriptionController.updatePrescriptionStatus);
router.post('/:id/refill', prescriptionController.requestRefill);
router.delete('/:id', authorize(UserRole.ADMIN, UserRole.HEALTH_WORKER), prescriptionController.cancelPrescription);

export default router;
