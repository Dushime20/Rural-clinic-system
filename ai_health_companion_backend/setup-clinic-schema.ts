import 'reflect-metadata';
import { AppDataSource } from './src/database/data-source';

async function setupClinicSchema() {
  try {
    console.log('🔍 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();

    console.log('📝 Setting up clinic schema...\n');

    // 1. Verify 'clinic' role exists in user_role_enum
    console.log('1️⃣ Verifying clinic role in user_role_enum...');
    const roleCheck = await queryRunner.query(`
      SELECT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'clinic'
        AND enumtypid = (
          SELECT oid FROM pg_type WHERE typname = 'users_role_enum'
        )
      );
    `);

    if (roleCheck[0].exists) {
      console.log('✅ Clinic role already exists\n');
    } else {
      console.log('⚠️  Clinic role not found. This should not happen with synchronize=true\n');
    }

    // 2. Create indexes for clinics table
    console.log('2️⃣ Creating indexes for clinics table...');
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_managerId" ON "clinics" ("managerId")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_isActive" ON "clinics" ("isActive")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinics_location" ON "clinics" ("latitude", "longitude")`
    );
    console.log('✅ Clinic indexes created\n');

    // 3. Create indexes for clinic_specialties table
    console.log('3️⃣ Creating indexes for clinic_specialties table...');
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinic_specialties_clinicId" ON "clinic_specialties" ("clinicId")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_clinic_specialties_specialty" ON "clinic_specialties" ("specialty")`
    );
    console.log('✅ Clinic specialties indexes created\n');

    // 4. Create indexes for disease_specialty_mappings table
    console.log('4️⃣ Creating indexes for disease_specialty_mappings table...');
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_disease_specialty_mappings_diseaseName" ON "disease_specialty_mappings" ("diseaseName")`
    );
    console.log('✅ Disease specialty mappings indexes created\n');

    // 5. Create indexes for analytics_events table
    console.log('5️⃣ Creating indexes for analytics_events table...');
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_analytics_events_eventType_createdAt" ON "analytics_events" ("eventType", "createdAt")`
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_analytics_events_patientId" ON "analytics_events" ("patientId")`
    );
    console.log('✅ Analytics events indexes created\n');

    // 6. Seed disease-specialty mappings
    console.log('6️⃣ Seeding disease-specialty mappings...');
    await queryRunner.query(`
      INSERT INTO "disease_specialty_mappings" 
      ("diseaseName", "primarySpecialty", "secondarySpecialties", "priority") 
      VALUES
        ('Diabetes', 'Endocrinology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Hypertension', 'Cardiology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Heart Disease', 'Cardiology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Malaria', 'Infectious_Disease', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Tuberculosis', 'Pulmonology', ARRAY['Infectious_Disease', 'General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Pneumonia', 'Pulmonology', ARRAY['Infectious_Disease', 'General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Asthma', 'Pulmonology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Kidney Disease', 'Nephrology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Gastritis', 'Gastroenterology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Stroke', 'Neurology', ARRAY['Cardiology', 'General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Epilepsy', 'Neurology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Cancer', 'Oncology', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Skin Infection', 'Dermatology', ARRAY['Infectious_Disease', 'General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 2),
        ('Fracture', 'Orthopedics', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 1),
        ('Arthritis', 'Orthopedics', ARRAY['General_Medicine']::disease_specialty_mappings_secondaryspecialties_enum[], 2)
      ON CONFLICT DO NOTHING
    `);
    
    const count = await queryRunner.query(`SELECT COUNT(*) as count FROM disease_specialty_mappings;`);
    console.log(`✅ Seeded ${count[0].count} disease-specialty mappings\n`);

    console.log('🎉 Clinic schema setup complete!');

    await queryRunner.release();
    await AppDataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  }
}

setupClinicSchema();
