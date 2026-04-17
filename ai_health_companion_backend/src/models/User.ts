import 'reflect-metadata';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index, BeforeInsert, BeforeUpdate } from 'typeorm';
import bcrypt from 'bcryptjs';
import { config } from '../config';

export enum UserRole {
    ADMIN = 'admin',
    HEALTH_WORKER = 'health_worker',
    CLINIC_STAFF = 'clinic_staff',
    SUPERVISOR = 'supervisor'
}

@Entity('users')
@Index(['email'])
@Index(['clinicId'])
@Index(['role'])
export class User {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'varchar', length: 255, unique: true })
    email!: string;

    @Column({ type: 'varchar', length: 255, select: false })
    password!: string;

    @Column({ type: 'varchar', length: 50 })
    firstName!: string;

    @Column({ type: 'varchar', length: 50 })
    lastName!: string;

    @Column({
        type: 'enum',
        enum: UserRole,
        default: UserRole.HEALTH_WORKER
    })
    role!: UserRole;

    @Column({ type: 'varchar', length: 255, nullable: true })
    clinicId?: string;

    @Column({ type: 'varchar', length: 20, nullable: true })
    phoneNumber?: string;

    @Column({ type: 'boolean', default: true })
    isActive!: boolean;

    @Column({ type: 'boolean', default: false })
    isEmailVerified!: boolean;

    @Column({ type: 'timestamp', nullable: true })
    lastLogin?: Date;

    @Column({ type: 'varchar', length: 500, nullable: true, select: false })
    refreshToken?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    // Hash password before insert
    @BeforeInsert()
    @BeforeUpdate()
    async hashPassword() {
        if (this.password && !this.password.startsWith('$2')) {
            const salt = await bcrypt.genSalt(config.bcryptRounds);
            this.password = await bcrypt.hash(this.password, salt);
        }
    }

    // Compare password method
    async comparePassword(candidatePassword: string): Promise<boolean> {
        return bcrypt.compare(candidatePassword, this.password);
    }

    // Get full name method
    getFullName(): string {
        return `${this.firstName} ${this.lastName}`;
    }

    // Transform to JSON (exclude sensitive fields)
    toJSON() {
        const { password, refreshToken, ...user } = this as any;
        return user;
    }
}
