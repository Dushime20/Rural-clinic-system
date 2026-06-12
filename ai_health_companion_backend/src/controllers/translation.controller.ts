import { Response, NextFunction } from 'express';
import { Diagnosis } from '../models/Diagnosis';
import { AppDataSource } from '../database/data-source';
import { AppError } from '../middleware/error-handler';
import { AuthRequest } from '../middleware/auth';
import { logger } from '../utils/logger';
import { translationService } from '../services/translation.service';

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

        // Skip availability check and go straight to translation
        // The translateMedicalReport method has its own error handling
        logger.info('Starting translation...');

        // Translate the report
        const translatedReport = await translationService.translateMedicalReport(originalReport);

        // Check if translation actually worked (not just returned original)
        if (translatedReport.disease === originalReport.disease && 
            translatedReport.description === originalReport.description) {
            logger.warn('Translation service may have failed - returned original text');
        }

        logger.info('Translation completed successfully');

        res.status(200).json({
            success: true,
            diagnosisId: id,
            language: 'kinyarwanda',
            original: originalReport,
            translated: translatedReport
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

        res.status(200).json({
            success: true,
            service: 'Mbaza NLP Translation',
            status: isAvailable ? 'available' : 'unavailable',
            endpoint: process.env.MBAZA_TRANSLATION_URL || 'http://localhost:9000/translate'
        });

    } catch (error: any) {
        logger.error(`Error in getTranslationServiceStatus: ${error.message}`);
        next(error);
    }
};
