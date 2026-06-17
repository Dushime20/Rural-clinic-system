import { Response, NextFunction } from 'express';
import { Diagnosis } from '../models/Diagnosis';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { translationService } from '../services/translation.service';
import diseaseTranslationCacheService from '../services/disease-translation-cache.service';

const diagnosisRepository = AppDataSource.getRepository(Diagnosis);

/**
 * @swagger
 * /diagnosis/{id}/translate:
 *   get:
 *     summary: Translate diagnosis report to Kinyarwanda
 *     tags: [Diagnosis, Translation]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Diagnosis ID
 *     responses:
 *       200:
 *         description: Diagnosis report translated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 diagnosisId:
 *                   type: string
 *                 language:
 *                   type: string
 *                 original:
 *                   type: object
 *                 translated:
 *                   type: object
 *       404:
 *         description: Diagnosis not found
 *       500:
 *         description: Translation failed
 */
export const translateDiagnosisReport = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { id } = req.params;

        // Find diagnosis
        const diagnosis = await diagnosisRepository.findOne({
            where: { id },
            relations: ['patient', 'performedBy']
        });

        if (!diagnosis) {
            throw new AppError('Diagnosis not found', 404);
        }

        // Extract AI predictions
        const aiPredictions = diagnosis.aiPredictions as any[];
        const primaryPrediction = aiPredictions && aiPredictions.length > 0 ? aiPredictions[0] : null;

        if (!primaryPrediction) {
            throw new AppError('No AI predictions found for this diagnosis', 404);
        }

        // Translate ALL disease names (for top 3 predictions) if cache available
        const translatedDiseaseNames: Record<string, string> = {};
        if (diseaseTranslationCacheService.isCacheAvailable()) {
            for (const prediction of aiPredictions) {
                const cached = diseaseTranslationCacheService.getDiseaseTranslation(prediction.disease);
                if (cached) {
                    translatedDiseaseNames[prediction.disease] = cached.translatedName;
                }
            }
        }

        // Prepare original report sections
        // Note: Disease name is NOT translated (kept in English for medical accuracy)
        const originalReport = {
            disease: primaryPrediction.disease || '', // NOT translated
            confidence: primaryPrediction.confidence 
                ? `Confidence: ${Math.round(primaryPrediction.confidence)}%`
                : '',
            description: primaryPrediction.description || '',
            precautions: primaryPrediction.precautions || [],
            medications: primaryPrediction.medications || [],
            diet: primaryPrediction.diet_recommendations || primaryPrediction.diet || [],
            lifestyle: primaryPrediction.lifestyle_recommendations || primaryPrediction.lifestyle || [],
            workout: primaryPrediction.workout_recommendations || primaryPrediction.workout || [],
            notes: diagnosis.notes || '',
            // Prescription fields (dosage, frequency, duration)
            prescriptions: diagnosis.prescriptions || []
        };

        logger.info(`Translating diagnosis report for ID: ${id}`);
        logger.info(`Disease: ${originalReport.disease}`);
        logger.info(`Sections to translate: ${Object.keys(originalReport).length}`);

        let translatedReport: any;

        // Try to use cached translation first (FAST - no Mbaza call needed!)
        if (diseaseTranslationCacheService.isCacheAvailable()) {
            logger.info('✨ Using cached translation (instant)');
            
            const cachedTranslation = diseaseTranslationCacheService.getDiseaseTranslation(
                originalReport.disease
            );

            if (cachedTranslation) {
                // Build translated report from cache
                translatedReport = {
                    disease: cachedTranslation.translatedName, // Translated disease name!
                    diseaseEnglish: originalReport.disease, // Keep English for reference
                    confidence: originalReport.confidence, // Keep as is
                    description: cachedTranslation.description,
                    precautions: cachedTranslation.precautions,
                    medications: cachedTranslation.medications,
                    diet: cachedTranslation.diet,
                    lifestyle: cachedTranslation.workout, // workout serves as lifestyle
                    workout: cachedTranslation.workout,
                    notes: originalReport.notes ? await translationService.translateToKinyarwanda(originalReport.notes) : '',
                    prescriptions: await translationService.translatePrescriptions(originalReport.prescriptions) // Translate prescription fields
                };
                
                logger.info('✅ Cached translation used - instant response!');
            } else {
                logger.warn(`No cached translation for disease: ${originalReport.disease}`);
                logger.info('Falling back to Mbaza API...');
                translatedReport = await translationService.translateMedicalReport(originalReport);
            }
        } else {
            // Fallback to real-time Mbaza translation (SLOW - 2-3 minutes)
            logger.warn('⚠️  Translation cache not available - using Mbaza API (this will be slow)');
            logger.info('💡 Run "npm run translate-diseases" to generate cache for instant translations');
            translatedReport = await translationService.translateMedicalReport(originalReport);
        }

        logger.info('Translation completed successfully');

        res.status(200).json({
            success: true,
            diagnosisId: id,
            language: 'kinyarwanda',
            original: originalReport,
            translated: translatedReport,
            // Include all translated disease names for top 3 predictions
            translatedDiseaseNames: translatedDiseaseNames
        });

    } catch (error: any) {
        logger.error(`Error in translateDiagnosisReport: ${error.message}`);
        next(error);
    }
};

/**
 * @swagger
 * /translate/text:
 *   post:
 *     summary: Translate arbitrary text to Kinyarwanda
 *     tags: [Translation]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - text
 *             properties:
 *               text:
 *                 type: string
 *                 description: English text to translate
 *     responses:
 *       200:
 *         description: Text translated successfully
 *       400:
 *         description: Invalid request
 *       503:
 *         description: Translation service unavailable
 */
export const translateText = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const { text } = req.body;

        if (!text || typeof text !== 'string') {
            throw new AppError('Text is required and must be a string', 400);
        }

        // Check if translation service is available
        const isAvailable = await translationService.isAvailable();
        if (!isAvailable) {
            res.status(503).json({
                success: false,
                message: 'Translation service is currently unavailable',
                english: text
            });
            return;
        }

        const kinyarwanda = await translationService.translateToKinyarwanda(text);

        res.status(200).json({
            success: true,
            english: text,
            kinyarwanda
        });

    } catch (error: any) {
        logger.error(`Error in translateText: ${error.message}`);
        next(error);
    }
};

/**
 * @swagger
 * /translate/status:
 *   get:
 *     summary: Check translation service status
 *     tags: [Translation]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Service status
 */
export const getTranslationServiceStatus = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const isAvailable = await translationService.isAvailable();
        const cacheAvailable = diseaseTranslationCacheService.isCacheAvailable();
        const cacheMetadata = diseaseTranslationCacheService.getCacheMetadata();

        res.status(200).json({
            success: true,
            mbazaService: {
                name: 'Mbaza NLP Translation',
                status: isAvailable ? 'available' : 'unavailable',
                endpoint: process.env.MBAZA_TRANSLATION_URL || 'http://localhost:9000/translate'
            },
            translationCache: {
                status: cacheAvailable ? 'loaded' : 'not_loaded',
                ...cacheMetadata,
                message: cacheAvailable 
                    ? 'Instant translations available (no Mbaza calls needed)'
                    : 'Cache not available - run: npm run translate-diseases'
            }
        });

    } catch (error: any) {
        logger.error(`Error in getTranslationServiceStatus: ${error.message}`);
        next(error);
    }
};
