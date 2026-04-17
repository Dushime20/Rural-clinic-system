import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { Patient } from './Patient';
import { User } from './User';
import { Diagnosis } from './Diagnosis';

export enum LabOrderStatus {
    PENDING = 'pending',
    COLLECTED = 'collected',
    IN_PROGRESS = 'in_progress',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled',
    REJECTED = 'rejected'
}

export enum LabOrderPriority {
    ROUTINE = 'routine',
    URGENT = 'urgent',
    STAT = 'stat'
}

export interface LabTest {
    testCode: string;
    testName: string;
    category: string;
    instructions?: string;
}

@Entity('lab_orders')
@Index(['orderId'], { unique: true })
@Index(['patientId'])
@Index(['orderingProviderId'])
@Index(['diagnosisId'])
@Index(['clinicId'])
@Index(['status'])
@Index(['orderDate'])
export class LabOrder {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    orderId!: string;

    @Column({ type: 'uuid' })
    patientId!: string;

    @ManyToOne(() => Patient)
    @JoinColumn({ name: 'patientId' })
    patient?: Patient;

    @Column({ type: 'uuid' })
    orderingProviderId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'orderingProviderId' })
    orderingProvider?: User;

    @Column({ type: 'uuid', nullable: true })
    diagnosisId?: string;

    @ManyToOne(() => Diagnosis)
    @JoinColumn({ name: 'diagnosisId' })
    diagnosis?: Diagnosis;

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'jsonb' })
    tests!: LabTest[];

    @Column({
        type: 'enum',
        enum: LabOrderStatus,
        default: LabOrderStatus.PENDING
    })
    status!: LabOrderStatus;

    @Column({
        type: 'enum',
        enum: LabOrderPriority,
        default: LabOrderPriority.ROUTINE
    })
    priority!: LabOrderPriority;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    orderDate!: Date;

    @Column({ type: 'text', nullable: true })
    clinicalNotes?: string;

    @Column({ type: 'text', nullable: true })
    specialInstructions?: string;

    @Column({ type: 'timestamp', nullable: true })
    collectedAt?: Date;

    @Column({ type: 'uuid', nullable: true })
    collectedBy?: string;

    @Column({ type: 'timestamp', nullable: true })
    expectedCompletionDate?: Date;

    @Column({ type: 'boolean', default: false })
    isFasting!: boolean;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
