/**
 * Unit Tests for ClinicService
 * Tests CRUD operations for clinic management
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach } from '@jest/globals';
import { AppDataSource } from '../database/data-source';
import { clinicService } from '../services/clinic.service';
import { MedicalSpecialty } from '../models/ClinicSpecialty';
import { User, UserRole } from '../models/User';
import { Clinic } from '../models/Clinic';

describe('ClinicService', () => {
  beforeAll(async () => {
    // Initialize database connection for tests
    if (!AppDataSource.isInitialized) {
      await AppDataSource.initialize();
    }
  });

  afterAll(async () => {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
  });

  beforeEach(async () => {
    // Clean up test data before each test
    const clinicRepo = AppDataSource.getRepository(Clinic);
    const userRepo = AppDataSource.getRepository(User);
    
    const testClinics = await clinicRepo.find({
      where: { email: 'test@clinic.com' } as any
    });
    
    for (const clinic of testClinics) {
      await clinicRepo.remove(clinic);
    }
    
    const testUsers = await userRepo.find({
      where: { email: 'test@clinic.com' }
    });
    
    for (const user of testUsers) {
      await userRepo.remove(user);
    }
  });

  describe('createClinic', () => {
    it('should create a clinic with valid input', async () => {
      const input = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        phoneNumber: '+250788123456',
        address: '123 Test Street',
        city: 'Kigali',
        district: 'Gasabo',
        country: 'Rwanda',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.CARDIOLOGY, MedicalSpecialty.GENERAL_MEDICINE]
      };

      const result = await clinicService.createClinic(input);

      expect(result).toBeDefined();
      expect(result.user).toBeDefined();
      expect(result.user.email).toBe(input.email);
      expect(result.user.role).toBe(UserRole.CLINIC);
      expect(result.user.mustChangePassword).toBe(true);
      expect(result.clinic).toBeDefined();
      expect(result.clinic.name).toBe(input.name);
      expect(result.clinic.latitude).toBe(input.latitude);
      expect(result.clinic.longitude).toBe(input.longitude);
      expect(result.temporaryPassword).toBeDefined();
      expect(result.temporaryPassword.length).toBe(12);
      expect(result.clinic.specialties).toBeDefined();
      expect(result.clinic.specialties.length).toBe(2);
    });

    it('should reject invalid latitude', async () => {
      const input = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test2@clinic.com',
        latitude: 95, // Invalid: must be between -90 and 90
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      await expect(clinicService.createClinic(input)).rejects.toThrow(
        'Latitude must be between -90 and 90'
      );
    });

    it('should reject invalid longitude', async () => {
      const input = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test3@clinic.com',
        latitude: -1.9441,
        longitude: 185, // Invalid: must be between -180 and 180
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      await expect(clinicService.createClinic(input)).rejects.toThrow(
        'Longitude must be between -180 and 180'
      );
    });

    it('should reject empty specialties array', async () => {
      const input = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test4@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [] // Invalid: at least one specialty required
      };

      await expect(clinicService.createClinic(input)).rejects.toThrow(
        'At least one specialty is required'
      );
    });

    it('should reject duplicate email', async () => {
      const input = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      // Create first clinic
      await clinicService.createClinic(input);

      // Try to create second clinic with same email
      await expect(clinicService.createClinic(input)).rejects.toThrow(
        'User with this email already exists'
      );
    });
  });

  describe('updateClinic', () => {
    it('should update clinic profile', async () => {
      // Create a clinic first
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      const created = await clinicService.createClinic(createInput);

      // Update the clinic
      const updateInput = {
        name: 'Updated Clinic Name',
        phoneNumber: '+250788999888',
        city: 'Kigali'
      };

      const updated = await clinicService.updateClinic(created.clinic.id, updateInput);

      expect(updated.name).toBe(updateInput.name);
      expect(updated.phoneNumber).toBe(updateInput.phoneNumber);
      expect(updated.city).toBe(updateInput.city);
    });

    it('should reject invalid latitude on update', async () => {
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      const created = await clinicService.createClinic(createInput);

      const updateInput = {
        latitude: 100 // Invalid
      };

      await expect(
        clinicService.updateClinic(created.clinic.id, updateInput)
      ).rejects.toThrow('Latitude must be between -90 and 90');
    });
  });

  describe('getClinicById', () => {
    it('should retrieve clinic by ID', async () => {
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.CARDIOLOGY]
      };

      const created = await clinicService.createClinic(createInput);
      const retrieved = await clinicService.getClinicById(created.clinic.id);

      expect(retrieved).toBeDefined();
      expect(retrieved!.id).toBe(created.clinic.id);
      expect(retrieved!.name).toBe(createInput.name);
      expect(retrieved!.specialties.length).toBe(1);
    });

    it('should return null for non-existent ID', async () => {
      const retrieved = await clinicService.getClinicById('00000000-0000-0000-0000-000000000000');
      expect(retrieved).toBeNull();
    });
  });

  describe('listClinics', () => {
    it('should list clinics with pagination', async () => {
      // Create multiple clinics
      for (let i = 0; i < 3; i++) {
        await clinicService.createClinic({
          name: `Test Clinic ${i}`,
          managerName: 'Test Manager',
          email: `test${i}@clinic.com`,
          latitude: -1.9441,
          longitude: 30.0619,
          specialties: [MedicalSpecialty.GENERAL_MEDICINE]
        });
      }

      const result = await clinicService.listClinics({ page: 1, limit: 10 });

      expect(result.clinics.length).toBeGreaterThanOrEqual(3);
      expect(result.pagination.page).toBe(1);
      expect(result.pagination.limit).toBe(10);
      expect(result.pagination.total).toBeGreaterThanOrEqual(3);
    });

    it('should filter by specialty', async () => {
      await clinicService.createClinic({
        name: 'Cardiology Clinic',
        managerName: 'Test Manager',
        email: 'cardio@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.CARDIOLOGY]
      });

      const result = await clinicService.listClinics({
        specialty: MedicalSpecialty.CARDIOLOGY
      });

      expect(result.clinics.length).toBeGreaterThan(0);
      const hasCardiology = result.clinics.every(clinic =>
        clinic.specialties.some(s => s.specialty === MedicalSpecialty.CARDIOLOGY)
      );
      expect(hasCardiology).toBe(true);
    });
  });

  describe('updateClinicStatus', () => {
    it('should activate and deactivate clinic', async () => {
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      const created = await clinicService.createClinic(createInput);
      expect(created.clinic.isActive).toBe(true);

      // Deactivate
      const deactivated = await clinicService.updateClinicStatus(created.clinic.id, false);
      expect(deactivated.isActive).toBe(false);

      // Reactivate
      const reactivated = await clinicService.updateClinicStatus(created.clinic.id, true);
      expect(reactivated.isActive).toBe(true);
    });
  });

  describe('updateClinicSpecialties', () => {
    it('should update clinic specialties', async () => {
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      const created = await clinicService.createClinic(createInput);

      const newSpecialties = [
        MedicalSpecialty.CARDIOLOGY,
        MedicalSpecialty.ENDOCRINOLOGY
      ];

      const updated = await clinicService.updateClinicSpecialties(
        created.clinic.id,
        newSpecialties
      );

      expect(updated.specialties.length).toBe(2);
      const specialtyValues = updated.specialties.map(s => s.specialty);
      expect(specialtyValues).toContain(MedicalSpecialty.CARDIOLOGY);
      expect(specialtyValues).toContain(MedicalSpecialty.ENDOCRINOLOGY);
    });

    it('should reject empty specialties array', async () => {
      const createInput = {
        name: 'Test Clinic',
        managerName: 'John Doe',
        email: 'test@clinic.com',
        latitude: -1.9441,
        longitude: 30.0619,
        specialties: [MedicalSpecialty.GENERAL_MEDICINE]
      };

      const created = await clinicService.createClinic(createInput);

      await expect(
        clinicService.updateClinicSpecialties(created.clinic.id, [])
      ).rejects.toThrow('At least one specialty is required');
    });
  });
});
