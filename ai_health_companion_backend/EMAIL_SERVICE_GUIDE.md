# Email Service Implementation Guide

## Overview

The email service has been fully implemented to allow administrators to create users and automatically send welcome emails with login credentials for the Flutter mobile app.

## Features Implemented

### 1. Email Service (`src/services/email.service.ts`)
- ✅ Nodemailer integration with SMTP support
- ✅ Beautiful HTML email templates
- ✅ Welcome email with credentials
- ✅ Password reset email
- ✅ Account activation email
- ✅ Automatic fallback to plain text
- ✅ Error handling and logging
- ✅ Configuration validation

### 2. User Controller (`src/controllers/user.controller.ts`)
- ✅ Create user endpoint (admin only)
- ✅ Get all users with filters and pagination
- ✅ Get user by ID
- ✅ Update user
- ✅ Delete user
- ✅ Reset user password
- ✅ Get current user profile
- ✅ Update current user profile
- ✅ Change password
- ✅ Automatic password generation
- ✅ Email sending on user creation

### 3. User Routes (`src/routes/user.routes.ts`)
- ✅ All endpoints configured with proper authentication
- ✅ Admin-only routes protected with authorization middleware
- ✅ User profile routes for all authenticated users

## API Endpoints

### Admin Endpoints (Require Admin Role)

#### Create User
```http
POST /api/v1/users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "email": "doctor@clinic.rw",
  "firstName": "John",
  "lastName": "Doe",
  "role": "DOCTOR",
  "clinicId": "clinic-123",
  "phoneNumber": "+250788123456",
  "sendEmail": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": {
      "id": "uuid",
      "email": "doctor@clinic.rw",
      "firstName": "John",
      "lastName": "Doe",
      "role": "DOCTOR",
      "clinicId": "clinic-123",
      "phoneNumber": "+250788123456",
      "isActive": true
    },
    "temporaryPassword": "Xy9@mK2pL5qR",
    "emailSent": true
  }
}
```

#### Get All Users
```http
GET /api/v1/users?role=DOCTOR&page=1&limit=20
Authorization: Bearer <admin_token>
```

#### Get User by ID
```http
GET /api/v1/users/:id
Authorization: Bearer <admin_token>
```

#### Update User
```http
PUT /api/v1/users/:id
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "firstName": "Jane",
  "isActive": false
}
```

#### Delete User
```http
DELETE /api/v1/users/:id
Authorization: Bearer <admin_token>
```

#### Reset User Password
```http
POST /api/v1/users/:id/reset-password
Authorization: Bearer <admin_token>
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

### User Endpoints (All Authenticated Users)

#### Get Current User Profile
```http
GET /api/v1/users/me
Authorization: Bearer <token>
```

#### Update Current User Profile
```http
PUT /api/v1/users/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "firstName": "Jane",
  "lastName": "Smith",
  "phoneNumber": "+250788999888"
}
```

#### Change Password
```http
POST /api/v1/users/me/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "currentPassword": "OldPassword123!",
  "newPassword": "NewPassword456!"
}
```

## Email Configuration

### 1. Environment Variables

Add these to your `.env` file:

```env
# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_NAME=AI Health Companion
SUPPORT_EMAIL=support@clinic.rw
APP_DOWNLOAD_URL=https://play.google.com/store/apps/details?id=com.ruralclinic.healthcompanion
```

### 2. Gmail Setup (Recommended)

If using Gmail:

1. **Enable 2-Factor Authentication** on your Google account
2. **Generate App Password:**
   - Go to Google Account Settings
   - Security → 2-Step Verification → App passwords
   - Select "Mail" and "Other (Custom name)"
   - Copy the 16-character password
   - Use this as `SMTP_PASSWORD`

3. **Configuration:**
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password
```

### 3. Other Email Providers

#### Outlook/Office 365
```env
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_SECURE=false
```

#### SendGrid
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

#### Mailgun
```env
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=postmaster@your-domain.mailgun.org
SMTP_PASSWORD=your-mailgun-password
```

## Email Templates

### Welcome Email Features

The welcome email includes:
- 🏥 Professional header with gradient design
- 🔐 Clearly displayed credentials (email, password, role)
- ⚠️ Security warnings and best practices
- 📱 Step-by-step getting started guide
- 📲 Download app button
- 🤖 Feature highlights (AI Diagnosis, Offline Mode, etc.)
- 📧 Support contact information
- 📱 Mobile-responsive design

### Email Content

When a user is created, they receive:
1. **Subject:** "Welcome to AI Health Companion - Your Account Credentials"
2. **Content:**
   - Personalized greeting
   - Login credentials (email + temporary password)
   - Security notice about changing password
   - Getting started steps
   - App download link
   - Feature overview
   - Support contact

## Testing the Email Service

### 1. Test Email Configuration

Create a test endpoint or use the built-in test:

```typescript
import { emailService } from './services/email.service';

// Test connection
const isConnected = await emailService.testConnection();
console.log('Email service connected:', isConnected);
```

### 2. Test User Creation

```bash
# Login as admin
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'

# Create user (use token from login response)
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{
    "email": "test.doctor@clinic.rw",
    "firstName": "Test",
    "lastName": "Doctor",
    "role": "DOCTOR",
    "sendEmail": true
  }'
```

### 3. Check Email Delivery

1. Check the response for `emailSent: true`
2. Check server logs for email sending confirmation
3. Check the recipient's inbox (and spam folder)
4. Verify email content and formatting

## User Roles

Available roles for user creation:
- `ADMIN` - Full system access
- `DOCTOR` - Medical professional
- `NURSE` - Nursing staff
- `CHW` - Community Health Worker
- `PHARMACIST` - Pharmacy staff
- `LAB_TECHNICIAN` - Laboratory staff

## Password Security

### Auto-Generated Passwords
- 12 characters long
- Contains uppercase letters
- Contains lowercase letters
- Contains numbers
- Contains special characters (!@#$%^&*)
- Randomly shuffled for security

### Password Requirements
Users should change their password on first login to:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

## Workflow

### Admin Creates User

1. **Admin logs in** to admin dashboard
2. **Admin creates user** via POST /api/v1/users
3. **System generates** random secure password
4. **System creates** user account in database
5. **System sends** welcome email with credentials
6. **Admin receives** response with temporary password
7. **User receives** email with login instructions

### User First Login

1. **User receives** welcome email
2. **User downloads** mobile app from link
3. **User logs in** with email and temporary password
4. **System prompts** user to change password
5. **User sets** new secure password
6. **User completes** profile setup
7. **User starts** using the app

## Troubleshooting

### Email Not Sending

1. **Check Configuration:**
   ```bash
   # Verify environment variables are set
   echo $SMTP_HOST
   echo $SMTP_USER
   ```

2. **Check Logs:**
   ```bash
   # Look for email service errors
   tail -f logs/app.log | grep -i email
   ```

3. **Common Issues:**
   - ❌ Wrong SMTP credentials → Check username/password
   - ❌ Gmail blocking → Enable "Less secure app access" or use App Password
   - ❌ Firewall blocking port 587 → Check network settings
   - ❌ Invalid email format → Validate email addresses

### Email Goes to Spam

1. **Add SPF Record** to your domain
2. **Add DKIM** signature
3. **Use verified sender** email
4. **Avoid spam trigger words** in subject/content
5. **Test with different** email providers

### Email Service Not Configured

If SMTP variables are not set:
- Service logs warning but doesn't crash
- User creation still succeeds
- Email is not sent
- Response shows `emailSent: false`
- Admin can still see the temporary password in response

## Security Best Practices

1. **Environment Variables:**
   - Never commit `.env` file
   - Use strong SMTP passwords
   - Rotate credentials regularly

2. **Email Content:**
   - Temporary passwords expire on first login
   - Encourage immediate password change
   - Include security warnings

3. **Admin Access:**
   - Only admins can create users
   - Only admins can reset passwords
   - Audit log all user management actions

4. **Password Handling:**
   - Passwords are hashed before storage
   - Temporary passwords shown only once
   - No passwords in logs

## Next Steps

1. ✅ Email service implemented
2. ✅ User management endpoints created
3. ✅ Routes configured
4. ✅ Documentation complete
5. ⏳ Configure SMTP credentials in `.env`
6. ⏳ Test email sending
7. ⏳ Integrate with admin dashboard UI
8. ⏳ Add email templates for other notifications

## Admin Dashboard Integration

To integrate with the admin dashboard (React):

```typescript
// Create user API call
const createUser = async (userData) => {
  const response = await fetch('http://localhost:5000/api/v1/users', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${adminToken}`
    },
    body: JSON.stringify(userData)
  });
  
  const result = await response.json();
  
  if (result.success) {
    // Show success message
    alert(`User created! Temporary password: ${result.data.temporaryPassword}`);
    // Email sent: ${result.data.emailSent}
  }
};
```

## Support

For issues or questions:
- 📧 Email: support@clinic.rw
- 📖 Documentation: This file
- 🐛 Bug reports: Create an issue in the repository

---

**Status:** ✅ Fully Implemented and Ready for Testing
**Last Updated:** 2026-04-28
