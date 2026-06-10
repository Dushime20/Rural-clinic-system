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
import { Clinic } from '../models/Clinic';
import { ClinicSpecialty } from '../models/ClinicSpecialty';
import { DiseaseSpecialtyMapping } from '../models/DiseaseSpecialtyMapping';
import { AnalyticsEvent } from '../models/AnalyticsEvent';
import { InitialSchema1738765423000 } from './migrations/1738765423000-InitialSchema';
import { AddInternationalFeatures1738766000000 } from './migrations/1738766000000-AddInternationalFeatures';
import { AddPasswordResetFields1735400000000 } from './migrations/1735400000000-AddPasswordResetFields';
import { AddPharmacyFeature1746000000000 } from './migrations/1746000000000-AddPharmacyFeature';
import { RemoveDiagnosisStatus1747392000000 } from './migrations/1747392000000-RemoveDiagnosisStatus';
import { AddClinicSpecializedRecommendations1748000000000 } from './migrations/1748000000000-AddClinicSpecializedRecommendations';
import { SeedDiseaseSpecialtyMappings1748000001000 } from './migrations/1748000001000-SeedDiseaseSpecialtyMappings';

export const AppDataSource = new DataSource({
    type: 'postgres',
    url: config.nodeEnv === 'test' ? config.databaseTestUrl : config.databaseUrl,
    synchronize: true, // Enable auto-sync for development
    logging: config.nodeEnv === 'development' ? ['error', 'warn'] : ['error'],
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
        PharmacyMedicine,
        Clinic,
        ClinicSpecialty,
        DiseaseSpecialtyMapping,
        AnalyticsEvent
    ],
    migrations: [
        InitialSchema1738765423000,
        AddInternationalFeatures1738766000000,
        AddPasswordResetFields1735400000000,
        AddPharmacyFeature1746000000000,
        RemoveDiagnosisStatus1747392000000,
        AddClinicSpecializedRecommendations1748000000000,
        SeedDiseaseSpecialtyMappings1748000001000
    ],
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
