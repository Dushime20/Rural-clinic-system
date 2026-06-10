/**
 * Diagnosis History Service
 * Handles pattern detection for recurring, persistent, and chronic conditions
 */

import { AppDataSource } from '../database/data-source';
import { Diagnosis } from '../models/Diagnosis';
import { Patient } from '../models/Patient';
import { logger } from '../utils/logger';
import { MoreThan, LessThanOrEqual, In } from 'typeorm';
import { CHRONIC_CONDITIONS, isChronicCondition } from '../config/chronic-conditions';

interface RecurringDiseaseInfo {
  isRecurring: boolean;
  occurrenceCount: number;
  timeWindowDays: number;
  firstOccurrence?: Date;
  lastOccurrence?: Date;
}

interface PersistentDiseaseInfo {
  isPersistent: boolean;
  durationDays: number;
  firstActiveDiagnosis?: Date;
  status: 'active' | 'ongoing' | 'resolved';
}

class DiagnosisHistoryService {
  private diagnosisRepository = AppDataSource.getRepository(Diagnosis);
  private patientRepository = AppDataSource.getRepository(Patient);

  private readonly RECURRING_WINDOW_DAYS = 90;
  private readonly RECURRING_THRESHOLD = 2; // Changed from 3 to 2
  private readonly PERSISTENT_THRESHOLD_DAYS = 7; // Changed from 30 to 7 days
  private readonly CHRONIC_SIMILARITY_THRESHOLD = 0.8;

  /**
   * Detect if a disease is recurring for a patient
   * A disease is recurring if it appears 3+ times within 90 days
   */
  async detectRecurringDisease(
    patientId: string,
    diseaseName: string
  ): Promise<RecurringDiseaseInfo> {
    try {
      logger.info(`[RecurringDetection] Checking for patient ${patientId}, disease: ${diseaseName}`);
      
      const now = new Date();
      const windowStart = new Date(now.getTime() - this.RECURRING_WINDOW_DAYS * 24 * 60 * 60 * 1000);

      // Query diagnoses within the time window
      const diagnoses = await this.diagnosisRepository
        .createQueryBuilder('diagnosis')
        .where('diagnosis.patientId = :patientId', { patientId })
        .andWhere('diagnosis.diagnosisDate >= :windowStart', { windowStart })
        .andWhere('diagnosis.diagnosisDate <= :now', { now })
        .orderBy('diagnosis.diagnosisDate', 'ASC')
        .getMany();

      logger.info(`[RecurringDetection] Found ${diagnoses.length} diagnoses in last ${this.RECURRING_WINDOW_DAYS} days`);

      // Filter for matching disease (case-insensitive)
      // Check both selectedDiagnosis and aiPredictions
      // For recurring detection, count ALL matching diagnoses (don't exclude resolved ones)
      const matchingDiagnoses = diagnoses.filter(d => {
        const selectedDisease = d.selectedDiagnosis?.disease?.toLowerCase();
        const predictedDiseases = d.aiPredictions?.map(p => p.disease.toLowerCase()) || [];
        const targetDisease = diseaseName.toLowerCase();

        const isMatchingDisease = (
          selectedDisease === targetDisease ||
          predictedDiseases.includes(targetDisease)
        );

        logger.info(`[RecurringDetection] Diagnosis ${d.diagnosisId}: disease="${selectedDisease || predictedDiseases[0]}", matching=${isMatchingDisease}`);

        return isMatchingDisease;
      });

      const occurrenceCount = matchingDiagnoses.length;
      const isRecurring = occurrenceCount >= this.RECURRING_THRESHOLD;

      logger.info(`[RecurringDetection] Result: ${occurrenceCount} matching diagnoses, recurring=${isRecurring} (threshold=${this.RECURRING_THRESHOLD})`);

      const result: RecurringDiseaseInfo = {
        isRecurring,
        occurrenceCount,
        timeWindowDays: this.RECURRING_WINDOW_DAYS
      };

      if (matchingDiagnoses.length > 0) {
        result.firstOccurrence = matchingDiagnoses[0].diagnosisDate;
        result.lastOccurrence = matchingDiagnoses[matchingDiagnoses.length - 1].diagnosisDate;
      }

      if (isRecurring) {
        logger.info(
          `Recurring disease detected: ${diseaseName} for patient ${patientId} (${occurrenceCount} times in ${this.RECURRING_WINDOW_DAYS} days)`
        );
      }

      return result;
    } catch (error) {
      logger.error('Error detecting recurring disease:', error);
      return {
        isRecurring: false,
        occurrenceCount: 0,
        timeWindowDays: this.RECURRING_WINDOW_DAYS
      };
    }
  }

  /**
   * Detect if a disease is persistent for a patient
   * A disease is persistent if it has been active for more than 30 days
   */
  async detectPersistentDisease(
    patientId: string,
    diseaseName: string
  ): Promise<PersistentDiseaseInfo> {
    try {
      const now = new Date();
      const thresholdDate = new Date(now.getTime() - this.PERSISTENT_THRESHOLD_DAYS * 24 * 60 * 60 * 1000);

      // Query old diagnoses
      const diagnoses = await this.diagnosisRepository
        .createQueryBuilder('diagnosis')
        .where('diagnosis.patientId = :patientId', { patientId })
        .andWhere('diagnosis.diagnosisDate <= :thresholdDate', { thresholdDate })
        .orderBy('diagnosis.diagnosisDate', 'ASC')
        .getMany();

      // Filter for matching disease
      const matchingDiagnoses = diagnoses.filter(d => {
        const selectedDisease = d.selectedDiagnosis?.disease?.toLowerCase();
        const predictedDiseases = d.aiPredictions?.map(p => p.disease.toLowerCase()) || [];
        const targetDisease = diseaseName.toLowerCase();

        return (
          selectedDisease === targetDisease ||
          predictedDiseases.includes(targetDisease)
        );
      });

      // For persistent detection, count ALL matching diagnoses (even if resolved)
      // A disease is persistent if diagnosed more than 30 days ago and still recurring
      const isPersistent = matchingDiagnoses.length > 0;

      const result: PersistentDiseaseInfo = {
        isPersistent,
        durationDays: 0,
        status: 'active'
      };

      if (matchingDiagnoses.length > 0) {
        const firstDiagnosis = matchingDiagnoses[0];
        result.firstActiveDiagnosis = firstDiagnosis.diagnosisDate;

        // Calculate duration in days
        const durationMs = now.getTime() - firstDiagnosis.diagnosisDate.getTime();
        result.durationDays = Math.floor(durationMs / (24 * 60 * 60 * 1000));

        if (isPersistent) {
          logger.info(
            `Persistent disease detected: ${diseaseName} for patient ${patientId} (active for ${result.durationDays} days)`
          );
        }
      }

      return result;
    } catch (error) {
      logger.error('Error detecting persistent disease:', error);
      return {
        isPersistent: false,
        durationDays: 0,
        status: 'resolved'
      };
    }
  }

  /**
   * Check if a disease matches a patient's chronic condition OR is a known chronic disease
   * Uses fuzzy string matching with 80% similarity threshold for patient's list
   * Uses exact/fuzzy matching for global chronic conditions list
   */
  async matchesChronicCondition(patientId: string, diseaseName: string): Promise<boolean> {
    try {
      const diseaseNameLower = diseaseName.toLowerCase().trim();

      // First, check if disease is in the global chronic conditions list (exact match)
      if (isChronicCondition(diseaseName)) {
        logger.info(
          `Chronic condition match (global list): "${diseaseName}" for patient ${patientId}`
        );
        return true;
      }

      // Second, check against patient's personal chronic conditions list (fuzzy matching)
      const patient = await this.patientRepository.findOne({
        where: { id: patientId }
      });

      if (!patient || !patient.chronicConditions || patient.chronicConditions.length === 0) {
        return false;
      }

      // Check for fuzzy matches against patient's chronic conditions
      for (const condition of patient.chronicConditions) {
        const conditionLower = condition.toLowerCase().trim();
        const similarity = this.calculateStringSimilarity(diseaseNameLower, conditionLower);

        if (similarity >= this.CHRONIC_SIMILARITY_THRESHOLD) {
          logger.info(
            `Chronic condition match (patient list): "${diseaseName}" matches "${condition}" for patient ${patientId} (similarity: ${similarity.toFixed(2)})`
          );
          return true;
        }
      }

      return false;
    } catch (error) {
      logger.error('Error matching chronic condition:', error);
      return false;
    }
  }

  /**
   * Calculate string similarity using Levenshtein distance
   * Returns a value between 0 and 1 (1 = identical)
   */
  private calculateStringSimilarity(str1: string, str2: string): number {
    const longer = str1.length > str2.length ? str1 : str2;
    const shorter = str1.length > str2.length ? str2 : str1;

    if (longer.length === 0) {
      return 1.0;
    }

    const distance = this.levenshteinDistance(longer, shorter);
    return (longer.length - distance) / longer.length;
  }

  /**
   * Calculate Levenshtein distance between two strings
   */
  private levenshteinDistance(str1: string, str2: string): number {
    const matrix: number[][] = [];

    for (let i = 0; i <= str2.length; i++) {
      matrix[i] = [i];
    }

    for (let j = 0; j <= str1.length; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= str2.length; i++) {
      for (let j = 1; j <= str1.length; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1, // substitution
            matrix[i][j - 1] + 1,     // insertion
            matrix[i - 1][j] + 1      // deletion
          );
        }
      }
    }

    return matrix[str2.length][str1.length];
  }

  /**
   * Get diagnosis history for a patient
   */
  async getDiagnosisHistory(patientId: string, limit: number = 50): Promise<Diagnosis[]> {
    return await this.diagnosisRepository.find({
      where: { patientId },
      order: { diagnosisDate: 'DESC' },
      take: limit
    });
  }
}

export const diagnosisHistoryService = new DiagnosisHistoryService();
