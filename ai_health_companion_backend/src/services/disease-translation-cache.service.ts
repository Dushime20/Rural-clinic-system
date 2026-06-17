/**
 * Disease Translation Cache Service
 * Provides instant access to pre-translated disease information
 * Eliminates the need for real-time Mbaza API calls during diagnosis
 */

import fs from 'fs';
import path from 'path';
import logger from '../utils/logger';

interface DiseaseTranslation {
    originalName: string;
    translatedName: string;
    description: string;
    medications: string[];
    diet: string[];
    workout: string[];
    precautions: string[];
}

interface TranslationCache {
    generatedAt: string;
    language: string;
    totalDiseases: number;
    translations: Record<string, DiseaseTranslation>;
}

class DiseaseTranslationCacheService {
    private cache: TranslationCache | null = null;
    private cacheFilePath: string;
    private isLoaded: boolean = false;

    constructor() {
        this.cacheFilePath = path.join(
            __dirname,
            '../../data/disease-translations-kinyarwanda.json'
        );
        this.loadCache();
    }

    /**
     * Load translation cache from JSON file
     */
    private loadCache(): void {
        try {
            if (!fs.existsSync(this.cacheFilePath)) {
                logger.warn(`Translation cache file not found: ${this.cacheFilePath}`);
                logger.info('Run: npm run translate-diseases to generate the cache');
                return;
            }

            const data = fs.readFileSync(this.cacheFilePath, 'utf-8');
            this.cache = JSON.parse(data);
            this.isLoaded = true;

            logger.info(
                `✅ Loaded translation cache: ${this.cache?.totalDiseases} diseases (Generated: ${this.cache?.generatedAt})`
            );
        } catch (error) {
            logger.error('Failed to load translation cache:', error);
            this.cache = null;
            this.isLoaded = false;
        }
    }

    /**
     * Reload cache from disk (useful after regenerating translations)
     */
    public reloadCache(): void {
        this.loadCache();
    }

    /**
     * Check if cache is available
     */
    public isCacheAvailable(): boolean {
        return this.isLoaded && this.cache !== null;
    }

    /**
     * Get translation for a specific disease
     */
    public getDiseaseTranslation(diseaseName: string): DiseaseTranslation | null {
        if (!this.isCacheAvailable()) {
            logger.warn('Translation cache not available');
            return null;
        }

        const translation = this.cache!.translations[diseaseName];
        if (!translation) {
            logger.warn(`No translation found for disease: ${diseaseName}`);
            return null;
        }

        return translation;
    }

    /**
     * Get translated disease name
     */
    public getTranslatedDiseaseName(diseaseName: string): string | null {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.translatedName || null;
    }

    /**
     * Get translated description
     */
    public getTranslatedDescription(diseaseName: string): string | null {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.description || null;
    }

    /**
     * Get translated medications
     */
    public getTranslatedMedications(diseaseName: string): string[] {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.medications || [];
    }

    /**
     * Get translated diet recommendations
     */
    public getTranslatedDiet(diseaseName: string): string[] {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.diet || [];
    }

    /**
     * Get translated workout recommendations
     */
    public getTranslatedWorkout(diseaseName: string): string[] {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.workout || [];
    }

    /**
     * Get translated precautions
     */
    public getTranslatedPrecautions(diseaseName: string): string[] {
        const translation = this.getDiseaseTranslation(diseaseName);
        return translation?.precautions || [];
    }

    /**
     * Get all available disease names
     */
    public getAllDiseaseNames(): string[] {
        if (!this.isCacheAvailable()) {
            return [];
        }
        return Object.keys(this.cache!.translations);
    }

    /**
     * Get cache metadata
     */
    public getCacheMetadata(): { generatedAt: string; totalDiseases: number; language: string } | null {
        if (!this.isCacheAvailable()) {
            return null;
        }
        return {
            generatedAt: this.cache!.generatedAt,
            totalDiseases: this.cache!.totalDiseases,
            language: this.cache!.language
        };
    }

    /**
     * Translate complete diagnosis report using cache
     * This is the main method for instant translation
     */
    public translateDiagnosisReport(report: {
        disease: string;
        description?: string;
        recommendations?: string[];
        diet?: string[];
        workout?: string[];
        medications?: string[];
        precautions?: string[];
    }): {
        disease: string;
        description: string;
        recommendations: string[];
        diet: string[];
        workout: string[];
        medications: string[];
        precautions: string[];
    } | null {
        const translation = this.getDiseaseTranslation(report.disease);
        
        if (!translation) {
            logger.warn(`Cannot translate report for disease: ${report.disease}`);
            return null;
        }

        return {
            disease: translation.translatedName,
            description: translation.description,
            recommendations: translation.precautions, // Precautions serve as recommendations
            diet: translation.diet,
            workout: translation.workout,
            medications: translation.medications,
            precautions: translation.precautions
        };
    }
}

// Singleton instance
const diseaseTranslationCacheService = new DiseaseTranslationCacheService();

export default diseaseTranslationCacheService;
