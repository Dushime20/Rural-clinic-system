/**
 * Property-Based Test: Geographic Coordinate Validation
 * 
 * Feature: clinic-specialized-recommendations
 * Property: Property 3 - Geographic Coordinate Validation
 * Validates: Requirements 1.5
 * 
 * For any clinic creation or update request, the system SHALL accept latitude 
 * values between -90 and 90 (inclusive) and longitude values between -180 and 
 * 180 (inclusive), and SHALL reject coordinates outside these ranges.
 */

import 'reflect-metadata';
import fc from 'fast-check';
import { DataSource } from 'typeorm';
import { Clinic } from '../models/Clinic';
import { ClinicSpecialty } from '../models/ClinicSpecialty';
import { User, UserRole } from '../models/User';

describe('Property 3: Geographic Coordinate Validation', () => {
  let dataSource: DataSource;

  beforeAll(async () => {
    // Load environment variables
    require('dotenv').config();
    
    // Parse DATABASE_TEST_URL
    const testDbUrl = process.env.DATABASE_TEST_URL || 'postgresql://postgres:1235@localhost:5432/ai_health_companion_test';
    const url = new URL(testDbUrl);
    
    dataSource = new DataSource({
      type: 'postgres',
      host: url.hostname,
      port: parseInt(url.port || '5432'),
      username: url.username,
      password: url.password,
      database: url.pathname.slice(1),
      entities: [Clinic, ClinicSpecialty, User],
      synchronize: true,
      dropSchema: true,
      logging: false,
    });

    await dataSource.initialize();
  }, 30000); // 30 second timeout for database connection

  afterAll(async () => {
    if (dataSource && dataSource.isInitialized) {
      await dataSource.destroy();
    }
  });

  beforeEach(async () => {
    // Clean up between tests - use query instead of clear to avoid FK issues
    await dataSource.query('TRUNCATE TABLE clinic_specialties, clinics, users RESTART IDENTITY CASCADE');
  });

  /**
   * Helper function to create a clinic user for testing
   */
  const createClinicUser = async (): Promise<User> => {
    const userRepo = dataSource.getRepository(User);
    const user = userRepo.create({
      email: `clinic-${Date.now()}@example.com`,
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'Clinic',
      mustChangePassword: false,
    });
    return await userRepo.save(user);
  };

  /**
   * Helper function to attempt creating a clinic with given coordinates
   */
  const attemptClinicCreation = async (
    latitude: number,
    longitude: number,
    managerId: string
  ): Promise<{ success: boolean; error?: string }> => {
    const clinicRepo = dataSource.getRepository(Clinic);
    
    try {
      const clinic = clinicRepo.create({
        managerId,
        name: 'Test Clinic',
        latitude,
        longitude,
        isActive: true,
      });

      await clinicRepo.save(clinic);
      return { success: true };
    } catch (error: any) {
      return {
        success: false,
        error: error.message || 'Unknown error',
      };
    }
  };

  describe('Valid Coordinate Acceptance', () => {
    test('should accept all valid coordinate combinations', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate valid latitudes: -90 to 90
          fc.double({ min: -90, max: 90, noNaN: true }),
          // Generate valid longitudes: -180 to 180
          fc.double({ min: -180, max: 180, noNaN: true }),
          async (latitude, longitude) => {
            // Create a unique user for this property test iteration
            const user = await createClinicUser();

            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: All valid coordinates MUST be accepted
            expect(result.success).toBe(true);
            expect(result.error).toBeUndefined();
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });

    test('should accept boundary values for latitude and longitude', async () => {
      const boundaryValues = [
        { lat: -90, lon: -180, desc: 'minimum latitude and longitude' },
        { lat: -90, lon: 180, desc: 'minimum latitude, maximum longitude' },
        { lat: 90, lon: -180, desc: 'maximum latitude, minimum longitude' },
        { lat: 90, lon: 180, desc: 'maximum latitude and longitude' },
        { lat: 0, lon: 0, desc: 'zero latitude and longitude' },
        { lat: -90, lon: 0, desc: 'minimum latitude, zero longitude' },
        { lat: 90, lon: 0, desc: 'maximum latitude, zero longitude' },
        { lat: 0, lon: -180, desc: 'zero latitude, minimum longitude' },
        { lat: 0, lon: 180, desc: 'zero latitude, maximum longitude' },
      ];

      for (const { lat, lon, desc } of boundaryValues) {
        const user = await createClinicUser();
        const result = await attemptClinicCreation(lat, lon, user.id);

        expect(result.success).toBe(true);
        expect(result.error).toBeUndefined();
      }
    });
  });

  describe('Invalid Coordinate Rejection', () => {
    test('should reject coordinates with latitude less than -90', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate invalid latitudes: < -90
          fc.double({ min: -200, max: -90.0001, noNaN: true }),
          // Generate valid longitudes
          fc.double({ min: -180, max: 180, noNaN: true }),
          async (latitude, longitude) => {
            const user = await createClinicUser();
            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: Latitudes < -90 MUST be rejected
            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error).toMatch(/constraint|check|latitude/i);
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });

    test('should reject coordinates with latitude greater than 90', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate invalid latitudes: > 90
          fc.double({ min: 90.0001, max: 200, noNaN: true }),
          // Generate valid longitudes
          fc.double({ min: -180, max: 180, noNaN: true }),
          async (latitude, longitude) => {
            const user = await createClinicUser();
            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: Latitudes > 90 MUST be rejected
            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error).toMatch(/constraint|check|latitude/i);
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });

    test('should reject coordinates with longitude less than -180', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate valid latitudes
          fc.double({ min: -90, max: 90, noNaN: true }),
          // Generate invalid longitudes: < -180
          fc.double({ min: -300, max: -180.0001, noNaN: true }),
          async (latitude, longitude) => {
            const user = await createClinicUser();
            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: Longitudes < -180 MUST be rejected
            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error).toMatch(/constraint|check|longitude/i);
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });

    test('should reject coordinates with longitude greater than 180', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate valid latitudes
          fc.double({ min: -90, max: 90, noNaN: true }),
          // Generate invalid longitudes: > 180
          fc.double({ min: 180.0001, max: 300, noNaN: true }),
          async (latitude, longitude) => {
            const user = await createClinicUser();
            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: Longitudes > 180 MUST be rejected
            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error).toMatch(/constraint|check|longitude/i);
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });

    test('should reject coordinates with both invalid latitude and longitude', async () => {
      await fc.assert(
        fc.asyncProperty(
          fc.oneof(
            // Invalid latitude cases
            fc.double({ min: -200, max: -90.0001, noNaN: true }),
            fc.double({ min: 90.0001, max: 200, noNaN: true })
          ),
          fc.oneof(
            // Invalid longitude cases
            fc.double({ min: -300, max: -180.0001, noNaN: true }),
            fc.double({ min: 180.0001, max: 300, noNaN: true })
          ),
          async (latitude, longitude) => {
            const user = await createClinicUser();
            const result = await attemptClinicCreation(
              latitude,
              longitude,
              user.id
            );

            // Property: Invalid combinations MUST be rejected
            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error).toMatch(/constraint|check/i);
          }
        ),
        { numRuns: 100, verbose: true }
      );
    });
  });

  describe('Coordinate Update Validation', () => {
    test('should accept valid coordinate updates', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Initial valid coordinates
          fc.double({ min: -90, max: 90, noNaN: true }),
          fc.double({ min: -180, max: 180, noNaN: true }),
          // Updated valid coordinates
          fc.double({ min: -90, max: 90, noNaN: true }),
          fc.double({ min: -180, max: 180, noNaN: true }),
          async (
            initialLat,
            initialLon,
            updatedLat,
            updatedLon
          ) => {
            const user = await createClinicUser();
            const clinicRepo = dataSource.getRepository(Clinic);

            // Create clinic with initial coordinates
            const clinic = clinicRepo.create({
              managerId: user.id,
              name: 'Test Clinic',
              latitude: initialLat,
              longitude: initialLon,
              isActive: true,
            });
            await clinicRepo.save(clinic);

            // Update with new valid coordinates
            clinic.latitude = updatedLat;
            clinic.longitude = updatedLon;

            let success = true;
            let error: string | undefined;

            try {
              await clinicRepo.save(clinic);
            } catch (e: any) {
              success = false;
              error = e.message;
            }

            // Property: Valid coordinate updates MUST succeed
            expect(success).toBe(true);
            expect(error).toBeUndefined();
          }
        ),
        { numRuns: 50, verbose: true }
      );
    });

    test('should reject invalid coordinate updates', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Initial valid coordinates
          fc.double({ min: -90, max: 90, noNaN: true }),
          fc.double({ min: -180, max: 180, noNaN: true }),
          // Invalid update coordinates
          fc.oneof(
            fc.record({
              latitude: fc.oneof(
                fc.double({ min: -200, max: -90.0001, noNaN: true }),
                fc.double({ min: 90.0001, max: 200, noNaN: true })
              ),
              longitude: fc.double({ min: -180, max: 180, noNaN: true }),
            }),
            fc.record({
              latitude: fc.double({ min: -90, max: 90, noNaN: true }),
              longitude: fc.oneof(
                fc.double({ min: -300, max: -180.0001, noNaN: true }),
                fc.double({ min: 180.0001, max: 300, noNaN: true })
              ),
            })
          ),
          async (initialLat, initialLon, invalidCoords) => {
            const user = await createClinicUser();
            const clinicRepo = dataSource.getRepository(Clinic);

            // Create clinic with initial valid coordinates
            const clinic = clinicRepo.create({
              managerId: user.id,
              name: 'Test Clinic',
              latitude: initialLat,
              longitude: initialLon,
              isActive: true,
            });
            await clinicRepo.save(clinic);

            // Attempt to update with invalid coordinates
            clinic.latitude = invalidCoords.latitude;
            clinic.longitude = invalidCoords.longitude;

            let success = true;
            let error: string | undefined;

            try {
              await clinicRepo.save(clinic);
            } catch (e: any) {
              success = false;
              error = e.message;
            }

            // Property: Invalid coordinate updates MUST be rejected
            expect(success).toBe(false);
            expect(error).toBeDefined();
            expect(error).toMatch(/constraint|check/i);
          }
        ),
        { numRuns: 50, verbose: true }
      );
    });
  });
});
