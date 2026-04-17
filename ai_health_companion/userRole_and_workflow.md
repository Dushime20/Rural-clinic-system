# 🎭 ROLE PERMISSIONS - QUICK REFERENCE

## Visual Permission Matrix

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AI HEALTH COMPANION - USER ROLES                  │
└─────────────────────────────────────────────────────────────────────┘

👤 ADMIN (System Administrator)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Full system access
✅ User management (create, update, delete)
✅ Patient management (including delete)
✅ Medication management (create, update, stock)
✅ Prescription management (cancel)
✅ Lab result review and approval
✅ Audit log access
✅ Report generation (all types)
✅ System configuration

🏥 HEALTH_WORKER (Doctor/Nurse/Clinical Officer)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Patient management (create, update, view)
✅ AI-powered diagnosis (create, update)
✅ Prescription management (create, update, cancel)
✅ Lab orders (create, view, update status)
✅ Lab results (create, view)
✅ Appointment management (create, view, update, cancel)
✅ e-LMIS integration (check availability, reserve)
✅ Notifications (send, view)
✅ FHIR data access
❌ User management
❌ Audit logs
❌ Reports
❌ Medication catalog management

📋 CLINIC_STAFF (Receptionist/Pharmacist)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Patient management (create, update, view)
✅ Appointment management (create, view, update)
✅ Medication management (create, update, stock)
✅ Prescription dispensing
✅ e-LMIS integration (check availability, reserve)
✅ Notifications (send, view)
✅ Lab orders (view, update status)
✅ FHIR data access
❌ Diagnosis creation
❌ Prescription creation
❌ Lab result creation
❌ User management
❌ Audit logs
❌ Reports

📊 SUPERVISOR (Clinical Manager/MoH Official)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ View all patient data
✅ View all diagnoses
✅ View all prescriptions
✅ View all lab results
✅ Lab result review and approval
✅ Audit log access (full)
✅ Report generation (all types)
✅ User activity monitoring
✅ Analytics dashboard
✅ FHIR data access
❌ Patient creation/update
❌ Diagnosis creation
❌ Prescription creation
❌ Medication management
❌ User management
```

---

## 🔐 Authentication Requirements

**All Roles Require**:
- Valid email and password
- JWT token for API access
- Token refresh every 24 hours
- Clinic ID assignment (except Admin)

---

## 📱 Typical Daily Actions

### ADMIN (30-60 min/day)
```
Morning:
  ☑ Review audit logs (10 min)
  ☑ Check system health (5 min)
  ☑ Review low stock alerts (5 min)

As Needed:
  ☑ Create user accounts (5 min each)
  ☑ Update medication catalog (10 min)
  ☑ Resolve data issues (varies)

Monthly:
  ☑ Generate MoH reports (30 min)
  ☑ System maintenance (2 hours)
```

### HEALTH_WORKER (8 hours/day)
```
Per Patient (15-20 min):
  ☑ Search/view patient (2 min)
  ☑ Record symptoms & vitals (3 min)
  ☑ AI diagnosis (2 min)
  ☑ Review predictions (2 min)
  ☑ Create prescription (3 min)
  ☑ Order labs if needed (2 min)
  ☑ Schedule follow-up (2 min)
  ☑ Documentation (2 min)

Daily: 20-30 patients = 5-10 hours
```

### CLINIC_STAFF (8 hours/day)
```
Per Patient Registration (5 min):
  ☑ Collect information (3 min)
  ☑ Enter into system (2 min)

Per Appointment (3 min):
  ☑ Check availability (1 min)
  ☑ Schedule appointment (2 min)

Per Prescription (10 min):
  ☑ Retrieve prescription (2 min)
  ☑ Check stock (2 min)
  ☑ Dispense medication (3 min)
  ☑ Patient counseling (3 min)

Daily: 40-60 transactions
```

### SUPERVISOR (2-4 hours/week)
```
Weekly:
  ☑ Review audit logs (30 min)
  ☑ Check critical lab results (15 min)
  ☑ Disease surveillance (30 min)
  ☑ Staff performance review (30 min)

Monthly:
  ☑ Generate MoH report (30 min)
  ☑ Performance report (30 min)
  ☑ Quality assurance review (2 hours)
```

---

## 🎯 Key Endpoints by Role

### ADMIN - Top 10 Endpoints
```
1. POST   /api/v1/auth/register
2. GET    /api/v1/audit
3. GET    /api/v1/medications/low-stock
4. POST   /api/v1/medications
5. PUT    /api/v1/medications/:id/stock
6. DELETE /api/v1/patients/:id
7. GET    /api/v1/reports/moh
8. GET    /api/v1/reports/performance
9. PUT    /api/v1/lab/results/:id/review
10. GET   /api/v1/analytics/dashboard
```

### HEALTH_WORKER - Top 10 Endpoints
```
1. POST   /api/v1/auth/login
2. GET    /api/v1/patients/search
3. GET    /api/v1/patients/:id
4. POST   /api/v1/diagnosis
5. POST   /api/v1/prescriptions
6. POST   /api/v1/lab/orders
7. POST   /api/v1/appointments
8. GET    /api/v1/pharmacy/availability
9. GET    /api/v1/appointments?date=today
10. GET   /api/v1/lab/results/critical
```

### CLINIC_STAFF - Top 10 Endpoints
```
1. POST   /api/v1/auth/login
2. POST   /api/v1/patients
3. POST   /api/v1/appointments
4. PUT    /api/v1/appointments/:id/status
5. PUT    /api/v1/prescriptions/:id/dispense
6. GET    /api/v1/patients/search
7. POST   /api/v1/medications
8. PUT    /api/v1/medications/:id/stock
9. GET    /api/v1/pharmacy/availability
10. GET   /api/v1/appointments?date=today
```

### SUPERVISOR - Top 10 Endpoints
```
1. POST   /api/v1/auth/login
2. GET    /api/v1/audit
3. GET    /api/v1/reports/surveillance
4. GET    /api/v1/reports/moh
5. GET    /api/v1/reports/performance
6. PUT    /api/v1/lab/results/:id/review
7. GET    /api/v1/audit/user/:userId
8. GET    /api/v1/lab/results/critical
9. GET    /api/v1/analytics/dashboard
10. GET   /api/v1/patients
```

---

## 🚦 Access Control Rules

### Rule 1: Clinic Isolation
- Users can only access data from their assigned clinic
- Exception: Admins and Supervisors (multi-clinic access)

### Rule 2: Role Hierarchy
```
ADMIN > SUPERVISOR > HEALTH_WORKER > CLINIC_STAFF
```

### Rule 3: Data Ownership
- Users can view all records in their clinic
- Users can only modify records they created (except Admins)

### Rule 4: Sensitive Operations
- Delete operations: Admin only
- Audit log access: Admin + Supervisor only
- Report generation: Admin + Supervisor only
- User management: Admin only

### Rule 5: Emergency Override
- Admins can access any data in emergency situations
- All emergency access is logged in audit trail

---

## 📊 Permission Enforcement

### Backend (API Level)
```typescript
// Authentication middleware
router.use(authenticate);

// Authorization middleware
router.post('/diagnosis', 
  authorize(UserRole.HEALTH_WORKER, UserRole.ADMIN),
  createDiagnosis
);
```

### Database Level
```sql
-- Row-level security
WHERE clinicId = current_user.clinicId

-- Audit logging
INSERT INTO audit_logs (userId, action, resource, ...)
```

### Frontend Level
```typescript
// Hide UI elements based on role
{user.role === 'admin' && <DeleteButton />}

// Disable actions based on permissions
<Button disabled={!canEdit(user.role)} />
```

---

## ✅ Compliance & Security

### HIPAA Compliance
✅ Role-based access control  
✅ Audit trail for all actions  
✅ Encryption at rest and in transit  
✅ Automatic session timeout  
✅ Password complexity requirements

### GDPR Compliance
✅ Data minimization  
✅ Right to access (patient data export)  
✅ Right to erasure (patient deletion)  
✅ Audit trail  
✅ Consent management

### Rwanda Health Data Protection
✅ Ministry of Health reporting  
✅ Disease surveillance  
✅ Data sovereignty (local hosting)  
✅ e-LMIS integration  
✅ FHIR compliance

---

**Document Version**: 1.0  
**Last Updated**: February 5, 2026  
**Status**: Production Ready ✅
