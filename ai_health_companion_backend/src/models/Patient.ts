import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './User';

export enum Gender {
    MALE = 'male',
    FEMALE = 'female',
    OTHER = 'other'
}

export enum BloodType {
    A_POSITIVE = 'A+',
    A_NEGATIVE = 'A-',
    B_POSITIVE = 'B+',
    B_NEGATIVE = 'B-',
    AB_POSITIVE = 'AB+',
    AB_NEGATIVE = 'AB-',
    O_POSITIVE = 'O+',
    O_NEGATIVE = 'O-',
    UNKNOWN = 'unknown'
}

interface Address {
    street?: string;
    city?: string;
    state?: string;
    country?: string;
    postalCode?: string;
}

interface EmergencyContact {
    name: string;
    relationship: string;
    phoneNumber: string;
}

interface SyncStatus {
    lastSynced?: Date;
    pendingSync: boolean;
    syncVersion: number;
}

@Entity('patients')
@Index(['patientId'], { unique: true })
@Index(['clinicId'])
@Index(['createdById'])
@Index(['firstName', 'lastName'])
@Index(['syncStatus'], { where: "(sync_status->>'pendingSync')::boolean = true" })
export class Patient {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    patientId!: string;

    @Column({ type: 'varchar', length: 50 })
    firstName!: string;

    @Column({ type: 'varchar', length: 50 })
    lastName!: string;

    @Column({ type: 'date' })
    dateOfBirth!: Date;

    @Column({
        type: 'enum',
        enum: Gender
    })
    gender!: Gender;

    @Column({
        type: 'enum',
        enum: BloodType,
        default: BloodType.UNKNOWN
    })
    bloodType?: BloodType;

    @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
    weight?: number;

    @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
    height?: number;

    @Column({ type: 'jsonb', nullable: true })
    address?: Address;

    @Column({ type: 'varchar', length: 20, nullable: true })
    phoneNumber?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    email?: string;

    @Column({ type: 'jsonb', nullable: true })
    emergencyContact?: EmergencyContact;

    @Column({ type: 'text', array: true, default: '{}' })
    allergies?: string[];

    @Column({ type: 'text', array: true, default: '{}' })
    chronicConditions?: string[];

    @Column({ type: 'text', array: true, default: '{}' })
    currentMedications?: string[];

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'uuid' })
    createdById!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'createdById' })
    createdBy?: User;

    @Column({ type: 'boolean', default: true })
    isActive!: boolean;

    @Column({ type: 'timestamp', nullable: true })
    lastVisit?: Date;

    @Column({ type: 'jsonb', nullable: true })
    syncStatus?: SyncStatus;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    // Calculate age method
    getAge(): number {
        const today = new Date();
        const birthDate = new Date(this.dateOfBirth);
        let age = today.getFullYear() - birthDate.getFullYear();
        const monthDiff = today.getMonth() - birthDate.getMonth();

        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        return age;
    }

    // Get full name method
    getFullName(): string {
        return `${this.firstName} ${this.lastName}`;
    }
}
