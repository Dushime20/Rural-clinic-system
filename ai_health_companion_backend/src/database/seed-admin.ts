/**
 * Admin User Seed Script
 * Run: npm run seed:admin
 */
import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { User, UserRole } from '../models/User';
import dotenv from 'dotenv';

dotenv.config();

const ADMIN = {
    email: 'admin@clinic.rw',
    password: 'Admin@1234',
    firstName: 'System',
    lastName: 'Admin',
    role: UserRole.ADMIN,
    isActive: true,
    isEmailVerified: true,
};

// Parse the DATABASE_URL manually to handle Neon's channel_binding param
// which TypeORM's pg driver doesn't support natively
function buildDataSource(): DataSource {
    const rawUrl = process.env.DATABASE_URL || '';

    // Strip unsupported params from the URL for TypeORM
    const cleanUrl = rawUrl
        .replace(/[?&]channel_binding=[^&]*/g, '')
        .replace(/\?&/, '?')
        .replace(/&&/, '&')
        .replace(/[?&]$/, '');

    return new DataSource({
        type: 'postgres',
        url: cleanUrl,
        ssl: { rejectUnauthorized: false },
        synchronize: false,
        logging: false,
        entities: [User],
        connectTimeoutMS: 15000,
    });
}

async function seed() {
    console.log('🌱 Connecting to database...');

    const ds = buildDataSource();

    try {
        await ds.initialize();
        console.log('✅ Database connected');

        const repo = ds.getRepository(User);

        // Check if admin already exists
        const existing = await repo.findOne({ where: { email: ADMIN.email } });

        if (existing) {
            console.log(`⚠️  Admin user already exists: ${ADMIN.email}`);
            console.log('   To reset, delete the user and re-run this script.');
        } else {
            const user = repo.create(ADMIN);
            await repo.save(user);

            console.log('');
            console.log('✅ Admin user created successfully!');
            console.log('');
            console.log('  ┌─────────────────────────────────────┐');
            console.log('  │         Admin Credentials            │');
            console.log('  ├─────────────────────────────────────┤');
            console.log(`  │  Email   : ${ADMIN.email.padEnd(26)}│`);
            console.log(`  │  Password: ${ADMIN.password.padEnd(26)}│`);
            console.log('  └─────────────────────────────────────┘');
            console.log('');
            console.log('  ⚠️  Change the password after first login!');
        }
    } catch (error) {
        console.error('❌ Seed failed:', error);
        process.exit(1);
    } finally {
        if (ds.isInitialized) {
            await ds.destroy();
        }
        process.exit(0);
    }
}

seed();
