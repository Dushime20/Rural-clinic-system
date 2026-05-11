import 'reflect-metadata';
import { AppDataSource } from './src/database/data-source';

async function testConnection() {
    try {
        console.log('Testing database connection...');
        await AppDataSource.initialize();
        console.log('✅ Database connected successfully!');
        console.log('Database:', AppDataSource.options.database);
        await AppDataSource.destroy();
        process.exit(0);
    } catch (error) {
        console.error('❌ Database connection failed:', error);
        process.exit(1);
    }
}

testConnection();
