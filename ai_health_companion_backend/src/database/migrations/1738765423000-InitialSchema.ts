import { MigrationInterface, QueryRunner } from "typeorm";

export class InitialSchema1738765423000 implements MigrationInterface {
    name = 'InitialSchema1738765423000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create users table
        await queryRunner.query(`
            CREATE TYPE "user_role_enum" AS ENUM('admin', 'health_worker', 'clinic_staff', 'supervisor')
        `);

        await queryRunner.query(`
            CREATE TABLE "users" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "email" character varying(255) NOT NULL,
                "password" character varying(255) NOT NULL,
                "firstName" character varying(50) NOT NULL,
                "lastName" character varying(50) NOT NULL,
                "role" "user_role_enum" NOT NULL DEFAULT 'health_worker',
                "clinicId" character varying(255),
                "phoneNumber" character varying(20),
                "isActive" boolean NOT NULL DEFAULT true,
                "isEmailVerified" boolean NOT NULL DEFAULT false,
                "lastLogin" TIMESTAMP,
                "refreshToken" character varying(500),
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_users_email" UNIQUE ("email"),
                CONSTRAINT "PK_users_id" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_users_email" ON "users" ("email")`);
        await queryRunner.query(`CREATE INDEX "IDX_users_clinicId" ON "users" ("clinicId")`);
        await queryRunner.query(`CREATE INDEX "IDX_users_role" ON "users" ("role")`);

        // Create patients table
        await queryRunner.query(`
            CREATE TYPE "patient_gender_enum" AS ENUM('male', 'female', 'other')
        `);

        await queryRunner.query(`
            CREATE TYPE "patient_blood_type_enum" AS ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'unknown')
        `);

        await queryRunner.query(`
            CREATE TABLE "patients" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "patientId" character varying(100) NOT NULL,
                "firstName" character varying(50) NOT NULL,
                "lastName" character varying(50) NOT NULL,
                "dateOfBirth" date NOT NULL,
                "gender" "patient_gender_enum" NOT NULL,
                "bloodType" "patient_blood_type_enum" DEFAULT 'unknown',
                "weight" decimal(5,2),
                "height" decimal(5,2),
                "address" jsonb,
                "phoneNumber" character varying(20),
                "email" character varying(255),
                "emergencyContact" jsonb,
                "allergies" text[] DEFAULT '{}',
                "chronicConditions" text[] DEFAULT '{}',
                "currentMedications" text[] DEFAULT '{}',
                "clinicId" character varying(255) NOT NULL,
                "createdById" uuid NOT NULL,
                "isActive" boolean NOT NULL DEFAULT true,
                "lastVisit" TIMESTAMP,
                "syncStatus" jsonb,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_patients_patientId" UNIQUE ("patientId"),
                CONSTRAINT "PK_patients_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_patients_createdBy" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_patients_patientId" ON "patients" ("patientId")`);
        await queryRunner.query(`CREATE INDEX "IDX_patients_clinicId" ON "patients" ("clinicId")`);
        await queryRunner.query(`CREATE INDEX "IDX_patients_createdById" ON "patients" ("createdById")`);
        await queryRunner.query(`CREATE INDEX "IDX_patients_name" ON "patients" ("firstName", "lastName")`);
        await queryRunner.query(`CREATE INDEX "IDX_patients_syncStatus" ON "patients" ((("syncStatus"->>'pendingSync')::boolean)) WHERE (("syncStatus"->>'pendingSync')::boolean) = true`);

        // Create diagnoses table
        await queryRunner.query(`
            CREATE TYPE "diagnosis_status_enum" AS ENUM('pending', 'confirmed', 'revised', 'cancelled')
        `);

        await queryRunner.query(`
            CREATE TABLE "diagnoses" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "diagnosisId" character varying(100) NOT NULL,
                "patientId" uuid NOT NULL,
                "performedById" uuid NOT NULL,
                "clinicId" character varying(255) NOT NULL,
                "symptoms" jsonb NOT NULL,
                "vitalSigns" jsonb NOT NULL,
                "patientAge" integer NOT NULL,
                "patientGender" character varying(10) NOT NULL,
                "medicalHistory" text[] DEFAULT '{}',
                "aiPredictions" jsonb NOT NULL,
                "selectedDiagnosis" jsonb,
                "notes" text,
                "followUpRequired" boolean NOT NULL DEFAULT false,
                "followUpDate" TIMESTAMP,
                "prescriptions" jsonb,
                "labTestsOrdered" text[] DEFAULT '{}',
                "referralRequired" boolean NOT NULL DEFAULT false,
                "referralDetails" text,
                "status" "diagnosis_status_enum" NOT NULL DEFAULT 'pending',
                "diagnosisDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                "syncStatus" jsonb,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_diagnoses_diagnosisId" UNIQUE ("diagnosisId"),
                CONSTRAINT "PK_diagnoses_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_diagnoses_patient" FOREIGN KEY ("patientId") REFERENCES "patients"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_diagnoses_performedBy" FOREIGN KEY ("performedById") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_diagnosisId" ON "diagnoses" ("diagnosisId")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_patientId" ON "diagnoses" ("patientId")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_performedById" ON "diagnoses" ("performedById")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_clinicId" ON "diagnoses" ("clinicId")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_diagnosisDate" ON "diagnoses" ("diagnosisDate")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_status" ON "diagnoses" ("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_diagnoses_syncStatus" ON "diagnoses" ((("syncStatus"->>'pendingSync')::boolean)) WHERE (("syncStatus"->>'pendingSync')::boolean) = true`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop diagnoses table
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_syncStatus"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_status"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_diagnosisDate"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_clinicId"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_performedById"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_patientId"`);
        await queryRunner.query(`DROP INDEX "IDX_diagnoses_diagnosisId"`);
        await queryRunner.query(`DROP TABLE "diagnoses"`);
        await queryRunner.query(`DROP TYPE "diagnosis_status_enum"`);

        // Drop patients table
        await queryRunner.query(`DROP INDEX "IDX_patients_syncStatus"`);
        await queryRunner.query(`DROP INDEX "IDX_patients_name"`);
        await queryRunner.query(`DROP INDEX "IDX_patients_createdById"`);
        await queryRunner.query(`DROP INDEX "IDX_patients_clinicId"`);
        await queryRunner.query(`DROP INDEX "IDX_patients_patientId"`);
        await queryRunner.query(`DROP TABLE "patients"`);
        await queryRunner.query(`DROP TYPE "patient_blood_type_enum"`);
        await queryRunner.query(`DROP TYPE "patient_gender_enum"`);

        // Drop users table
        await queryRunner.query(`DROP INDEX "IDX_users_role"`);
        await queryRunner.query(`DROP INDEX "IDX_users_clinicId"`);
        await queryRunner.query(`DROP INDEX "IDX_users_email"`);
        await queryRunner.query(`DROP TABLE "users"`);
        await queryRunner.query(`DROP TYPE "user_role_enum"`);
    }
}
