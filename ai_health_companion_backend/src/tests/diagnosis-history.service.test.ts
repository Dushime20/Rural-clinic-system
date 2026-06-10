/**
 * Tests for DiagnosisHistoryService pattern detection methods
 * Validates Task 2.6: DiagnosisHistoryService extensions for pattern detection
 */

import { diagnosisHistoryService } from '../services/diagnosis-history.service';
import { AppDataSource } from '../database/data-source';
import { Diagnosis } from '../models/Diagnosis';
import { Patient, Gender, BloodType } from '../models/Patient';
import { User, UserRole } from '../models/User';

describe('DiagnosisHistoryService - Pattern Detection', () => {
  let testPatient: Patient;
  let testUser: User;
  let diagnosisRepository: any;
  let patientRepository: any;

  beforeAll(async () => {
    // Initialize database connection
    if (!AppDataSource.isInitialized) {
      await AppDataSource.initialize();
    }

    diagnosisRepository = AppDataSource.getRepository(Diagnosis);
    patientRepository = AppDataSource.getRepository(Patient);
  });

  beforeEach(async () => {
    // Clean up test data
    await diagnosisRepository.createQueryBuilder().delete().execute();
    await patientRepository.createQueryBuilder().delete().execute();
    await AppDataSource.getRepository(User).delete({ email: 'test@example.com' });

    // Create test user
    testUser = AppDataSource.getRepository(User).create({
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.HEALTH_WORKER,
      password: 'hashedpassword',
      phoneNumber: '1234567890',
      isActive: true,
      mustChangePassword: false
    });
    await AppDataSource.getRepository(User).save(testUser);

    // Create test patient
    testPatient = patientRepository.create({
      patientId: 'TEST-PAT-001',
      firstName: 'John',
      lastName: 'Doe',
      dateOfBirth: new Date('1990-01-01'),
      gender: Gender.MALE,
      bloodType: BloodType.O_POSITIVE,
      clinicId: 'clinic-001',
      createdById: testUser.id,
      chronicConditions: ['Diabetes', 'Hypertension']
    });
    await patientRepository.save(testPatient);
  });

  afterAll(async () => {
    // Clean up and close connection
    await diagnosisRepository.createQueryBuilder().delete().execute();
    await patientRepository.createQueryBuilder().delete().execute();
    await AppDataSource.getRepository(User).delete({ email: 'test@example.com' });
    
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
  });

  describe('detectRecurringDisease', () => {
    it('should detect recurring disease with 3+ occurrences in 90 days', async () => {
      const now = new Date();
      const diseaseName = 'Malaria';

      // Create 4 diagnoses within 90 days
      for (let i = 0; i < 4; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 20 * 24 * 60 * 60 * 1000); // 20 days apart
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'fever', category: 'general', severity: 'moderate' }],
          vitalSigns: { temperature: 38.5 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: diseaseName, confidence: 0.9 }],
          selectedDiagnosis: { disease: diseaseName, confidence: 0.9 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isRecurring).toBe(true);
      expect(result.occurrenceCount).toBe(4);
      expect(result.timeWindowDays).toBe(90);
      expect(result.firstOccurrence).toBeDefined();
      expect(result.lastOccurrence).toBeDefined();
    });

    it('should not detect recurring disease with only 2 occurrences', async () => {
      const now = new Date();
      const diseaseName = 'Flu';

      // Create 2 diagnoses
      for (let i = 0; i < 2; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 30 * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'cough', category: 'respiratory' }],
          vitalSigns: { temperature: 37.5 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: diseaseName, confidence: 0.85 }],
          selectedDiagnosis: { disease: diseaseName, confidence: 0.85 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isRecurring).toBe(false);
      expect(result.occurrenceCount).toBe(2);
    });

    it('should not detect recurring disease when occurrences are outside 90-day window', async () => {
      const now = new Date();
      const diseaseName = 'Typhoid';

      // Create 3 diagnoses outside 90-day window
      for (let i = 0; i < 3; i++) {
        const diagnosisDate = new Date(now.getTime() - (100 + i * 30) * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'fever', category: 'general' }],
          vitalSigns: { temperature: 39.0 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: diseaseName, confidence: 0.88 }],
          selectedDiagnosis: { disease: diseaseName, confidence: 0.88 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isRecurring).toBe(false);
      expect(result.occurrenceCount).toBe(0);
    });

    it('should match disease name case-insensitively', async () => {
      const now = new Date();

      // Create 3 diagnoses with different case variations
      const diseaseVariations = ['Malaria', 'malaria', 'MALARIA'];
      for (let i = 0; i < 3; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 20 * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'fever', category: 'general' }],
          vitalSigns: { temperature: 38.5 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: diseaseVariations[i], confidence: 0.9 }],
          selectedDiagnosis: { disease: diseaseVariations[i], confidence: 0.9 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        'malaria'
      );

      expect(result.isRecurring).toBe(true);
      expect(result.occurrenceCount).toBe(3);
    });

    it('should return empty result for non-existent patient', async () => {
      const result = await diagnosisHistoryService.detectRecurringDisease(
        'non-existent-patient',
        'Malaria'
      );

      expect(result.isRecurring).toBe(false);
      expect(result.occurrenceCount).toBe(0);
    });
  });

  describe('detectPersistentDisease', () => {
    it('should detect persistent disease active for more than 30 days', async () => {
      const now = new Date();
      const diseaseName = 'Tuberculosis';
      const oldDate = new Date(now.getTime() - 45 * 24 * 60 * 60 * 1000); // 45 days ago

      const diagnosis = diagnosisRepository.create({
        diagnosisId: 'DIAG-PERSISTENT',
        patientId: testPatient.id,
        performedById: testUser.id,
        clinicId: 'clinic-001',
        symptoms: [{ name: 'persistent cough', category: 'respiratory' }],
        vitalSigns: { temperature: 37.8 },
        patientAge: 30,
        patientGender: 'male',
        aiPredictions: [{ disease: diseaseName, confidence: 0.92 }],
        selectedDiagnosis: { disease: diseaseName, confidence: 0.92 },
        diagnosisDate: oldDate,
        followUpRequired: true
      });
      await diagnosisRepository.save(diagnosis);

      const result = await diagnosisHistoryService.detectPersistentDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isPersistent).toBe(true);
      expect(result.durationDays).toBeGreaterThanOrEqual(45);
      expect(result.firstActiveDiagnosis).toBeDefined();
      expect(result.status).toBe('active');
    });

    it('should not detect persistent disease when less than 30 days old', async () => {
      const now = new Date();
      const diseaseName = 'Common Cold';
      const recentDate = new Date(now.getTime() - 15 * 24 * 60 * 60 * 1000); // 15 days ago

      const diagnosis = diagnosisRepository.create({
        diagnosisId: 'DIAG-RECENT',
        patientId: testPatient.id,
        performedById: testUser.id,
        clinicId: 'clinic-001',
        symptoms: [{ name: 'cough', category: 'respiratory' }],
        vitalSigns: { temperature: 37.2 },
        patientAge: 30,
        patientGender: 'male',
        aiPredictions: [{ disease: diseaseName, confidence: 0.85 }],
        selectedDiagnosis: { disease: diseaseName, confidence: 0.85 },
        diagnosisDate: recentDate,
        followUpRequired: false
      });
      await diagnosisRepository.save(diagnosis);

      const result = await diagnosisHistoryService.detectPersistentDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isPersistent).toBe(false);
      expect(result.durationDays).toBe(0);
    });

    it('should not detect persistent disease when no historical diagnoses exist', async () => {
      const result = await diagnosisHistoryService.detectPersistentDisease(
        testPatient.id,
        'NonExistentDisease'
      );

      expect(result.isPersistent).toBe(false);
      expect(result.durationDays).toBe(0);
    });

    it('should match disease name case-insensitively for persistent detection', async () => {
      const now = new Date();
      const oldDate = new Date(now.getTime() - 40 * 24 * 60 * 60 * 1000);

      const diagnosis = diagnosisRepository.create({
        diagnosisId: 'DIAG-CASE-TEST',
        patientId: testPatient.id,
        performedById: testUser.id,
        clinicId: 'clinic-001',
        symptoms: [{ name: 'fever', category: 'general' }],
        vitalSigns: { temperature: 38.0 },
        patientAge: 30,
        patientGender: 'male',
        aiPredictions: [{ disease: 'Chronic Bronchitis', confidence: 0.87 }],
        selectedDiagnosis: { disease: 'Chronic Bronchitis', confidence: 0.87 },
        diagnosisDate: oldDate,
        followUpRequired: true
      });
      await diagnosisRepository.save(diagnosis);

      const result = await diagnosisHistoryService.detectPersistentDisease(
        testPatient.id,
        'chronic bronchitis'
      );

      expect(result.isPersistent).toBe(true);
    });
  });

  describe('matchesChronicCondition', () => {
    it('should match exact chronic condition name', async () => {
      const result = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Diabetes'
      );

      expect(result).toBe(true);
    });

    it('should match chronic condition with fuzzy matching at 80% threshold', async () => {
      // "Diabete" is similar to "Diabetes" (similarity ~85%)
      const result = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Diabete'
      );

      expect(result).toBe(true);
    });

    it('should match case-insensitively', async () => {
      const result = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'diabetes'
      );

      expect(result).toBe(true);
    });

    it('should not match dissimilar disease names', async () => {
      const result = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Malaria'
      );

      expect(result).toBe(false);
    });

    it('should return false when patient has no chronic conditions', async () => {
      // Create patient without chronic conditions
      const newPatient = patientRepository.create({
        patientId: 'TEST-PAT-002',
        firstName: 'Jane',
        lastName: 'Smith',
        dateOfBirth: new Date('1985-05-15'),
        gender: Gender.FEMALE,
        bloodType: BloodType.A_POSITIVE,
        clinicId: 'clinic-001',
        createdById: testUser.id,
        chronicConditions: []
      });
      await patientRepository.save(newPatient);

      const result = await diagnosisHistoryService.matchesChronicCondition(
        newPatient.id,
        'Diabetes'
      );

      expect(result).toBe(false);
    });

    it('should return false for non-existent patient', async () => {
      const result = await diagnosisHistoryService.matchesChronicCondition(
        'non-existent-patient',
        'Diabetes'
      );

      expect(result).toBe(false);
    });

    it('should match with partial names above 80% threshold', async () => {
      // Update patient with more specific chronic condition
      testPatient.chronicConditions = ['Type 2 Diabetes Mellitus'];
      await patientRepository.save(testPatient);

      // "Type 2 Diabetes" should match "Type 2 Diabetes Mellitus" with high similarity
      const result = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Type 2 Diabetes'
      );

      expect(result).toBe(true);
    });

    it('should check multiple chronic conditions', async () => {
      const diabetesMatch = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Diabetes'
      );

      const hypertensionMatch = await diagnosisHistoryService.matchesChronicCondition(
        testPatient.id,
        'Hypertension'
      );

      expect(diabetesMatch).toBe(true);
      expect(hypertensionMatch).toBe(true);
    });
  });

  describe('Edge Cases and Error Handling', () => {
    it('should handle database errors gracefully in detectRecurringDisease', async () => {
      // Temporarily break the connection by closing it
      if (AppDataSource.isInitialized) {
        await AppDataSource.destroy();
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        'Malaria'
      );

      expect(result.isRecurring).toBe(false);
      expect(result.occurrenceCount).toBe(0);

      // Reinitialize for other tests
      await AppDataSource.initialize();
    });

    it('should handle empty diagnosis history', async () => {
      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        'NonExistentDisease'
      );

      expect(result.isRecurring).toBe(false);
      expect(result.occurrenceCount).toBe(0);
      expect(result.firstOccurrence).toBeUndefined();
      expect(result.lastOccurrence).toBeUndefined();
    });

    it('should handle diagnoses with only aiPredictions (no selectedDiagnosis)', async () => {
      const now = new Date();
      const diseaseName = 'Dengue';

      // Create diagnoses with only aiPredictions
      for (let i = 0; i < 3; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 20 * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-AI-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'fever', category: 'general' }],
          vitalSigns: { temperature: 38.5 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: diseaseName, confidence: 0.9 }],
          // No selectedDiagnosis
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const result = await diagnosisHistoryService.detectRecurringDisease(
        testPatient.id,
        diseaseName
      );

      expect(result.isRecurring).toBe(true);
      expect(result.occurrenceCount).toBe(3);
    });
  });

  describe('getDiagnosisHistory', () => {
    it('should retrieve diagnosis history for a patient', async () => {
      const now = new Date();

      // Create 3 diagnoses
      for (let i = 0; i < 3; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 10 * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-HIST-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'fever', category: 'general' }],
          vitalSigns: { temperature: 38.0 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: 'Flu', confidence: 0.85 }],
          selectedDiagnosis: { disease: 'Flu', confidence: 0.85 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const history = await diagnosisHistoryService.getDiagnosisHistory(testPatient.id);

      expect(history).toHaveLength(3);
      expect(history[0].diagnosisDate.getTime()).toBeGreaterThan(history[1].diagnosisDate.getTime());
    });

    it('should limit diagnosis history results', async () => {
      const now = new Date();

      // Create 5 diagnoses
      for (let i = 0; i < 5; i++) {
        const diagnosisDate = new Date(now.getTime() - i * 5 * 24 * 60 * 60 * 1000);
        const diagnosis = diagnosisRepository.create({
          diagnosisId: `DIAG-LIMIT-${i}`,
          patientId: testPatient.id,
          performedById: testUser.id,
          clinicId: 'clinic-001',
          symptoms: [{ name: 'headache', category: 'general' }],
          vitalSigns: { temperature: 37.0 },
          patientAge: 30,
          patientGender: 'male',
          aiPredictions: [{ disease: 'Migraine', confidence: 0.8 }],
          selectedDiagnosis: { disease: 'Migraine', confidence: 0.8 },
          diagnosisDate,
          followUpRequired: false
        });
        await diagnosisRepository.save(diagnosis);
      }

      const history = await diagnosisHistoryService.getDiagnosisHistory(testPatient.id, 3);

      expect(history).toHaveLength(3);
    });
  });
});
