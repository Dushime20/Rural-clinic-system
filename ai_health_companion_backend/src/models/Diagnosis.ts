import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { Patient } from './Patient';
import { User } from './User';

export interface ISymptom {
    name: string;
    category: string;
    severity?: 'mild' | 'moderate' | 'severe';
    duration?: string;
}

export interface IVitalSigns {
    temperature?: number;
    bloodPressureSystolic?: number;
    bloodPressureDiastolic?: number;
    heartRate?: number;
    respiratoryRate?: number;
    oxygenSaturation?: number;
    weight?: number;
    height?: number;
}

export interface IPrediction {
    disease: string;
    confidence: number;
    icd10Code?: string;
    recommendations?: string[];
}

export interface ISelectedDiagnosis {
    disease: string;
    confidence: number;
    icd10Code?: string;
}

export interface IPrescription {
    medication: string;
    dosage: string;
    frequency: string;
    duration: string;
}

interface SyncStatus {
    lastSynced?: Date;
    pendingSync: boolean;
    syncVersion: number;
}

@Entity('diagnoses')
@Index(['diagnosisId'], { unique: true })
@Index(['patientId'])
@Index(['performedById'])
@Index(['clinicId'])
@Index(['diagnosisDate'])
@Index(['status'])
@Index(['syncStatus'], { where: "(sync_status->>'pendingSync')::boolean = true" })
export class Diagnosis {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    diagnosisId!: string;

    @Column({ type: 'uuid' })
    patientId!: string;

    @ManyToOne(() => Patient)
    @JoinColumn({ name: 'patientId' })
    patient?: Patient;

    @Column({ type: 'uuid' })
    performedById!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'performedById' })
    performedBy?: User;

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'jsonb' })
    symptoms!: ISymptom[];

    @Column({ type: 'jsonb' })
    vitalSigns!: IVitalSigns;

    @Column({ type: 'integer' })
    patientAge!: number;

    @Column({
        type: 'enum',
        enum: ['male', 'female', 'other']
    })
    patientGender!: string;

    @Column({ type: 'text', array: true, default: '{}', nullable: true })
    medicalHistory?: string[];

    @Column({ type: 'jsonb' })
    aiPredictions!: IPrediction[];

    @Column({ type: 'jsonb', nullable: true })
    selectedDiagnosis?: ISelectedDiagnosis;

    @Column({ type: 'text', nullable: true })
    notes?: string;

    @Column({ type: 'boolean', default: false })
    followUpRequired!: boolean;

    @Column({ type: 'timestamp', nullable: true })
    followUpDate?: Date;

    @Column({ type: 'jsonb', nullable: true })
    prescriptions?: IPrescription[];

    @Column({ type: 'text', array: true, default: '{}', nullable: true })
    labTestsOrdered?: string[];

    @Column({ type: 'boolean', default: false })
    referralRequired!: boolean;

    @Column({ type: 'text', nullable: true })
    referralDetails?: string;

    @Column({
        type: 'enum',
        enum: ['pending', 'confirmed', 'revised', 'cancelled'],
        default: 'pending'
    })
    status!: string;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    diagnosisDate!: Date;

    @Column({ type: 'jsonb', nullable: true })
    syncStatus?: SyncStatus;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
