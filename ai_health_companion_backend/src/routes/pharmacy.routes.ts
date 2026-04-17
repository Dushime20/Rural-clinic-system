import { Router } from 'express';
import * as pharmacyController from '../controllers/pharmacy.controller';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

router.get('/availability', pharmacyController.checkAvailability);
router.get('/search', pharmacyController.searchMedications);
router.get('/alternatives/:medicationId', pharmacyController.getAlternatives);
router.get('/facilities/nearby', pharmacyController.findNearbyFacilities);
router.post('/reserve', pharmacyController.reserveStock);

export default router;
