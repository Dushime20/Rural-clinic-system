/**
 * Clinic Service
 * Handles CRUD operations for clinic management
 */

import { AppDataSource } from '../database/data-source';
import { Clinic } from '../models/Clinic';
import { ClinicSpecialty, MedicalSpecialty } from '../models/ClinicSpecialty';
import { User, UserRole } from '../models/User';
import { logger } from '../utils/logger';
import bcrypt from 'bcryptjs';
import { In, Like } from 'typeorm';

interface CreateClinicInput {
  name: string;
  managerName: string;
  email: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude: number;
  longitude: number;
  openingHours?: any;
  specialties: MedicalSpecialty[];
}

interface UpdateClinicInput {
  name?: string;
  managerName?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  openingHours?: any;
}

interface ListClinicsParams {
  page?: number;
  limit?: number;
  search?: string;
  specialty?: MedicalSpecialty;
  isActive?: boolean;
}

interface CreateClinicResult {
  user: User;
  clinic: Clinic;
  temporaryPassword: string;
}

class ClinicService {
  private clinicRepository = AppDataSource.getRepository(Clinic);
  private clinicSpecialtyRepository = AppDataSource.getRepository(ClinicSpecialty);
  private userRepository = AppDataSource.getRepository(User);

  /**
   * Create a new clinic with user account and credentials
   */
  async createClinic(input: CreateClinicInput): Promise<CreateClinicResult> {
    // Validate coordinates
    if (input.latitude < -90 || input.latitude > 90) {
      throw new Error('Latitude must be between -90 and 90');
    }
    if (input.longitude < -180 || input.longitude > 180) {
      throw new Error('Longitude must be between -180 and 180');
    }

    // Validate specialties
    if (!input.specialties || input.specialties.length === 0) {
      throw new Error('At least one specialty is required');
    }

    // Check if user with email already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: input.email }
    });
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Generate temporary password
    const temporaryPassword = this.generateTemporaryPassword();
    const hashedPassword = await bcrypt.hash(temporaryPassword, 12);

    // Start transaction
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Create user account
      const user = queryRunner.manager.create(User, {
        email: input.email,
        password: hashedPassword,
        firstName: input.managerName.split(' ')[0] || 'Clinic',
        lastName: input.managerName.split(' ').slice(1).join(' ') || 'Manager',
        role: UserRole.CLINIC,
        mustChangePassword: true,
        isActive: true
      });
      await queryRunner.manager.save(user);

      // Create clinic profile
      const clinic = queryRunner.manager.create(Clinic, {
        managerId: user.id,
        name: input.name,
        managerName: input.managerName,
        phoneNumber: input.phoneNumber,
        address: input.address,
        city: input.city,
        district: input.district,
        country: input.country,
        latitude: input.latitude,
        longitude: input.longitude,
        openingHours: input.openingHours,
        isActive: true
      });
      await queryRunner.manager.save(clinic);

      // Create clinic specialties
      const specialties = input.specialties.map(specialty =>
        queryRunner.manager.create(ClinicSpecialty, {
          clinicId: clinic.id,
          specialty
        })
      );
      await queryRunner.manager.save(specialties);

      await queryRunner.commitTransaction();

      // Reload clinic with specialties
      const createdClinic = await this.clinicRepository.findOne({
        where: { id: clinic.id },
        relations: ['specialties']
      });

      logger.info(`Clinic created: ${clinic.id} for user ${user.id}`);

      return {
        user,
        clinic: createdClinic!,
        temporaryPassword
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      logger.error('Failed to create clinic:', error);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Update clinic profile
   */
  async updateClinic(clinicId: string, input: UpdateClinicInput): Promise<Clinic> {
    const clinic = await this.clinicRepository.findOne({
      where: { id: clinicId },
      relations: ['specialties']
    });

    if (!clinic) {
      throw new Error('Clinic not found');
    }

    // Validate coordinates if provided
    if (input.latitude !== undefined) {
      if (input.latitude < -90 || input.latitude > 90) {
        throw new Error('Latitude must be between -90 and 90');
      }
    }
    if (input.longitude !== undefined) {
      if (input.longitude < -180 || input.longitude > 180) {
        throw new Error('Longitude must be between -180 and 180');
      }
    }

    // Update fields
    Object.assign(clinic, input);

    const updatedClinic = await this.clinicRepository.save(clinic);
    logger.info(`Clinic updated: ${clinicId}`);

    return updatedClinic;
  }

  /**
   * Get clinic by ID
   */
  async getClinicById(clinicId: string): Promise<Clinic | null> {
    const clinic = await this.clinicRepository.findOne({
      where: { id: clinicId },
      relations: ['specialties']
    });

    return clinic;
  }

  /**
   * Get clinic by manager ID
   */
  async getClinicByManagerId(managerId: string): Promise<Clinic | null> {
    const clinic = await this.clinicRepository.findOne({
      where: { managerId },
      relations: ['specialties']
    });

    return clinic;
  }

  /**
   * List clinics with pagination and filters
   */
  async listClinics(params: ListClinicsParams) {
    const page = params.page || 1;
    const limit = params.limit || 20;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clinicRepository
      .createQueryBuilder('clinic')
      .leftJoinAndSelect('clinic.specialties', 'specialties');

    // Apply search filter
    if (params.search) {
      queryBuilder.andWhere(
        '(clinic.name ILIKE :search OR clinic.city ILIKE :search OR clinic.district ILIKE :search)',
        { search: `%${params.search}%` }
      );
    }

    // Apply specialty filter
    if (params.specialty) {
      queryBuilder.andWhere('specialties.specialty = :specialty', {
        specialty: params.specialty
      });
    }

    // Apply active status filter
    if (params.isActive !== undefined) {
      queryBuilder.andWhere('clinic.isActive = :isActive', {
        isActive: params.isActive
      });
    }

    // Get total count
    const total = await queryBuilder.getCount();

    // Get paginated results
    const clinics = await queryBuilder
      .orderBy('clinic.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    return {
      clinics,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * Update clinic status (activate/deactivate)
   */
  async updateClinicStatus(clinicId: string, isActive: boolean): Promise<Clinic> {
    const clinic = await this.clinicRepository.findOne({
      where: { id: clinicId }
    });

    if (!clinic) {
      throw new Error('Clinic not found');
    }

    clinic.isActive = isActive;
    const updatedClinic = await this.clinicRepository.save(clinic);

    logger.info(`Clinic ${clinicId} ${isActive ? 'activated' : 'deactivated'}`);

    return updatedClinic;
  }

  /**
   * Update clinic specialties
   */
  async updateClinicSpecialties(
    clinicId: string,
    specialties: MedicalSpecialty[]
  ): Promise<Clinic> {
    if (!specialties || specialties.length === 0) {
      throw new Error('At least one specialty is required');
    }

    const clinic = await this.clinicRepository.findOne({
      where: { id: clinicId },
      relations: ['specialties']
    });

    if (!clinic) {
      throw new Error('Clinic not found');
    }

    // Delete existing specialties
    await this.clinicSpecialtyRepository.delete({ clinicId });

    // Create new specialties
    const newSpecialties = specialties.map(specialty =>
      this.clinicSpecialtyRepository.create({
        clinicId,
        specialty
      })
    );
    await this.clinicSpecialtyRepository.save(newSpecialties);

    // Reload clinic with new specialties
    const updatedClinic = await this.clinicRepository.findOne({
      where: { id: clinicId },
      relations: ['specialties']
    });

    logger.info(`Clinic specialties updated: ${clinicId}`);

    return updatedClinic!;
  }

  /**
   * Generate temporary password
   */
  private generateTemporaryPassword(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    let password = '';
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
  }
}

export const clinicService = new ClinicService();
