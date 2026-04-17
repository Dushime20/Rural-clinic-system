/**
 * ML Configuration
 * 
 * Configuration for ML model integration.
 */

import path from 'path';

export const mlConfig = {
    // Model paths
    modelBasePath: path.join(__dirname, '../../models'),
    activeModelVersion: process.env.ML_MODEL_VERSION || 'v1.0.0',
    
    // Inference settings
    confidenceThreshold: parseFloat(process.env.ML_CONFIDENCE_THRESHOLD || '0.6'),
    maxPredictions: parseInt(process.env.ML_MAX_PREDICTIONS || '5'),
    inferenceTimeout: parseInt(process.env.ML_INFERENCE_TIMEOUT || '2000'), // ms
    
    // A/B Testing
    abTesting: {
        enabled: process.env.ML_AB_TESTING_ENABLED === 'true',
        mlTrafficPercentage: parseFloat(process.env.ML_AB_TRAFFIC_PERCENTAGE || '50'),
        logComparisons: process.env.ML_AB_LOG_COMPARISONS !== 'false'
    },
    
    // Performance monitoring
    monitoring: {
        enabled: process.env.ML_MONITORING_ENABLED !== 'false',
        accuracyThreshold: parseFloat(process.env.ML_ACCURACY_THRESHOLD || '0.85'),
        alertOnLowAccuracy: process.env.ML_ALERT_ON_LOW_ACCURACY !== 'false'
    },
    
    // Feature flags
    features: {
        useMLModel: process.env.ML_USE_MODEL !== 'false',
        fallbackEnabled: process.env.ML_FALLBACK_ENABLED !== 'false',
        versioningEnabled: process.env.ML_VERSIONING_ENABLED !== 'false'
    }
};

export function getModelPath(version?: string): string {
    const modelVersion = version || mlConfig.activeModelVersion;
    return path.join(mlConfig.modelBasePath, modelVersion);
}

export function getMetadataPath(version?: string): string {
    return path.join(getModelPath(version), 'metadata.json');
}
