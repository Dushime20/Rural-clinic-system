# Forgot Password & First-Time Password Change Implementation

## Overview

Implemented modern password management features:
1. **Forgot Password** - Email-based password reset
2. **Force Password Change** - First-time users must change their default password
3. **Removed Demo Button** - Cleaned up login page

## Backend Changes ✅

### 1. Database Schema (`User.ts`)
Added new fields:
```typescript
@Column({ type: 'boolean', default: true })
mustChangePassword!: boolean;  // Force password change for new users

@Column({ type: 'varchar', length: 255, nullable: true, select: false })
passwordResetToken?: string;  // Hashed reset token

@Column({ type: 'timestamp', nullable: true })
passwordResetExpires?: Date;  // Token expiry (1 hour)
```

### 2. New API Endpoints (`auth.routes.ts`)

**POST /api/v1/auth/forgot-password**
- Request password reset
- Sends email with reset token
- Token expires in 1 hour

**POST /api/v1/auth/reset-password**
- Reset password with token
- Validates token and expiry
- Sets new password

**POST /api/v1/auth/change-password**
- Change password (authenticated users)
- Validates current password
- Sets new password
- Clears `mustChangePassword` flag

### 3. Login Response Updated
Now includes `mustChangePassword` flag:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "email": "user@clinic.rw",
      "mustChangePassword": true  // ← NEW
    },
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### 4. Email Service (`email.service.ts`)
Updated `sendPasswordResetEmail` method:
- Sends beautiful HTML email
- Includes reset link for web
- Includes 8-character code for mobile app
- Security warnings included

### 5. Database Migration
Created migration: `1735400000000-AddPasswordResetFields.ts`
- Adds `mustChangePassword` column (default: true)
- Adds `passwordResetToken` column
- Adds `passwordResetExpires` column

## Frontend Changes ✅

### 1. Login Page (`login_page.dart`)
- ✅ Removed demo button
- ✅ Added forgot password navigation
- ✅ Cleaned up UI

### 2. Pages to Create

#### Forgot Password Page
**File**: `ai_health_companion/lib/features/auth/presentation/pages/forgot_password_page.dart`

Features:
- Email input field
- Send reset code button
- Navigate to reset password page
- Beautiful gradient UI matching login page

#### Reset Password Page
**File**: `ai_health_companion/lib/features/auth/presentation/pages/reset_password_page.dart`

Features:
- Reset token/code input
- New password input
- Confirm password input
- Submit button
- Navigate back to login on success

#### Change Password Page (First-Time)
**File**: `ai_health_companion/lib/features/auth/presentation/pages/change_password_page.dart`

Features:
- Current password input
- New password input
- Confirm password input
- Password strength indicator
- Submit button
- Cannot skip (for first-time users)

## Implementation Flow

### Forgot Password Flow
```
1. User clicks "Forgot Password?" on login page
   ↓
2. Navigate to Forgot Password page
   ↓
3. User enters email
   ↓
4. POST /api/v1/auth/forgot-password
   ↓
5. Email sent with reset token
   ↓
6. Navigate to Reset Password page
   ↓
7. User enters token + new password
   ↓
8. POST /api/v1/auth/reset-password
   ↓
9. Password reset successful
   ↓
10. Navigate back to login
```

### First-Time Login Flow
```
1. User logs in with default password
   ↓
2. Backend returns mustChangePassword: true
   ↓
3. Check mustChangePassword flag
   ↓
4. If true: Navigate to Change Password page (FORCED)
   ↓
5. User enters current + new password
   ↓
6. POST /api/v1/auth/change-password
   ↓
7. Password changed, mustChangePassword set to false
   ↓
8. Navigate to home page
```

## API Examples

### 1. Forgot Password Request
```bash
POST http://localhost:5000/api/v1/auth/forgot-password
Content-Type: application/json

{
  "email": "user@clinic.rw"
}
```

**Response:**
```json
{
  "success": true,
  "message": "If an account with that email exists, a password reset link has been sent"
}
```

### 2. Reset Password
```bash
POST http://localhost:5000/api/v1/auth/reset-password
Content-Type: application/json

{
  "token": "abc123def456...",
  "newPassword": "NewSecure@123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successful. Please login with your new password."
}
```

### 3. Change Password (First-Time)
```bash
POST http://localhost:5000/api/v1/auth/change-password
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "currentPassword": "TempPass@123",
  "newPassword": "MyNewSecure@123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

## Security Features

### Password Reset
- ✅ Token hashed in database (SHA-256)
- ✅ Token expires in 1 hour
- ✅ One-time use (cleared after reset)
- ✅ Email enumeration prevention (always returns success)
- ✅ All sessions invalidated on reset

### Password Requirements
- ✅ Minimum 8 characters
- ✅ Must be different from current password
- ✅ Validated on both frontend and backend

### First-Time Users
- ✅ Cannot skip password change
- ✅ Must use current password to change
- ✅ Flag cleared after successful change

## Email Template

The password reset email includes:
- 🔐 Professional header
- 📧 Personalized greeting
- 🔗 Clickable reset link (for web)
- 🔢 8-character code (for mobile app)
- ⚠️ Security warnings
- ⏰ Expiry notice (1 hour)
- 📱 Instructions for both web and mobile

## Testing

### 1. Run Database Migration
```bash
cd ai_health_companion_backend
npm run migration:run
```

### 2. Start Backend
```bash
npm run dev
```

### 3. Test Forgot Password
```bash
curl -X POST http://localhost:5000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@clinic.rw"}'
```

### 4. Check Email
- Check your email inbox
- Copy the reset token
- Use it to reset password

### 5. Test First-Time Login
1. Create a new user (gets default password)
2. Login with default password
3. Should be redirected to change password page
4. Change password
5. Should navigate to home page

## Next Steps

### Flutter Pages to Create

1. **Forgot Password Page** (`forgot_password_page.dart`)
2. **Reset Password Page** (`reset_password_page.dart`)
3. **Change Password Page** (`change_password_page.dart`)

### Router Configuration
Add routes in `app_router.dart`:
```dart
GoRoute(
  path: '/forgot-password',
  builder: (context, state) => const ForgotPasswordPage(),
),
GoRoute(
  path: '/reset-password',
  builder: (context, state) => const ResetPasswordPage(),
),
GoRoute(
  path: '/change-password',
  builder: (context, state) => const ChangePasswordPage(),
),
```

### Auth Service Updates
Update `auth_service.dart` to:
- Handle `mustChangePassword` flag from login response
- Add `forgotPassword()` method
- Add `resetPassword()` method
- Add `changePassword()` method

## Summary

✅ **Backend Complete**:
- Database schema updated
- API endpoints created
- Email service updated
- Migration created

✅ **Frontend Partial**:
- Login page updated (demo button removed, forgot password link added)
- Need to create 3 new pages
- Need to update auth service
- Need to add router configuration

**Status**: Backend ready, Flutter pages need to be created.
