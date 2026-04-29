import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';
import {
    getMyPharmacy,
    registerPharmacy,
    updatePharmacy,
    getMedicines,
    addMedicine,
    updateMedicine,
    deleteMedicine,
    findNearbyPharmaciesWithMedicine,
    getAllPharmacies,
} from '../controllers/pharmacy-manager.controller';

const router = Router();

// ─── Public / Health Worker routes (authenticated, any role) ─────────────────
router.get('/map', authenticate, getAllPharmacies);
router.get('/nearby', authenticate, findNearbyPharmaciesWithMedicine);

// ─── Pharmacist-only routes ───────────────────────────────────────────────────
router.use(authenticate, authorize(UserRole.PHARMACIST));

// Pharmacy profile
router.get('/my', getMyPharmacy);
router.post('/my', registerPharmacy);
router.put('/my', updatePharmacy);

// Medicine management
router.get('/my/medicines', getMedicines);
router.post('/my/medicines', addMedicine);
router.put('/my/medicines/:id', updateMedicine);
router.delete('/my/medicines/:id', deleteMedicine);

export default router;
