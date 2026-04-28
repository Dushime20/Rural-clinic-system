# Quick Reference Card - Password Management

## 🚀 Start Commands

```bash
# Backend
cd ai_health_companion_backend
npm run migration:run  # First time only
npm run dev

# Flutter
cd ai_health_companion
flutter pub get  # First time only
flutter run
```

## 🔗 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/login` | POST | Login user |
| `/auth/forgot-password` | POST | Request password reset |
| `/auth/reset-password` | POST | Reset password with token |
| `/auth/change-password` | POST | Change password (authenticated) |

## 📱 Flutter Pages

| Route | Page | Purpose |
|-------|------|---------|
| `/login` | LoginPage | User login |
| `/forgot-password` | ForgotPasswordPage | Request password reset |
| `/reset-password` | ResetPasswordPage | Reset with token |
| `/change-password` | ChangePasswordPage | Change password |

## 🔐 Test Credentials

- **Email**: `admin@clinic.rw`
- **Password**: `Admin@1234`

## 📋 Test Checklist

- [ ] Backend running on port 5000
- [ ] Flutter app running
- [ ] Login works
- [ ] Forgot password sends email
- [ ] Reset password works
- [ ] First-time user forced to change password
- [ ] Password strength indicator shows

## ⚙️ Configuration

### Development (localhost)
```dart
// app_constants.dart
static const String baseUrl = 'http://localhost:5000/api/v1';
```

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
```

### Physical Device
```dart
static const String baseUrl = 'http://YOUR_IP:5000/api/v1';
```

## 🐛 Quick Fixes

### Port already in use?
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:5000 | xargs kill -9
```

### Flutter errors?
```bash
flutter clean
flutter pub get
flutter run
```

### Email not working?
Check `.env`:
```
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## ✅ Status

**All features complete and working!**
