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

    @Column({ type: 'boolean', default: true })
    mustChangePassword!: boolean;

    @Column({ type: 'varchar', length: 255, nullable: true, select: false })
    passwordResetToken?: string;

    @Column({ type: 'timestamp', nullable: true })
    passwordResetExpires?: Date;

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
        // Only hash if password field was explicitly changed and is not already hashed
        if (this.password && !this.password.startsWith('$2a$') && !this.password.startsWith('$2b$')) {
            console.log(`[HASH] Hashing password, length before: ${this.password.length}`);
            const salt = await bcrypt.genSalt(config.bcryptRounds);
            this.password = await bcrypt.hash(this.password, salt);
            console.log(`[HASH] Password hashed, stored hash starts with: ${this.password.substring(0, 7)}`);
        }
    }

    // Compare password method
    async comparePassword(candidatePassword: string): Promise<boolean> {
        console.log(`[COMPARE] candidate length: ${candidatePassword?.length}, hash length: ${this.password?.length}`);
        console.log(`[COMPARE] hash starts with: ${this.password?.substring(0, 7)}`);
        const result = await bcrypt.compare(candidatePassword, this.password);
        console.log(`[COMPARE] bcrypt result: ${result}`);
        return result;
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
