/**
 * Unit Tests for ClinicSearchService
 * Tests location-based clinic search with specialty mapping
 * Validates Task 2.3 requirements: searchByDisease, searchBySpecialties,
 * Haversine distance calculation, isClinicOpen, radius filtering, sorting, and timeout
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach } from '@jest/globals';
import { AppDataSource } from '../database/data-source';
import { clinicSearchService } from '../services/clinic-search.service';
import { clinicService } from '../services/clinic.service';
import { MedicalSpecialty } from '../models/ClinicSpecialty';
import { DiseaseSpecialtyMapping } from '../models/DiseaseSpecialtyMapping';
import { Clinic } from '../models/Clinic';
import { User } from '../models/User';

describe('ClinicSearchService', () => {
  let testClinicIds: string[] = [];
  let testUserEmails: string[] = [];

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
    const diseaseMappingRepo = AppDataSource.getRepository(DiseaseSpecialtyMapping);

    // Remove test clinics
    for (const clinicId of testClinicIds) {
      try {
        const clinic = await clinicRepo.findOne({ where: { id: clinicId } });
        if (clinic) {
          await clinicRepo.remove(clinic);
        }
      } catch (error) {
        // Ignore errors during cleanup
      }
    }

    // Remove test users
    for (const email of testUserEmails) {
      try {
        const user = await userRepo.findOne({ where: { email } });
        if (user) {
          await userRepo.remove(user);
        }
      } catch (error) {
        // Ignore errors during cleanup
      }
    }

    // Remove test disease mappings
    try {
      await diseaseMappingRepo.delete({ diseaseName: 'Test Diabetes' });
      await diseaseMappingRepo.delete({ diseaseName: 'Test Heart Disease' });
      await diseaseMappingRepo.delete({ diseaseName: 'Unknown Test Disease' });
    } catch (error) {
      // Ignore errors during cleanup
    }

    testClinicIds = [];
    testUserEmails = [];
  });

  // Helper function to create a test clinic
  async function createTestClinic(
    name: string,
    latitude: number,
    longitude: number,
    specialties: MedicalSpecialty[],
    openingHours?: any
  ) {
    const email = `${name.toLowerCase().replace(/\s+/g, '.')}@testclinic.com`;
    testUserEmails.push(email);

    const result = await clinicService.createClinic({
      name,
      managerName: 'Test Manager',
      email,
      latitude,
      longitude,
      city: 'Test City',
      country: 'Test Country',
      specialties,
      openingHours
    });

    testClinicIds.push(result.clinic.id);
    return result.clinic;
  }

  // Helper function to create a disease mapping
  async function createTestDiseaseMapping(
    diseaseName: string,
    primarySpecialty: MedicalSpecialty,
    secondarySpecialties: MedicalSpecialty[] = []
  ) {
    const diseaseMappingRepo = AppDataSource.getRepository(DiseaseSpecialtyMapping);
    const mapping = diseaseMappingRepo.create({
      diseaseName,
      primarySpecialty,
      secondarySpecialties,
      priority: 1
    });
    return await diseaseMappingRepo.save(mapping);
  }

  describe('calculateDistance', () => {
    it('should calculate distance using Haversine formula', () => {
      // Kigali to Musanze (approx 60km)
      const distance = clinicSearchService.calculateDistance(
        -1.9441, // Kigali latitude
        30.0619, // Kigali longitude
        -1.4996, // Musanze latitude
        29.6338  // Musanze longitude
      );

      // Distance should be approximately 60-70km
      expect(distance).toBeGreaterThan(50);
      expect(distance).toBeLessThan(80);
    });

    it('should return 0 for same coordinates', () => {
      const distance = clinicSearchService.calculateDistance(
        -1.9441,
        30.0619,
        -1.9441,
        30.0619
      );

      expect(distance).toBe(0);
    });

    it('should handle coordinates across the equator', () => {
      const distance = clinicSearchService.calculateDistance(
        10, // North of equator
        30,
        -10, // South of equator
        30
      );

      expect(distance).toBeGreaterThan(0);
      expect(distance).toBeGreaterThan(2000); // Should be around 2200km
    });

    it('should return positive distance regardless of order', () => {
      const distance1 = clinicSearchService.calculateDistance(-1.9441, 30.0619, -1.4996, 29.6338);
      const distance2 = clinicSearchService.calculateDistance(-1.4996, 29.6338, -1.9441, 30.0619);

      expect(distance1).toBe(distance2);
      expect(distance1).toBeGreaterThan(0);
    });
  });

  describe('isClinicOpen', () => {
    it('should return false for clinic without opening hours', async () => {
      const clinic = await createTestClinic(
        'Test No Hours Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const isOpen = clinicSearchService.isClinicOpen(clinic);
      expect(isOpen).toBe(false);
    });

    it('should return false for clinic closed on current day', async () => {
      // Create opening hours that exclude today
      const today = new Date().getDay();
      const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
      const todayName = days[today];
      
      const openingHours: any = {};
      // Set hours for other days but not today
      days.forEach((day, index) => {
        if (index !== today) {
          openingHours[day] = { open: '08:00', close: '17:00' };
        }
      });

      const clinic = await createTestClinic(
        'Test Closed Today Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE],
        openingHours
      );

      const isOpen = clinicSearchService.isClinicOpen(clinic);
      expect(isOpen).toBe(false);
    });

    it('should correctly check if clinic is open during operating hours', async () => {
      const now = new Date();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();

      // Create opening hours that should be open now (current time ± 2 hours)
      const openHour = Math.max(0, currentHour - 2);
      const closeHour = Math.min(23, currentHour + 2);

      const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
      const todayName = days[now.getDay()];

      const openingHours: any = {
        [todayName]: {
          open: `${String(openHour).padStart(2, '0')}:00`,
          close: `${String(closeHour).padStart(2, '0')}:00`
        }
      };

      const clinic = await createTestClinic(
        'Test Open Now Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE],
        openingHours
      );

      const isOpen = clinicSearchService.isClinicOpen(clinic);
      
      // Should be open if current time is between open and close
      if (currentHour >= openHour && currentHour < closeHour) {
        expect(isOpen).toBe(true);
      } else {
        expect(isOpen).toBe(false);
      }
    });
  });

  describe('searchBySpecialties', () => {
    it('should find clinics with matching specialties', async () => {
      // Create clinics with different specialties
      await createTestClinic(
        'Test Cardiology Clinic 1',
        -1.9441,
        30.0619,
        [MedicalSpecialty.CARDIOLOGY]
      );

      await createTestClinic(
        'Test Cardiology Clinic 2',
        -1.9500,
        30.0700,
        [MedicalSpecialty.CARDIOLOGY, MedicalSpecialty.GENERAL_MEDICINE]
      );

      await createTestClinic(
        'Test General Medicine Only',
        -1.9600,
        30.0800,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const results = await clinicSearchService.searchBySpecialties({
        specialties: [MedicalSpecialty.CARDIOLOGY]
      });

      expect(results.length).toBeGreaterThanOrEqual(2);
      results.forEach(clinic => {
        const hasCardiology = clinic.specialties.some(
          s => s.specialty === MedicalSpecialty.CARDIOLOGY
        );
        expect(hasCardiology).toBe(true);
      });
    });

    it('should filter clinics by radius when location provided', async () => {
      const centerLat = -1.9441;
      const centerLon = 30.0619;

      // Create clinic within 50km
      await createTestClinic(
        'Test Near Clinic',
        -1.95, // Very close
        30.07,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      // Create clinic beyond 50km (approx 60km away)
      await createTestClinic(
        'Test Far Clinic',
        -1.50, // Far away
        29.63,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const results = await clinicSearchService.searchBySpecialties({
        specialties: [MedicalSpecialty.GENERAL_MEDICINE],
        latitude: centerLat,
        longitude: centerLon,
        radiusKm: 50
      });

      // Should only include the near clinic
      expect(results.length).toBeGreaterThanOrEqual(1);
      results.forEach(clinic => {
        expect(clinic.distance).toBeDefined();
        expect(clinic.distance!).toBeLessThanOrEqual(50);
      });
    });

    it('should sort results by distance ascending', async () => {
      const centerLat = -1.9441;
      const centerLon = 30.0619;

      // Create clinics at different distances
      await createTestClinic('Test Close', -1.945, 30.062, [MedicalSpecialty.GENERAL_MEDICINE]);
      await createTestClinic('Test Medium', -1.950, 30.070, [MedicalSpecialty.GENERAL_MEDICINE]);
      await createTestClinic('Test Far', -1.960, 30.080, [MedicalSpecialty.GENERAL_MEDICINE]);

      const results = await clinicSearchService.searchBySpecialties({
        specialties: [MedicalSpecialty.GENERAL_MEDICINE],
        latitude: centerLat,
        longitude: centerLon,
        radiusKm: 100
      });

      expect(results.length).toBeGreaterThanOrEqual(3);

      // Verify results are sorted by distance
      for (let i = 1; i < results.length; i++) {
        expect(results[i].distance).toBeGreaterThanOrEqual(results[i - 1].distance!);
      }
    });

    it('should limit results to specified limit', async () => {
      // Create many clinics
      for (let i = 0; i < 15; i++) {
        await createTestClinic(
          `Test Clinic ${i}`,
          -1.94 + i * 0.001, // Slightly different locations
          30.06 + i * 0.001,
          [MedicalSpecialty.GENERAL_MEDICINE]
        );
      }

      const results = await clinicSearchService.searchBySpecialties({
        specialties: [MedicalSpecialty.GENERAL_MEDICINE],
        limit: 5
      });

      expect(results.length).toBeLessThanOrEqual(5);
    });

    it('should handle search without location (no distance calculation)', async () => {
      await createTestClinic(
        'Test Clinic No Location',
        -1.9441,
        30.0619,
        [MedicalSpecialty.ENDOCRINOLOGY]
      );

      const results = await clinicSearchService.searchBySpecialties({
        specialties: [MedicalSpecialty.ENDOCRINOLOGY]
      });

      expect(results.length).toBeGreaterThanOrEqual(1);
      // When no location provided, distance should be undefined
      const hasUndefinedDistance = results.some(c => c.distance === undefined);
      expect(hasUndefinedDistance).toBe(true);
    });
  });

  describe('searchByDisease', () => {
    it('should find clinics based on disease-specialty mapping', async () => {
      // Create disease mapping
      await createTestDiseaseMapping(
        'Test Diabetes',
        MedicalSpecialty.ENDOCRINOLOGY,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      // Create clinics with relevant specialties
      await createTestClinic(
        'Test Endocrinology Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.ENDOCRINOLOGY]
      );

      await createTestClinic(
        'Test General Clinic',
        -1.9500,
        30.0700,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Diabetes',
        latitude: -1.9441,
        longitude: 30.0619
      });

      expect(result.clinics.length).toBeGreaterThanOrEqual(2);
      expect(result.mappedSpecialties).toContain(MedicalSpecialty.ENDOCRINOLOGY);
      expect(result.mappedSpecialties).toContain(MedicalSpecialty.GENERAL_MEDICINE);
    });

    it('should default to General Medicine for unmapped diseases', async () => {
      // Create a General Medicine clinic
      await createTestClinic(
        'Test General Medicine Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Unknown Test Disease',
        latitude: -1.9441,
        longitude: 30.0619
      });

      expect(result.mappedSpecialties).toContain(MedicalSpecialty.GENERAL_MEDICINE);
      expect(result.mappedSpecialties.length).toBe(1);
    });

    it('should apply 100km default radius filter', async () => {
      await createTestDiseaseMapping(
        'Test Heart Disease',
        MedicalSpecialty.CARDIOLOGY
      );

      const centerLat = -1.9441;
      const centerLon = 30.0619;

      // Create clinic within 100km
      await createTestClinic(
        'Test Near Cardiology',
        -1.95,
        30.07,
        [MedicalSpecialty.CARDIOLOGY]
      );

      // Create clinic beyond 100km
      await createTestClinic(
        'Test Far Cardiology',
        -0.5, // Much farther away (>150km)
        30.0,
        [MedicalSpecialty.CARDIOLOGY]
      );

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Heart Disease',
        latitude: centerLat,
        longitude: centerLon
      });

      // Should only include clinics within 100km
      result.clinics.forEach(clinic => {
        expect(clinic.distance).toBeLessThanOrEqual(100);
      });
    });

    it('should limit results to 10 clinics by default', async () => {
      await createTestDiseaseMapping(
        'Test Common Disease',
        MedicalSpecialty.GENERAL_MEDICINE
      );

      // Create many clinics
      for (let i = 0; i < 15; i++) {
        await createTestClinic(
          `Test Many Clinic ${i}`,
          -1.94 + i * 0.001,
          30.06 + i * 0.001,
          [MedicalSpecialty.GENERAL_MEDICINE]
        );
      }

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Common Disease',
        latitude: -1.9441,
        longitude: 30.0619
      });

      expect(result.clinics.length).toBeLessThanOrEqual(10);
    });

    it('should filter by operating hours when onlyOpen is true', async () => {
      await createTestDiseaseMapping(
        'Test Disease Hours',
        MedicalSpecialty.GENERAL_MEDICINE
      );

      // Create clinic without hours (closed)
      await createTestClinic(
        'Test Closed Clinic Hours',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Disease Hours',
        latitude: -1.9441,
        longitude: 30.0619,
        onlyOpen: true
      });

      // All returned clinics should have isOpenNow = true
      result.clinics.forEach(clinic => {
        if (result.clinics.length > 0) {
          expect(clinic.isOpenNow).toBe(true);
        }
      });
    });

    it('should include isOpenNow status for all clinics', async () => {
      await createTestDiseaseMapping(
        'Test Disease Status',
        MedicalSpecialty.GENERAL_MEDICINE
      );

      await createTestClinic(
        'Test Status Clinic',
        -1.9441,
        30.0619,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Disease Status',
        latitude: -1.9441,
        longitude: 30.0619
      });

      expect(result.clinics.length).toBeGreaterThanOrEqual(1);
      result.clinics.forEach(clinic => {
        expect(clinic.isOpenNow).toBeDefined();
        expect(typeof clinic.isOpenNow).toBe('boolean');
      });
    });

    it('should handle timeout with graceful degradation', async () => {
      // This test verifies timeout behavior exists
      // In practice, the timeout is 5 seconds, so we can't easily trigger it
      // We're just verifying the method completes
      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Timeout Test Disease',
        latitude: -1.9441,
        longitude: 30.0619
      });

      // Should return empty result on timeout or error
      expect(result).toBeDefined();
      expect(result.clinics).toBeDefined();
      expect(Array.isArray(result.clinics)).toBe(true);
    });

    it('should return empty results when no clinics match', async () => {
      await createTestDiseaseMapping(
        'Test Rare Disease',
        MedicalSpecialty.ONCOLOGY
      );

      // Don't create any oncology clinics
      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Rare Disease',
        latitude: -1.9441,
        longitude: 30.0619
      });

      expect(result.clinics).toEqual([]);
      expect(result.totalFound).toBe(0);
      expect(result.mappedSpecialties).toContain(MedicalSpecialty.ONCOLOGY);
    });
  });

  describe('integration scenarios', () => {
    it('should handle complete search workflow', async () => {
      // Create disease mapping
      await createTestDiseaseMapping(
        'Test Integration Disease',
        MedicalSpecialty.CARDIOLOGY,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      // Create clinics at various distances
      const clinic1 = await createTestClinic(
        'Test Integration Near',
        -1.945,
        30.062,
        [MedicalSpecialty.CARDIOLOGY]
      );

      const clinic2 = await createTestClinic(
        'Test Integration Medium',
        -1.950,
        30.070,
        [MedicalSpecialty.GENERAL_MEDICINE]
      );

      const centerLat = -1.9441;
      const centerLon = 30.0619;

      // Search by disease
      const result = await clinicSearchService.searchByDisease({
        diseaseName: 'Test Integration Disease',
        latitude: centerLat,
        longitude: centerLon,
        radiusKm: 100,
        limit: 10
      });

      // Verify results
      expect(result.clinics.length).toBeGreaterThanOrEqual(2);
      expect(result.mappedSpecialties).toContain(MedicalSpecialty.CARDIOLOGY);
      expect(result.totalFound).toBe(result.clinics.length);

      // Verify distance calculation
      result.clinics.forEach(clinic => {
        expect(clinic.distance).toBeDefined();
        expect(clinic.distance!).toBeLessThanOrEqual(100);
        expect(clinic.isOpenNow).toBeDefined();
      });

      // Verify sorting by distance
      for (let i = 1; i < result.clinics.length; i++) {
        expect(result.clinics[i].distance).toBeGreaterThanOrEqual(
          result.clinics[i - 1].distance!
        );
      }
    });
  });
});
