/**
 * Fallback Mechanism
 * 
 * Handles ML model failures and falls back to rule-based predictions.
 */

import { logger } from '../../utils/logger';
import { DiagnosisInput, Prediction } from '../ai.service';
import { PredictionResult } from '../../types/ml.types';
import { InferenceEngine } from './inference-engine';

export class FallbackMechanism {
    constructor(
        private mlPredictor: InferenceEngine | null,
        private ruleBasedPredictor: (input: DiagnosisInput) => Promise<Prediction[]>
    ) {}

    async predict(input: DiagnosisInput): Promise<PredictionResult> {
        // Try ML prediction first
        if (this.mlPredictor) {
            const mlResult = await this.tryMLPrediction(input);
            if (mlResult) {
                return {
                    predictions: mlResult,
                    method: 'ml'
                };
            }
        }

        // Fallback to rule-based
        logger.info('Using rule-based fallback for prediction');
        const ruleBasedPredictions = await this.fallbackToRuleBased(input, new Error('ML model not available'));
        
        return {
            predictions: ruleBasedPredictions,
            method: 'rule-based',
            fallbackReason: 'ML model not available or failed'
        };
    }

    private async tryMLPrediction(input: DiagnosisInput): Promise<Prediction[] | null> {
        try {
            if (!this.mlPredictor) {
                return null;
            }

            const predictions = await this.mlPredictor.predict(input);
            return predictions;
        } catch (error) {
            logger.error('ML prediction failed:', error);
            this.logFallback(error as Error, input);
            return null;
        }
    }

    private async fallbackToRuleBased(input: DiagnosisInput, error: Error): Promise<Prediction[]> {
        try {
            this.logFallback(error, input);
            return await this.ruleBasedPredictor(input);
        } catch (fallbackError) {
            logger.error('Rule-based fallback also failed:', fallbackError);
            throw new Error('Both ML and rule-based predictions failed');
        }
    }

    private logFallback(error: Error, input: DiagnosisInput): void {
        logger.warn('Fallback mechanism activated', {
            error: error.message,
            inputAge: input.age,
            inputGender: input.gender,
            symptomCount: input.symptoms.length,
            timestamp: new Date().toISOString()
        });
    }

    setMLPredictor(predictor: InferenceEngine): void {
        this.mlPredictor = predictor;
    }
}
