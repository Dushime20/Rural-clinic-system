import dotenv from 'dotenv';
import path from 'path';

// Load environment variables
dotenv.config();

interface Config {
    nodeEnv: string;
    port: number;
    apiVersion: string;

    // Database
    databaseUrl: string;
    databaseTestUrl: string;

    // Redis
    redisHost: string;
    redisPort: number;
    redisPassword: string;

    // JWT
    jwtSecret: string;
    jwtRefreshSecret: string;
    jwtExpiresIn: string;
    jwtRefreshExpiresIn: string;

    // Encryption
    encryptionKey: string;
    encryptionAlgorithm: string;

    // CORS
    corsOrigin: string[];

    // File Upload
    maxFileSize: number;
    uploadPath: string;
    allowedFileTypes: string[];

    // AI Model
    aiModelPath: string;
    aiModelConfidenceThreshold: number;
    aiMaxPredictions: number;

    // Email
    smtpHost: string;
    smtpPort: number;
    smtpSecure: boolean;
    smtpUser: string;
    smtpPassword: string;

    // Rate Limiting
    rateLimitWindowMs: number;
    rateLimitMaxRequests: number;

    // Logging
    logLevel: string;
    logFilePath: string;

    // Sync
    syncBatchSize: number;
    syncRetryAttempts: number;
    syncRetryDelay: number;

    // Security
    bcryptRounds: number;
    sessionSecret: string;

    // FHIR
    fhirBaseUrl: string;
    fhirVersion: string;

    // Monitoring
    enableMetrics: boolean;
    metricsPort: number;
}

export const config: Config = {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '5000', 10),
    apiVersion: process.env.API_VERSION || 'v1',

    // Database
    databaseUrl: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/ai_health_companion',
    databaseTestUrl: process.env.DATABASE_TEST_URL || 'postgresql://postgres:postgres@localhost:5432/ai_health_companion_test',

    // Redis
    redisHost: process.env.REDIS_HOST || 'localhost',
    redisPort: parseInt(process.env.REDIS_PORT || '6379', 10),
    redisPassword: process.env.REDIS_PASSWORD || '',

    // JWT
    jwtSecret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'your-super-secret-refresh-key',
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',
    jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',

    // Encryption
    encryptionKey: process.env.ENCRYPTION_KEY || 'your-32-character-encryption-key',
    encryptionAlgorithm: process.env.ENCRYPTION_ALGORITHM || 'aes-256-gcm',

    // CORS
    corsOrigin: (process.env.CORS_ORIGIN || 'http://localhost:3000').split(','),

    // File Upload
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10),
    uploadPath: process.env.UPLOAD_PATH || path.join(__dirname, '../../uploads'),
    allowedFileTypes: (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/jpg,application/pdf').split(','),

    // AI Model
    aiModelPath: process.env.AI_MODEL_PATH || path.join(__dirname, '../../models/disease_classifier.tflite'),
    aiModelConfidenceThreshold: parseFloat(process.env.AI_MODEL_CONFIDENCE_THRESHOLD || '0.6'),
    aiMaxPredictions: parseInt(process.env.AI_MAX_PREDICTIONS || '3', 10),

    // Email
    smtpHost: process.env.SMTP_HOST || 'smtp.gmail.com',
    smtpPort: parseInt(process.env.SMTP_PORT || '587', 10),
    smtpSecure: process.env.SMTP_SECURE === 'true',
    smtpUser: process.env.SMTP_USER || '',
    smtpPassword: process.env.SMTP_PASSWORD || '',

    // Rate Limiting
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),

    // Logging
    logLevel: process.env.LOG_LEVEL || 'info',
    logFilePath: process.env.LOG_FILE_PATH || path.join(__dirname, '../../logs'),

    // Sync
    syncBatchSize: parseInt(process.env.SYNC_BATCH_SIZE || '100', 10),
    syncRetryAttempts: parseInt(process.env.SYNC_RETRY_ATTEMPTS || '3', 10),
    syncRetryDelay: parseInt(process.env.SYNC_RETRY_DELAY || '5000', 10),

    // Security
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '12', 10),
    sessionSecret: process.env.SESSION_SECRET || 'your-session-secret',

    // FHIR
    fhirBaseUrl: process.env.FHIR_BASE_URL || 'http://localhost:8080/fhir',
    fhirVersion: process.env.FHIR_VERSION || 'R4',

    // Monitoring
    enableMetrics: process.env.ENABLE_METRICS === 'true',
    metricsPort: parseInt(process.env.METRICS_PORT || '9090', 10),
};

// Validate critical configuration
if (config.nodeEnv === 'production') {
    const requiredEnvVars = [
        'JWT_SECRET',
        'JWT_REFRESH_SECRET',
        'ENCRYPTION_KEY',
        'DATABASE_URL'
    ];

    const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

    if (missingVars.length > 0) {
        throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
    }
}

export default config;
