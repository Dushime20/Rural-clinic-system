import 'reflect-metadata';
import {
    Entity, PrimaryGeneratedColumn, Column,
    CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index
} from 'typeorm';
import { Pharmacy } from './Pharmacy';

@Entity('pharmacy_medicines')
@Index(['pharmacyId', 'medicationName'])
@Index(['pharmacyId'])
export class PharmacyMedicine {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'uuid' })
    pharmacyId!: string;

    @ManyToOne(() => Pharmacy, (p) => p.medicines, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'pharmacyId' })
    pharmacy!: Pharmacy;

    // Medicine details (stored directly so pharmacy can manage their own catalog)
    @Column({ type: 'varchar', length: 255 })
    medicationName!: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    genericName?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    brandName?: string;

    @Column({ type: 'varchar', length: 100, nullable: true })
    strength?: string;

    @Column({ type: 'varchar', length: 50, nullable: true })
    form?: string; // tablet, syrup, injection, etc.

    @Column({ type: 'varchar', length: 100, nullable: true })
    category?: string;

    // Pricing
    @Column({ type: 'decimal', precision: 10, scale: 2 })
    price!: number;

    @Column({ type: 'varchar', length: 10, default: 'RWF' })
    currency!: string;

    // Stock
    @Column({ type: 'integer', default: 0 })
    stockQuantity!: number;

    @Column({ type: 'boolean', default: true })
    isAvailable!: boolean;

    @Column({ type: 'text', nullable: true })
    notes?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
