# Database Setup Guide

## Step 1: Verify PostgreSQL is Running

Open a new terminal and run:
```bash
psql -U postgres
```

If it connects, PostgreSQL is running. Type `\q` to exit.

## Step 2: Create Database (if not already created)

```bash
psql -U postgres -c "CREATE DATABASE ai_health_companion;"
```

## Step 3: Run Database Migrations

From the `ai_health_companion_backend` directory:

```bash
npm run migration:run
```

This will create all the necessary tables.

## Step 4: Seed Admin User (Optional)

Create a default admin user:

```bash
npm run seed:admin
```

## Step 5: Start the Server

```bash
npm run dev
```

## Troubleshooting

### If migrations fail:
1. Check if database exists:
   ```bash
   psql -U postgres -l
   ```

2. Drop and recreate database:
   ```bash
   psql -U postgres -c "DROP DATABASE IF EXISTS ai_health_companion;"
   psql -U postgres -c "CREATE DATABASE ai_health_companion;"
   npm run migration:run
   ```

### If connection fails:
- Verify PostgreSQL is running
- Check `.env` file has correct DATABASE_URL
- Default: `postgresql://postgres:postgres@localhost:5432/ai_health_companion`
