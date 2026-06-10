/**
 * Chronic Conditions List
 * 
 * This file contains a comprehensive list of chronic diseases that require
 * long-term management and specialized medical care.
 * 
 * Used by the diagnosis-history service to detect if a patient's diagnosis
 * matches a chronic condition for targeted clinic recommendations.
 */

export const CHRONIC_CONDITIONS = [
  // Metabolic & Endocrine Disorders
  'Diabetes',
  'Diabetes ',  // Note: Dataset has trailing space
  'Hypothyroidism',
  'Hyperthyroidism',
  'Hypoglycemia',
  
  // Cardiovascular Diseases
  'Hypertension',
  'Hypertension ',  // Note: Dataset has trailing space
  'Heart attack',
  'Heart disease',
  'Varicose veins',
  
  // Respiratory Conditions
  'Bronchial Asthma',
  'Asthma',
  'COPD',
  'Chronic Obstructive Pulmonary Disease',
  
  // Liver & Digestive Disorders
  'Chronic cholestasis',
  'Hepatitis B',
  'Hepatitis C',
  'Hepatitis D',
  'Cirrhosis',
  'GERD',
  'Peptic ulcer diseae',  // Note: Typo in dataset
  'Peptic ulcer disease',
  
  // Autoimmune & Inflammatory
  'Arthritis',
  'Rheumatoid Arthritis',
  'Osteoarthristis',  // Note: Typo in dataset
  'Osteoarthritis',
  'Psoriasis',
  'Cervical spondylosis',
  
  // Neurological Disorders
  'Migraine',
  'Epilepsy',
  'Paralysis (brain hemorrhage)',
  'Parkinson\'s Disease',
  'Alzheimer\'s Disease',
  '(vertigo) Paroymsal  Positional Vertigo',
  
  // Kidney & Urinary
  'Chronic Kidney Disease',
  'CKD',
  'Kidney failure',
  
  // Infectious Diseases (Chronic)
  'AIDS',
  'HIV',
  'Tuberculosis',
  'TB',
  
  // Other Chronic Conditions
  'Dimorphic hemmorhoids(piles)',  // Note: Typo in dataset
  'Hemorrhoids',
  'Piles',
  'Chronic pain',
  'Fibromyalgia',
  'Chronic Fatigue Syndrome',
] as const;

/**
 * Check if a disease is considered chronic
 */
export function isChronicCondition(diseaseName: string): boolean {
  const normalizedDisease = diseaseName.toLowerCase().trim();
  return CHRONIC_CONDITIONS.some(
    condition => condition.toLowerCase().trim() === normalizedDisease
  );
}

/**
 * Get all chronic conditions as array
 */
export function getAllChronicConditions(): string[] {
  return [...CHRONIC_CONDITIONS];
}

export default CHRONIC_CONDITIONS;
