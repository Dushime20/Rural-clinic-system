/**
 * Clinic Search Service
 * Handles location-based clinic search with specialty mapping
 */

import { AppDataSource } from '../database/data-source';
import { Clinic } from '../models/Clinic';
import { ClinicSpecialty, MedicalSpecialty } from '../models/ClinicSpecialty';
import { DiseaseSpecialtyMapping } from '../models/DiseaseSpecialtyMapping';
import { logger } from '../utils/logger';
import { Like } from 'typeorm';

interface SearchByDiseaseParams {
  diseaseName: string;
  latitude?: number;
  longitude?: number;
  radiusKm?: number;
  onlyOpen?: boolean;
  limit?: number;
}

interface SearchBySpecialtiesParams {
  specialties: MedicalSpecialty[];
  latitude?: number;
  longitude?: number;
  radiusKm?: number;
  limit?: number;
}

export interface ClinicWithDistance {
  id: string;
  managerId: string;
  name: string;
  managerName?: string;
  phoneNumber?: string;
  address?: string;
  latitude: number;
  longitude: number;
  city?: string;
  district?: string;
  country?: string;
  isActive: boolean;
  openingHours?: any;
  specialties: any[];
  createdAt: Date;
  updatedAt: Date;
  distance?: number;
  isOpenNow?: boolean;
}

interface ClinicSearchResult {
  clinics: ClinicWithDistance[];
  mappedSpecialties: MedicalSpecialty[];
  totalFound: number;
}

class ClinicSearchService {
  private clinicRepository = AppDataSource.getRepository(Clinic);
  private diseaseMappingRepository = AppDataSource.getRepository(DiseaseSpecialtyMapping);

  private readonly DEFAULT_RADIUS_KM = 100;
  private readonly DEFAULT_LIMIT = 10;
  private readonly SEARCH_TIMEOUT_MS = 5000;

  /**
   * Search for clinics by disease and location
   * Implements timeout protection and graceful error handling
   * Requirement 24.7: 5-second timeout for clinic search operations
   */
  async searchByDisease(params: SearchByDiseaseParams): Promise<ClinicSearchResult> {
    const timeoutPromise = new Promise<ClinicSearchResult>((_, reject) => {
      setTimeout(() => reject(new Error('Clinic search timeout after 5 seconds')), this.SEARCH_TIMEOUT_MS);
    });

    const searchPromise = this._performDiseaseSearch(params);

    try {
      return await Promise.race([searchPromise, timeoutPromise]);
    } catch (error) {
      // Requirement 24.1: Log errors but don't fail diagnosis workflow
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      logger.error(`[ClinicSearchService] Clinic search failed: ${errorMessage}`, {
        diseaseName: params.diseaseName,
        hasLocation: !!(params.latitude && params.longitude),
        error
      });
      
      // Requirement 24.4: Return empty clinic array on service failures
      return {
        clinics: [],
        mappedSpecialties: [],
        totalFound: 0
      };
    }
  }

  /**
   * Internal method to perform disease search
   * Implements error handling for database operations
   */
  private async _performDiseaseSearch(params: SearchByDiseaseParams): Promise<ClinicSearchResult> {
    const radiusKm = params.radiusKm || this.DEFAULT_RADIUS_KM;
    const limit = params.limit || this.DEFAULT_LIMIT;

    // Step 1: Query disease-specialty mapping with error handling
    let specialties: MedicalSpecialty[];
    try {
      const mapping = await this.diseaseMappingRepository.findOne({
        where: { diseaseName: Like(`%${params.diseaseName}%`) }
      });

      if (mapping) {
        specialties = mapping.getAllSpecialties();
        logger.info(`[ClinicSearchService] Mapped disease "${params.diseaseName}" to specialties: ${specialties.join(', ')}`);
      } else {
        // Default to General_Medicine when no mapping found
        specialties = [MedicalSpecialty.GENERAL_MEDICINE];
        logger.info(`[ClinicSearchService] No mapping found for disease "${params.diseaseName}", defaulting to General_Medicine`);
      }
    } catch (error) {
      // Requirement 24.2: Fall back to General_Medicine on mapping query failure
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      logger.error(`[ClinicSearchService] Disease mapping query failed, falling back to General_Medicine: ${errorMessage}`, {
        diseaseName: params.diseaseName,
        error
      });
      specialties = [MedicalSpecialty.GENERAL_MEDICINE];
    }

    // Step 2: Search for clinics with those specialties (with error handling)
    let clinics: ClinicWithDistance[];
    try {
      clinics = await this.searchBySpecialties({
        specialties,
        latitude: params.latitude,
        longitude: params.longitude,
        radiusKm,
        limit
      });
    } catch (error) {
      // Requirement 24.1: Handle database errors gracefully
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      logger.error(`[ClinicSearchService] Clinic specialty search failed: ${errorMessage}`, {
        specialties,
        error
      });
      // Return empty results on database error
      return {
        clinics: [],
        mappedSpecialties: specialties,
        totalFound: 0
      };
    }

    // Step 3: Filter by operating hours if requested
    try {
      let filteredClinics = clinics.map(clinic => ({
        ...clinic,
        isOpenNow: this.isClinicOpenFromData(clinic.openingHours)
      }));

      if (params.onlyOpen) {
        filteredClinics = filteredClinics.filter(c => c.isOpenNow);
      }

      return {
        clinics: filteredClinics,
        mappedSpecialties: specialties,
        totalFound: filteredClinics.length
      };
    } catch (error) {
      // Safeguard: if filtering fails, return unfiltered results
      logger.error('[ClinicSearchService] Error filtering clinics by operating hours:', error);
      return {
        clinics,
        mappedSpecialties: specialties,
        totalFound: clinics.length
      };
    }
  }

  /**
   * Search for clinics by specialties
   */
  async searchBySpecialties(params: SearchBySpecialtiesParams): Promise<ClinicWithDistance[]> {
    const radiusKm = params.radiusKm || this.DEFAULT_RADIUS_KM;
    const limit = params.limit || this.DEFAULT_LIMIT;

    // Build query to find clinics with matching specialties
    const queryBuilder = this.clinicRepository
      .createQueryBuilder('clinic')
      .leftJoinAndSelect('clinic.specialties', 'specialty')
      .where('clinic.isActive = :isActive', { isActive: true })
      .andWhere('specialty.specialty IN (:...specialties)', { specialties: params.specialties });

    const clinics = await queryBuilder.getMany();

    // If location provided, calculate distances and filter by radius
    if (params.latitude !== undefined && params.longitude !== undefined) {
      const clinicsWithDistance = clinics.map(clinic => this.clinicToPlainObject(clinic, {
        distance: this.calculateDistance(
          params.latitude!,
          params.longitude!,
          clinic.latitude,
          clinic.longitude
        )
      }));

      // Filter by radius
      const filteredClinics = clinicsWithDistance.filter(
        c => c.distance !== undefined && c.distance <= radiusKm
      );

      // Sort by distance ascending
      filteredClinics.sort((a, b) => (a.distance || 0) - (b.distance || 0));

      // Limit results
      return filteredClinics.slice(0, limit);
    }

    // No location: return first N clinics without distance
    return clinics.slice(0, limit).map(clinic => this.clinicToPlainObject(clinic));
  }

  /**
   * Convert Clinic entity to plain object
   */
  private clinicToPlainObject(clinic: Clinic, extra?: Partial<ClinicWithDistance>): ClinicWithDistance {
    return {
      id: clinic.id,
      managerId: clinic.managerId,
      name: clinic.name,
      managerName: clinic.managerName,
      phoneNumber: clinic.phoneNumber,
      address: clinic.address,
      latitude: clinic.latitude,
      longitude: clinic.longitude,
      city: clinic.city,
      district: clinic.district,
      country: clinic.country,
      isActive: clinic.isActive,
      openingHours: clinic.openingHours,
      specialties: clinic.specialties,
      createdAt: clinic.createdAt,
      updatedAt: clinic.updatedAt,
      ...extra
    };
  }

  /**
   * Calculate distance between two coordinates using Haversine formula
   * Returns distance in kilometers
   */
  calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in kilometers

    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) *
        Math.cos(this.toRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const distance = R * c;

    return Math.round(distance * 10) / 10; // Round to 1 decimal place
  }

  /**
   * Convert degrees to radians
   */
  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  /**
   * Check if clinic is currently open (for Clinic entities)
   */
  isClinicOpen(clinic: Clinic): boolean {
    return this.isClinicOpenFromData(clinic.openingHours);
  }

  /**
   * Check if clinic is currently open from opening hours data
   */
  private isClinicOpenFromData(openingHours: any): boolean {
    if (!openingHours) {
      return false;
    }

    const now = new Date();
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const dayName = days[now.getDay()];
    const hours = openingHours[dayName];

    if (!hours || !hours.open || !hours.close) {
      return false;
    }

    const currentTime = now.getHours() * 60 + now.getMinutes();
    const [openHour, openMin] = hours.open.split(':').map(Number);
    const [closeHour, closeMin] = hours.close.split(':').map(Number);
    const openTime = openHour * 60 + openMin;
    const closeTime = closeHour * 60 + closeMin;

    return currentTime >= openTime && currentTime < closeTime;
  }
}

export const clinicSearchService = new ClinicSearchService();
