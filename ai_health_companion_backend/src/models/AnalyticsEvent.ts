import 'reflect-metadata';
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index
} from 'typeorm';

@Entity('analytics_events')
@Index(['eventType', 'createdAt'])
export class AnalyticsEvent {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  eventType!: string;

  @Column({ type: 'uuid', nullable: true })
  patientId?: string;

  @Column({ type: 'uuid', nullable: true })
  diagnosisId?: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  diseaseName?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  reason?: string;

  @Column({ type: 'int', nullable: true })
  clinicCount?: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn()
  createdAt!: Date;
}
