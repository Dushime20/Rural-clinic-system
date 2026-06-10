import 'reflect-metadata';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index
} from 'typeorm';
import { Clinic } from './Clinic';

export enum MedicalSpecialty {
  CARDIOLOGY = 'Cardiology',
  ENDOCRINOLOGY = 'Endocrinology',
  INFECTIOUS_DISEASE = 'Infectious_Disease',
  PULMONOLOGY = 'Pulmonology',
  NEPHROLOGY = 'Nephrology',
  GASTROENTEROLOGY = 'Gastroenterology',
  NEUROLOGY = 'Neurology',
  ONCOLOGY = 'Oncology',
  DERMATOLOGY = 'Dermatology',
  ORTHOPEDICS = 'Orthopedics',
  GENERAL_MEDICINE = 'General_Medicine'
}

@Entity('clinic_specialties')
@Index(['clinicId', 'specialty'], { unique: true })
export class ClinicSpecialty {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  clinicId!: string;

  @Column({
    type: 'enum',
    enum: MedicalSpecialty
  })
  specialty!: MedicalSpecialty;

  @ManyToOne(() => Clinic, (clinic) => clinic.specialties, {
    onDelete: 'CASCADE'
  })
  @JoinColumn({ name: 'clinicId' })
  clinic!: Clinic;

  @CreateDateColumn()
  createdAt!: Date;
}
