import 'reflect-metadata';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  OneToMany,
  BeforeInsert,
  BeforeUpdate
} from 'typeorm';
import { ClinicSpecialty } from './ClinicSpecialty';

export interface OperatingHours {
  monday?: { open: string; close: string };
  tuesday?: { open: string; close: string };
  wednesday?: { open: string; close: string };
  thursday?: { open: string; close: string };
  friday?: { open: string; close: string };
  saturday?: { open: string; close: string };
  sunday?: { open: string; close: string };
}

@Entity('clinics')
@Index(['managerId'], { unique: true }) // One clinic per clinic user
@Index(['isActive'])
@Index(['latitude', 'longitude']) // Geospatial index
export class Clinic {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', unique: true })
  managerId!: string;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  managerName?: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  phoneNumber?: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  address?: string;

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

  @Column({ type: 'jsonb', nullable: true })
  openingHours?: OperatingHours;

  @OneToMany(() => ClinicSpecialty, (cs) => cs.clinic, {
    cascade: true,
    eager: true
  })
  specialties!: ClinicSpecialty[];

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;

  /**
   * Helper method to check if clinic is open at a given time
   */
  isOpenAt(date: Date): boolean {
    if (!this.openingHours) return false;

    const days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    const dayName = days[date.getDay()] as keyof OperatingHours;
    const hours = this.openingHours[dayName];

    if (!hours) return false;

    const currentTime = date.getHours() * 60 + date.getMinutes();
    const [openHour, openMin] = hours.open.split(':').map(Number);
    const [closeHour, closeMin] = hours.close.split(':').map(Number);
    const openTime = openHour * 60 + openMin;
    const closeTime = closeHour * 60 + closeMin;

    return currentTime >= openTime && currentTime < closeTime;
  }

  /**
   * Validate coordinates before insert
   */
  @BeforeInsert()
  @BeforeUpdate()
  validateCoordinates() {
    if (this.latitude < -90 || this.latitude > 90) {
      throw new Error(
        `Latitude must be between -90 and 90 (inclusive), got ${this.latitude}`
      );
    }
    if (this.longitude < -180 || this.longitude > 180) {
      throw new Error(
        `Longitude must be between -180 and 180 (inclusive), got ${this.longitude}`
      );
    }
  }

  /**
   * Transform to JSON with computed fields
   */
  toJSON() {
    return {
      ...this,
      specialties: this.specialties?.map((s) => s.specialty) || [],
      isOpenNow: this.isOpenAt(new Date())
    };
  }
}