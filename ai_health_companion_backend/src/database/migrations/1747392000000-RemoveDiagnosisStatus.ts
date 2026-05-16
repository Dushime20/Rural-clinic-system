import { MigrationInterface, QueryRunner } from 'typeorm';

export class RemoveDiagnosisStatus1747392000000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Drop the status column from diagnoses table
        await queryRunner.query(`
            ALTER TABLE "diagnoses" DROP COLUMN IF EXISTS "status"
        `);

        // Drop the status index if it exists
        await queryRunner.query(`
            DROP INDEX IF EXISTS "IDX_diagnoses_status"
        `);

        // Drop the diagnosis_status_enum type
        await queryRunner.query(`
            DROP TYPE IF EXISTS "diagnosis_status_enum"
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Recreate the diagnosis_status_enum type
        await queryRunner.query(`
            CREATE TYPE "diagnosis_status_enum" AS ENUM('pending', 'confirmed', 'revised', 'cancelled')
        `);

        // Add the status column back
        await queryRunner.query(`
            ALTER TABLE "diagnoses" 
            ADD COLUMN "status" "diagnosis_status_enum" NOT NULL DEFAULT 'pending'
        `);

        // Recreate the status index
        await queryRunner.query(`
            CREATE INDEX "IDX_diagnoses_status" ON "diagnoses" ("status")
        `);
    }
}
