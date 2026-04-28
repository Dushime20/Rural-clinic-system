# Admin Credentials

## 🔐 Default Admin User

The system comes with a default admin user that can be created using the seed script.

### Credentials

```
┌─────────────────────────────────────┐
│         Admin Credentials            │
├─────────────────────────────────────┤
│  Email   : admin@clinic.rw          │
│  Password: Admin@1234               │
│  Role    : ADMIN                    │
└─────────────────────────────────────┘
```

---

## 🚀 How to Create Admin User

### Method 1: Using npm script (Recommended)

```bash
cd ai_health_companion_backend
npm run seed:admin
```

### Method 2: Using ts-node directly

```bash
cd ai_health_companion_backend
npx ts-node -r reflect-metadata src/database/seed-admin.ts
```

---

## 📋 Admin User Details

| Field | Value |
|-------|-------|
| **Email** | admin@clinic.rw |
| **Password** | Admin@1234 |
| **First Name** | System |
| **Last Name** | Admin |
| **Role** | ADMIN |
| **Status** | Active |
| **Email Verified** | Yes |

---

## 🔑 Login Process

### Step 1: Start the Backend

```bash
cd ai_health_companion_backend
npm run dev
```

### Step 2: Login via API

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'
```

### Step 3: Get Access Token

Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "admin@clinic.rw",
      "firstName": "System",
      "lastName": "Admin",
      "role": "ADMIN"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

### Step 4: Use Access Token

```bash
curl -X GET http://localhost:5000/api/v1/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 🌐 Admin Dashboard Login

### Web Dashboard

1. Open: `http://localhost:3000` (or your admin dashboard URL)
2. Enter credentials:
   - **Email**: `admin@clinic.rw`
   - **Password**: `Admin@1234`
3. Click "Login"

---

## ⚠️ Security Recommendations

### 1. Change Password Immediately

After first login, change the default password:

```bash
curl -X PUT http://localhost:5000/api/v1/auth/change-password \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "Admin@1234",
    "newPassword": "YourStrongPassword@2024"
  }'
```

### 2. Use Strong Password

Requirements:
- ✅ Minimum 8 characters
- ✅ At least 1 uppercase letter
- ✅ At least 1 lowercase letter
- ✅ At least 1 number
- ✅ At least 1 special character (@, #, $, etc.)

### 3. Enable Two-Factor Authentication (if available)

### 4. Don't Share Credentials

- Never share admin credentials
- Create separate accounts for other admins
- Use role-based access control

---

## 👥 Creating Additional Admin Users

### Via API

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newadmin@clinic.rw",
    "password": "SecurePassword@123",
    "firstName": "John",
    "lastName": "Doe",
    "role": "ADMIN"
  }'
```

### Via Admin Dashboard

1. Login as admin
2. Go to "Users" section
3. Click "Add User"
4. Fill in details
5. Select role: "ADMIN"
6. Click "Create"

---

## 🔄 Reset Admin Password

### If You Forgot Password

#### Method 1: Re-run Seed Script

```bash
# Delete existing admin user from database
psql $DATABASE_URL -c "DELETE FROM users WHERE email='admin@clinic.rw';"

# Re-run seed script
npm run seed:admin
```

#### Method 2: Direct Database Update

```bash
# Connect to database
psql $DATABASE_URL

# Update password (hashed)
UPDATE users 
SET password = '$2b$12$...' -- Use bcrypt to hash new password
WHERE email = 'admin@clinic.rw';
```

#### Method 3: Use Password Reset API

```bash
curl -X POST http://localhost:5000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw"
  }'
```

---

## 🛡️ Admin Permissions

The admin user has full access to:

### User Management
- ✅ Create, read, update, delete users
- ✅ Assign roles and permissions
- ✅ Activate/deactivate accounts

### Patient Management
- ✅ View all patient records
- ✅ Edit patient information
- ✅ Delete patient records

### Diagnosis Management
- ✅ View all diagnoses
- ✅ Review AI predictions
- ✅ Override diagnoses

### System Configuration
- ✅ Update system settings
- ✅ Configure AI model
- ✅ Manage integrations

### Reports & Analytics
- ✅ View all reports
- ✅ Export data
- ✅ Generate analytics

### Audit Logs
- ✅ View all system logs
- ✅ Track user activities
- ✅ Monitor system health

---

## 📊 Verification

### Check if Admin Exists

```bash
# Via API
curl -X GET http://localhost:5000/api/v1/users?email=admin@clinic.rw \
  -H "Authorization: Bearer YOUR_TOKEN"

# Via Database
psql $DATABASE_URL -c "SELECT * FROM users WHERE email='admin@clinic.rw';"
```

### Test Admin Login

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "user": {
      "role": "ADMIN"
    },
    "tokens": {
      "accessToken": "..."
    }
  }
}
```

---

## 🔧 Troubleshooting

### Issue: "Admin user already exists"

**Solution**: Admin is already created. Use existing credentials or delete and recreate:

```bash
psql $DATABASE_URL -c "DELETE FROM users WHERE email='admin@clinic.rw';"
npm run seed:admin
```

### Issue: "Invalid credentials"

**Possible causes**:
1. Wrong password (case-sensitive)
2. User not created yet
3. User is inactive

**Solution**:
```bash
# Check user status
psql $DATABASE_URL -c "SELECT email, is_active FROM users WHERE email='admin@clinic.rw';"

# Activate user if needed
psql $DATABASE_URL -c "UPDATE users SET is_active=true WHERE email='admin@clinic.rw';"
```

### Issue: "Database connection failed"

**Solution**: Check DATABASE_URL in .env file:

```bash
# Verify connection
psql $DATABASE_URL -c "SELECT 1;"

# Update .env if needed
DATABASE_URL=postgresql://user:password@host:5432/database
```

---

## 📝 Notes

1. **Default Password**: `Admin@1234` is the default password. Change it immediately after first login.

2. **Email Format**: The email `admin@clinic.rw` uses `.rw` (Rwanda) domain. You can change this in the seed script if needed.

3. **Password Hashing**: Passwords are automatically hashed using bcrypt before storage.

4. **Token Expiry**: 
   - Access Token: 24 hours
   - Refresh Token: 7 days

5. **Multiple Admins**: You can create multiple admin users with different emails.

---

## 🎯 Quick Reference

```bash
# Create admin
npm run seed:admin

# Login
Email: admin@clinic.rw
Password: Admin@1234

# API Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@clinic.rw","password":"Admin@1234"}'

# Change password (after login)
curl -X PUT http://localhost:5000/api/v1/auth/change-password \
  -H "Authorization: Bearer TOKEN" \
  -d '{"currentPassword":"Admin@1234","newPassword":"NewPassword@123"}'
```

---

## 🔐 Security Checklist

- [ ] Admin user created
- [ ] Default password changed
- [ ] Strong password set
- [ ] Two-factor authentication enabled (if available)
- [ ] Admin email verified
- [ ] Backup admin account created
- [ ] Password stored securely (password manager)
- [ ] Regular password rotation scheduled

---

**⚠️ IMPORTANT**: Change the default password immediately after first login for security!

---

**Last Updated**: 2026-04-28
