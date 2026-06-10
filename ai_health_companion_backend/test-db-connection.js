// Simple database connection test
const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL
});

console.log('Testing database connection...');
console.log('Database URL:', process.env.DATABASE_URL);

client.connect()
    .then(() => {
        console.log('✅ Database connection successful!');
        return client.query('SELECT NOW()');
    })
    .then(result => {
        console.log('✅ Database is responding:', result.rows[0]);
        client.end();
        process.exit(0);
    })
    .catch(err => {
        console.error('❌ Database connection failed:');
        console.error('Error:', err.message);
        console.error('\nPossible issues:');
        console.error('1. PostgreSQL server is not running');
        console.error('2. Database "ai_health_companion" does not exist');
        console.error('3. Wrong credentials (username/password)');
        console.error('4. Wrong host/port');
        console.error('\nTo fix:');
        console.error('1. Start PostgreSQL: net start postgresql-x64-XX (Windows)');
        console.error('2. Create database: createdb ai_health_companion');
        console.error('3. Check .env file has correct DATABASE_URL');
        client.end();
        process.exit(1);
    });
