/**
 * Recommendation Engine Service
 * Orchestrates pharmacy and clinic recommendations based on diagnosis patterns
 */

import { logger } from '../utils/logger';
import { diagnosisHistoryService } from './diagnosis-history.service';
import { clinicSearchService, ClinicWithDistance } from './clinic-search.service';
import { analyticsService } from './analytics.service';

export type RecommendationReason =
  | 'no_pharmacy_found'
  | 'recurring_disease'
  | 'persistent_disease'
  | 'chronic_condition';

interface PatternAnalysis {
  isRecurring: boolean;
  isPersistent: boolean;
  matchesChronicCondition: boolean;
  occurrenceCount?: number;
  durationDays?: number;
}

interface PharmacyRecommendation {
  id: string;
  name: string;
  address?: string;
  phoneNumber?: string;
  distance?: number;
  // Additional pharmacy fields from existing implementation
  [key: string]: any;
}

interface ClinicRecommendation {
  id: string;
  name: string;
  specialties: string[];
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  latitude: number;
  longitude: number;
  distance?: number;
  isOpenNow?: boolean;
  openingHours?: any;
}

interface RecommendationEngineParams {
  diagnosisId: string;
  patientId: string;
  diseaseName: string;
  medications: string[];
  latitude?: number;
  longitude?: number;
  pharmacyRecommendations?: PharmacyRecommendation[]; // Pre-fetched pharmacy results
}

interface RecommendationResult {
  pharmacies: PharmacyRecommendation[];
  clinics?: ClinicRecommendation[];
  clinicRecommendationReason?: RecommendationReason;
  patternAnalysis?: PatternAnalysis;
}

interface ShouldRecommendClinicsResult {
  shouldRecommend: boolean;
  reason?: RecommendationReason;
  priority: 'high' | 'normal';
}

class RecommendationEngineService {
  /**
   * Get comprehensive recommendations for a diagnosis
   */
  async getRecommendations(params: RecommendationEngineParams): Promise<RecommendationResult> {
    try {
      const {
        diagnosisId,
        patientId,
        diseaseName,
        medications,
        latitude,
        longitude,
        pharmacyRecommendations = []
      } = params;

      logger.info(`[RecommendationEngine] Processing recommendations for diagnosis ${diagnosisId}`);

      // Step 1: Analyze diagnosis patterns
      const patternAnalysis = await this.analyzePatterns(patientId, diseaseName);

      // Step 2: Determine if clinic recommendations are needed
      const { shouldRecommend, reason, priority } = this.shouldRecommendClinics({
        hasPharmacyResults: pharmacyRecommendations.length > 0,
        isRecurring: patternAnalysis.isRecurring,
        isPersistent: patternAnalysis.isPersistent,
        matchesChronicCondition: patternAnalysis.matchesChronicCondition
      });

      logger.info(`[RecommendationEngine] Should recommend clinics: ${shouldRecommend}, reason: ${reason}, priority: ${priority}`);

      // Step 3: Search for clinics if needed
      let clinicRecommendations: ClinicRecommendation[] = [];
      if (shouldRecommend) {
        try {
          clinicRecommendations = await this.searchClinics({
            diseaseName,
            latitude,
            longitude
          });

          logger.info(`[RecommendationEngine] Found ${clinicRecommendations.length} clinic recommendations`);
        } catch (error) {
          // Graceful degradation: log error but don't fail the diagnosis
          logger.error('[RecommendationEngine] Clinic search failed, returning empty array:', error);
          clinicRecommendations = [];
        }
      }

      // Step 4: Build result
      const result: RecommendationResult = {
        pharmacies: pharmacyRecommendations,
        patternAnalysis
      };

      // Include clinic fields when recommendations should be shown (even if empty)
      if (shouldRecommend) {
        result.clinics = clinicRecommendations; // Can be empty array
        result.clinicRecommendationReason = reason;
        
        // Log analytics event only if clinics were found
        if (clinicRecommendations.length > 0) {
          analyticsService.logClinicRecommendation({
            diagnosisId,
            patientId,
            reason: reason!,
            clinicCount: clinicRecommendations.length,
            metadata: {
              hasLocation: !!(latitude && longitude),
              diseaseName,
              patternAnalysis
            }
          }).catch(err => {
            logger.error('[RecommendationEngine] Failed to log analytics (non-blocking):', err);
          });
        } else {
          logger.warn(`[RecommendationEngine] Clinic recommendations triggered but no clinics found (reason: ${reason})`);
        }
      }

      return result;
    } catch (error) {
      logger.error('[RecommendationEngine] Fatal error in getRecommendations:', error);
      // Return minimal result with pharmacies only
      return {
        pharmacies: params.pharmacyRecommendations || [],
      };
    }
  }

  /**
   * Analyze diagnosis patterns for a patient
   */
  private async analyzePatterns(patientId: string, diseaseName: string): Promise<PatternAnalysis> {
    try {
      // Run pattern detection in parallel
      const [recurringInfo, persistentInfo, isChronicMatch] = await Promise.all([
        diagnosisHistoryService.detectRecurringDisease(patientId, diseaseName),
        diagnosisHistoryService.detectPersistentDisease(patientId, diseaseName),
        diagnosisHistoryService.matchesChronicCondition(patientId, diseaseName)
      ]);

      return {
        isRecurring: recurringInfo.isRecurring,
        isPersistent: persistentInfo.isPersistent,
        matchesChronicCondition: isChronicMatch,
        occurrenceCount: recurringInfo.occurrenceCount,
        durationDays: persistentInfo.durationDays
      };
    } catch (error) {
      logger.error('[RecommendationEngine] Error analyzing patterns:', error);
      // Return safe defaults on error
      return {
        isRecurring: false,
        isPersistent: false,
        matchesChronicCondition: false
      };
    }
  }

  /**
   * Determine if clinic recommendations should be provided
   */
  shouldRecommendClinics(params: {
    hasPharmacyResults: boolean;
    isRecurring: boolean;
    isPersistent: boolean;
    matchesChronicCondition: boolean;
  }): ShouldRecommendClinicsResult {
    // Proactive mode: Recurring disease
    if (params.isRecurring) {
      return {
        shouldRecommend: true,
        reason: 'recurring_disease',
        priority: 'high'
      };
    }

    // Proactive mode: Persistent disease
    if (params.isPersistent) {
      return {
        shouldRecommend: true,
        reason: 'persistent_disease',
        priority: 'high'
      };
    }

    // Proactive mode: Chronic condition
    if (params.matchesChronicCondition) {
      return {
        shouldRecommend: true,
        reason: 'chronic_condition',
        priority: 'high'
      };
    }

    // Fallback mode: No pharmacy found
    if (!params.hasPharmacyResults) {
      return {
        shouldRecommend: true,
        reason: 'no_pharmacy_found',
        priority: 'normal'
      };
    }

    // No clinic recommendations needed
    return {
      shouldRecommend: false,
      priority: 'normal'
    };
  }

  /**
   * Search for clinics based on disease and location
   */
  private async searchClinics(params: {
    diseaseName: string;
    latitude?: number;
    longitude?: number;
  }): Promise<ClinicRecommendation[]> {
    const result = await clinicSearchService.searchByDisease({
      diseaseName: params.diseaseName,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: 100,
      limit: 10
    });

    // Map to clinic recommendation format
    return result.clinics.map((clinic: ClinicWithDistance) => ({
      id: clinic.id,
      name: clinic.name,
      specialties: clinic.specialties?.map((s: any) => s.specialty) || [],
      phoneNumber: clinic.phoneNumber,
      address: clinic.address,
      city: clinic.city,
      district: clinic.district,
      latitude: clinic.latitude,
      longitude: clinic.longitude,
      distance: clinic.distance,
      isOpenNow: clinic.isOpenNow,
      openingHours: clinic.openingHours
    }));
  }
}

export const recommendationEngineService = new RecommendationEngineService();
