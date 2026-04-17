import { Router } from 'express';
import * as auditController from '../controllers/audit.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();
router.use(authenticate);
router.use(authorize(UserRole.ADMIN, UserRole.SUPERVISOR)); // Only admins and supervisors

router.get('/', auditController.getAuditLogs);
router.get('/user/:userId', auditController.getUserActivity);
router.get('/resource/:resource/:resourceId', auditController.getResourceHistory);

export default router;
