# Pharmacist Password Loop - Complete Fix

## Problem
Pharmacists were being prompted to change their password **every time they logged in**, even after successfully changing it. This was frustrating and prevented them from accessing the pharmacy portal.

## Root Cause Analysis

The issue had **TWO parts**:

### Backend Issues (Primary Cause)
1. **`changePassword` endpoint** wasn't updating the `mustChangePassword` flag to `false`
2. **`getCurrentUser` endpoint** (`/users/me`) wasn't returning the `mustChangePassword` field
3. **`getAllUsers` and `getUserById`** endpoints also missing `mustChangePassword` in responses

### Frontend Issues (Secondary)
1. User type definition missing `mustChangePassword` property
2. No error handling for failed user refresh after password change

## Complete Fix Applied

### Backend Changes (`ai_health_companion_backend/`)

#### 1. **user.controller.ts** - `changePassword` function
```typescript
// Added mustChangePassword to the select fields
select: ['id', 'email', 'password', 'firstName', 'lastName', 'role', 'mustChangePassword', ...]

// Set flag to false after password change
user.password = newPassword;
user.mustChangePassword = false; // ✅ KEY FIX
await userRepository.save(user);
```

#### 2. **user.controller.ts** - `getCurrentUser` function
```typescript
// Added mustChangePassword to response
user: {
    id: user.id,
    email: user.email,
    ...
    mustChangePassword: user.mustChangePassword, // ✅ KEY FIX
    lastLogin: user.lastLogin,
    createdAt: user.createdAt
}
```

#### 3. **user.controller.ts** - `getAllUsers` and `getUserById`
Added `mustChangePassword` to user response objects for consistency.

### Frontend Changes (`admin_dashboard/`)

#### 1. **src/types/index.ts** - User interface
```typescript
export interface User {
    ...
    mustChangePassword?: boolean; // ✅ Added
    ...
}
```

#### 2. **src/contexts/AuthContext.tsx**
- Improved `refreshUser()` to return user object and handle errors
- Added debug logging to track `mustChangePassword` status

#### 3. **src/pages/pharmacy/ChangePassword.tsx**
- Added automatic redirect if user doesn't need password change
- Enhanced error handling for user refresh failures
- Added fallback navigation mechanism

## How It Works Now

### First Time Login
1. Pharmacist account created with `mustChangePassword: true`
2. Login → Backend returns user with `mustChangePassword: true`
3. Frontend redirects to `/change-password` page
4. User changes password
5. **Backend updates `mustChangePassword: false` in database** ✅
6. Frontend calls `/users/me` to refresh user
7. **Backend returns updated user with `mustChangePassword: false`** ✅
8. Frontend updates local state and localStorage
9. User redirected to pharmacy portal

### Subsequent Logins
1. Login → Backend returns user with `mustChangePassword: false`
2. Frontend checks: `user.mustChangePassword === false`
3. User goes **directly to pharmacy portal** (no password prompt) ✅

## Testing Steps

### 1. Test New Pharmacist Account
```bash
# Create new pharmacist via admin dashboard
# Note the temporary password

# Login with pharmacist credentials
# Verify: Should redirect to change password page

# Change password
# Verify: Should redirect to pharmacy portal

# Check browser console
# Should see: "User refreshed: { ..., mustChangePassword: false }"
```

### 2. Test Subsequent Login
```bash
# Logout

# Login again with NEW password
# Verify: Should go DIRECTLY to pharmacy portal (no password change prompt)
```

### 3. Database Verification (Optional)
```sql
-- Check the database directly
SELECT id, email, "mustChangePassword" FROM users WHERE role = 'pharmacist';

-- Before password change: mustChangePassword = true
-- After password change: mustChangePassword = false
```

## Debugging Tools

### Browser Console Logs
The frontend now includes debug logs:
```javascript
// On login:
"User logged in: { ..., mustChangePassword: true/false }"

// After password change and refresh:
"User refreshed: { ..., mustChangePassword: false }"
```

### Backend Logs
Check `logs/` folder for:
```
[INFO] Password changed for user: pharmacist@example.com
```

## What Changed in Database

The `mustChangePassword` field:
- **Default value**: `true` (set when user is created)
- **Changed to `false`** when:
  - User changes password via `/users/me/change-password`
  - User resets password via `/auth/reset-password/:token`

## Files Modified

### Backend (3 files)
- ✅ `ai_health_companion_backend/src/controllers/user.controller.ts`
  - Updated `changePassword()` function
  - Updated `getCurrentUser()` function  
  - Updated `getAllUsers()` function
  - Updated `getUserById()` function

### Frontend (3 files)
- ✅ `admin_dashboard/src/types/index.ts`
- ✅ `admin_dashboard/src/contexts/AuthContext.tsx`
- ✅ `admin_dashboard/src/pages/pharmacy/ChangePassword.tsx`

## Important Notes

1. **Backend must be restarted** for changes to take effect
2. **Existing pharmacist accounts** may still have `mustChangePassword: true` in database - they will need to change password once more
3. **Database migration** already exists for the `mustChangePassword` column (no new migration needed)

## If Issue Persists

If the issue still occurs, check:

1. **Backend is running the latest build**:
   ```bash
   cd ai_health_companion_backend
   npm run build
   npm start
   ```

2. **Database has the column**:
   ```sql
   SELECT column_name FROM information_schema.columns 
   WHERE table_name='users' AND column_name='mustChangePassword';
   ```

3. **Browser cache cleared**: Hard refresh (Ctrl+Shift+R) or clear localStorage

4. **Check backend logs** for the password change request

5. **Verify API response** in browser DevTools Network tab:
   - `/auth/login` should return `mustChangePassword: true` for new accounts
   - `/users/me` should return `mustChangePassword: false` after password change

## Restart Instructions

### Backend
```bash
cd ai_health_companion_backend
npm run build  # Compile TypeScript
npm start      # Or: npm run dev
```

### Frontend
```bash
cd admin_dashboard
npm run dev
```

The fix is now complete and should resolve the password loop issue permanently! 🎉
