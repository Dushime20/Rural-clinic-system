/**
 * Structure Tests for ClinicService
 * Verifies that the service has all required methods and interfaces
 */

import { describe, it, expect } from '@jest/globals';
import { clinicService } from '../services/clinic.service';

describe('ClinicService Structure', () => {
  it('should export a singleton instance', () => {
    expect(clinicService).toBeDefined();
    expect(typeof clinicService).toBe('object');
  });

  it('should have createClinic method', () => {
    expect(clinicService.createClinic).toBeDefined();
    expect(typeof clinicService.createClinic).toBe('function');
  });

  it('should have updateClinic method', () => {
    expect(clinicService.updateClinic).toBeDefined();
    expect(typeof clinicService.updateClinic).toBe('function');
  });

  it('should have getClinicById method', () => {
    expect(clinicService.getClinicById).toBeDefined();
    expect(typeof clinicService.getClinicById).toBe('function');
  });

  it('should have getClinicByManagerId method', () => {
    expect(clinicService.getClinicByManagerId).toBeDefined();
    expect(typeof clinicService.getClinicByManagerId).toBe('function');
  });

  it('should have listClinics method', () => {
    expect(clinicService.listClinics).toBeDefined();
    expect(typeof clinicService.listClinics).toBe('function');
  });

  it('should have updateClinicStatus method', () => {
    expect(clinicService.updateClinicStatus).toBeDefined();
    expect(typeof clinicService.updateClinicStatus).toBe('function');
  });

  it('should have updateClinicSpecialties method', () => {
    expect(clinicService.updateClinicSpecialties).toBeDefined();
    expect(typeof clinicService.updateClinicSpecialties).toBe('function');
  });
});
