import * as tf from '@tensorflow/tfjs';
import { config } from '../config';
import { logger } from '../utils/logger';
import { mlConfig, getModelPath, getMetadataPath } from '../config/ml.config';
import { ModelLoader } from './ml/model-loader';
import { InferenceEngine } from './ml/inference-engine';
import { FallbackMechanism } from './ml/fallback-mechanism';
import { PredictionResult } from '../types/ml.types';

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
}

export class AIService {
    private modelLoader: ModelLoader | null = null;
    private inferenceEngine: InferenceEngine | null = null;
    private fallbackMechanism: FallbackMechanism;
    private isModelLoaded: boolean = false;

    constructor() {
        // Initialize fallback mechanism with rule-based predictor
        this.fallbackMechanism = new FallbackMechanism(
            null,
            this.ruleBasedPredict.bind(this)
        );
        
        this.initializeModel();
    }

    private async initializeModel(): Promise<void> {
        try {
            logger.info('Initializing AI model...');

            if (!mlConfig.features.useMLModel) {
                logger.info('ML model disabled, using rule-based predictions only');
                this.isModelLoaded = false;
                return;
            }

            // Load ML model
            const modelPath = getModelPath();
            const metadataPath = getMetadataPath();

            this.modelLoader = new ModelLoader(modelPath, metadataPath);
            
            try {
                await this.modelLoader.loadModel();
                await this.modelLoader.loadMetadata();

                // Create inference engine
                this.inferenceEngine = new InferenceEngine(
                    this.modelLoader.getModel(),
                    this.modelLoader.getMetadata()
                );

                // Update fallback mechanism
                this.fallbackMechanism.setMLPredictor(this.inferenceEngine);

                this.isModelLoaded = true;
                logger.info('ML model initialized successfully');
            } catch (modelError) {
                logger.error('Failed to load ML model, will use rule-based fallback:', modelError);
                this.isModelLoaded = false;
            }
        } catch (error) {
            logger.error('Failed to initialize AI model:', error);
            this.isModelLoaded = false;
        }
    }

    public async predictDisease(input: DiagnosisInput): Promise<Prediction[]> {
        try {
            const startTime = Date.now();

            // Use fallback mechanism (handles both ML and rule-based)
            const result: PredictionResult = await this.fallbackMechanism.predict(input);

            const inferenceTime = Date.now() - startTime;
            
            logger.info(
                `Prediction completed using ${result.method} method in ${inferenceTime}ms, ` +
                `${result.predictions.length} diseases predicted`
            );

            // Log if fallback was used
            if (result.method === 'rule-based' && result.fallbackReason) {
                logger.warn(`Fallback reason: ${result.fallbackReason}`);
            }

            return result.predictions;
        } catch (error) {
            logger.error('Error during disease prediction:', error);
            throw error;
        }
    }

    /**
     * Rule-based prediction (fallback method)
     */
    private async ruleBasedPredict(input: DiagnosisInput): Promise<Prediction[]> {
        logger.info('Using rule-based prediction');
        
        const predictions = this.mockPredict(input);

        // Filter by confidence threshold and get top predictions
        const filteredPredictions = predictions
            .filter(p => p.confidence >= config.aiModelConfidenceThreshold)
            .sort((a, b) => b.confidence - a.confidence)
            .slice(0, config.aiMaxPredictions);

        return filteredPredictions;
    }

    /*
    private preprocessInput(input: DiagnosisInput): number[] {
        // This is now handled by InferenceEngine
        // Kept for reference
    }

    private normalize(value: number, min: number, max: number): number {
        return (value - min) / (max - min);
    }
    */

    private mockPredict(input: DiagnosisInput): Prediction[] {
        // Mock prediction logic based on symptoms
        const predictions: Prediction[] = [];
        const symptomNames = input.symptoms.map(s => s.name.toLowerCase());

        // Simple rule-based mock predictions
        if (symptomNames.some(s => s.includes('fever') || s.includes('cough'))) {
            predictions.push({
                disease: 'Common Cold',
                confidence: 0.75,
                icd10Code: 'J00'
            });
            predictions.push({
                disease: 'Influenza',
                confidence: 0.68,
                icd10Code: 'J11'
            });
        }

        if (input.vitalSigns.temperature && input.vitalSigns.temperature > 38.5) {
            predictions.push({
                disease: 'Malaria',
                confidence: 0.72,
                icd10Code: 'B54'
            });
        }

        if (input.vitalSigns.bloodPressureSystolic && input.vitalSigns.bloodPressureSystolic > 140) {
            predictions.push({
                disease: 'Hypertension',
                confidence: 0.82,
                icd10Code: 'I10'
            });
        }

        if (symptomNames.some(s => s.includes('diarrhea') || s.includes('vomiting'))) {
            predictions.push({
                disease: 'Gastroenteritis',
                confidence: 0.78,
                icd10Code: 'A09'
            });
        }

        if (predictions.length === 0) {
            predictions.push({
                disease: 'Common Cold',
                confidence: 0.65,
                icd10Code: 'J00',
                recommendations: this.getRecommendations('Common Cold')
            });
        } else {
            // Add recommendations to all predictions
            predictions.forEach(p => {
                p.recommendations = this.getRecommendations(p.disease);
            });
        }

        return predictions;
    }

    private getRecommendations(disease: string): string[] {
        const recommendationsMap: Record<string, string[]> = {
            'Common Cold': [
                'Rest and adequate sleep',
                'Increase fluid intake',
                'Over-the-counter pain relievers if needed',
                'Monitor symptoms for 7-10 days'
            ],
            'Influenza': [
                'Antiviral medication within 48 hours of symptom onset',
                'Complete bed rest',
                'Isolation to prevent spread',
                'Monitor for complications'
            ],
            'Malaria': [
                'Immediate antimalarial treatment',
                'Blood test confirmation recommended',
                'Monitor for severe symptoms',
                'Prevent mosquito bites'
            ],
            'Hypertension': [
                'Lifestyle modifications (diet, exercise)',
                'Regular blood pressure monitoring',
                'Consider antihypertensive medication',
                'Follow-up in 2-4 weeks'
            ],
            'Gastroenteritis': [
                'Oral rehydration therapy',
                'BRAT diet (Bananas, Rice, Applesauce, Toast)',
                'Avoid dairy and fatty foods',
                'Monitor for dehydration signs'
            ]
        };

        return recommendationsMap[disease] || [
            'Consult with healthcare provider',
            'Monitor symptoms closely',
            'Follow prescribed treatment plan',
            'Schedule follow-up visit'
        ];
    }
}
