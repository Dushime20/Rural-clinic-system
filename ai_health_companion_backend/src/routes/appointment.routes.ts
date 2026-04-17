import { Router } from 'express';
import * as appointmentController from '../controllers/appointment.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);

router.post('/', authorize(UserRole.HEALTH_WORKER, UserRole.CLINIC_STAFF, UserRole.ADMIN), appointmentController.createAppointment);
router.get('/', appointmentController.getAppointmentsByDateRange);
router.get('/available-slots', appointmentController.getAvailableSlots);
router.get('/:id', appointmentController.getAppointmentById);
router.put('/:id/status', appointmentController.updateAppointmentStatus);
router.put('/:id/reschedule', appointmentController.rescheduleAppointment);
router.delete('/:id', authorize(UserRole.ADMIN, UserRole.HEALTH_WORKER), appointmentController.cancelAppointment);

export default router;
