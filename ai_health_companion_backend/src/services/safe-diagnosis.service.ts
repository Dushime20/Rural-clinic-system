/**
 * Safe Diagnosis Service
 * Integrates AI prediction with patient safety checks
 */

import { flaskMLService } from './flask-ml.service';
import { patientSafetyService, PatientContext, SafetyCheck } from './patient-safety.service';
import { logger } from '../utils/logger';

export interface DiagnosisInput {
  patientId: string;
  symptoms: string[];
  vitalSigns: {
    temperature?: number;
    bloodPressureSystolic?: number;
    bloodPressureDiastolic?: number;
    heartRate?: number;
    respiratoryRate?: number;
    oxygenSaturation?: number;
    weight?: number;
    height?: number;
  };
}

export interface SafeDiagnosisResult {
  success: boolean;
  prediction: {
    disease: string;
    icd10Code: string;
    confidence: number;
    symptomsUsed: string[];
  };
  patientContext: PatientContext;
  safetyCheck: SafetyCheck;
  originalRecommendations: {
    medications: string[];
    precautions: string[];
    diet: string[];
    workout: string[];
  };
  safeRecommendations: {
    medications: string[];
    precautions: string[];
    diet: string[];
    workout: string[];
    warnings: string[];
    contraindications: string[];
  };
  requiresSpecialistReferral: boolean;
  timestamp: string;
}

export class SafeDiagnosisService {
  /**
   * Run AI diagnosis with comprehensive safety checks
   */
  async diagnoseWithSafety(input: DiagnosisInput): Promise<SafeDiagnosisResult> {
    const startTime = Date.now();
    
    try {
      // Step 1: Get patient context (CRITICAL)
      logger.info(`Fetching patient context for: ${input.patientId}`);
      const patientContext = await patientSafetyService.getPatientContext(input.patientId);
      
      if (!patientContext) {
        throw new Error('Patient record not found. Cannot proceed with diagnosis.');
      }

      logger.info(`Patient context loaded: ${patientContext.allergies.length} allergies, ${patientContext.chronicConditions.length} conditions, ${patientContext.currentMedications.length} medications`);

      // Step 2: Get AI prediction
      logger.info('Requesting AI prediction from Flask service');
      const prediction = await flaskMLService.predictDisease(
        input.symptoms,
        input.vitalSigns,
        {
          age: patientContext.age,
          gender: patientContext.gender
        }
      );

      logger.info(`AI prediction: ${prediction.prediction.disease} (confidence: ${prediction.prediction.confidence})`);

      // Step 3: Run safety checks
      logger.info('Running safety checks');
      const safetyCheck = await patientSafetyService.runSafetyChecks(
        prediction.information.medications,
        patientContext,
        prediction.prediction.disease
      );

      logger.info(`Safety check complete: ${safetyCheck.passed ? 'PASSED' : 'FAILED'} (risk level: ${safetyCheck.riskLevel})`);

      // Step 4: Adjust recommendations based on safety checks
      const safeRecommendations = this.adjustRecommendations(
        prediction.information,
        safetyCheck
      );

      // Step 5: Determine if specialist referral needed
      const requiresSpecialistReferral = this.requiresSpecialistReferral(
        safetyCheck,
        prediction.prediction.confidence
      );

      const duration = Date.now() - startTime;
      logger.info(`Safe diagnosis completed in ${duration}ms`);

      return {
        success: true,
        prediction: {
          disease: prediction.prediction.disease,
          icd10Code: prediction.prediction.icd10Code,
          confidence: prediction.prediction.confidence,
          symptomsUsed: prediction.prediction.symptoms_used
        },
        patientContext,
        safetyCheck,
        originalRecommendations: {
          medications: prediction.information.medications,
          precautions: prediction.information.precautions,
          diet: prediction.information.diet,
          workout: prediction.information.workout
        },
        safeRecommendations,
        requiresSpecialistReferral,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      logger.error('Safe diagnosis failed:', error);
      throw error;
    }
  }

  /**
   * Adjust recommendations based on safety checks
   */
  private adjustRecommendations(
    originalInfo: any,
    safetyCheck: SafetyCheck
  ): {
    medications: string[];
    precautions: string[];
    diet: string[];
    workout: string[];
    warnings: string[];
    contraindications: string[];
  } {
    // Filter out contraindicated medications
    const safeMedications = originalInfo.medications.filter((med: string) => {
      return !safetyCheck.contraindications.some(contra =>
        contra.toLowerCase().includes(med.toLowerCase())
      );
    });

    // Add safety-based precautions
    const enhancedPrecautions = [
      ...originalInfo.precautions,
      ...safetyCheck.adjustedRecommendations
    ];

    return {
      medications: safeMedications,
      precautions: enhancedPrecautions,
      diet: originalInfo.diet,
      workout: originalInfo.workout,
      warnings: safetyCheck.warnings,
      contraindications: safetyCheck.contraindications
    };
  }

  /**
   * Determine if specialist referral is needed
   */
  private requiresSpecialistReferral(
    safetyCheck: SafetyCheck,
    confidence: number
  ): boolean {
    // Refer if critical risk level
    if (safetyCheck.riskLevel === 'critical') {
      return true;
    }

    // Refer if high risk with multiple contraindications
    if (safetyCheck.riskLevel === 'high' && safetyCheck.contraindications.length >= 2) {
      return true;
    }

    // Refer if low confidence prediction with safety concerns
    if (confidence < 0.7 && safetyCheck.warnings.length > 0) {
      return true;
    }

    return false;
  }

  /**
   * Emergency diagnosis without patient context (USE ONLY IN EMERGENCIES)
   */
  async emergencyDiagnosis(input: Omit<DiagnosisInput, 'patientId'>): Promise<any> {
    logger.warn('⚠️ EMERGENCY DIAGNOSIS WITHOUT PATIENT CONTEXT');
    
    // Get basic AI prediction
    const prediction = await flaskMLService.predictDisease(
      input.symptoms,
      input.vitalSigns
    );

    return {
      success: true,
      prediction: prediction.prediction,
      information: prediction.information,
      warning: '⚠️ THIS DIAGNOSIS WAS PERFORMED WITHOUT PATIENT MEDICAL HISTORY',
      risks: [
        'Allergies NOT checked',
        'Drug interactions NOT verified',
        'Chronic conditions NOT considered',
        'Current medications NOT reviewed'
      ],
      recommendation: 'Follow up with complete patient history when internet available',
      timestamp: new Date().toISOString()
    };
  }
}

export const safeDiagnosisService = new SafeDiagnosisService();
