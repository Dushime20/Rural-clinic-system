import { logger } from '../utils/logger';
import { flaskMLService } from './flask-ml.service';

export interface DiagnosisInput {
    symptoms: Array<{ name: string; category: string; severity?: string }>;
    vitalSigns: {
        temperature?: number;
        bloodPressureSystolic?: number;
        bloodPressureDiastolic?: number;
        heartRate?: number;
        respiratoryRate?: number;
        oxygenSaturation?: number;
    };
    age: number;
    gender: string;
    medicalHistory?: string[];
}

export interface Prediction {
    disease: string;
    confidence: number;
    icd10Code?: string;
    recommendations?: string[];
    // Full disease information from Flask
    description?: string;
    precautions?: string[];
    medications?: string[];
    diet?: string[];
    workout?: string[];
}

export class AIService {
    constructor() {
        logger.info('AI Service initialized - using Flask ML service only');
        this.verifyFlaskMLConfiguration();
    }

    private verifyFlaskMLConfiguration(): void {
        const useFlask = process.env.USE_FLASK_ML_SERVICE === 'true';
        const flaskUrl = process.env.FLASK_ML_SERVICE_URL || 'http://localhost:5001';
        
        if (!useFlask) {
            logger.warn('⚠️  Flask ML service is DISABLED. Set USE_FLASK_ML_SERVICE=true to enable.');
        } else {
            logger.info(`✓ Flask ML service enabled at ${flaskUrl}`);
        }
    }

    public async predictDisease(input: DiagnosisInput): Promise<Prediction[]> {
        // Always use Flask ML service - no fallback to rule-based predictions
        const useFlask = process.env.USE_FLASK_ML_SERVICE === 'true';
        
        if (!useFlask) {
            const error = new Error(
                'ML service is disabled. Please enable USE_FLASK_ML_SERVICE in environment variables.'
            );
            logger.error('ML service disabled:', error.message);
            throw error;
        }

        try {
            // Check if Flask ML service is healthy
            const isHealthy = await flaskMLService.healthCheck();
            
            if (!isHealthy) {
                const error = new Error(
                    'ML prediction service is currently unavailable. The AI model may be offline or not responding. Please ensure the Flask ML service is running on port 5001.'
                );
                logger.error('Flask ML service health check failed');
                throw error;
            }

            // Use Flask ML service for prediction
            logger.info('Using Flask ML service for prediction');
            const symptomNames = input.symptoms.map(s => s.name);
            
            const flaskResult = await flaskMLService.predictDisease(
                symptomNames,
                input.vitalSigns,
                { age: input.age, gender: input.gender }
            );

            // Use top_predictions if available, otherwise fall back to single prediction
            const rawPredictions: Array<{ disease: string; confidence: number; icd10Code?: string }> =
                (flaskResult as any).top_predictions?.length
                    ? (flaskResult as any).top_predictions
                    : [{ 
                        disease: flaskResult.prediction.disease, 
                        confidence: flaskResult.prediction.confidence, 
                        icd10Code: flaskResult.prediction.icd10Code 
                    }];

            const predictions: Prediction[] = rawPredictions.map((p, index) => ({
                disease: p.disease.trim(),
                confidence: p.confidence,
                icd10Code: p.icd10Code,
                // Full disease info only on primary prediction
                ...(index === 0 ? {
                    description: flaskResult.information.description,
                    precautions: flaskResult.information.precautions,
                    medications: flaskResult.information.medications,
                    diet: flaskResult.information.diet,
                    workout: flaskResult.information.workout,
                    recommendations: [
                        ...flaskResult.information.precautions,
                        ...flaskResult.information.medications.slice(0, 3)
                    ].filter(Boolean),
                } : {})
            }));

            logger.info(
                `Flask ML predictions: ${predictions.map(p => `${p.disease}(${(p.confidence * 100).toFixed(1)}%)`).join(', ')}`
            );
            
            return predictions;
            
        } catch (error: any) {
            // Provide clear error messages for different failure scenarios
            if (error.message?.includes('ECONNREFUSED')) {
                const enhancedError = new Error(
                    'Cannot connect to ML prediction service. Please ensure the Flask ML service is running on port 5001. Start it with: cd model-training && python api.py'
                );
                logger.error('Flask ML service connection refused:', error.message);
                throw enhancedError;
            }
            
            if (error.message?.includes('timeout')) {
                const enhancedError = new Error(
                    'ML prediction service timed out. The model may be overloaded or experiencing issues. Please try again or check the Flask ML service logs.'
                );
                logger.error('Flask ML service timeout:', error.message);
                throw enhancedError;
            }
            
            if (error.message?.includes('No valid symptoms')) {
                const enhancedError = new Error(
                    'No valid symptoms were recognized by the ML model. Please check symptom names and try again.'
                );
                logger.error('Invalid symptoms provided:', error.message);
                throw enhancedError;
            }
            
            // If Flask returned a specific error message (success: false), pass it through
            if (error.message?.includes('Flask ML prediction failed:')) {
                logger.error('Flask ML service returned error:', error.message);
                throw error; // Pass through the Flask error message as-is
            }
            
            // Re-throw the error with context
            logger.error('Flask ML service prediction failed:', error);
            throw new Error(
                'AI diagnosis service is currently unavailable. Please contact your system administrator.'
            );
        }
    }
}
