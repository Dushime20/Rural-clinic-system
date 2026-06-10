import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddClinicSpecializedRecommendations1748000000000
  implements MigrationInterface
{
  name = 'AddClinicSpecializedRecommendations1748000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 1. Add 'clinic' role to the existing user_role_enum
    await queryRunner.query(`
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_enum
                    WHERE enumlabel = 'clinic'
                    AND enumtypid = (
                        SELECT oid FROM pg_type WHERE typname = 'user_role_enum'
                    )
                ) THEN
                    ALTER TYPE user_role_enum ADD VALUE 'clinic';
                END IF;
            END
            $$;
        `);

    // 2. Create medical_specialty enum type
    await queryRunner.query(`
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'medical_specialty_enum') THEN
                    CREATE TYPE medical_specialty_enum AS ENUM (
                        'Cardiology',
                        'Endocrinology',
                        'Infectious_Disease',
                        'Pulmonology',
                        'Nephrology',
                        'Gastroenterology',
                        'Neurology',
                        'Oncology',
                        'Dermatology',
                        'Orthopedics',
                        'General_Medicine'
                    );
                END IF;
            END
            $$;
        `);

    // 3. Create clinics table
    await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "clinics" (
                "id"            uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "managerId"     uuid              NOT NULL,
                "name"          character varying(255) NOT NULL,
                "managerName"   character varying(255),
                "phoneNumber"   character varying(20),
                "address"       character varying(500),
                "latitude"      numeric(10,7)     NOT NULL,
                "longitude"     numeric(10,7)     NOT NULL,
                "city"          character varying(255),
                "district"      character varying(255),
                "country"       character varying(255),
                "isActive"      boolean           NOT NULL DEFAULT true,
                "openingHours"  jsonb,
                "createdAt"     TIMESTAMP         NOT NULL DEFAULT now(),
                "updatedAt"     TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_clinics_managerId" UNIQUE ("managerId"),
                CONSTRAINT "PK_clinics" PRIMARY KEY ("id"),
                CONSTRAINT "FK_clinics_user"
                    FOREIGN KEY ("managerId")
                    REFERENCES "users"("id")
                    ON DELETE CASCADE,
                CONSTRAINT "CHK_clinics_latitude" CHECK (latitude >= -90 AND latitude <= 90),
                CONSTRAINT "CHK_clinics_longitude" CHECK (longitude >= -180 AND longitude <= 180)
            )
        `);

    // 4. Create clinic_specialties table
    await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "clinic_specialties" (
                "id"               uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "clinicId"         uuid              NOT NULL,
                "specialty"        medical_specialty_enum NOT NULL,
                "createdAt"        TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "PK_clinic_specialties" PRIMARY KEY ("id"),
                CONSTRAINT "UQ_clinic_specialty" UNIQUE ("clinicId", "specialty"),
                CONSTRAINT "FK_clinic_specialties_clinic"
                    FOREIGN KEY ("clinicId")
                    REFERENCES "clinics"("id")
                    ON DELETE CASCADE
            )
        `);

    // 5. Create disease_specialty_mappings table
    await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "disease_specialty_mappings" (
                "id"                     uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "diseaseName"            character varying(255) NOT NULL,
                "primarySpecialty"       medical_specialty_enum NOT NULL,
                "secondarySpecialties"   medical_specialty_enum[] DEFAULT '{}',
                "priority"               integer           NOT NULL DEFAULT 1,
                "createdAt"              TIMESTAMP         NOT NULL DEFAULT now(),
                "updatedAt"              TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "PK_disease_specialty_mappings" PRIMARY KEY ("id")
            )
        `);

    // 6. Create analytics_events table
    await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "analytics_events" (
                "id"            uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "eventType"     character varying(100) NOT NULL,
                "patientId"     uuid,
                "diagnosisId"   uuid,
                "diseaseName"   character varying(255),
                "reason"        character varying(100),
                "clinicCount"   integer,
                "metadata"      jsonb,
                "createdAt"     TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "PK_analytics_events" PRIMARY KEY ("id")
            )
        `);

    // 7. Create indexes for clinics table
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_managerId" ON "clinics" ("managerId")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_isActive" ON "clinics" ("isActive")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_location" ON "clinics" ("latitude", "longitude")`
    );

    // 8. Create indexes for clinic_specialties table
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinic_specialties_clinicId" ON "clinic_specialties" ("clinicId")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinic_specialties_specialty" ON "clinic_specialties" ("specialty")`
    );

    // 9. Create indexes for disease_specialty_mappings table
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_disease_specialty_mappings_diseaseName" ON "disease_specialty_mappings" ("diseaseName")`
    );

    // 10. Create indexes for analytics_events table
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_analytics_events_eventType_createdAt" ON "analytics_events" ("eventType", "createdAt")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_analytics_events_patientId" ON "analytics_events" ("patientId")`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop tables in reverse order
    await queryRunner.query(`DROP TABLE IF EXISTS "analytics_events"`);
    await queryRunner.query(
      `DROP TABLE IF EXISTS "disease_specialty_mappings"`
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "clinic_specialties"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "clinics"`);

    // Drop enum type
    await queryRunner.query(`DROP TYPE IF EXISTS "medical_specialty_enum"`);

    // Note: PostgreSQL does not support removing enum values directly.
    // The clinic enum value would need a full enum recreation to remove.
  }
}
