import 'reflect-metadata';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index
} from 'typeorm';
import { MedicalSpecialty } from './ClinicSpecialty';

@Entity('disease_specialty_mappings')
@Index(['diseaseName'])
export class DiseaseSpecialtyMapping {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 255 })
  diseaseName!: string;

  @Column({
    type: 'enum',
    enum: MedicalSpecialty
  })
  primarySpecialty!: MedicalSpecialty;

  @Column({
    type: 'enum',
    enum: MedicalSpecialty,
    array: true,
    default: []
  })
  secondarySpecialties!: MedicalSpecialty[];

  @Column({ type: 'int', default: 1 })
  priority!: number;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;

  /**
   * Helper method to get all specialties
   */
  getAllSpecialties(): MedicalSpecialty[] {
    return [this.primarySpecialty, ...this.secondarySpecialties];
  }
}
