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

export const AppDataSource = new DataSource({
    type: 'postgres',
    url: config.nodeEnv === 'test' ? config.databaseTestUrl : config.databaseUrl,
    synchronize: false, // Never use synchronize in production
    logging: config.nodeEnv === 'development' ? ['query', 'error'] : ['error'],
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
        AuditLog
    ],
    migrations: ['src/database/migrations/*.ts'],
    subscribers: [],
    extra: {
        max: 10, // Maximum pool size
        min: 5,  // Minimum pool size
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 5000,
    },
});

export const initializeDatabase = async (): Promise<void> => {
    try {
        await AppDataSource.initialize();
        console.log('✅ PostgreSQL connected successfully');
    } catch (error) {
        console.error('❌ Failed to connect to PostgreSQL:', error);
        throw error;
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
