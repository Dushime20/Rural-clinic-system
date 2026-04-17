import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, Index } from 'typeorm';

export enum AuditAction {
    CREATE = 'create',
    READ = 'read',
    UPDATE = 'update',
    DELETE = 'delete',
    LOGIN = 'login',
    LOGOUT = 'logout',
    EXPORT = 'export',
    PRINT = 'print'
}

export enum AuditResource {
    USER = 'user',
    PATIENT = 'patient',
    DIAGNOSIS = 'diagnosis',
    APPOINTMENT = 'appointment',
    LAB_ORDER = 'lab_order',
    LAB_RESULT = 'lab_result',
    PRESCRIPTION = 'prescription',
    MEDICATION = 'medication'
}

@Entity('audit_logs')
@Index(['userId'])
@Index(['action'])
@Index(['resource'])
@Index(['timestamp'])
@Index(['ipAddress'])
export class AuditLog {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'uuid', nullable: true })
    userId?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    userEmail?: string;

    @Column({
        type: 'enum',
        enum: AuditAction
    })
    action!: AuditAction;

    @Column({
        type: 'enum',
        enum: AuditResource
    })
    resource!: AuditResource;

    @Column({ type: 'uuid', nullable: true })
    resourceId?: string;

    @Column({ type: 'jsonb', nullable: true })
    oldValue?: any;

    @Column({ type: 'jsonb', nullable: true })
    newValue?: any;

    @Column({ type: 'varchar', length: 45, nullable: true })
    ipAddress?: string;

    @Column({ type: 'text', nullable: true })
    userAgent?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    clinicId?: string;

    @Column({ type: 'text', nullable: true })
    description?: string;

    @Column({ type: 'boolean', default: true })
    success!: boolean;

    @Column({ type: 'text', nullable: true })
    errorMessage?: string;

    @CreateDateColumn()
    timestamp!: Date;
}
