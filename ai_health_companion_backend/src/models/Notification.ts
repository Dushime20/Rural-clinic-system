import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

export enum NotificationType {
    APPOINTMENT_REMINDER = 'appointment_reminder',
    APPOINTMENT_CONFIRMATION = 'appointment_confirmation',
    LAB_RESULT_READY = 'lab_result_ready',
    PRESCRIPTION_READY = 'prescription_ready',
    FOLLOW_UP_REMINDER = 'follow_up_reminder',
    MEDICATION_REMINDER = 'medication_reminder',
    CRITICAL_RESULT = 'critical_result',
    SYSTEM_ALERT = 'system_alert',
    MESSAGE = 'message'
}

export enum NotificationChannel {
    IN_APP = 'in_app',
    EMAIL = 'email',
    SMS = 'sms',
    PUSH = 'push'
}

export enum NotificationStatus {
    PENDING = 'pending',
    SENT = 'sent',
    DELIVERED = 'delivered',
    READ = 'read',
    FAILED = 'failed'
}

@Entity('notifications')
@Index(['userId'])
@Index(['type'])
@Index(['status'])
@Index(['createdAt'])
export class Notification {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'uuid' })
    userId!: string;

    @Column({
        type: 'enum',
        enum: NotificationType
    })
    type!: NotificationType;

    @Column({
        type: 'enum',
        enum: NotificationChannel
    })
    channel!: NotificationChannel;

    @Column({
        type: 'enum',
        enum: NotificationStatus,
        default: NotificationStatus.PENDING
    })
    status!: NotificationStatus;

    @Column({ type: 'varchar', length: 255 })
    title!: string;

    @Column({ type: 'text' })
    message!: string;

    @Column({ type: 'jsonb', nullable: true })
    data?: any;

    @Column({ type: 'varchar', length: 500, nullable: true })
    actionUrl?: string;

    @Column({ type: 'timestamp', nullable: true })
    sentAt?: Date;

    @Column({ type: 'timestamp', nullable: true })
    readAt?: Date;

    @Column({ type: 'timestamp', nullable: true })
    expiresAt?: Date;

    @Column({ type: 'integer', default: 0 })
    retryCount!: number;

    @Column({ type: 'text', nullable: true })
    errorMessage?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
