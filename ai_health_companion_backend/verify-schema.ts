import 'reflect-metadata';
import { AppDataSource } from './src/database/data-source';

async function verifySchema() {
  try {
    console.log('🔍 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();

    // Check if tables exist
    const tables = [
      'users',
      'clinics',
      'clinic_specialties',
      'disease_specialty_mappings',
      'analytics_events'
    ];

    console.log('📋 Checking tables:\n');

    for (const table of tables) {
      const result = await queryRunner.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_name = '${table}'
        );
      `);

      const exists = result[0].exists;
      console.log(`${exists ? '✅' : '❌'} ${table}: ${exists ? 'EXISTS' : 'NOT FOUND'}`);

      if (exists && table === 'users') {
        // Check if clinic role exists
        const roleCheck = await queryRunner.query(`
          SELECT EXISTS (
            SELECT 1 FROM pg_enum
            WHERE enumlabel = 'clinic'
            AND enumtypid = (
              SELECT oid FROM pg_type WHERE typname = 'users_role_enum'
            )
          );
        `);
        console.log(`   ${roleCheck[0].exists ? '✅' : '❌'} 'clinic' role in users_role_enum`);
      }

      if (exists && table === 'clinics') {
        // Check indexes
        const indexCheck = await queryRunner.query(`
          SELECT indexname FROM pg_indexes 
          WHERE tablename = 'clinics' 
          AND indexname LIKE 'IDX_clinics%';
        `);
        console.log(`   ✅ ${indexCheck.length} geospatial/active indexes found`);
      }

      if (exists && table === 'disease_specialty_mappings') {
        // Check seed data
        const count = await queryRunner.query(`SELECT COUNT(*) as count FROM disease_specialty_mappings;`);
        console.log(`   ✅ ${count[0].count} disease-specialty mappings seeded`);
      }
    }

    console.log('\n📊 Schema Verification Complete!');

    await queryRunner.release();
    await AppDataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('❌ Verification failed:', error);
    process.exit(1);
  }
}

verifySchema();
