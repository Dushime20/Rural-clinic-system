# Quick Start: Email Service & User Management

## 🚀 Quick Setup (5 Minutes)

### Step 1: Configure Email (2 minutes)

Add to your `.env` file:

```env
# Gmail Example (Recommended for testing)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_NAME=AI Health Companion
SUPPORT_EMAIL=support@clinic.rw
APP_DOWNLOAD_URL=https://play.google.com/store
```

**Gmail App Password Setup:**
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification
3. Go to App passwords
4. Generate password for "Mail"
5. Copy 16-character password to `SMTP_PASSWORD`

### Step 2: Start Server (1 minute)

```bash
cd ai_health_companion_backend
npm run dev
```

### Step 3: Test User Creation (2 minutes)

#### 3.1 Login as Admin

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'
```

Copy the `accessToken` from response.

#### 3.2 Create Test User

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -d '{
    "email": "test.doctor@clinic.rw",
    "firstName": "Test",
    "lastName": "Doctor",
    "role": "DOCTOR",
    "sendEmail": true
  }'
```

#### 3.3 Check Results

✅ **Response should show:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": { ... },
    "temporaryPassword": "Xy9@mK2pL5qR",
    "emailSent": true
  }
}
```

✅ **Email should arrive** at test.doctor@clinic.rw with:
- Login credentials
- Getting started guide
- App download link

## 📱 User Login Flow

### Mobile App Login

User receives email and uses:
- **Email:** test.doctor@clinic.rw
- **Password:** Xy9@mK2pL5qR (from email)

```bash
# Test login with new user credentials
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.doctor@clinic.rw",
    "password": "Xy9@mK2pL5qR"
  }'
```

### Change Password (First Login)

```bash
curl -X POST http://localhost:5000/api/v1/users/me/change-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer USER_ACCESS_TOKEN" \
  -d '{
    "currentPassword": "Xy9@mK2pL5qR",
    "newPassword": "MyNewSecure@Pass123"
  }'
```

## 🎯 Common Use Cases

### Create Doctor

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "email": "doctor@clinic.rw",
    "firstName": "John",
    "lastName": "Doe",
    "role": "DOCTOR",
    "clinicId": "clinic-001",
    "phoneNumber": "+250788123456"
  }'
```

### Create Nurse

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "email": "nurse@clinic.rw",
    "firstName": "Jane",
    "lastName": "Smith",
    "role": "NURSE",
    "clinicId": "clinic-001"
  }'
```

### Create Community Health Worker

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "email": "chw@clinic.rw",
    "firstName": "Mary",
    "lastName": "Johnson",
    "role": "CHW",
    "clinicId": "clinic-002"
  }'
```

### Reset User Password

```bash
curl -X POST http://localhost:5000/api/v1/users/USER_ID/reset-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "sendEmail": true
  }'
```

### Get All Users

```bash
curl -X GET "http://localhost:5000/api/v1/users?page=1&limit=20" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Filter Users by Role

```bash
curl -X GET "http://localhost:5000/api/v1/users?role=DOCTOR&page=1&limit=20" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Deactivate User

```bash
curl -X PUT http://localhost:5000/api/v1/users/USER_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "isActive": false
  }'
```

## 🔍 Troubleshooting

### Email Not Sending?

**Check logs:**
```bash
# Look for email service messages
tail -f logs/app.log | grep -i email
```

**Test without email:**
```bash
# Create user without sending email
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "email": "test@clinic.rw",
    "firstName": "Test",
    "lastName": "User",
    "role": "DOCTOR",
    "sendEmail": false
  }'
```

### Can't Login as Admin?

**Seed admin user:**
```bash
npm run seed:admin
```

**Default credentials:**
- Email: admin@clinic.rw
- Password: Admin@1234

### 401 Unauthorized?

- Check if token is valid
- Token expires after 24 hours
- Login again to get new token

### 403 Forbidden?

- Only ADMIN role can create users
- Check user role in token
- Login with admin account

## 📊 Available Roles

| Role | Description | Can Create Users |
|------|-------------|------------------|
| ADMIN | System administrator | ✅ Yes |
| DOCTOR | Medical doctor | ❌ No |
| NURSE | Nursing staff | ❌ No |
| CHW | Community Health Worker | ❌ No |
| PHARMACIST | Pharmacy staff | ❌ No |
| LAB_TECHNICIAN | Lab technician | ❌ No |

## 🎨 Email Preview

The welcome email includes:

```
┌─────────────────────────────────────┐
│   🏥 Welcome to AI Health Companion  │
│   Your account has been created      │
└─────────────────────────────────────┘

Hello John Doe! 👋

Welcome to AI Health Companion!

🔐 Your Login Credentials
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email: doctor@clinic.rw
Password: Xy9@mK2pL5qR
Role: Doctor

⚠️ Important Security Notice
• This is a temporary password
• Change it on first login
• Never share your password

📱 Getting Started
✓ Download the mobile app
✓ Open and tap "Login"
✓ Enter your credentials
✓ Create new password
✓ Complete profile
✓ Start providing care!

[📲 Download Mobile App]

Features:
🤖 AI Diagnosis  📴 Offline Mode
👥 Patient Records  📊 Reports

Need Help?
📧 support@clinic.rw
```

## 🔗 API Endpoints Summary

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/v1/users` | Admin | Create user |
| GET | `/api/v1/users` | Admin | List users |
| GET | `/api/v1/users/:id` | Admin | Get user |
| PUT | `/api/v1/users/:id` | Admin | Update user |
| DELETE | `/api/v1/users/:id` | Admin | Delete user |
| POST | `/api/v1/users/:id/reset-password` | Admin | Reset password |
| GET | `/api/v1/users/me` | User | Get profile |
| PUT | `/api/v1/users/me` | User | Update profile |
| POST | `/api/v1/users/me/change-password` | User | Change password |

## ✅ Checklist

Before going to production:

- [ ] Configure production SMTP server
- [ ] Update `APP_DOWNLOAD_URL` with real app store link
- [ ] Set `SUPPORT_EMAIL` to real support email
- [ ] Test email delivery to different providers (Gmail, Outlook, etc.)
- [ ] Verify email doesn't go to spam
- [ ] Test all user roles
- [ ] Test password reset flow
- [ ] Configure email rate limiting
- [ ] Set up email monitoring/alerts
- [ ] Document admin procedures

## 📚 Full Documentation

For complete details, see:
- `EMAIL_SERVICE_GUIDE.md` - Full implementation guide
- `ADMIN_CREDENTIALS.md` - Admin access information
- API documentation at http://localhost:5000/api-docs

---

**Ready to test!** 🚀
