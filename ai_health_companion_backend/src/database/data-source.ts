import { DataSource } from 'typeorm';
import { config } from '../config';
import { User } from '../models/User';
import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { Appointment } from '../models/Appointment';
import { LabOrder } from '../models/LabOrder';
import { LabResult } from '../models/LabResult';
import { Prescription } from '../models/Prescription';
import { Medication } from '../models/Medication';
import { Notification } from '../models/Notification';
import { AuditLog } from '../models/AuditLog';
import { Pharmacy } from '../models/Pharmacy';
import { PharmacyMedicine } from '../models/PharmacyMedicine';

export const AppDataSource = new DataSource({
    type: 'postgres',
    url: config.nodeEnv === 'test' ? config.databaseTestUrl : config.databaseUrl,
    synchronize: false,
    logging: config.nodeEnv === 'development' ? ['error'] : ['error'],
    entities: [
        User,
        Patient,
        Diagnosis,
        Appointment,
        LabOrder,
        LabResult,
        Prescription,
        Medication,
        Notification,
        AuditLog,
        Pharmacy,
        PharmacyMedicine
    ],
    migrations: ['src/database/migrations/*.ts'],
    subscribers: [],
    extra: {
        // Neon serverless-friendly pool settings
        max: 3,                        // Small pool — Neon free tier has connection limits
        min: 0,                        // Don't keep idle connections (Neon kills them)
        idleTimeoutMillis: 10000,      // Release idle connections after 10s
        connectionTimeoutMillis: 30000, // 30s timeout for Neon cold starts
        keepAlive: true,               // Send TCP keepalive to detect dead connections
        keepAliveInitialDelayMillis: 10000,
    },
});

export const initializeDatabase = async (): Promise<void> => {
    const maxRetries = 5;
    let attempt = 0;

    while (attempt < maxRetries) {
        try {
            await AppDataSource.initialize();
            console.log('✅ PostgreSQL connected successfully');
            return;
        } catch (error) {
            attempt++;
            console.error(`❌ Database connection attempt ${attempt}/${maxRetries} failed:`, error);
            if (attempt >= maxRetries) {
                throw error;
            }
            const delay = attempt * 3000; // 3s, 6s, 9s, 12s
            console.log(`⏳ Retrying in ${delay / 1000}s...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
};

export const closeDatabase = async (): Promise<void> => {
    try {
        if (AppDataSource.isInitialized) {
            await AppDataSource.destroy();
            console.log('✅ PostgreSQL disconnected successfully');
        }
    } catch (error) {
        console.error('❌ Error disconnecting from PostgreSQL:', error);
        throw error;
    }
};
