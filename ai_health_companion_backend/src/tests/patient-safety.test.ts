/**
 * Patient Safety Service Tests
 */

import { patientSafetyService, PatientContext } from '../services/patient-safety.service';

describe('PatientSafetyService', () => {
  
  describe('Allergy Checking', () => {
    
    test('should detect penicillin allergy conflict', async () => {
      const suggestedMeds = ['Amoxicillin', 'Paracetamol'];
      const patientAllergies = ['Penicillin'];
      
      const result = (patientSafetyService as any).checkAllergies(
        suggestedMeds,
        patientAllergies
      );
      
      expect(result.hasConflict).toBe(true);
      expect(result.conflictingMeds).toContain('Amoxicillin');
      expect(result.alternatives).toContain('azithromycin');
    });
    
    test('should not flag safe medications', async () => {
      const suggestedMeds = ['Azithromycin', 'Paracetamol'];
      const patientAllergies = ['Penicillin'];
      
      const result = (patientSafetyService as any).checkAllergies(
        suggestedMeds,
        patientAllergies
      );
      
      expect(result.hasConflict).toBe(false);
      expect(result.conflictingMeds).toHaveLength(0);
    });
    
    test('should detect multiple allergy conflicts', async () => {
      const suggestedMeds = ['Amoxicillin', 'Aspirin', 'Ibuprofen'];
      const patientAllergies = ['Penicillin', 'Aspirin'];
      
      const result = (patientSafetyService as any).checkAllergies(
        suggestedMeds,
        patientAllergies
      );
      
      expect(result.hasConflict).toBe(true);
      expect(result.conflictingMeds.length).toBeGreaterThan(1);
    });
    
    test('should suggest alternatives for allergic medications', async () => {
      const suggestedMeds = ['Amoxicillin'];
      const patientAllergies = ['Penicillin'];
      
      const result = (patientSafetyService as any).checkAllergies(
        suggestedMeds,
        patientAllergies
      );
      
      expect(result.alternatives.length).toBeGreaterThan(0);
      expect(result.alternatives).toEqual(
        expect.arrayContaining(['azithromycin', 'ciprofloxacin'])
      );
    });
  });
  
  describe('Drug Interaction Checking', () => {
    
    test('should detect warfarin-aspirin interaction', async () => {
      const suggestedMeds = ['Aspirin'];
      const currentMeds = ['Warfarin'];
      
      const result = (patientSafetyService as any).checkDrugInteractions(
        suggestedMeds,
        currentMeds
      );
      
      expect(result.hasInteraction).toBe(true);
      expect(result.interactions[0]).toContain('bleeding risk');
    });
    
    test('should detect metformin-contrast interaction', async () => {
      const suggestedMeds = ['Contrast dye'];
      const currentMeds = ['Metformin'];
      
      const result = (patientSafetyService as any).checkDrugInteractions(
        suggestedMeds,
        currentMeds
      );
      
      expect(result.hasInteraction).toBe(true);
      expect(result.interactions[0]).toContain('Lactic acidosis');
    });
    
    test('should not flag safe drug combinations', async () => {
      const suggestedMeds = ['Paracetamol'];
      const currentMeds = ['Metformin'];
      
      const result = (patientSafetyService as any).checkDrugInteractions(
        suggestedMeds,
        currentMeds
      );
      
      expect(result.hasInteraction).toBe(false);
    });
  });
  
  describe('Chronic Condition Checking', () => {
    
    test('should flag diabetes with infection', async () => {
      const disease = 'Bacterial infection';
      const conditions = ['Diabetes'];
      
      const result = (patientSafetyService as any).checkChronicConditions(
        disease,
        conditions
      );
      
      expect(result.hasRisk).toBe(true);
      expect(result.recommendations).toEqual(
        expect.arrayContaining([
          expect.stringContaining('blood sugar')
        ])
      );
    });
    
    test('should flag kidney disease with appropriate recommendations', async () => {
      const disease = 'Urinary tract infection';
      const conditions = ['Kidney disease'];
      
      const result = (patientSafetyService as any).checkChronicConditions(
        disease,
        conditions
      );
      
      expect(result.hasRisk).toBe(true);
      expect(result.recommendations).toEqual(
        expect.arrayContaining([
          expect.stringContaining('renal function')
        ])
      );
    });
    
    test('should not flag unrelated conditions', async () => {
      const disease = 'Common Cold';
      const conditions = ['Diabetes'];
      
      const result = (patientSafetyService as any).checkChronicConditions(
        disease,
        conditions
      );
      
      expect(result.hasRisk).toBe(false);
    });
  });
  
  describe('Age-based Contraindications', () => {
    
    test('should flag aspirin for children', async () => {
      const medications = ['Aspirin'];
      const age = 10;
      
      const result = (patientSafetyService as any).checkAgeContraindications(
        medications,
        age
      );
      
      expect(result.hasContraindication).toBe(true);
      expect(result.reason).toContain('Reye');
      expect(result.alternatives).toContain('Use acetaminophen or ibuprofen instead');
    });
    
    test('should flag NSAIDs for elderly', async () => {
      const medications = ['Ibuprofen'];
      const age = 75;
      
      const result = (patientSafetyService as any).checkAgeContraindications(
        medications,
        age
      );
      
      expect(result.hasContraindication).toBe(true);
      expect(result.reason).toContain('elderly');
    });
    
    test('should not flag safe medications for adults', async () => {
      const medications = ['Paracetamol', 'Azithromycin'];
      const age = 35;
      
      const result = (patientSafetyService as any).checkAgeContraindications(
        medications,
        age
      );
      
      expect(result.hasContraindication).toBe(false);
    });
  });
  
  describe('Comprehensive Safety Checks', () => {
    
    test('should pass safety check for safe scenario', async () => {
      const suggestedMeds = ['Paracetamol'];
      const patientContext: PatientContext = {
        patientId: 'test-123',
        allergies: [],
        chronicConditions: [],
        currentMedications: [],
        age: 35,
        gender: 'male'
      };
      const disease = 'Common Cold';
      
      const result = await patientSafetyService.runSafetyChecks(
        suggestedMeds,
        patientContext,
        disease
      );
      
      expect(result.passed).toBe(true);
      expect(result.contraindications).toHaveLength(0);
      expect(result.riskLevel).toBe('low');
    });
    
    test('should fail safety check with allergy conflict', async () => {
      const suggestedMeds = ['Amoxicillin'];
      const patientContext: PatientContext = {
        patientId: 'test-123',
        allergies: ['Penicillin'],
        chronicConditions: [],
        currentMedications: [],
        age: 35,
        gender: 'male'
      };
      const disease = 'Bacterial infection';
      
      const result = await patientSafetyService.runSafetyChecks(
        suggestedMeds,
        patientContext,
        disease
      );
      
      expect(result.passed).toBe(false);
      expect(result.contraindications.length).toBeGreaterThan(0);
      expect(result.contraindications[0]).toContain('ALLERGY ALERT');
      expect(result.riskLevel).toBe('critical');
    });
    
    test('should detect multiple safety issues', async () => {
      const suggestedMeds = ['Amoxicillin', 'Aspirin'];
      const patientContext: PatientContext = {
        patientId: 'test-123',
        allergies: ['Penicillin'],
        chronicConditions: ['Diabetes'],
        currentMedications: ['Warfarin'],
        age: 35,
        gender: 'male'
      };
      const disease = 'Bacterial infection';
      
      const result = await patientSafetyService.runSafetyChecks(
        suggestedMeds,
        patientContext,
        disease
      );
      
      expect(result.passed).toBe(false);
      expect(result.contraindications.length).toBeGreaterThan(1);
      expect(result.warnings.length).toBeGreaterThan(0);
      expect(result.riskLevel).toBe('critical');
    });
    
    test('should provide adjusted recommendations', async () => {
      const suggestedMeds = ['Amoxicillin'];
      const patientContext: PatientContext = {
        patientId: 'test-123',
        allergies: ['Penicillin'],
        chronicConditions: [],
        currentMedications: [],
        age: 35,
        gender: 'male'
      };
      const disease = 'Bacterial infection';
      
      const result = await patientSafetyService.runSafetyChecks(
        suggestedMeds,
        patientContext,
        disease
      );
      
      expect(result.adjustedRecommendations.length).toBeGreaterThan(0);
      expect(result.adjustedRecommendations[0]).toContain('alternative');
    });
  });
  
  describe('Risk Level Determination', () => {
    
    test('should return critical for contraindications', () => {
      const riskLevel = (patientSafetyService as any).determineRiskLevel(1, 0);
      expect(riskLevel).toBe('critical');
    });
    
    test('should return high for multiple warnings', () => {
      const riskLevel = (patientSafetyService as any).determineRiskLevel(0, 3);
      expect(riskLevel).toBe('high');
    });
    
    test('should return medium for few warnings', () => {
      const riskLevel = (patientSafetyService as any).determineRiskLevel(0, 1);
      expect(riskLevel).toBe('medium');
    });
    
    test('should return low for no issues', () => {
      const riskLevel = (patientSafetyService as any).determineRiskLevel(0, 0);
      expect(riskLevel).toBe('low');
    });
  });
});
