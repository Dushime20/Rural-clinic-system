# User Creation & Email Workflow

## Complete End-to-End Workflow

This document shows the complete workflow from admin creating a user to the user logging into the mobile app.

## 🎯 Workflow Overview

```
┌─────────────┐
│   ADMIN     │
│  Dashboard  │
└──────┬──────┘
       │
       │ 1. Creates User
       ▼
┌─────────────────┐
│   Backend API   │
│  (Node.js)      │
└──────┬──────────┘
       │
       ├─ 2. Generates Password
       ├─ 3. Saves to Database
       ├─ 4. Sends Email
       │
       ▼
┌─────────────────┐
│  Email Service  │
│  (SMTP)         │
└──────┬──────────┘
       │
       │ 5. Delivers Email
       ▼
┌─────────────────┐
│   USER EMAIL    │
│   INBOX         │
└──────┬──────────┘
       │
       │ 6. User Opens Email
       ▼
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└──────┬──────────┘
       │
       │ 7. User Logs In
       ▼
┌─────────────────┐
│  Change Pass    │
│  First Login    │
└─────────────────┘
```

## 📋 Step-by-Step Process

### Step 1: Admin Creates User

**Admin Dashboard Action:**
```javascript
// Admin fills form:
{
  email: "doctor@clinic.rw",
  firstName: "John",
  lastName: "Doe",
  role: "DOCTOR",
  clinicId: "clinic-001",
  phoneNumber: "+250788123456"
}
```

**API Request:**
```bash
POST /api/v1/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "email": "doctor@clinic.rw",
  "firstName": "John",
  "lastName": "Doe",
  "role": "DOCTOR",
  "clinicId": "clinic-001",
  "phoneNumber": "+250788123456",
  "sendEmail": true
}
```

### Step 2: Backend Generates Password

**System Action:**
```typescript
// Auto-generated secure password
const temporaryPassword = generateRandomPassword();
// Result: "Xy9@mK2pL5qR"

// Password characteristics:
// - 12 characters
// - Uppercase: X, L, R
// - Lowercase: y, m, p, q
// - Numbers: 9, 2, 5
// - Special: @, @
```

### Step 3: User Saved to Database

**Database Record:**
```sql
INSERT INTO users (
  id,
  email,
  password, -- hashed: $2b$12$...
  first_name,
  last_name,
  role,
  clinic_id,
  phone_number,
  is_active,
  created_at
) VALUES (
  'uuid-here',
  'doctor@clinic.rw',
  '$2b$12$hashed_password_here',
  'John',
  'Doe',
  'DOCTOR',
  'clinic-001',
  '+250788123456',
  true,
  NOW()
);
```

### Step 4: Email Sent

**Email Service Action:**
```typescript
await emailService.sendWelcomeEmail({
  email: "doctor@clinic.rw",
  password: "Xy9@mK2pL5qR",
  firstName: "John",
  lastName: "Doe",
  role: "DOCTOR"
});
```

**SMTP Transaction:**
```
From: AI Health Companion <noreply@clinic.rw>
To: doctor@clinic.rw
Subject: Welcome to AI Health Companion - Your Account Credentials

[Beautiful HTML Email Content]
```

### Step 5: Admin Receives Response

**API Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "doctor@clinic.rw",
      "firstName": "John",
      "lastName": "Doe",
      "role": "DOCTOR",
      "clinicId": "clinic-001",
      "phoneNumber": "+250788123456",
      "isActive": true
    },
    "temporaryPassword": "Xy9@mK2pL5qR",
    "emailSent": true
  }
}
```

**Admin Dashboard Shows:**
```
✅ User Created Successfully!

User: John Doe (doctor@clinic.rw)
Role: Doctor
Temporary Password: Xy9@mK2pL5qR
Email Sent: ✅ Yes

The user will receive an email with login instructions.
```

### Step 6: User Receives Email

**Email Content (Simplified):**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 Welcome to AI Health Companion
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Hello John Doe! 👋

Welcome to AI Health Companion! An administrator has 
created an account for you.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 Your Login Credentials
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Email Address:    doctor@clinic.rw
Temporary Password: Xy9@mK2pL5qR
Role:             Doctor

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Important Security Notice
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• This is a temporary password
• You will be required to change it on first login
• Never share your password with anyone
• Keep this email secure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 Getting Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Download the AI Health Companion mobile app
✓ Open the app and tap "Login"
✓ Enter your email and temporary password
✓ Create a new secure password when prompted
✓ Complete your profile setup
✓ Start providing healthcare services!

[📲 Download Mobile App]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🤖 AI Diagnosis       📴 Offline Mode
👥 Patient Records    📊 Reports

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Need Help?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📧 Email: support@clinic.rw
📱 Contact your system administrator

Best regards,
AI Health Companion Team
```

### Step 7: User Downloads App

**User Actions:**
1. Opens email on phone
2. Taps "Download Mobile App" button
3. Redirected to Play Store/App Store
4. Downloads and installs app
5. Opens app

### Step 8: User Logs In

**Mobile App Login Screen:**
```
┌─────────────────────────────────┐
│                                 │
│    🏥 AI Health Companion       │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Email                     │ │
│  │ doctor@clinic.rw          │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Password                  │ │
│  │ Xy9@mK2pL5qR             │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │       LOGIN               │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

**Login API Request:**
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "doctor@clinic.rw",
  "password": "Xy9@mK2pL5qR"
}
```

**Login Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "doctor@clinic.rw",
      "firstName": "John",
      "lastName": "Doe",
      "role": "DOCTOR",
      "clinicId": "clinic-001"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Step 9: Change Password (First Login)

**Mobile App Shows:**
```
┌─────────────────────────────────┐
│                                 │
│    🔐 Change Password           │
│                                 │
│  For security, please change    │
│  your temporary password.       │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Current Password          │ │
│  │ Xy9@mK2pL5qR             │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ New Password              │ │
│  │ MySecure@Pass123          │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Confirm Password          │ │
│  │ MySecure@Pass123          │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │    CHANGE PASSWORD        │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

**Change Password API Request:**
```bash
POST /api/v1/users/me/change-password
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "currentPassword": "Xy9@mK2pL5qR",
  "newPassword": "MySecure@Pass123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

### Step 10: User Accesses App

**Mobile App Home Screen:**
```
┌─────────────────────────────────┐
│  👤 Dr. John Doe                │
│  📍 Clinic 001                  │
├─────────────────────────────────┤
│                                 │
│  🤖 AI Diagnosis                │
│  Analyze symptoms               │
│                                 │
│  👥 Patients                    │
│  Manage patient records         │
│                                 │
│  📊 Reports                     │
│  View health reports            │
│                                 │
│  💊 Prescriptions               │
│  Manage medications             │
│                                 │
└─────────────────────────────────┘
```

## 🔄 Alternative Scenarios

### Scenario A: Email Fails to Send

**What Happens:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": { ... },
    "temporaryPassword": "Xy9@mK2pL5qR",
    "emailSent": false  // ⚠️ Email failed
  }
}
```

**Admin Action:**
- Admin sees password in response
- Admin manually shares credentials with user
- Or admin uses "Reset Password" to try email again

### Scenario B: User Forgets Password

**User Action:**
1. User contacts admin
2. Admin resets password

**Admin API Request:**
```bash
POST /api/v1/users/550e8400-e29b-41d4-a716-446655440000/reset-password
Authorization: Bearer ADMIN_TOKEN
Content-Type: application/json

{
  "sendEmail": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successfully",
  "data": {
    "newPassword": "Qw8@nM3pK7tY",
    "emailSent": true
  }
}
```

**User receives new email** with new temporary password.

### Scenario C: Create Without Email

**Use Case:** Email service not configured yet

**API Request:**
```bash
POST /api/v1/users
Authorization: Bearer ADMIN_TOKEN
Content-Type: application/json

{
  "email": "doctor@clinic.rw",
  "firstName": "John",
  "lastName": "Doe",
  "role": "DOCTOR",
  "sendEmail": false  // Don't send email
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": { ... },
    "temporaryPassword": "Xy9@mK2pL5qR",
    "emailSent": false
  }
}
```

**Admin manually shares** credentials with user.

## 📊 Data Flow Diagram

```
┌──────────────┐
│ Admin Client │
└──────┬───────┘
       │ POST /api/v1/users
       │ {email, firstName, lastName, role}
       ▼
┌──────────────────────────────────────┐
│ User Controller                      │
│ - Validate input                     │
│ - Check if user exists               │
│ - Generate random password           │
│ - Create user record                 │
│ - Hash password                      │
└──────┬───────────────────────────────┘
       │
       ├─────────────────┬─────────────────┐
       ▼                 ▼                 ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Database   │   │Email Service│   │   Logger    │
│             │   │             │   │             │
│ Save User   │   │ Send Email  │   │ Log Event   │
│ Record      │   │ with Creds  │   │             │
└─────────────┘   └──────┬──────┘   └─────────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │ SMTP Server │
                  │             │
                  │ Deliver     │
                  │ Email       │
                  └──────┬──────┘
                         │
                         ▼
                  ┌─────────────┐
                  │ User Inbox  │
                  └─────────────┘
```

## 🎯 Success Indicators

### For Admin:
- ✅ API returns 201 status
- ✅ Response shows `emailSent: true`
- ✅ Temporary password visible in response
- ✅ User appears in user list
- ✅ Logs show "Email sent to: doctor@clinic.rw"

### For User:
- ✅ Email arrives within 1 minute
- ✅ Email not in spam folder
- ✅ Credentials clearly visible
- ✅ Download link works
- ✅ Can login with credentials
- ✅ Prompted to change password
- ✅ Can access app features

### For System:
- ✅ User record in database
- ✅ Password properly hashed
- ✅ Email logged as sent
- ✅ No errors in logs
- ✅ Audit trail created

## 🔍 Troubleshooting

### Email Not Received

**Check:**
1. Spam/Junk folder
2. Email address spelling
3. SMTP configuration
4. Server logs for errors
5. Email service status

**Solution:**
```bash
# Reset password and resend
POST /api/v1/users/:id/reset-password
```

### Cannot Login

**Check:**
1. Email spelling
2. Password (case-sensitive)
3. User is active
4. Account not locked

**Solution:**
```bash
# Admin resets password
POST /api/v1/users/:id/reset-password
```

### Email Goes to Spam

**Solutions:**
1. Add sender to contacts
2. Configure SPF/DKIM records
3. Use verified email domain
4. Test with different providers

## 📝 Logging

### What Gets Logged:

```
[INFO] New user created by admin: doctor@clinic.rw
[INFO] Email sent to doctor@clinic.rw: <message-id>
[INFO] User logged in: doctor@clinic.rw
[INFO] Password changed for user: doctor@clinic.rw
```

### What Doesn't Get Logged:
- ❌ Passwords (plain text)
- ❌ JWT tokens
- ❌ Email content
- ❌ Personal health information

## 🔐 Security Considerations

### Password Security:
- Generated passwords are cryptographically random
- Passwords hashed with bcrypt (12 rounds)
- Temporary passwords expire on first use
- Password history tracked

### Email Security:
- SMTP uses TLS encryption
- Credentials stored in environment variables
- Email content sanitized
- No sensitive data in email headers

### API Security:
- JWT authentication required
- Role-based authorization
- Rate limiting applied
- Input validation enforced

---

**This workflow is now fully implemented and ready for testing!** 🚀
