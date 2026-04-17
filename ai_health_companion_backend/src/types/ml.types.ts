/**
 * ML Model Integration Types
 */

export interface ModelMetadata {
    version: string;
    diseaseLabels: string[];
    icd10Codes: Record<string, string>;
    featureSpecs: {
        inputDim: number;
        vitalDim: number;
        demographicDim: number;
        symptomDim: number;
        symptomCategories: string[];
        vitalRanges: Record<string, { min: number; max: number }>;
        ageRange: { min: number; max: number };
    };
    normalizationParams: {
        vitalRanges: Record<string, { min: number; max: number }>;
        ageRange: { min: number; max: number };
    };
    trainingDate: string;
    accuracy: number;
    confidenceThreshold: number;
}

export interface FeatureVector {
    vitals: number[];
    demographics: number[];
    symptoms: number[];
}

export interface PredictionResult {
    predictions: Array<{
        disease: string;
        confidence: number;
        icd10Code?: string;
        recommendations?: string[];
    }>;
    method: 'ml' | 'rule-based';
    fallbackReason?: string;
    inferenceTime?: number;
    modelVersion?: string;
}

export interface ABTestConfig {
    enabled: boolean;
    mlTrafficPercentage: number;
    logComparisons: boolean;
}

export interface ABTestResult {
    requestId: string;
    mlPredictions: any[];
    ruleBasedPredictions: any[];
    selectedMethod: 'ml' | 'rule-based';
    timestamp: Date;
    patientAge?: number;
    patientGender?: string;
}

export interface ModelVersion {
    version: string;
    path: string;
    accuracy: number;
    deployedAt: Date;
    isActive: boolean;
}

export interface PredictionLog {
    id: string;
    timestamp: Date;
    input: any;
    predictions: any[];
    method: 'ml' | 'rule-based';
    inferenceTime: number;
    modelVersion?: string;
}

export interface PerformanceMetrics {
    totalPredictions: number;
    mlPredictions: number;
    ruleBasedPredictions: number;
    averageInferenceTime: number;
    rollingAccuracy?: number;
    accuracyByDisease?: Record<string, number>;
}
