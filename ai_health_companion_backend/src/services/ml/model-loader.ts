/**
 * Model Loader
 * 
 * Loads TensorFlow.js model and metadata from local file system.
 */

import * as tf from '@tensorflow/tfjs';
import * as fs from 'fs';
import * as path from 'path';
import { logger } from '../../utils/logger';
import { ModelMetadata } from '../../types/ml.types';

export class ModelLoader {
    private model: tf.GraphModel | null = null;
    private metadata: ModelMetadata | null = null;
    private modelPath: string;
    private metadataPath: string;

    constructor(modelPath: string, metadataPath: string) {
        this.modelPath = modelPath;
        this.metadataPath = metadataPath;
    }

    async loadModel(): Promise<void> {
        try {
            logger.info(`Loading ML model from ${this.modelPath}`);
            
            // Load TensorFlow.js model
            const modelJsonPath = `file://${path.resolve(this.modelPath, 'model.json')}`;
            this.model = await tf.loadGraphModel(modelJsonPath);
            
            logger.info('ML model loaded successfully');
        } catch (error) {
            logger.error('Failed to load ML model:', error);
            throw new Error(`Model loading failed: ${error}`);
        }
    }

    async loadMetadata(): Promise<void> {
        try {
            logger.info(`Loading model metadata from ${this.metadataPath}`);
            
            const metadataContent = fs.readFileSync(this.metadataPath, 'utf-8');
            this.metadata = JSON.parse(metadataContent) as ModelMetadata;
            
            logger.info(`Metadata loaded: version=${this.metadata.version}, accuracy=${this.metadata.accuracy}`);
        } catch (error) {
            logger.error('Failed to load metadata:', error);
            throw new Error(`Metadata loading failed: ${error}`);
        }
    }

    getModel(): tf.GraphModel {
        if (!this.model) {
            throw new Error('Model not loaded. Call loadModel() first.');
        }
        return this.model;
    }

    getMetadata(): ModelMetadata {
        if (!this.metadata) {
            throw new Error('Metadata not loaded. Call loadMetadata() first.');
        }
        return this.metadata;
    }

    async reloadModel(modelPath?: string): Promise<void> {
        logger.info('Reloading model...');
        
        if (modelPath) {
            this.modelPath = modelPath;
        }
        
        // Dispose old model
        if (this.model) {
            this.model.dispose();
            this.model = null;
        }
        
        await this.loadModel();
        await this.loadMetadata();
        
        logger.info('Model reloaded successfully');
    }

    isLoaded(): boolean {
        return this.model !== null && this.metadata !== null;
    }
}
