# Pharmacist Password Change Loop - Fix Applied

## Problem
Pharmacists were being prompted to change their password every time they logged in, even after successfully changing it.

## Root Cause
1. The `User` type definition was missing the `mustChangePassword` property
2. The `refreshUser()` function wasn't properly updating the user state after password change
3. There was no fallback mechanism if the user refresh failed

## Changes Made

### 1. Updated User Type (`src/types/index.ts`)
- Added `mustChangePassword?: boolean` property to the `User` interface
- This ensures TypeScript knows about the password change flag from the backend

### 2. Enhanced AuthContext (`src/contexts/AuthContext.tsx`)
- Improved `refreshUser()` function to:
  - Return the updated user object
  - Clear localStorage and throw error if refresh fails
  - Added debug logging to track `mustChangePassword` status
- Added debug logging in login mutation to track initial user state

### 3. Improved ChangePassword Component (`src/pages/pharmacy/ChangePassword.tsx`)
- Added redirect check: if user doesn't need to change password, immediately redirect to pharmacy portal
- Enhanced password change success handler:
  - Calls `refreshUser()` to get updated user data from backend
  - Added error handling for refresh failures
  - Added small delay (100ms) to ensure state updates propagate
  - Will navigate to portal even if refresh fails (fallback mechanism)
- Imported `useEffect` hook for redirect logic

## How It Works Now

1. **First Login**: Backend returns `mustChangePassword: true` → User redirected to `/change-password`
2. **Password Changed**: 
   - API call to change password succeeds
   - `refreshUser()` fetches updated user data with `mustChangePassword: false`
   - User state updated in AuthContext
   - LocalStorage updated with new user object
   - User redirected to pharmacy portal
3. **Subsequent Logins**: `mustChangePassword` is `false` → User goes directly to pharmacy portal

## Testing Recommendations

1. **Test new pharmacist first login**:
   - Create new pharmacist account
   - Login with temporary password
   - Verify redirect to change password page
   - Change password
   - Verify redirect to pharmacy portal

2. **Test subsequent logins**:
   - Logout after changing password
   - Login again with new password
   - Verify direct access to pharmacy portal (no password change prompt)

3. **Check browser console**:
   - Look for debug logs showing `mustChangePassword` values
   - Verify state updates during login and password change

## Backend Requirements

The backend must:
1. Return `mustChangePassword: true` when creating new pharmacist accounts
2. Update `mustChangePassword: false` after successful password change
3. Include `mustChangePassword` field in `/users/me` endpoint response
4. Include `mustChangePassword` field in login response

If the issue persists, check backend logs to ensure the `mustChangePassword` flag is being properly updated in the database.
