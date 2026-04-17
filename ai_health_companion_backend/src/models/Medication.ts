import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

export enum MedicationForm {
    TABLET = 'tablet',
    CAPSULE = 'capsule',
    SYRUP = 'syrup',
    INJECTION = 'injection',
    CREAM = 'cream',
    OINTMENT = 'ointment',
    DROPS = 'drops',
    INHALER = 'inhaler',
    PATCH = 'patch',
    SUPPOSITORY = 'suppository'
}

export enum MedicationCategory {
    ANTIBIOTIC = 'antibiotic',
    ANALGESIC = 'analgesic',
    ANTIHYPERTENSIVE = 'antihypertensive',
    ANTIDIABETIC = 'antidiabetic',
    ANTIMALARIAL = 'antimalarial',
    ANTIRETROVIRAL = 'antiretroviral',
    VITAMIN = 'vitamin',
    VACCINE = 'vaccine',
    OTHER = 'other'
}

interface StockInfo {
    quantity: number;
    reorderLevel: number;
    expiryDate?: Date;
    batchNumber?: string;
}

@Entity('medications')
@Index(['medicationCode'], { unique: true })
@Index(['genericName'])
@Index(['category'])
@Index(['clinicId'])
export class Medication {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    medicationCode!: string;

    @Column({ type: 'varchar', length: 255 })
    genericName!: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    brandName?: string;

    @Column({
        type: 'enum',
        enum: MedicationForm
    })
    form!: MedicationForm;

    @Column({ type: 'varchar', length: 100 })
    strength!: string;

    @Column({
        type: 'enum',
        enum: MedicationCategory
    })
    category!: MedicationCategory;

    @Column({ type: 'text', nullable: true })
    description?: string;

    @Column({ type: 'text', nullable: true })
    indications?: string;

    @Column({ type: 'text', nullable: true })
    contraindications?: string;

    @Column({ type: 'text', nullable: true })
    sideEffects?: string;

    @Column({ type: 'text', nullable: true })
    dosageInstructions?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    manufacturer?: string;

    @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
    unitPrice?: number;

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'jsonb', nullable: true })
    stockInfo?: StockInfo;

    @Column({ type: 'boolean', default: true })
    isAvailable!: boolean;

    @Column({ type: 'boolean', default: false })
    requiresPrescription!: boolean;

    @Column({ type: 'text', array: true, default: '{}', nullable: true })
    alternatives?: string[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
