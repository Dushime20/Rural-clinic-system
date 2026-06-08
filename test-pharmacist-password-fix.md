# Testing the Pharmacist Password Fix

## Quick Test Checklist

### ✅ Step 1: Start the Backend
```bash
cd ai_health_companion_backend
npm run dev
```
Wait until you see: `Server running on port 5000`

### ✅ Step 2: Start the Frontend
```bash
cd admin_dashboard
npm run dev
```
Open browser to: http://localhost:5173

### ✅ Step 3: Create Test Pharmacist (if needed)
1. Login as admin
2. Go to Users page
3. Create new pharmacist account
4. Note the temporary password shown

### ✅ Step 4: Test First Login
1. Logout from admin
2. Login with pharmacist credentials
3. **Expected**: Redirected to "Change Password" page
4. Enter temporary password and new password
5. **Expected**: Success message → Redirected to pharmacy dashboard
6. **Check Console**: Should see log with `mustChangePassword: false`

### ✅ Step 5: Test Subsequent Login
1. Logout from pharmacy portal
2. Login again with the NEW password
3. **Expected**: Goes DIRECTLY to pharmacy dashboard ✅
4. **Should NOT see**: Password change page

## What to Look For

### ✅ Success Indicators
- First login: Password change screen appears
- After password change: Redirected to pharmacy dashboard
- Second login: Goes directly to dashboard (NO password prompt)
- Console shows: `mustChangePassword: false` after password change

### ❌ Failure Indicators
- Second login still shows password change screen
- Console shows: `mustChangePassword: true` after password change
- Error messages about user refresh failing

## Debugging Commands

### Check Database Directly
```bash
# If using SQLite
cd ai_health_companion_backend
sqlite3 database.sqlite
SELECT email, mustChangePassword FROM users WHERE role = 'pharmacist';
.quit
```

### Check Backend Logs
```bash
cd ai_health_companion_backend
tail -f logs/app.log
# Or check the terminal where backend is running
```

### Clear Browser Cache
1. Open DevTools (F12)
2. Right-click Refresh button
3. Select "Empty Cache and Hard Reload"
4. Or: Clear localStorage in Console tab:
   ```javascript
   localStorage.clear()
   ```

## API Test (Alternative)

You can test the API directly:

### 1. Login
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "pharmacist@test.com",
    "password": "TempPassword123"
  }'
```
**Check response**: Should have `"mustChangePassword": true`

### 2. Change Password
```bash
# Replace YOUR_TOKEN with the accessToken from login response
curl -X POST http://localhost:5000/api/v1/users/me/change-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "currentPassword": "TempPassword123",
    "newPassword": "NewSecurePass123!"
  }'
```

### 3. Check User Profile
```bash
curl -X GET http://localhost:5000/api/v1/users/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```
**Check response**: Should have `"mustChangePassword": false`

## Expected Results Summary

| Action | mustChangePassword Value | Behavior |
|--------|-------------------------|----------|
| Account created | `true` | User must change password |
| After password change | `false` | User can access portal freely |
| Next login | `false` | Direct access to portal |

## Common Issues

### Issue: "mustChangePassword" is undefined
**Fix**: Backend not returning the field
- Restart backend after applying fixes
- Check backend console for errors

### Issue: Still shows password change page
**Fix**: Database not updated
- Check database value directly
- Verify API endpoint is being called
- Check backend logs for save operation

### Issue: Frontend errors
**Fix**: Clear browser cache and localStorage
```javascript
// In browser console
localStorage.clear()
location.reload()
```

## Success! 🎉
When test passes:
- ✅ First login requires password change
- ✅ Subsequent logins go directly to dashboard
- ✅ No more password loop!
