import 'reflect-metadata';
import {
    Entity, PrimaryGeneratedColumn, Column,
    CreateDateColumn, UpdateDateColumn, Index, OneToMany
} from 'typeorm';
import { PharmacyMedicine } from './PharmacyMedicine';

@Entity('pharmacies')
@Index(['managerId'], { unique: true }) // one pharmacy per pharmacist user
@Index(['isActive'])
export class Pharmacy {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    /** The user ID of the pharmacist who manages this pharmacy */
    @Column({ type: 'uuid', unique: true })
    managerId!: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    managerName?: string;

    @Column({ type: 'varchar', length: 255 })
    name!: string;

    @Column({ type: 'varchar', length: 20, nullable: true })
    phoneNumber?: string;

    @Column({ type: 'varchar', length: 500, nullable: true })
    address?: string;

    // GPS location
    @Column({ type: 'decimal', precision: 10, scale: 7 })
    latitude!: number;

    @Column({ type: 'decimal', precision: 10, scale: 7 })
    longitude!: number;

    @Column({ type: 'varchar', length: 255, nullable: true })
    city?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    district?: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    country?: string;

    @Column({ type: 'boolean', default: true })
    isActive!: boolean;

    @Column({ type: 'varchar', length: 100, nullable: true })
    openingHours?: string;

    @OneToMany(() => PharmacyMedicine, (pm) => pm.pharmacy, { cascade: true })
    medicines!: PharmacyMedicine[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
