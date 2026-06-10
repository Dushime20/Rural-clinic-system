/**
 * Analytics Service
 * Handles logging of analytics events including clinic recommendations
 */

import { AppDataSource } from '../database/data-source';
import { AnalyticsEvent } from '../models/AnalyticsEvent';
import { logger } from '../utils/logger';

interface LogClinicRecommendationParams {
  diagnosisId: string;
  patientId: string;
  reason: 'no_pharmacy_found' | 'recurring_disease' | 'persistent_disease' | 'chronic_condition';
  clinicCount: number;
  metadata?: Record<string, any>;
}

interface ClinicRecommendationStats {
  total: number;
  byReason: Record<string, number>;
  avgClinicsPerRecommendation: number;
  dateRange?: {
    from: Date;
    to: Date;
  };
}

class AnalyticsService {
  private analyticsRepository = AppDataSource.getRepository(AnalyticsEvent);

  /**
   * Log clinic recommendation event
   */
  async logClinicRecommendation(params: LogClinicRecommendationParams): Promise<void> {
    try {
      const { diagnosisId, patientId, reason, clinicCount, metadata = {} } = params;

      // Create analytics event asynchronously to avoid blocking diagnosis flow
      setImmediate(async () => {
        try {
          const event = this.analyticsRepository.create({
            eventType: 'clinic_recommendation',
            patientId,
            diagnosisId,
            reason,
            clinicCount,
            metadata,
          });

          await this.analyticsRepository.save(event);

          logger.info(`[Analytics] Clinic recommendation logged: ${reason}, ${clinicCount} clinics`);
        } catch (error) {
          // Don't fail the request if analytics logging fails
          logger.error('[Analytics] Failed to log clinic recommendation:', error);
        }
      });
    } catch (error) {
      // Silently fail - analytics should never block the main flow
      logger.error('[Analytics] Error initiating clinic recommendation log:', error);
    }
  }

  /**
   * Get clinic recommendation statistics
   */
  async getClinicRecommendationStats(params?: {
    from?: Date;
    to?: Date;
    reason?: string;
  }): Promise<ClinicRecommendationStats> {
    try {
      const { from, to, reason } = params || {};

      const queryBuilder = this.analyticsRepository
        .createQueryBuilder('event')
        .where("event.eventType = 'clinic_recommendation'");

      // Apply date range filter
      if (from) {
        queryBuilder.andWhere('event.createdAt >= :from', { from });
      }
      if (to) {
        queryBuilder.andWhere('event.createdAt <= :to', { to });
      }

      // Apply reason filter
      if (reason) {
        queryBuilder.andWhere("event.reason = :reason", { reason });
      }

      const events = await queryBuilder.getMany();

      // Calculate statistics
      const total = events.length;
      const byReason: Record<string, number> = {};
      let totalClinics = 0;

      events.forEach(event => {
        const eventReason = event.reason || 'unknown';
        const clinicCount = event.clinicCount || 0;

        byReason[eventReason] = (byReason[eventReason] || 0) + 1;
        totalClinics += clinicCount;
      });

      const avgClinicsPerRecommendation = total > 0 ? totalClinics / total : 0;

      return {
        total,
        byReason,
        avgClinicsPerRecommendation: Math.round(avgClinicsPerRecommendation * 10) / 10,
        dateRange: from && to ? { from, to } : undefined,
      };
    } catch (error) {
      logger.error('[Analytics] Error getting clinic recommendation stats:', error);
      return {
        total: 0,
        byReason: {},
        avgClinicsPerRecommendation: 0,
      };
    }
  }

  /**
   * Log general analytics event
   */
  async logEvent(eventType: string, metadata: Record<string, any>): Promise<void> {
    try {
      setImmediate(async () => {
        try {
          const event = this.analyticsRepository.create({
            eventType,
            metadata,
          });

          await this.analyticsRepository.save(event);

          logger.info(`[Analytics] Event logged: ${eventType}`);
        } catch (error) {
          logger.error(`[Analytics] Failed to log event ${eventType}:`, error);
        }
      });
    } catch (error) {
      logger.error('[Analytics] Error initiating event log:', error);
    }
  }
}

export const analyticsService = new AnalyticsService();
