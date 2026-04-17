/**
 * Inference Engine
 * 
 * Performs model inference and preprocessing of input data.
 */

import * as tf from '@tensorflow/tfjs';
import { logger } from '../../utils/logger';
import { ModelMetadata, FeatureVector } from '../../types/ml.types';
import { DiagnosisInput, Prediction } from '../ai.service';

export class InferenceEngine {
    constructor(
        private model: tf.GraphModel,
        private metadata: ModelMetadata
    ) {}

    async predict(input: DiagnosisInput, confidenceThreshold?: number): Promise<Prediction[]> {
        const startTime = Date.now();
        
        try {
            // Preprocess input
            const featureVector = this.preprocessInput(input);
            
            // Run inference
            const predictions = await this.runInference(featureVector);
            
            // Filter by confidence threshold
            const threshold = confidenceThreshold || this.metadata.confidenceThreshold || 0.6;
            const filteredPredictions = this.filterByConfidence(predictions, threshold);
            
            // Map to disease objects
            const result = this.mapToDiseases(filteredPredictions);
            
            const inferenceTime = Date.now() - startTime;
            logger.info(`Inference completed in ${inferenceTime}ms, ${result.length} predictions`);
            
            return result;
        } catch (error) {
            logger.error('Inference failed:', error);
            throw error;
        }
    }

    preprocessInput(input: DiagnosisInput): FeatureVector {
        const vitals = this.normalizeVitals(input.vitalSigns);
        const demographics = this.encodeDemographics(input.age, input.gender);
        const symptoms = this.encodeSymptoms(input.symptoms);

        return { vitals, demographics, symptoms };
    }

    encodeSymptoms(symptoms: Array<{ name: string; category: string }>): number[] {
        const categories = this.metadata.featureSpecs.symptomCategories;
        const encoding = new Array(categories.length).fill(0);

        symptoms.forEach(symptom => {
            const category = symptom.category.toLowerCase();
            const index = categories.indexOf(category);
            if (index !== -1) {
                encoding[index] = 1;
            }
        });

        return encoding;
    }

    normalizeVitals(vitals: DiagnosisInput['vitalSigns']): number[] {
        const ranges = this.metadata.normalizationParams.vitalRanges;
        const normalized: number[] = [];

        const vitalKeys = [
            'temperature',
            'bloodPressureSystolic',
            'bloodPressureDiastolic',
            'heartRate',
            'respiratoryRate',
            'oxygenSaturation'
        ];

        vitalKeys.forEach(key => {
            const value = vitals[key as keyof typeof vitals];
            if (value !== undefined && ranges[key]) {
                const { min, max } = ranges[key];
                const normalizedValue = (value - min) / (max - min);
                normalized.push(Math.max(0, Math.min(1, normalizedValue)));
            } else {
                normalized.push(0.5); // Default middle value
            }
        });

        return normalized;
    }

    encodeDemographics(age: number, gender: string): number[] {
        const { min, max } = this.metadata.normalizationParams.ageRange;
        const normalizedAge = Math.max(0, Math.min(1, (age - min) / (max - min)));

        const genderLower = gender.toLowerCase();
        const genderMale = genderLower === 'male' ? 1 : 0;
        const genderFemale = genderLower === 'female' ? 1 : 0;

        return [normalizedAge, genderMale, genderFemale];
    }

    async runInference(featureVector: FeatureVector): Promise<number[]> {
        // Concatenate all features
        const features = [
            ...featureVector.vitals,
            ...featureVector.demographics,
            ...featureVector.symptoms
        ];

        // Create tensor
        const inputTensor = tf.tensor2d([features], [1, features.length]);

        try {
            // Run model prediction
            const outputTensor = this.model.predict(inputTensor) as tf.Tensor;
            const predictions = await outputTensor.data();
            
            // Clean up tensors
            inputTensor.dispose();
            outputTensor.dispose();

            return Array.from(predictions);
        } catch (error) {
            inputTensor.dispose();
            throw error;
        }
    }

    filterByConfidence(predictions: number[], threshold: number): Array<{ index: number; confidence: number }> {
        return predictions
            .map((confidence, index) => ({ index, confidence }))
            .filter(p => p.confidence >= threshold)
            .sort((a, b) => b.confidence - a.confidence)
            .slice(0, 5); // Top 5 predictions
    }

    mapToDiseases(predictions: Array<{ index: number; confidence: number }>): Prediction[] {
        return predictions.map(p => ({
            disease: this.metadata.diseaseLabels[p.index],
            confidence: p.confidence,
            icd10Code: this.metadata.icd10Codes[this.metadata.diseaseLabels[p.index]] || 'R69',
            recommendations: this.getRecommendations(this.metadata.diseaseLabels[p.index])
        }));
    }

    private getRecommendations(disease: string): string[] {
        // This could be loaded from a database or configuration file
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
