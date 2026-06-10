# Backend Startup Troubleshooting Guide

## ❌ Backend Crashes After "Email service initialized successfully"

This usually means the **database connection is failing**.

---

## 🔍 Quick Diagnosis

Run the database connection test:

```bash
cd ai_health_companion_backend
node test-db-connection.js
```

This will tell you exactly what's wrong.

---

## 🛠️ Common Issues & Solutions

### Issue 1: PostgreSQL Not Running

**Error Message:**
```
ECONNREFUSED 127.0.0.1:5432
```

**Solution:**

**Check if PostgreSQL is running:**
```bash
# Windows
sc query postgresql-x64-XX

# Or check if port 5432 is listening
netstat -an | findstr :5432
```

**Start PostgreSQL:**
```bash
# Windows (as Administrator)
net start postgresql-x64-XX

# Or use pg_ctl
pg_ctl -D "C:\Program Files\PostgreSQL\XX\data" start

# Or use Services app
# Press Win+R, type "services.msc", find PostgreSQL, click Start
```

---

### Issue 2: Database Doesn't Exist

**Error Message:**
```
database "ai_health_companion" does not exist
```

**Solution:**

**Create the database:**
```bash
# Option 1: Using createdb command
createdb -U postgres ai_health_companion

# Option 2: Using psql
psql -U postgres
CREATE DATABASE ai_health_companion;
\q

# Option 3: Using pgAdmin
# Open pgAdmin → Right-click Databases → Create → Database
# Name: ai_health_companion
```

---

### Issue 3: Wrong Credentials

**Error Message:**
```
password authentication failed for user "postgres"
```

**Solution:**

**Update .env file with correct credentials:**
```bash
# Edit ai_health_companion_backend/.env
DATABASE_URL=postgresql://USERNAME:PASSWORD@localhost:5432/ai_health_companion

# Replace:
# USERNAME - your PostgreSQL username (default: postgres)
# PASSWORD - your PostgreSQL password
```

---

### Issue 4: Wrong Port

**Error Message:**
```
ECONNREFUSED 127.0.0.1:5432
```

**Solution:**

**Check PostgreSQL port:**
```bash
# Find PostgreSQL port in postgresql.conf
# Usually: C:\Program Files\PostgreSQL\XX\data\postgresql.conf
# Look for: port = 5432
```

**If PostgreSQL is on different port, update .env:**
```bash
DATABASE_URL=postgresql://postgres:password@localhost:PORT/ai_health_companion
```

---

### Issue 5: Missing Environment Variable

**Error:**
```
Cannot read property 'CLINIC_DASHBOARD_URL' of undefined
```

**Solution:**

I've already added `CLINIC_DASHBOARD_URL=http://localhost:5175` to your `.env` file.

If you see other missing variables, check that your `.env` file is complete.

---

## ✅ Complete Setup Steps

### Step 1: Install PostgreSQL

If you don't have PostgreSQL installed:

**Windows:**
1. Download from: https://www.postgresql.org/download/windows/
2. Run installer
3. Remember the password you set for `postgres` user
4. Keep default port: 5432

### Step 2: Create Database

```bash
# Using psql (after PostgreSQL is installed)
psql -U postgres
# Enter password when prompted

# Then run:
CREATE DATABASE ai_health_companion;
\q
```

### Step 3: Update .env File

```bash
# Edit ai_health_companion_backend/.env
# Update this line with your PostgreSQL password:
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/ai_health_companion
```

### Step 4: Test Connection

```bash
cd ai_health_companion_backend
node test-db-connection.js
```

**Expected output:**
```
Testing database connection...
Database URL: postgresql://postgres:****@localhost:5432/ai_health_companion
✅ Database connection successful!
✅ Database is responding: { now: 2024-01-10T10:30:00.000Z }
```

### Step 5: Start Backend

```bash
cd ai_health_companion_backend
npm run dev
```

**Expected output:**
```
2026-06-09 18:42:25 [info]: Email service initialized successfully
✅ PostgreSQL connected successfully
🚀 Server running on port 5000 in development mode
📚 API Documentation: http://localhost:5000/api-docs
🏥 Health Check: http://localhost:5000/health
```

---

## 🔧 Alternative: Use Docker PostgreSQL

If you have Docker installed, you can run PostgreSQL in a container:

```bash
# Start PostgreSQL container
docker run --name postgres-health-companion \
  -e POSTGRES_PASSWORD=1235 \
  -e POSTGRES_DB=ai_health_companion \
  -p 5432:5432 \
  -d postgres:14

# Check if running
docker ps

# Your DATABASE_URL in .env should be:
# DATABASE_URL=postgresql://postgres:1235@localhost:5432/ai_health_companion
```

**Stop PostgreSQL container:**
```bash
docker stop postgres-health-companion
```

**Start PostgreSQL container again:**
```bash
docker start postgres-health-companion
```

---

## 📊 Verification Checklist

Before starting the backend, verify:

- [ ] PostgreSQL is running
  ```bash
  netstat -an | findstr :5432
  # Should show LISTENING
  ```

- [ ] Database exists
  ```bash
  psql -U postgres -l | findstr ai_health_companion
  # Should show ai_health_companion in list
  ```

- [ ] Connection test passes
  ```bash
  node test-db-connection.js
  # Should show ✅ success messages
  ```

- [ ] .env file has correct DATABASE_URL
  ```bash
  # Check the file
  cat .env | findstr DATABASE_URL
  ```

---

## 🆘 Still Not Working?

### Get Detailed Error Information

1. **Check backend logs:**
   ```bash
   # If using start-all-services scripts
   cat logs/backend.log
   ```

2. **Run backend manually to see error:**
   ```bash
   cd ai_health_companion_backend
   npm run dev
   # Watch the terminal for error messages
   ```

3. **Check PostgreSQL logs:**
   ```
   # Windows: Usually in
   C:\Program Files\PostgreSQL\XX\data\log\
   ```

### Common Error Messages

**"role 'postgres' does not exist":**
```bash
# Create postgres user
createuser -s postgres
```

**"could not connect to server":**
- PostgreSQL service is not running
- Firewall is blocking port 5432
- PostgreSQL is configured to not accept connections

**"too many connections":**
- Restart PostgreSQL service
- Or increase max_connections in postgresql.conf

---

## 📝 Summary: Most Common Fix

**For most users, the issue is simply that PostgreSQL is not running:**

```bash
# Windows (Run as Administrator)
net start postgresql-x64-14

# Or use Services
# Win+R → services.msc → Find PostgreSQL → Start
```

Then test:
```bash
node test-db-connection.js
```

Then start backend:
```bash
npm run dev
```

---

## ✅ Success!

When everything is working, you'll see:

```
2026-06-09 18:42:25 [info]: Email service initialized successfully
✅ PostgreSQL connected successfully
🚀 Server running on port 5000 in development mode
📚 API Documentation: http://localhost:5000/api-docs
🏥 Health Check: http://localhost:5000/health
📱 Emulator Access: http://10.0.2.2:5000
```

Now you can access:
- Backend API: http://localhost:5000
- API Docs: http://localhost:5000/api-docs
- Health Check: http://localhost:5000/health

---

**Need more help?** Check the error message and search for it in this guide.
