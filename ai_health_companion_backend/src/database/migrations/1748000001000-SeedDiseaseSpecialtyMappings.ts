import { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedDiseaseSpecialtyMappings1748000001000
  implements MigrationInterface
{
  name = 'SeedDiseaseSpecialtyMappings1748000001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Seed disease-specialty mappings
    await queryRunner.query(`
            INSERT INTO "disease_specialty_mappings" 
            ("diseaseName", "primarySpecialty", "secondarySpecialties", "priority") 
            VALUES
                ('Diabetes', 'Endocrinology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Hypertension', 'Cardiology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Heart Disease', 'Cardiology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Malaria', 'Infectious_Disease', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Tuberculosis', 'Pulmonology', ARRAY['Infectious_Disease', 'General_Medicine']::medical_specialty_enum[], 1),
                ('Pneumonia', 'Pulmonology', ARRAY['Infectious_Disease', 'General_Medicine']::medical_specialty_enum[], 1),
                ('Asthma', 'Pulmonology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Kidney Disease', 'Nephrology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Gastritis', 'Gastroenterology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Stroke', 'Neurology', ARRAY['Cardiology', 'General_Medicine']::medical_specialty_enum[], 1),
                ('Epilepsy', 'Neurology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Cancer', 'Oncology', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Skin Infection', 'Dermatology', ARRAY['Infectious_Disease', 'General_Medicine']::medical_specialty_enum[], 2),
                ('Fracture', 'Orthopedics', ARRAY['General_Medicine']::medical_specialty_enum[], 1),
                ('Arthritis', 'Orthopedics', ARRAY['General_Medicine']::medical_specialty_enum[], 2)
            ON CONFLICT DO NOTHING
        `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Delete seeded data
    await queryRunner.query(`
            DELETE FROM "disease_specialty_mappings"
            WHERE "diseaseName" IN (
                'Diabetes', 'Hypertension', 'Heart Disease', 'Malaria', 
                'Tuberculosis', 'Pneumonia', 'Asthma', 'Kidney Disease', 
                'Gastritis', 'Stroke', 'Epilepsy', 'Cancer', 
                'Skin Infection', 'Fracture', 'Arthritis'
            )
        `);
  }
}
