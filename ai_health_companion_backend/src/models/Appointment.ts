import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, ManyToOne, JoinColumn } from 'typeorm';
import { Patient } from './Patient';
import { User } from './User';

export enum AppointmentStatus {
    SCHEDULED = 'scheduled',
    CONFIRMED = 'confirmed',
    CHECKED_IN = 'checked_in',
    IN_PROGRESS = 'in_progress',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled',
    NO_SHOW = 'no_show',
    RESCHEDULED = 'rescheduled'
}

export enum AppointmentType {
    CONSULTATION = 'consultation',
    FOLLOW_UP = 'follow_up',
    EMERGENCY = 'emergency',
    VACCINATION = 'vaccination',
    LAB_TEST = 'lab_test',
    PROCEDURE = 'procedure',
    TELEMEDICINE = 'telemedicine'
}

interface ReminderSettings {
    sms: boolean;
    email: boolean;
    reminderSent: boolean;
    reminderSentAt?: Date;
}

@Entity('appointments')
@Index(['appointmentId'], { unique: true })
@Index(['patientId'])
@Index(['providerId'])
@Index(['clinicId'])
@Index(['appointmentDate'])
@Index(['status'])
export class Appointment {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    appointmentId!: string;

    @Column({ type: 'uuid' })
    patientId!: string;

    @ManyToOne(() => Patient)
    @JoinColumn({ name: 'patientId' })
    patient?: Patient;

    @Column({ type: 'uuid' })
    providerId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'providerId' })
    provider?: User;

    @Column({ type: 'varchar', length: 255 })
    clinicId!: string;

    @Column({ type: 'timestamp' })
    appointmentDate!: Date;

    @Column({ type: 'integer' })
    durationMinutes!: number;

    @Column({
        type: 'enum',
        enum: AppointmentType
    })
    appointmentType!: AppointmentType;

    @Column({
        type: 'enum',
        enum: AppointmentStatus,
        default: AppointmentStatus.SCHEDULED
    })
    status!: AppointmentStatus;

    @Column({ type: 'text', nullable: true })
    reason?: string;

    @Column({ type: 'text', nullable: true })
    notes?: string;

    @Column({ type: 'jsonb', nullable: true })
    reminderSettings?: ReminderSettings;

    @Column({ type: 'timestamp', nullable: true })
    checkedInAt?: Date;

    @Column({ type: 'timestamp', nullable: true })
    completedAt?: Date;

    @Column({ type: 'timestamp', nullable: true })
    cancelledAt?: Date;

    @Column({ type: 'text', nullable: true })
    cancellationReason?: string;

    @Column({ type: 'uuid', nullable: true })
    cancelledBy?: string;

    @Column({ type: 'uuid', nullable: true })
    rescheduledFrom?: string;

    @Column({ type: 'boolean', default: false })
    isTelemedicine!: boolean;

    @Column({ type: 'varchar', length: 500, nullable: true })
    telemedicineLink?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
