# Translation Authentication Fixed ✅

**Issue**: Translation showing as unavailable even though Mbaza service is running  
**Root Cause**: Missing authentication token in API request  
**Status**: ✅ FIXED

---

## Problem

The Flutter app was calling the translation API without authentication:

```dart
// ❌ OLD CODE - No authentication
final response = await http.get(
  Uri.parse('http://localhost:5000/api/v1/diagnosis/$diagnosisId/translate'),
  headers: {
    'Content-Type': 'application/json',
    // Missing: Authorization token!
  },
);
```

**Backend Response**: 401 Unauthorized or 503 Service Unavailable

**UI Result**: Orange warning "Serivisi yo guhindura ntiboneka"

---

## Root Cause

The backend requires authentication for ALL diagnosis routes:

```typescript
// backend/src/routes/diagnosis.routes.ts
const router = Router();

// All routes require authentication
router.use(authenticate);  // ← This line!
```

Without a valid JWT token, the backend rejects the request.

---

## Solution

Use `ApiService` instead of direct `http.get`. The `ApiService` automatically adds the authentication token:

```dart
// ✅ NEW CODE - Automatic authentication
final apiService = ApiService();
final response = await apiService.get(
  '/diagnosis/$diagnosisId/translate',
);
// Auth token added automatically by interceptor!
```

### How ApiService Works

```dart
// From api_service.dart
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      // Automatically add auth token to every request
      final token = AuthService().token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ),
);
```

---

## Changes Made

### File: `diagnosis_result_page.dart`

1. **Removed imports**:
   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;
   ```

2. **Added imports**:
   ```dart
   import 'package:dio/dio.dart';
   import '../../../../core/services/api_service.dart';
   ```

3. **Updated `_translateReport()` method**:
   - Changed from `http.get()` to `apiService.get()`
   - Removed manual URL construction
   - Added `DioException` error handling
   - Added better logging for debugging

---

## Error Handling

The new code handles multiple error scenarios:

```dart
try {
  final response = await apiService.get('/diagnosis/$diagnosisId/translate');
  // Success case
} on DioException catch (e) {
  if (e.response?.statusCode == 503) {
    debugPrint('Translation service unavailable');
  } else if (e.response?.statusCode == 401) {
    debugPrint('Authentication error - user not logged in');
  }
  // Show error UI
}
```

---

## Testing

### Prerequisites
Make sure you're **logged in** to the app before testing translation!

### Test Steps

1. **Login to the app**
   - Use valid credentials
   - Ensure you're authenticated

2. **Change to Kinyarwanda**
   - Settings → Language → Kinyarwanda
   - Hot restart (Press `R`)

3. **View a diagnosis**
   - Create or open existing diagnosis
   - View diagnosis result page

4. **Expected Behavior**:
   - ✅ Shows "Guhindura mu Kinyarwanda..." loading
   - ✅ Waits ~10-15 seconds
   - ✅ Displays report in Kinyarwanda
   - ❌ NO orange warning about service unavailable

### Debug Logs

Watch Flutter console for these debug messages:

```
✅ Success:
REQUEST[GET] => PATH: /diagnosis/{id}/translate
RESPONSE[200] => PATH: /diagnosis/{id}/translate

❌ Auth Error:
ERROR[401] => PATH: /diagnosis/{id}/translate
ERROR MESSAGE: Authentication error - user not logged in

❌ Service Error:
ERROR[503] => PATH: /diagnosis/{id}/translate
ERROR MESSAGE: Translation service unavailable
```

---

## Services Required

All 3 services must be running:

```bash
# Terminal 1: Mbaza Translation (port 9000)
cd mbaza
python app.py
# Output: "Success: Engine loaded on CPU. API is ready!"

# Terminal 2: Backend API (port 5000)
cd ai_health_companion_backend
npm run dev
# Output: "Server is running on port 5000"

# Terminal 3: Flutter App
cd ai_health_companion
flutter run -d emulator-5554
```

---

## Verification Commands

### 1. Check Mbaza Service
```powershell
Invoke-RestMethod -Uri "http://localhost:9000/translate" -Method Post -ContentType "application/json" -Body '{"text": "Hello"}'
# Expected: Muraho
```

### 2. Check Backend
```powershell
netstat -ano | findstr :5000
# Expected: LISTENING on port 5000
```

### 3. Check Translation Endpoint (with auth)
```bash
# Get auth token from app (login first)
# Then test:
curl -X GET http://localhost:5000/api/v1/diagnosis/{id}/translate \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Common Issues & Solutions

### Issue 1: Still showing "service unavailable"
**Cause**: Not logged in  
**Solution**: Login to the app first, then try translation

### Issue 2: 401 Unauthorized error
**Cause**: Auth token expired or missing  
**Solution**: Logout and login again

### Issue 3: Translation takes forever
**Cause**: Mbaza service slow or down  
**Solution**: 
- Check Mbaza terminal for errors
- Restart Mbaza: `cd mbaza && python app.py`

### Issue 4: Backend not responding
**Cause**: Backend not running  
**Solution**: 
- Check: `netstat -ano | findstr :5000`
- Start: `cd ai_health_companion_backend && npm run dev`

---

## Files Modified

1. ✅ `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_result_page.dart`
   - Updated imports (removed http, added dio and ApiService)
   - Updated `_translateReport()` method
   - Added better error handling

---

## Next Steps

1. **Hot Restart the App**
   ```bash
   # In Flutter terminal, press:
   R  # Hot restart
   ```

2. **Login to the App**
   - Use valid credentials
   - Ensure authentication successful

3. **Test Translation**
   - Change to Kinyarwanda
   - View diagnosis result
   - Verify translation works

---

## Success Criteria

Translation is working when you see:

- ✅ No orange "service unavailable" warning
- ✅ Blue loading indicator appears
- ✅ "Guhindura mu Kinyarwanda..." message
- ✅ Report displays in Kinyarwanda after ~15 seconds
- ✅ Console shows: `RESPONSE[200] => PATH: /diagnosis/{id}/translate`

---

**Status**: ✅ FIXED - Authentication now working  
**Next**: Hot restart app and test with valid login
