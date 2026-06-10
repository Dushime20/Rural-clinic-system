/**
 * Simple test to verify database connection and coordinate validation
 */

import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { Clinic } from '../models/Clinic';
import { ClinicSpecialty } from '../models/ClinicSpecialty';
import { User, UserRole } from '../models/User';

describe('Simple Coordinate Validation Test', () => {
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
      database: url.pathname.slice(1), // Remove leading slash
      entities: [Clinic, ClinicSpecialty, User],
      synchronize: true,
      dropSchema: true,
      logging: false,
    });

    await dataSource.initialize();
  }, 30000);

  afterAll(async () => {
    if (dataSource && dataSource.isInitialized) {
      await dataSource.destroy();
    }
  });

  test('should connect to database', async () => {
    expect(dataSource.isInitialized).toBe(true);
  });

  test('should accept valid coordinates', async () => {
    const userRepo = dataSource.getRepository(User);
    const clinicRepo = dataSource.getRepository(Clinic);

    const user = userRepo.create({
      email: 'test@example.com',
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'User',
    });
    await userRepo.save(user);

    const clinic = clinicRepo.create({
      managerId: user.id,
      name: 'Test Clinic',
      latitude: 45.5,
      longitude: -73.5,
      isActive: true,
    });

    await expect(clinicRepo.save(clinic)).resolves.toBeDefined();
  });

  test('should reject invalid latitude (< -90)', async () => {
    const userRepo = dataSource.getRepository(User);
    const clinicRepo = dataSource.getRepository(Clinic);

    const user = userRepo.create({
      email: 'test2@example.com',
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'User',
    });
    await userRepo.save(user);

    const clinic = clinicRepo.create({
      managerId: user.id,
      name: 'Test Clinic',
      latitude: -95,
      longitude: -73.5,
      isActive: true,
    });

    await expect(clinicRepo.save(clinic)).rejects.toThrow();
  });

  test('should reject invalid latitude (> 90)', async () => {
    const userRepo = dataSource.getRepository(User);
    const clinicRepo = dataSource.getRepository(Clinic);

    const user = userRepo.create({
      email: 'test3@example.com',
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'User',
    });
    await userRepo.save(user);

    const clinic = clinicRepo.create({
      managerId: user.id,
      name: 'Test Clinic',
      latitude: 95,
      longitude: -73.5,
      isActive: true,
    });

    await expect(clinicRepo.save(clinic)).rejects.toThrow();
  });

  test('should reject invalid longitude (< -180)', async () => {
    const userRepo = dataSource.getRepository(User);
    const clinicRepo = dataSource.getRepository(Clinic);

    const user = userRepo.create({
      email: 'test4@example.com',
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'User',
    });
    await userRepo.save(user);

    const clinic = clinicRepo.create({
      managerId: user.id,
      name: 'Test Clinic',
      latitude: 45.5,
      longitude: -185,
      isActive: true,
    });

    await expect(clinicRepo.save(clinic)).rejects.toThrow();
  });

  test('should reject invalid longitude (> 180)', async () => {
    const userRepo = dataSource.getRepository(User);
    const clinicRepo = dataSource.getRepository(Clinic);

    const user = userRepo.create({
      email: 'test5@example.com',
      password: 'hashedPassword123',
      role: UserRole.CLINIC,
      firstName: 'Test',
      lastName: 'User',
    });
    await userRepo.save(user);

    const clinic = clinicRepo.create({
      managerId: user.id,
      name: 'Test Clinic',
      latitude: 45.5,
      longitude: 185,
      isActive: true,
    });

    await expect(clinicRepo.save(clinic)).rejects.toThrow();
  });
});
