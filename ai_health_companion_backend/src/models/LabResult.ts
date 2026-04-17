import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { LabOrder } from './LabOrder';
import { User } from './User';

export enum ResultStatus {
    PRELIMINARY = 'preliminary',
    FINAL = 'final',
    CORRECTED = 'corrected',
    CANCELLED = 'cancelled'
}

export enum AbnormalFlag {
    NORMAL = 'normal',
    LOW = 'low',
    HIGH = 'high',
    CRITICAL_LOW = 'critical_low',
    CRITICAL_HIGH = 'critical_high'
}

export interface TestResult {
    testCode: string;
    testName: string;
    value: string;
    unit: string;
    referenceRange: string;
    abnormalFlag: AbnormalFlag;
    notes?: string;
}

@Entity('lab_results')
@Index(['resultId'], { unique: true })
@Index(['labOrderId'])
@Index(['reviewedBy'])
@Index(['status'])
@Index(['resultDate'])
export class LabResult {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    resultId!: string;

    @Column({ type: 'uuid' })
    labOrderId!: string;

    @ManyToOne(() => LabOrder)
    @JoinColumn({ name: 'labOrderId' })
    labOrder?: LabOrder;

    @Column({ type: 'jsonb' })
    results!: TestResult[];

    @Column({
        type: 'enum',
        enum: ResultStatus,
        default: ResultStatus.PRELIMINARY
    })
    status!: ResultStatus;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    resultDate!: Date;

    @Column({ type: 'uuid', nullable: true })
    performedBy?: string;

    @Column({ type: 'uuid', nullable: true })
    reviewedBy?: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'reviewedBy' })
    reviewer?: User;

    @Column({ type: 'timestamp', nullable: true })
    reviewedAt?: Date;

    @Column({ type: 'text', nullable: true })
    interpretation?: string;

    @Column({ type: 'text', nullable: true })
    technicalNotes?: string;

    @Column({ type: 'boolean', default: false })
    hasCriticalValues!: boolean;

    @Column({ type: 'boolean', default: false })
    notificationSent!: boolean;

    @Column({ type: 'varchar', length: 500, nullable: true })
    attachmentUrl?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
