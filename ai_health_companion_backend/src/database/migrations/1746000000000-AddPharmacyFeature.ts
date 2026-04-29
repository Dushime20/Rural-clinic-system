import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPharmacyFeature1746000000000 implements MigrationInterface {
    name = 'AddPharmacyFeature1746000000000';

    public async up(queryRunner: QueryRunner): Promise<void> {
        // 1. Add 'pharmacist' to the existing user_role_enum
        await queryRunner.query(`
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_enum
                    WHERE enumlabel = 'pharmacist'
                    AND enumtypid = (
                        SELECT oid FROM pg_type WHERE typname = 'user_role_enum'
                    )
                ) THEN
                    ALTER TYPE user_role_enum ADD VALUE 'pharmacist';
                END IF;
            END
            $$;
        `);

        // 2. Create pharmacies table
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "pharmacies" (
                "id"            uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "managerId"     uuid              NOT NULL,
                "managerName"   character varying(255),
                "name"          character varying(255) NOT NULL,
                "phoneNumber"   character varying(20),
                "address"       character varying(500),
                "latitude"      numeric(10,7)     NOT NULL,
                "longitude"     numeric(10,7)     NOT NULL,
                "city"          character varying(255),
                "district"      character varying(255),
                "country"       character varying(255),
                "isActive"      boolean           NOT NULL DEFAULT true,
                "openingHours"  character varying(100),
                "createdAt"     TIMESTAMP         NOT NULL DEFAULT now(),
                "updatedAt"     TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_pharmacies_managerId" UNIQUE ("managerId"),
                CONSTRAINT "PK_pharmacies" PRIMARY KEY ("id")
            )
        `);

        // 3. Create pharmacy_medicines table
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "pharmacy_medicines" (
                "id"               uuid              NOT NULL DEFAULT uuid_generate_v4(),
                "pharmacyId"       uuid              NOT NULL,
                "medicationName"   character varying(255) NOT NULL,
                "genericName"      character varying(255),
                "brandName"        character varying(255),
                "strength"         character varying(100),
                "form"             character varying(50),
                "category"         character varying(100),
                "price"            numeric(10,2)     NOT NULL,
                "currency"         character varying(10) NOT NULL DEFAULT 'RWF',
                "stockQuantity"    integer           NOT NULL DEFAULT 0,
                "isAvailable"      boolean           NOT NULL DEFAULT true,
                "notes"            text,
                "createdAt"        TIMESTAMP         NOT NULL DEFAULT now(),
                "updatedAt"        TIMESTAMP         NOT NULL DEFAULT now(),
                CONSTRAINT "PK_pharmacy_medicines" PRIMARY KEY ("id"),
                CONSTRAINT "FK_pharmacy_medicines_pharmacy"
                    FOREIGN KEY ("pharmacyId")
                    REFERENCES "pharmacies"("id")
                    ON DELETE CASCADE
            )
        `);

        // 4. Indexes
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_pharmacies_managerId"  ON "pharmacies" ("managerId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_pharmacies_isActive"   ON "pharmacies" ("isActive")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_pharm_med_pharmacyId"  ON "pharmacy_medicines" ("pharmacyId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_pharm_med_name"        ON "pharmacy_medicines" ("pharmacyId", "medicationName")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE IF EXISTS "pharmacy_medicines"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "pharmacies"`);
        // Note: PostgreSQL does not support removing enum values directly.
        // The pharmacist enum value would need a full enum recreation to remove.
    }
}
