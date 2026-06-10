/**
 * Script to create the test database
 */

import { Client } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

async function createTestDatabase() {
  // Connect to the default postgres database to create the test database
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: '1235',
    database: 'postgres', // Connect to default database
  });

  try {
    await client.connect();
    console.log('Connected to PostgreSQL');

    // Check if test database exists
    const res = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = 'ai_health_companion_test'"
    );

    if (res.rowCount === 0) {
      // Create test database
      await client.query('CREATE DATABASE ai_health_companion_test');
      console.log('✓ Test database created successfully');
    } else {
      console.log('✓ Test database already exists');
    }
  } catch (error) {
    console.error('Error creating test database:', error);
    throw error;
  } finally {
    await client.end();
  }
}

createTestDatabase()
  .then(() => {
    console.log('Test database setup complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Failed to setup test database:', error);
    process.exit(1);
  });
