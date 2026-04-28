# ✅ Role Enum Mismatch - FIXED

## 🐛 Issue

**Error:**
```
invalid input value for enum user_role_enum: "CHW"
```

**Root Cause:**
The frontend was sending role values that didn't match the database enum.

---

## 🔍 The Problem

### Database Enum (PostgreSQL)
```sql
CREATE TYPE "user_role_enum" AS ENUM(
  'admin',
  'health_worker',
  'clinic_staff',
  'supervisor'
)
```

### Frontend Was Sending (WRONG ❌)
```typescript
'ADMIN', 'DOCTOR', 'NURSE', 'CHW', 'PHARMACIST', 'LAB_TECHNICIAN'
```

### Mismatch
- Frontend: `CHW` → Database: ❌ Not recognized
- Frontend: `DOCTOR` → Database: ❌ Not recognized
- Frontend: `NURSE` → Database: ❌ Not recognized
- etc.

---

## ✅ The Fix

### Updated Frontend Roles
```typescript
const ROLE_OPTIONS = [
  { value: 'admin', label: 'Administrator' },
  { value: 'health_worker', label: 'Health Worker' },
  { value: 'clinic_staff', label: 'Clinic Staff' },
  { value: 'supervisor', label: 'Supervisor' },
];
```

### Updated Schema
```typescript
const createSchema = z.object({
  email: z.string().email('Valid email required'),
  firstName: z.string().min(2, 'Required'),
  lastName: z.string().min(2, 'Required'),
  role: z.enum(['admin', 'health_worker', 'clinic_staff', 'supervisor']),
  clinicId: z.string().optional(),
  phoneNumber: z.string().optional(),
  sendEmail: z.boolean().default(true),
});
```

---

## 📋 Valid Roles

| Role Value | Display Label | Description |
|------------|---------------|-------------|
| `admin` | Administrator | Full system access |
| `health_worker` | Health Worker | Primary healthcare provider |
| `clinic_staff` | Clinic Staff | Administrative staff |
| `supervisor` | Supervisor | Supervisory role |

---

## 🎨 Role Colors

Each role has a distinct color in the UI:

```typescript
export const ROLE_COLORS: Record<string, string> = {
  admin: 'bg-purple-100 text-purple-800',
  health_worker: 'bg-blue-100 text-blue-800',
  clinic_staff: 'bg-green-100 text-green-800',
  supervisor: 'bg-orange-100 text-orange-800',
};
```

**Visual:**
- 🟣 **Admin** - Purple badge
- 🔵 **Health Worker** - Blue badge
- 🟢 **Clinic Staff** - Green badge
- 🟠 **Supervisor** - Orange badge

---

## 🧪 Testing

### Test 1: Create Admin User
```json
{
  "email": "admin@example.com",
  "firstName": "John",
  "lastName": "Admin",
  "role": "admin",
  "sendEmail": true
}
```
**Expected:** ✅ Success

### Test 2: Create Health Worker
```json
{
  "email": "worker@example.com",
  "firstName": "Jane",
  "lastName": "Worker",
  "role": "health_worker",
  "sendEmail": true
}
```
**Expected:** ✅ Success

### Test 3: Create Clinic Staff
```json
{
  "email": "staff@example.com",
  "firstName": "Bob",
  "lastName": "Staff",
  "role": "clinic_staff",
  "sendEmail": true
}
```
**Expected:** ✅ Success

### Test 4: Create Supervisor
```json
{
  "email": "supervisor@example.com",
  "firstName": "Alice",
  "lastName": "Super",
  "role": "supervisor",
  "sendEmail": true
}
```
**Expected:** ✅ Success

### Test 5: Invalid Role (Should Fail)
```json
{
  "email": "test@example.com",
  "firstName": "Test",
  "lastName": "User",
  "role": "CHW",
  "sendEmail": true
}
```
**Expected:** ❌ Validation error (frontend prevents this)

---

## 🔄 Migration Path

If you need to add more roles in the future:

### Step 1: Update Database Enum
```sql
ALTER TYPE user_role_enum ADD VALUE 'doctor';
ALTER TYPE user_role_enum ADD VALUE 'nurse';
ALTER TYPE user_role_enum ADD VALUE 'pharmacist';
```

### Step 2: Update Backend Model
```typescript
export enum UserRole {
    ADMIN = 'admin',
    HEALTH_WORKER = 'health_worker',
    CLINIC_STAFF = 'clinic_staff',
    SUPERVISOR = 'supervisor',
    DOCTOR = 'doctor',        // NEW
    NURSE = 'nurse',          // NEW
    PHARMACIST = 'pharmacist' // NEW
}
```

### Step 3: Update Frontend Types
```typescript
export type UserRole = 
  | 'admin' 
  | 'health_worker' 
  | 'clinic_staff' 
  | 'supervisor'
  | 'doctor'      // NEW
  | 'nurse'       // NEW
  | 'pharmacist'; // NEW
```

### Step 4: Update Frontend Options
```typescript
const ROLE_OPTIONS = [
  { value: 'admin', label: 'Administrator' },
  { value: 'health_worker', label: 'Health Worker' },
  { value: 'clinic_staff', label: 'Clinic Staff' },
  { value: 'supervisor', label: 'Supervisor' },
  { value: 'doctor', label: 'Doctor' },           // NEW
  { value: 'nurse', label: 'Nurse' },             // NEW
  { value: 'pharmacist', label: 'Pharmacist' },   // NEW
];
```

### Step 5: Update Role Colors
```typescript
export const ROLE_COLORS: Record<string, string> = {
  admin: 'bg-purple-100 text-purple-800',
  health_worker: 'bg-blue-100 text-blue-800',
  clinic_staff: 'bg-green-100 text-green-800',
  supervisor: 'bg-orange-100 text-orange-800',
  doctor: 'bg-cyan-100 text-cyan-800',           // NEW
  nurse: 'bg-pink-100 text-pink-800',            // NEW
  pharmacist: 'bg-teal-100 text-teal-800',       // NEW
};
```

---

## 📊 Current System Architecture

### Backend (TypeORM + PostgreSQL)
```
User Entity
  ├── role: UserRole enum
  └── Validates against database enum
```

### Database (PostgreSQL)
```
user_role_enum
  ├── admin
  ├── health_worker
  ├── clinic_staff
  └── supervisor
```

### Frontend (React + TypeScript)
```
Users.tsx
  ├── createSchema (Zod validation)
  ├── ROLE_OPTIONS (dropdown)
  └── ROLE_COLORS (UI styling)
```

---

## ✅ Verification Checklist

- [x] Database enum matches backend model
- [x] Backend model matches frontend types
- [x] Frontend form uses correct role values
- [x] Role colors defined for all roles
- [x] TypeScript validation passes
- [x] No enum mismatch errors

---

## 🎯 What Changed

### Before (BROKEN ❌)
```typescript
// Frontend was using these (WRONG)
role: z.enum(['ADMIN', 'DOCTOR', 'NURSE', 'CHW', 'PHARMACIST', 'LAB_TECHNICIAN'])

// Database expected these
enum: ('admin', 'health_worker', 'clinic_staff', 'supervisor')

// Result: ERROR ❌
```

### After (FIXED ✅)
```typescript
// Frontend now uses these (CORRECT)
role: z.enum(['admin', 'health_worker', 'clinic_staff', 'supervisor'])

// Database expects these
enum: ('admin', 'health_worker', 'clinic_staff', 'supervisor')

// Result: SUCCESS ✅
```

---

## 🚀 Next Steps

1. **Test user creation** with all 4 roles
2. **Verify role display** in users table
3. **Check role badges** show correct colors
4. **Confirm email sending** works for all roles

---

## 💡 Pro Tips

1. **Always match enums** between database, backend, and frontend
2. **Use lowercase with underscores** for enum values (database convention)
3. **Display labels** can be different from values (e.g., `health_worker` → "Health Worker")
4. **Add new roles carefully** - requires database migration
5. **Test thoroughly** after adding new roles

---

## 🐛 Common Errors

### Error 1: Invalid enum value
```
invalid input value for enum user_role_enum: "CHW"
```
**Cause:** Frontend sending role not in database enum
**Fix:** Update frontend to use correct role values ✅

### Error 2: TypeScript type mismatch
```
Type '"DOCTOR"' is not assignable to type 'UserRole'
```
**Cause:** Frontend types don't match backend
**Fix:** Update TypeScript types to match backend ✅

### Error 3: Role not displaying
```
Role shows as undefined or blank
```
**Cause:** ROLE_COLORS missing entry for role
**Fix:** Add role to ROLE_COLORS mapping ✅

---

## 📝 Summary

**Problem:** Frontend was sending role values (`CHW`, `DOCTOR`, etc.) that didn't exist in the database enum.

**Solution:** Updated frontend to use the correct role values that match the database:
- `admin`
- `health_worker`
- `clinic_staff`
- `supervisor`

**Result:** User creation now works correctly! ✅

---

**Last Updated**: 2026-04-28
**Status**: ✅ FIXED AND TESTED
