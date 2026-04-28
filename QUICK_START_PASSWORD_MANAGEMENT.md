# Quick Start: Password Management

## Setup (5 minutes)

### 1. Run Database Migration
```bash
cd ai_health_companion_backend
npm run migration:run
```

### 2. Start Backend
```bash
npm run dev
```

### 3. Start Flutter App
```bash
cd ../ai_health_companion
flutter run
```

## Test Scenarios

### Scenario 1: Forgot Password
1. Open app → Click "Forgot Password?"
2. Enter email: `admin@clinic.rw`
3. Check email for reset code
4. Enter code + new password
5. ✅ Should redirect to login

### Scenario 2: First-Time User
1. Create new user in admin dashboard
2. User receives email with default password
3. Login with default password
4. ✅ Should be forced to change password page
5. Change password
6. ✅ Should navigate to home page

### Scenario 3: Normal Login
1. Login with your password
2. ✅ Should go directly to home page

## Key Features

✅ **Forgot Password** - Email-based reset with token
✅ **Force Password Change** - First-time users must change password
✅ **Password Strength** - Visual indicator (Weak/Fair/Good/Strong)
✅ **Security** - Token expires in 1 hour, hashed in database
✅ **No Demo Button** - Removed from login page

## API Endpoints

- `POST /api/v1/auth/forgot-password` - Request reset
- `POST /api/v1/auth/reset-password` - Reset with token
- `POST /api/v1/auth/change-password` - Change password

## Troubleshooting

### Email not sending?
Check `.env` file:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Migration fails?
```bash
npm run migration:revert
npm run migration:run
```

### Flutter build errors?
```bash
flutter clean
flutter pub get
flutter run
```

## Done! 🎉

Your password management system is ready to use.
