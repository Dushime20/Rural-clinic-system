/**
 * One-time script: adds 'pharmacist' to the users_role_enum type in PostgreSQL.
 * Run with: npx ts-node -r reflect-metadata scripts/add-pharmacist-enum.ts
 */
import 'reflect-metadata';
import { AppDataSource } from '../src/database/data-source';

async function run() {
    await AppDataSource.initialize();
    console.log('Connected to database');

    try {
        // Add pharmacist to the existing enum (safe to run multiple times)
        await AppDataSource.query(`
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_enum
                    WHERE enumlabel = 'pharmacist'
                    AND enumtypid = (
                        SELECT oid FROM pg_type WHERE typname = 'users_role_enum'
                    )
                ) THEN
                    ALTER TYPE users_role_enum ADD VALUE 'pharmacist';
                END IF;
            END
            $$;
        `);
        console.log('✅ pharmacist enum value added (or already existed)');
    } catch (err) {
        console.error('❌ Failed:', err);
    } finally {
        await AppDataSource.destroy();
    }
}

run();
