/**
 * Patient Safety Service
 * Ensures AI diagnosis considers patient medical history for safety
 */

import { AppDataSource } from '../database/data-source';
import { Patient } from '../models/Patient';
import { logger } from '../utils/logger';
import { MoreThan } from 'typeorm';

export interface PatientContext {
  patientId: string;
  allergies: string[];
  chronicConditions: string[];
  currentMedications: string[];
  age: number;
  gender: string;
  medicalHistory?: string[];
  pastDiagnoses?: Array<{
    disease: string;
    diagnosisDate: string;
    medications?: string[];
  }>;
  recentSymptoms?: string[];
}

export interface SafetyCheck {
  passed: boolean;
  warnings: string[];
  contraindications: string[];
  adjustedRecommendations: string[];
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
}

export interface AllergyCheckResult {
  hasConflict: boolean;
  conflictingMeds: string[];
  alternatives: string[];
}

export interface DrugInteractionCheck {
  hasInteraction: boolean;
  interactions: string[];
  conflictingMeds: string[];
}

export interface ConditionCheck {
  hasRisk: boolean;
  conditions: string[];
  recommendations: string[];
}

export class PatientSafetyService {
  private patientRepository = AppDataSource.getRepository(Patient);

  // Drug allergy database
  private allergyDatabase: Record<string, { drugs: string[]; alternatives: string[] }> = {
    'penicillin': {
      drugs: ['amoxicillin', 'ampicillin', 'penicillin', 'augmentin'],
      alternatives: ['azithromycin', 'ciprofloxacin', 'levofloxacin']
    },
    'sulfa': {
      drugs: ['sulfamethoxazole', 'trimethoprim', 'bactrim'],
      alternatives: ['doxycycline', 'levofloxacin', 'moxifloxacin']
    },
    'aspirin': {
      drugs: ['aspirin', 'ibuprofen', 'naproxen', 'diclofenac'],
      alternatives: ['acetaminophen', 'celecoxib', 'paracetamol']
    },
    'nsaid': {
      drugs: ['ibuprofen', 'naproxen', 'diclofenac', 'indomethacin'],
      alternatives: ['acetaminophen', 'tramadol', 'paracetamol']
    },
    'codeine': {
      drugs: ['codeine', 'hydrocodone', 'oxycodone'],
      alternatives: ['tramadol', 'acetaminophen', 'ibuprofen']
    }
  };

  // Drug interaction database
  private interactionDatabase: Record<string, { interactsWith: string[]; risk: string; severity: string }> = {
    'warfarin': {
      interactsWith: ['aspirin', 'ibuprofen', 'naproxen', 'vitamin k'],
      risk: 'Increased bleeding risk',
      severity: 'high'
    },
    'metformin': {
      interactsWith: ['contrast dye', 'alcohol'],
      risk: 'Lactic acidosis risk',
      severity: 'high'
    },
    'digoxin': {
      interactsWith: ['amiodarone', 'verapamil', 'quinidine'],
      risk: 'Digoxin toxicity',
      severity: 'high'
    },
    'ace inhibitor': {
      interactsWith: ['potassium', 'spironolactone', 'nsaid'],
      risk: 'Hyperkalemia or kidney damage',
      severity: 'medium'
    },
    'statin': {
      interactsWith: ['gemfibrozil', 'niacin', 'cyclosporine'],
      risk: 'Muscle damage (rhabdomyolysis)',
      severity: 'high'
    }
  };

  // Chronic condition considerations
  private conditionRisks: Record<string, { diseases: string[]; recommendations: string[] }> = {
    'diabetes': {
      diseases: ['infection', 'pneumonia', 'tuberculosis'],
      recommendations: [
        'Monitor blood sugar closely during treatment',
        'Adjust insulin dosage if needed',
        'Watch for signs of diabetic complications',
        'Ensure adequate hydration'
      ]
    },
    'hypertension': {
      diseases: ['heart attack', 'stroke', 'kidney disease'],
      recommendations: [
        'Monitor blood pressure regularly',
        'Avoid NSAIDs if possible (can raise BP)',
        'Consider cardiovascular risk factors',
        'Ensure medication compliance'
      ]
    },
    'kidney disease': {
      diseases: ['infection', 'dehydration', 'heart failure'],
      recommendations: [
        'Adjust medication dosage for renal function',
        'Avoid nephrotoxic drugs (NSAIDs, aminoglycosides)',
        'Monitor kidney function (creatinine, GFR)',
        'Ensure adequate but not excessive hydration'
      ]
    },
    'liver disease': {
      diseases: ['hepatitis', 'cirrhosis', 'infection'],
      recommendations: [
        'Avoid hepatotoxic drugs (acetaminophen in high doses)',
        'Adjust dosages for liver function',
        'Monitor liver enzymes',
        'Avoid alcohol completely'
      ]
    },
    'asthma': {
      diseases: ['respiratory infection', 'pneumonia', 'bronchitis'],
      recommendations: [
        'Avoid beta-blockers',
        'Avoid aspirin and NSAIDs (can trigger asthma)',
        'Ensure inhaler compliance',
        'Monitor respiratory status closely'
      ]
    },
    'heart disease': {
      diseases: ['heart attack', 'heart failure', 'arrhythmia'],
      recommendations: [
        'Monitor cardiac status closely',
        'Avoid drugs that increase cardiac workload',
        'Consider fluid balance carefully',
        'Watch for signs of heart failure'
      ]
    }
  };

  /**
   * Get complete patient context for safety checks
   */
  async getPatientContext(patientId: string): Promise<PatientContext | null> {
    try {
      const patient = await this.patientRepository.findOne({
        where: { id: patientId },
        select: [
          'id',
          'dateOfBirth',
          'gender',
          'allergies',
          'chronicConditions',
          'currentMedications'
        ]
      });

      if (!patient) {
        logger.error(`Patient not found: ${patientId}`);
        return null;
      }

      const age = this.calculateAge(patient.dateOfBirth);

      // Fetch past diagnoses (last 6 months)
      const pastDiagnoses = await this.getPastDiagnoses(patientId);

      // Extract recent symptoms from past diagnoses
      const recentSymptoms = this.extractRecentSymptoms(pastDiagnoses);

      return {
        patientId: patient.id,
        allergies: patient.allergies || [],
        chronicConditions: patient.chronicConditions || [],
        currentMedications: patient.currentMedications || [],
        age,
        gender: patient.gender,
        pastDiagnoses,
        recentSymptoms
      };
    } catch (error) {
      logger.error('Error fetching patient context:', error);
      throw error;
    }
  }

  /**
   * Get past diagnoses for pattern recognition
   */
  private async getPastDiagnoses(patientId: string): Promise<Array<{
    disease: string;
    diagnosisDate: string;
    medications?: string[];
  }>> {
    try {
      // Import Diagnosis entity dynamically to avoid circular dependency
      const { Diagnosis } = await import('../models/Diagnosis');
      const diagnosisRepository = AppDataSource.getRepository(Diagnosis);

      // Get diagnoses from last 6 months
      const sixMonthsAgo = new Date();
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

      const diagnoses = await diagnosisRepository.find({
        where: {
          patientId,
          createdAt: MoreThan(sixMonthsAgo) as any
        },
        order: {
          createdAt: 'DESC'
        },
        take: 10 // Last 10 diagnoses
      });

      return diagnoses.map(d => ({
        disease: d.selectedDiagnosis?.disease || 'Unknown',
        diagnosisDate: d.diagnosisDate.toISOString(),
        medications: [] // Would need to fetch from prescriptions
      }));
    } catch (error) {
      logger.warn('Could not fetch past diagnoses:', error);
      return [];
    }
  }

  /**
   * Extract recent symptoms from past diagnoses
   */
  private extractRecentSymptoms(pastDiagnoses: Array<{ disease: string }>): string[] {
    // This helps identify recurring patterns
    const symptoms: string[] = [];
    
    for (const diagnosis of pastDiagnoses) {
      const disease = diagnosis.disease.toLowerCase();
      
      // Map common diseases to their typical symptoms
      if (disease.includes('diabetes')) {
        symptoms.push('frequent urination', 'excessive thirst', 'fatigue');
      } else if (disease.includes('hypertension')) {
        symptoms.push('headache', 'dizziness');
      } else if (disease.includes('asthma')) {
        symptoms.push('shortness of breath', 'wheezing');
      }
    }
    
    return [...new Set(symptoms)]; // Remove duplicates
  }

  /**
   * Run comprehensive safety checks
   */
  async runSafetyChecks(
    suggestedMedications: string[],
    patientContext: PatientContext,
    predictedDisease: string
  ): Promise<SafetyCheck> {
    const warnings: string[] = [];
    const contraindications: string[] = [];
    const adjustedRecommendations: string[] = [];

    // Check 1: Allergies (CRITICAL)
    const allergyCheck = this.checkAllergies(
      suggestedMedications,
      patientContext.allergies
    );

    if (allergyCheck.hasConflict) {
      contraindications.push(
        `🚨 ALLERGY ALERT: Patient allergic to ${allergyCheck.conflictingMeds.join(', ')}`
      );
      adjustedRecommendations.push(
        `Use alternative medications: ${allergyCheck.alternatives.join(', ')}`
      );
    }

    // Check 2: Drug Interactions (CRITICAL)
    const drugCheck = this.checkDrugInteractions(
      suggestedMedications,
      patientContext.currentMedications
    );

    if (drugCheck.hasInteraction) {
      contraindications.push(
        `🚨 DRUG INTERACTION: ${drugCheck.interactions.join('; ')}`
      );
      adjustedRecommendations.push(
        `Avoid: ${drugCheck.conflictingMeds.join(', ')} due to interactions`
      );
    }

    // Check 3: Chronic Conditions (HIGH PRIORITY)
    const conditionCheck = this.checkChronicConditions(
      predictedDisease,
      patientContext.chronicConditions
    );

    if (conditionCheck.hasRisk) {
      warnings.push(
        `⚠️ Patient has ${conditionCheck.conditions.join(', ')} - requires special consideration`
      );
      adjustedRecommendations.push(...conditionCheck.recommendations);
    }

    // Check 4: Age-based Contraindications
    const ageCheck = this.checkAgeContraindications(
      suggestedMedications,
      patientContext.age
    );

    if (ageCheck.hasContraindication) {
      warnings.push(`⚠️ AGE CONSIDERATION: ${ageCheck.reason}`);
      adjustedRecommendations.push(...ageCheck.alternatives);
    }

    // Check 5: Past Diagnosis Patterns (NEW)
    const historyCheck = this.checkMedicalHistory(
      predictedDisease,
      patientContext.pastDiagnoses || []
    );

    if (historyCheck.hasPattern) {
      warnings.push(`📋 MEDICAL HISTORY: ${historyCheck.pattern}`);
      adjustedRecommendations.push(...historyCheck.recommendations);
    }

    // Determine risk level
    const riskLevel = this.determineRiskLevel(
      contraindications.length,
      warnings.length
    );

    const passed = contraindications.length === 0;

    return {
      passed,
      warnings,
      contraindications,
      adjustedRecommendations,
      riskLevel
    };
  }

  /**
   * Check for drug allergies
   */
  private checkAllergies(
    suggestedMeds: string[],
    patientAllergies: string[]
  ): AllergyCheckResult {
    const conflictingMeds: string[] = [];
    const alternatives: string[] = [];

    for (const allergy of patientAllergies) {
      const allergyInfo = this.allergyDatabase[allergy.toLowerCase()];

      if (allergyInfo) {
        for (const med of suggestedMeds) {
          const medLower = med.toLowerCase();
          if (allergyInfo.drugs.some(drug => medLower.includes(drug))) {
            conflictingMeds.push(med);
            alternatives.push(...allergyInfo.alternatives);
          }
        }
      }
    }

    return {
      hasConflict: conflictingMeds.length > 0,
      conflictingMeds,
      alternatives: [...new Set(alternatives)]
    };
  }

  /**
   * Check for drug interactions
   */
  private checkDrugInteractions(
    suggestedMeds: string[],
    currentMeds: string[]
  ): DrugInteractionCheck {
    const interactions: string[] = [];
    const conflictingMeds: string[] = [];

    for (const currentMed of currentMeds) {
      const medLower = currentMed.toLowerCase();
      
      // Check each interaction pattern
      for (const [drugClass, interaction] of Object.entries(this.interactionDatabase)) {
        if (medLower.includes(drugClass)) {
          for (const suggestedMed of suggestedMeds) {
            const suggestedLower = suggestedMed.toLowerCase();
            
            if (interaction.interactsWith.some(drug => suggestedLower.includes(drug))) {
              interactions.push(
                `${currentMed} + ${suggestedMed}: ${interaction.risk} (${interaction.severity} severity)`
              );
              conflictingMeds.push(suggestedMed);
            }
          }
        }
      }
    }

    return {
      hasInteraction: interactions.length > 0,
      interactions,
      conflictingMeds: [...new Set(conflictingMeds)]
    };
  }

  /**
   * Check chronic conditions
   */
  private checkChronicConditions(
    disease: string,
    conditions: string[]
  ): ConditionCheck {
    const risks: string[] = [];
    const recommendations: string[] = [];

    for (const condition of conditions) {
      const conditionLower = condition.toLowerCase();
      const risk = this.conditionRisks[conditionLower];

      if (risk) {
        const diseaseLower = disease.toLowerCase();
        if (risk.diseases.some(d => diseaseLower.includes(d))) {
          risks.push(condition);
          recommendations.push(...risk.recommendations);
        }
      }
    }

    return {
      hasRisk: risks.length > 0,
      conditions: risks,
      recommendations: [...new Set(recommendations)]
    };
  }

  /**
   * Check age-based contraindications
   */
  private checkAgeContraindications(
    medications: string[],
    age: number
  ): { hasContraindication: boolean; reason: string; alternatives: string[] } {
    const contraindications: string[] = [];
    const alternatives: string[] = [];

    // Pediatric considerations (< 18 years)
    if (age < 18) {
      for (const med of medications) {
        const medLower = med.toLowerCase();
        
        if (medLower.includes('aspirin')) {
          contraindications.push('Aspirin not recommended for children (Reye\'s syndrome risk)');
          alternatives.push('Use acetaminophen or ibuprofen instead');
        }
        
        if (medLower.includes('tetracycline') || medLower.includes('doxycycline')) {
          contraindications.push('Tetracyclines can affect bone/tooth development in children');
          alternatives.push('Use alternative antibiotics (amoxicillin, azithromycin)');
        }
      }
    }

    // Geriatric considerations (> 65 years)
    if (age > 65) {
      for (const med of medications) {
        const medLower = med.toLowerCase();
        
        if (medLower.includes('benzodiazepine') || medLower.includes('diazepam')) {
          contraindications.push('Benzodiazepines increase fall risk in elderly');
          alternatives.push('Consider non-benzodiazepine alternatives or lower doses');
        }
        
        if (medLower.includes('nsaid') || medLower.includes('ibuprofen')) {
          contraindications.push('NSAIDs increase GI bleeding and kidney damage risk in elderly');
          alternatives.push('Use acetaminophen or lower NSAID doses with monitoring');
        }
      }
    }

    return {
      hasContraindication: contraindications.length > 0,
      reason: contraindications.join('; '),
      alternatives
    };
  }

  /**
   * Determine overall risk level
   */
  private determineRiskLevel(
    contraindicationCount: number,
    warningCount: number
  ): 'low' | 'medium' | 'high' | 'critical' {
    if (contraindicationCount > 0) {
      return 'critical';
    }
    if (warningCount >= 3) {
      return 'high';
    }
    if (warningCount >= 1) {
      return 'medium';
    }
    return 'low';
  }

  /**
   * Calculate age from date of birth
   */
  private calculateAge(dateOfBirth: Date): number {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }

  /**
   * Check medical history for patterns and recurring issues
   */
  private checkMedicalHistory(
    currentDisease: string,
    pastDiagnoses: Array<{ disease: string; diagnosisDate: string }>
  ): { hasPattern: boolean; pattern: string; recommendations: string[] } {
    const recommendations: string[] = [];
    let pattern = '';
    let hasPattern = false;

    if (pastDiagnoses.length === 0) {
      return { hasPattern: false, pattern: '', recommendations: [] };
    }

    const currentDiseaseLower = currentDisease.toLowerCase();
    const pastDiseases = pastDiagnoses.map(d => d.disease.toLowerCase());

    // Check for recurring infections
    const infectionCount = pastDiagnoses.filter(d => 
      d.disease.toLowerCase().includes('infection')
    ).length;

    if (infectionCount >= 2 && currentDiseaseLower.includes('infection')) {
      hasPattern = true;
      pattern = `Recurring infections (${infectionCount} in past 6 months)`;
      recommendations.push(
        'Consider immune system evaluation',
        'Check for underlying conditions (diabetes, HIV)',
        'Ensure complete antibiotic courses',
        'Review hygiene and prevention measures'
      );
    }

    // Check for same disease recurrence
    const sameDisease = pastDiagnoses.find(d => 
      d.disease.toLowerCase() === currentDiseaseLower
    );

    if (sameDisease) {
      hasPattern = true;
      const daysSince = Math.floor(
        (new Date().getTime() - new Date(sameDisease.diagnosisDate).getTime()) / 
        (1000 * 60 * 60 * 24)
      );
      pattern = `Recurrence of ${currentDisease} (last occurrence ${daysSince} days ago)`;
      recommendations.push(
        'Investigate why previous treatment failed',
        'Consider antibiotic resistance testing',
        'Review patient compliance with previous treatment',
        'May need longer or different treatment course'
      );
    }

    // Check for related conditions
    if (currentDiseaseLower.includes('pneumonia') && 
        pastDiseases.some(d => d.includes('bronchitis') || d.includes('asthma'))) {
      hasPattern = true;
      pattern = 'History of respiratory conditions';
      recommendations.push(
        'Monitor respiratory function closely',
        'Consider chest X-ray',
        'May need respiratory specialist referral',
        'Ensure proper inhaler technique if applicable'
      );
    }

    // Check for diabetes-related complications
    if (pastDiseases.some(d => d.includes('diabetes'))) {
      if (currentDiseaseLower.includes('infection') || 
          currentDiseaseLower.includes('wound') ||
          currentDiseaseLower.includes('ulcer')) {
        hasPattern = true;
        pattern = 'Diabetic patient with infection/wound';
        recommendations.push(
          'Check blood sugar levels',
          'Ensure good glycemic control',
          'Monitor wound healing closely',
          'Consider longer antibiotic course'
        );
      }
    }

    // Check for cardiovascular history
    if (pastDiseases.some(d => d.includes('heart') || d.includes('hypertension'))) {
      if (currentDiseaseLower.includes('chest pain') || 
          currentDiseaseLower.includes('heart')) {
        hasPattern = true;
        pattern = 'History of cardiovascular disease';
        recommendations.push(
          'Urgent ECG required',
          'Check cardiac enzymes',
          'Consider cardiology referral',
          'Monitor blood pressure closely'
        );
      }
    }

    return {
      hasPattern,
      pattern,
      recommendations: [...new Set(recommendations)]
    };
  }
}

export const patientSafetyService = new PatientSafetyService();
