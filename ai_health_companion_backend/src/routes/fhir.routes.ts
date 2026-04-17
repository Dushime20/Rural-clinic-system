import { Router } from 'express';
import * as fhirController from '../controllers/fhir.controller';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

// FHIR R4 endpoints
router.get('/Patient/:id', fhirController.getFHIRPatient);
router.post('/Patient', fhirController.createFHIRPatient);
router.put('/Patient/:id', fhirController.updateFHIRPatient);
router.get('/Observation', fhirController.getFHIRObservations);
router.get('/Condition', fhirController.getFHIRConditions);
router.get('/MedicationRequest', fhirController.getFHIRMedicationRequests);
router.get('/Appointment', fhirController.getFHIRAppointments);

export default router;
