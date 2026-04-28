/**
 * Safe Diagnosis Integration Tests
 * Tests the complete flow from diagnosis request to safe recommendations
 */

import { safeDiagnosisService } from '../services/safe-diagnosis.service';
import { DiagnosisInput } from '../services/safe-diagnosis.service';

describe('Safe Diagnosis Integration Tests', () => {
  
  // Mock patient data
  const mockPatientWithAllergies = {
    id: 'patient-allergy-123',
    allergies: ['Penicillin'],
    chronicConditions: [],
    currentMedications: [],
    age: 35,
    gender: 'male'
  };
  
  const mockPatientWithDiabetes = {
    id: 'patient-diabetes-123',
    allergies: [],
    chronicConditions: ['Diabetes'],
    currentMedications: ['Metformin', 'Insulin'],
    age: 55,
    gender: 'female'
  };
  
  const mockComplexPatient = {
    id: 'patient-complex-123',
    allergies: ['Penicillin', 'Aspirin'],
    chronicConditions: ['Diabetes', 'Hypertension', 'Kidney disease'],
    currentMedications: ['Metformin', 'Lisinopril', 'Warfarin'],
    age: 70,
    gender: 'male'
  };
  
  describe('Scenario 1: Patient with Penicillin Allergy', () => {
    
    test('should detect allergy and suggest alternatives', async () => {
      const input: DiagnosisInput = {
        patientId: mockPatientWithAllergies.id,
        symptoms: ['fever', 'cough', 'chest pain'],
        vitalSigns: {
          temperature: 38.5,
          heartRate: 95,
          respiratoryRate: 22
        }
      };
      
      // Mock the patient context fetch
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(mockPatientWithAllergies);
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      expect(result.success).toBe(true);
      expect(result.patientContext.allergies).toContain('Penicillin');
      
      // Should have contraindications if penicillin-based meds suggested
      if (result.safetyCheck.contraindications.length > 0) {
        expect(result.safetyCheck.contraindications[0]).toContain('ALLERGY');
        expect(result.safeRecommendations.medications).not.toContain(
          expect.stringMatching(/amoxicillin|penicillin/i)
        );
      }
    });
  });
  
  describe('Scenario 2: Diabetic Patient with Infection', () => {
    
    test('should provide diabetes-specific warnings', async () => {
      const input: DiagnosisInput = {
        patientId: mockPatientWithDiabetes.id,
        symptoms: ['fever', 'frequent urination', 'fatigue'],
        vitalSigns: {
          temperature: 39.0,
          heartRate: 100
        }
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(mockPatientWithDiabetes);
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      expect(result.success).toBe(true);
      expect(result.patientContext.chronicConditions).toContain('Diabetes');
      
      // Should have patient context with chronic conditions
      expect(result.patientContext.chronicConditions.length).toBeGreaterThan(0);
      expect(result.patientContext.currentMedications.length).toBeGreaterThan(0);
      
      // Should complete diagnosis successfully
      expect(result.prediction.disease).toBeDefined();
      expect(result.prediction.confidence).toBeGreaterThan(0);
    });
  });
  
  describe('Scenario 3: Complex Patient (Multiple Conditions)', () => {
    
    test('should handle multiple safety concerns', async () => {
      const input: DiagnosisInput = {
        patientId: mockComplexPatient.id,
        symptoms: ['headache', 'dizziness', 'fatigue'],
        vitalSigns: {
          temperature: 37.2,
          bloodPressureSystolic: 150,
          bloodPressureDiastolic: 95,
          heartRate: 88
        }
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(mockComplexPatient);
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      expect(result.success).toBe(true);
      
      // Should have complex patient context
      expect(result.patientContext.allergies.length).toBeGreaterThan(0);
      expect(result.patientContext.chronicConditions.length).toBeGreaterThan(0);
      expect(result.patientContext.currentMedications.length).toBeGreaterThan(0);
      
      // Should complete diagnosis successfully
      expect(result.prediction.disease).toBeDefined();
      expect(result.prediction.confidence).toBeGreaterThan(0);
    });
    
    test('should detect drug interactions with warfarin', async () => {
      const input: DiagnosisInput = {
        patientId: mockComplexPatient.id,
        symptoms: ['pain', 'inflammation'],
        vitalSigns: {
          temperature: 37.0
        }
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(mockComplexPatient);
      
      // Mock Flask service to suggest NSAIDs
      jest.spyOn(require('../services/flask-ml.service').flaskMLService, 'predictDisease')
        .mockResolvedValue({
          prediction: {
            disease: 'Arthritis',
            icd10Code: 'M13.9',
            confidence: 0.85,
            symptoms_used: ['pain', 'inflammation']
          },
          information: {
            medications: ['Ibuprofen', 'Naproxen'],
            precautions: ['Rest', 'Ice'],
            diet: ['Anti-inflammatory foods'],
            workout: ['Gentle stretching']
          }
        });
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      // Should detect warfarin-NSAID interaction
      const hasInteractionWarning = result.safetyCheck.contraindications.some(
        contra => contra.toLowerCase().includes('interaction')
      );
      
      expect(hasInteractionWarning).toBe(true);
    });
  });
  
  describe('Scenario 4: Pediatric Patient', () => {
    
    test('should avoid aspirin for children', async () => {
      const childPatient = {
        id: 'patient-child-123',
        allergies: [],
        chronicConditions: [],
        currentMedications: [],
        age: 8,
        gender: 'male'
      };
      
      const input: DiagnosisInput = {
        patientId: childPatient.id,
        symptoms: ['fever', 'headache'],
        vitalSigns: {
          temperature: 38.5
        }
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(childPatient);
      
      // Mock Flask service to suggest aspirin
      jest.spyOn(require('../services/flask-ml.service').flaskMLService, 'predictDisease')
        .mockResolvedValue({
          prediction: {
            disease: 'Viral Fever',
            icd10Code: 'R50.9',
            confidence: 0.80,
            symptoms_used: ['fever', 'headache']
          },
          information: {
            medications: ['Aspirin', 'Rest'],
            precautions: ['Hydration'],
            diet: ['Light meals'],
            workout: ['Rest']
          }
        });
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      // Should warn about aspirin in children
      const hasAspirinWarning = result.safetyCheck.warnings.some(
        warning => warning.toLowerCase().includes('aspirin') || warning.toLowerCase().includes('reye')
      );
      
      expect(hasAspirinWarning).toBe(true);
    });
  });
  
  describe('Scenario 5: Elderly Patient', () => {
    
    test('should adjust recommendations for elderly', async () => {
      const elderlyPatient = {
        id: 'patient-elderly-123',
        allergies: [],
        chronicConditions: ['Hypertension'],
        currentMedications: ['Amlodipine'],
        age: 78,
        gender: 'female'
      };
      
      const input: DiagnosisInput = {
        patientId: elderlyPatient.id,
        symptoms: ['joint pain', 'stiffness'],
        vitalSigns: {
          temperature: 37.0,
          bloodPressureSystolic: 140,
          bloodPressureDiastolic: 85
        }
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(elderlyPatient);
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      // Should have age-related considerations
      expect(result.patientContext.age).toBeGreaterThan(65);
      
      // Should have warnings or adjusted recommendations for elderly
      const totalRecommendations = 
        result.safeRecommendations.warnings.length +
        result.safeRecommendations.precautions.length;
      
      expect(totalRecommendations).toBeGreaterThan(0);
    });
  });
  
  describe('Scenario 6: Emergency Diagnosis (No Patient Context)', () => {
    
    test('should allow emergency diagnosis with warnings', async () => {
      const input = {
        symptoms: ['chest pain', 'shortness of breath', 'sweating'],
        vitalSigns: {
          temperature: 37.5,
          heartRate: 120,
          bloodPressureSystolic: 160,
          bloodPressureDiastolic: 100
        }
      };
      
      const result = await safeDiagnosisService.emergencyDiagnosis(input);
      
      expect(result.success).toBe(true);
      expect(result.warning).toContain('WITHOUT PATIENT MEDICAL HISTORY');
      expect(result.risks).toContain('Allergies NOT checked');
      expect(result.risks).toContain('Drug interactions NOT verified');
    });
  });
  
  describe('Safety Check Results', () => {
    
    test('should include all required safety information', async () => {
      const input: DiagnosisInput = {
        patientId: 'test-patient-123',
        symptoms: ['fever', 'cough'],
        vitalSigns: {
          temperature: 38.0
        }
      };
      
      const mockPatient = {
        id: 'test-patient-123',
        allergies: [],
        chronicConditions: [],
        currentMedications: [],
        age: 30,
        gender: 'male'
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(mockPatient);
      
      const result = await safeDiagnosisService.diagnoseWithSafety(input);
      
      // Verify result structure
      expect(result).toHaveProperty('success');
      expect(result).toHaveProperty('prediction');
      expect(result).toHaveProperty('patientContext');
      expect(result).toHaveProperty('safetyCheck');
      expect(result).toHaveProperty('originalRecommendations');
      expect(result).toHaveProperty('safeRecommendations');
      expect(result).toHaveProperty('requiresSpecialistReferral');
      expect(result).toHaveProperty('timestamp');
      
      // Verify safety check structure
      expect(result.safetyCheck).toHaveProperty('passed');
      expect(result.safetyCheck).toHaveProperty('warnings');
      expect(result.safetyCheck).toHaveProperty('contraindications');
      expect(result.safetyCheck).toHaveProperty('adjustedRecommendations');
      expect(result.safetyCheck).toHaveProperty('riskLevel');
    });
  });
  
  describe('Error Handling', () => {
    
    test('should throw error if patient not found', async () => {
      const input: DiagnosisInput = {
        patientId: 'non-existent-patient',
        symptoms: ['fever'],
        vitalSigns: {}
      };
      
      jest.spyOn(require('../services/patient-safety.service').patientSafetyService, 'getPatientContext')
        .mockResolvedValue(null);
      
      await expect(
        safeDiagnosisService.diagnoseWithSafety(input)
      ).rejects.toThrow('Patient record not found');
    });
  });
});
