import axios, { AxiosInstance, AxiosError } from 'axios';
import { logger } from '../utils/logger';

export interface FlaskPredictionRequest {
    symptoms: string[];
}

export interface FlaskPredictionResponse {
    success: boolean;
    prediction: {
        disease: string;
        confidence: number;
        symptoms_used: string[];
        invalid_symptoms: string[];
    };
    information: {
        description: string;
        precautions: string[];
        medications: string[];
        diet: string[];
        workout: string[];
    };
    timestamp: string;
}

export interface FlaskHealthResponse {
    status: string;
    service: string;
    timestamp: string;
    model_loaded: boolean;
}

export interface FlaskSymptomValidationResponse {
    success: boolean;
    results: Array<{
        original: string;
        corrected: string | null;
        valid: boolean;
    }>;
}

export class FlaskMLService {
    private client: AxiosInstance;
    private baseUrl: string;
    private timeout: number;
    private retryAttempts: number;
    private retryDelay: number;
    private apiKey: string;

    constructor() {
        this.baseUrl = process.env.FLASK_ML_SERVICE_URL || 'http://localhost:5001';
        this.timeout = parseInt(process.env.FLASK_ML_TIMEOUT || '30000');
        this.retryAttempts = parseInt(process.env.FLASK_ML_RETRY_ATTEMPTS || '3');
        this.retryDelay = parseInt(process.env.FLASK_ML_RETRY_DELAY || '1000');
        this.apiKey = process.env.ML_SERVICE_API_KEY || '';

        this.client = axios.create({
            baseURL: this.baseUrl,
            timeout: this.timeout,
            headers: {
                'Content-Type': 'application/json',
                ...(this.apiKey && { 'X-API-Key': this.apiKey })
            },
        });

        // Request interceptor for logging
        this.client.interceptors.request.use(
            (config) => {
                logger.info(`Flask ML Request: ${config.method?.toUpperCase()} ${config.url}`);
                return config;
            },
            (error) => {
                logger.error('Flask ML Request Error:', error);
                return Promise.reject(error);
            }
        );

        // Response interceptor for logging
        this.client.interceptors.response.use(
            (response) => {
                logger.info(`Flask ML Response: ${response.status} ${response.config.url}`);
                return response;
            },
            (error) => {
                logger.error('Flask ML Response Error:', error.message);
                return Promise.reject(error);
            }
        );
    }

    /**
     * Check if Flask ML service is healthy
     */
    async healthCheck(): Promise<boolean> {
        try {
            const response = await this.client.get<FlaskHealthResponse>('/health');
            return response.data.status === 'healthy' && response.data.model_loaded;
        } catch (error) {
            logger.error('Flask ML health check failed:', error);
            return false;
        }
    }

    /**
     * Predict disease from symptoms
     */
    async predictDisease(symptoms: string[]): Promise<FlaskPredictionResponse> {
        return this.retryRequest(async () => {
            try {
                const response = await this.client.post<FlaskPredictionResponse>(
                    '/api/v1/predict',
                    { symptoms }
                );

                if (!response.data.success) {
                    throw new Error('Flask ML prediction failed');
                }

                return response.data;
            } catch (error) {
                this.handleError(error, 'predictDisease');
                throw error;
            }
        });
    }

    /**
     * Validate and correct symptom spellings
     */
    async validateSymptoms(symptoms: string[]): Promise<FlaskSymptomValidationResponse> {
        try {
            const response = await this.client.post<FlaskSymptomValidationResponse>(
                '/api/v1/validate-symptoms',
                { symptoms }
            );
            return response.data;
        } catch (error) {
            this.handleError(error, 'validateSymptoms');
            throw error;
        }
    }

    /**
     * Get list of all available symptoms
     */
    async getAvailableSymptoms(): Promise<string[]> {
        try {
            const response = await this.client.get<{ success: boolean; symptoms: string[] }>(
                '/api/v1/symptoms'
            );
            return response.data.symptoms;
        } catch (error) {
            this.handleError(error, 'getAvailableSymptoms');
            throw error;
        }
    }

    /**
     * Get list of all predictable diseases
     */
    async getAvailableDiseases(): Promise<string[]> {
        try {
            const response = await this.client.get<{ success: boolean; diseases: string[] }>(
                '/api/v1/diseases'
            );
            return response.data.diseases;
        } catch (error) {
            this.handleError(error, 'getAvailableDiseases');
            throw error;
        }
    }

    /**
     * Retry mechanism for failed requests
     */
    private async retryRequest<T>(
        requestFn: () => Promise<T>,
        attempt: number = 1
    ): Promise<T> {
        try {
            return await requestFn();
        } catch (error) {
            if (attempt < this.retryAttempts) {
                logger.warn(
                    `Flask ML request failed, retrying (${attempt}/${this.retryAttempts})...`
                );
                await this.delay(this.retryDelay * attempt);
                return this.retryRequest(requestFn, attempt + 1);
            }
            throw error;
        }
    }

    /**
     * Delay helper for retry mechanism
     */
    private delay(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    /**
     * Error handler
     */
    private handleError(error: any, method: string): void {
        if (axios.isAxiosError(error)) {
            const axiosError = error as AxiosError;
            if (axiosError.response) {
                logger.error(
                    `Flask ML ${method} error: ${axiosError.response.status} - ${JSON.stringify(
                        axiosError.response.data
                    )}`
                );
            } else if (axiosError.request) {
                logger.error(
                    `Flask ML ${method} error: No response received from service`
                );
            } else {
                logger.error(`Flask ML ${method} error: ${axiosError.message}`);
            }
        } else {
            logger.error(`Flask ML ${method} error:`, error);
        }
    }
}

// Export singleton instance
export const flaskMLService = new FlaskMLService();
