/**
 * Password Reset Script
 * Usage: npx ts-node -r reflect-metadata scripts/reset-password.ts <email> <newPassword>
 * Example: npx ts-node -r reflect-metadata scripts/reset-password.ts koyib45887@ryzid.com NewPass@123
 */

import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { User } from '../src/models/User';
import dotenv from 'dotenv';

dotenv.config();

const [, , email, newPassword] = process.argv;

if (!email || !newPassword) {
    console.error('Usage: npx ts-node -r reflect-metadata scripts/reset-password.ts <email> <newPassword>');
    process.exit(1);
}

if (newPassword.length < 8) {
    console.error('❌ Password must be at least 8 characters');
    process.exit(1);
}

function buildDataSource(): DataSource {
    const rawUrl = process.env.DATABASE_URL || '';
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

async function resetPassword() {
    console.log(`\n🔑 Resetting password for: ${email}`);

    const ds = buildDataSource();

    try {
        await ds.initialize();
        console.log('✅ Database connected');

        const repo = ds.getRepository(User);

        // Must addSelect password since it's select:false in the entity
        const user = await repo
            .createQueryBuilder('user')
            .addSelect('user.password')
            .where('user.email = :email', { email })
            .getOne();

        if (!user) {
            console.error(`❌ No user found with email: ${email}`);
            process.exit(1);
        }

        console.log(`   Found: ${user.firstName} ${user.lastName} (${user.role})`);

        // Set new password — @BeforeUpdate hook will hash it automatically
        user.password = newPassword;
        user.mustChangePassword = false;
        await repo.save(user);

        console.log('\n✅ Password updated successfully!');
        console.log('');
        console.log('  ┌─────────────────────────────────────┐');
        console.log('  │         Updated Credentials          │');
        console.log('  ├─────────────────────────────────────┤');
        console.log(`  │  Email   : ${email.padEnd(26)}│`);
        console.log(`  │  Password: ${newPassword.padEnd(26)}│`);
        console.log('  └─────────────────────────────────────┘');
        console.log('');

    } catch (error) {
        console.error('❌ Failed:', error);
        process.exit(1);
    } finally {
        if (ds.isInitialized) await ds.destroy();
        process.exit(0);
    }
}

resetPassword();
