import axios from 'axios';
import { logger } from '../utils/logger';

export class TranslationService {
    private mbazaUrl: string;
    private mbazaBatchUrl: string;

    constructor() {
        // Mbaza translation service URLs
        this.mbazaUrl = process.env.MBAZA_TRANSLATION_URL || 'http://localhost:9000/translate';
        this.mbazaBatchUrl = process.env.MBAZA_BATCH_URL || 'http://localhost:9000/translate/batch';
    }

    /**
     * Translate English text to Kinyarwanda using Mbaza NLP API
     * @param text English text to translate
     * @returns Kinyarwanda translation or original text if translation fails
     */
    async translateToKinyarwanda(text: string): Promise<string> {
        // Return empty string if input is empty
        if (!text || text.trim() === '') {
            return text;
        }

        try {
            const response = await axios.post(
                this.mbazaUrl,
                { text },
                {
                    headers: { 'Content-Type': 'application/json' },
                    timeout: 30000 // 30 second timeout per translation
                }
            );

            if (response.status === 200 && response.data?.kinyarwanda) {
                return response.data.kinyarwanda;
            }

            logger.warn(`Translation API returned unexpected response for: ${text.substring(0, 50)}`);
            return text; // Fallback to original text
        } catch (error: any) {
            logger.error(`Translation error for text "${text.substring(0, 50)}": ${error.message}`);
            return text; // Fallback to original text
        }
    }

    /**
     * Translate an array of strings using batch API for efficiency
     * @param items Array of English strings
     * @returns Array of Kinyarwanda translations
     */
    async translateArray(items: string[]): Promise<string[]> {
        if (items.length === 0) return [];
        
        // Use batch API for multiple items
        if (items.length > 1) {
            try {
                logger.info(`Translating batch of ${items.length} items via batch API`);
                const startTime = Date.now();
                
                const response = await axios.post(
                    this.mbazaBatchUrl,
                    { texts: items },
                    {
                        headers: { 'Content-Type': 'application/json' },
                        timeout: 60000 // 60 second timeout for batch
                    }
                );

                if (response.status === 200 && response.data?.translations) {
                    const translations = response.data.translations.map((t: any) => t.kinyarwanda || t.english);
                    const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(1);
                    logger.info(`Batch translation completed in ${elapsedTime}s`);
                    return translations;
                }

                logger.warn('Batch API returned unexpected response, falling back to individual translations');
            } catch (error: any) {
                logger.error(`Batch translation error: ${error.message}, falling back to individual translations`);
            }
        }
        
        // Fallback: translate one at a time
        const results: string[] = [];
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            logger.info(`Translating item ${i + 1} of ${items.length}`);
            const translation = await this.translateToKinyarwanda(item);
            results.push(translation);
        }
        return results;
    }

    /**
     * Translate a medical report structure using batch API for efficiency
     * @param report Medical report with various sections
     * @returns Translated report
     */
    async translateMedicalReport(report: {
        disease?: string;
        description?: string;
        precautions?: string[];
        medications?: string[];
        diet?: string[];
        lifestyle?: string[];
        workout?: string[];
        notes?: string;
        prescriptions?: any[];
    }): Promise<any> {
        try {
            logger.info('Starting medical report translation...');
            const startTime = Date.now();

            // Count total items to translate (excluding disease name)
            const totalItems = 
                (report.description ? 1 : 0) +
                (report.precautions?.length || 0) +
                (report.medications?.length || 0) +
                (report.diet?.length || 0) +
                (report.lifestyle?.length || 0) +
                (report.workout?.length || 0) +
                (report.notes ? 1 : 0) +
                ((report.prescriptions?.length || 0) * 3); // dosage, frequency, duration per prescription

            logger.info(`Total items to translate: ${totalItems}`);

            // Disease name is NOT translated (kept in English for medical accuracy)
            const disease = report.disease || '';
            logger.info('Disease name kept in English (not translated)');

            // Step 1: Batch translate single fields (description, notes)
            const singleFields: string[] = [];
            const singleFieldKeys: string[] = [];
            
            if (report.description) {
                singleFields.push(report.description);
                singleFieldKeys.push('description');
            }
            if (report.notes) {
                singleFields.push(report.notes);
                singleFieldKeys.push('notes');
            }

            let description = '';
            let notes = '';

            if (singleFields.length > 0) {
                logger.info(`Step 1: Translating ${singleFields.length} single fields via batch API`);
                const translatedFields = await this.translateArray(singleFields);
                
                // Map back to variables
                singleFieldKeys.forEach((key, index) => {
                    if (key === 'description') description = translatedFields[index];
                    if (key === 'notes') notes = translatedFields[index];
                });
            }

            // Step 2: Batch translate arrays
            logger.info('Step 2: Translating arrays via batch API');
            
            const precautions = report.precautions ? await this.translateArray(report.precautions) : [];
            logger.info(`Precautions complete (${precautions.length} items)`);

            const medications = report.medications ? await this.translateArray(report.medications) : [];
            logger.info(`Medications complete (${medications.length} items)`);

            const diet = report.diet ? await this.translateArray(report.diet) : [];
            logger.info(`Diet complete (${diet.length} items)`);

            const lifestyle = report.lifestyle ? await this.translateArray(report.lifestyle) : [];
            logger.info(`Lifestyle complete (${lifestyle.length} items)`);

            const workout = report.workout ? await this.translateArray(report.workout) : [];
            logger.info(`Workout complete (${workout.length} items)`);

            // Step 3: Translate prescriptions (uses cache for common phrases)
            const prescriptions = report.prescriptions ? await this.translatePrescriptions(report.prescriptions) : [];
            logger.info(`Prescriptions complete (${prescriptions.length} prescriptions)`);

            const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(1);
            logger.info(`Medical report translation completed in ${elapsedTime}s`);

            return {
                disease, // NOT translated
                description,
                precautions,
                medications,
                diet,
                lifestyle,
                workout,
                notes,
                prescriptions
            };
        } catch (error: any) {
            logger.error(`Error translating medical report: ${error.message}`);
            // Return original report if translation fails
            return report;
        }
    }

    /**
     * Translate prescription fields (dosage, frequency, duration)
     * Uses local cache for common phrases to avoid unnecessary API calls
     * @param prescriptions Array of prescription objects
     * @returns Array of prescriptions with translated fields
     */
    async translatePrescriptions(prescriptions: any[]): Promise<any[]> {
        // Common prescription phrases - cached translations
        const commonPhrases: { [key: string]: string } = {
            'As directed': 'Nkuko byateganyijwe',
            'as directed': 'Nkuko byateganyijwe',
            'AS DIRECTED': 'Nkuko byateganyijwe',
            'As directed by physician': 'Nkuko muganga yategetse',
            'as directed by physician': 'Nkuko muganga yategetse',
            'AS DIRECTED BY PHYSICIAN': 'Nkuko muganga yategetse',
            'As directed by doctor': 'Nkuko muganga yategetse',
            'as directed by doctor': 'Nkuko muganga yategetse',
            'As needed': 'Igihe bibaye ngombwa',
            'as needed': 'Igihe bibaye ngombwa',
            'Once daily': 'Rimwe kumunsi',
            'once daily': 'Rimwe kumunsi',
            'Twice daily': 'Inshuro ebyiri kumunsi',
            'twice daily': 'Inshuro ebyiri kumunsi',
            'Three times daily': 'Inshuro eshatu kumunsi',
            'three times daily': 'Inshuro eshatu kumunsi',
            'Once a day': 'Rimwe kumunsi',
            'Twice a day': 'Inshuro ebyiri kumunsi',
            'Three times a day': 'Inshuro eshatu kumunsi',
            'Daily': 'Buri munsi',
            'daily': 'Buri munsi',
            'Weekly': 'Buri cyumweru',
            'weekly': 'Buri cyumweru',
            'Monthly': 'Buri kwezi',
            'monthly': 'Buri kwezi',
            'Before meals': 'Mbere yo kurya',
            'before meals': 'Mbere yo kurya',
            'After meals': 'Nyuma yo kurya',
            'after meals': 'Nyuma yo kurya',
            'With food': 'Hamwe nibiryo',
            'with food': 'Hamwe nibiryo',
            'On empty stomach': 'Inda ubusa',
            'on empty stomach': 'Inda ubusa',
            'At bedtime': 'Mbere yo kuryama',
            'at bedtime': 'Mbere yo kuryama',
            'In the morning': 'Mugitondo',
            'in the morning': 'Mugitondo',
            'In the evening': 'Nimugoroba',
            'in the evening': 'Nimugoroba'
        };

        const translatedPrescriptions: any[] = [];

        for (let i = 0; i < prescriptions.length; i++) {
            const prescription = prescriptions[i];
            logger.info(`Translating prescription ${i + 1} of ${prescriptions.length}`);

            // Use cached translation if available, otherwise call Mbaza
            const dosage = prescription.dosage 
                ? (commonPhrases[prescription.dosage] || await this.translateToKinyarwanda(prescription.dosage))
                : '';
            
            const frequency = prescription.frequency 
                ? (commonPhrases[prescription.frequency] || await this.translateToKinyarwanda(prescription.frequency))
                : '';
            
            const duration = prescription.duration 
                ? (commonPhrases[prescription.duration] || await this.translateToKinyarwanda(prescription.duration))
                : '';

            // Log if we used cache vs API
            if (commonPhrases[prescription.dosage]) logger.info(`  Dosage: Used cached translation`);
            if (commonPhrases[prescription.frequency]) logger.info(`  Frequency: Used cached translation`);
            if (commonPhrases[prescription.duration]) logger.info(`  Duration: Used cached translation`);

            translatedPrescriptions.push({
                ...prescription,
                dosage,
                frequency,
                duration
            });
        }

        return translatedPrescriptions;
    }

    /**
     * Check if Mbaza translation service is available
     * @returns true if service is reachable
     */
    async isAvailable(): Promise<boolean> {
        try {
            const response = await axios.post(
                this.mbazaUrl,
                { text: 'test' },
                { timeout: 10000 }
            );
            return response.status === 200;
        } catch (error) {
            logger.warn('Mbaza translation service is not available');
            return false;
        }
    }
}

// Export singleton instance
export const translationService = new TranslationService();
