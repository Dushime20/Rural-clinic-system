import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { Patient } from './Patient';
import { User } from './User';
import { Diagnosis } from './Diagnosis';

export enum PrescriptionStatus {
    ACTIVE = 'active',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled',
    EXPIRED = 'expired'
}

export interface PrescriptionItem {
    medicationId: string;
    medicationName: string;
    dosage: string;
    frequency: string;
    duration: string;
    quantity: number;
    instructions: string;
    refillsAllowed: number;
    refillsRemaining: number;
}

@Entity('prescriptions')
@Index(['prescriptionId'], { unique: true })
@Index(['patientId'])
@Index(['prescriberId'])
@Index(['diagnosisId'])
@Index(['status'])
@Index(['prescriptionDate'])
export class Prescription {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    prescriptionId!: string;

    @Column({ type: 'uuid' })
    patientId!: string;

    @ManyToOne(() => Patient)
    @JoinColumn({ name: 'patientId' })
    patient?: Patient;

    @Column({ type: 'uuid' })
    prescriberId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'prescriberId' })
    prescriber?: User;

    @Column({ type: 'uuid', nullable: true })
    diagnosisId?: string;

    @ManyToOne(() => Diagnosis)
    @JoinColumn({ name: 'diagnosisId' })
    diagnosis?: Diagnosis;

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'jsonb' })
    medications!: PrescriptionItem[];

    @Column({
        type: 'enum',
        enum: PrescriptionStatus,
        default: PrescriptionStatus.ACTIVE
    })
    status!: PrescriptionStatus;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    prescriptionDate!: Date;

    @Column({ type: 'date', nullable: true })
    expiryDate?: Date;

    @Column({ type: 'text', nullable: true })
    notes?: string;

    @Column({ type: 'text', nullable: true })
    pharmacyInstructions?: string;

    @Column({ type: 'boolean', default: false })
    isDispensed!: boolean;

    @Column({ type: 'timestamp', nullable: true })
    dispensedAt?: Date;

    @Column({ type: 'uuid', nullable: true })
    dispensedBy?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    pharmacyId?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
