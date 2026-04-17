# 👥 USER ROLES AND WORKFLOWS

## Overview

The AI-Powered Community Health Companion system supports 4 distinct user roles, each with specific permissions and workflows designed for rural clinic operations in Rwanda.

---

## 🎭 USER ROLES

### 1. **ADMIN** (System Administrator)
**Access Level**: Full system access  
**Typical Users**: IT administrators, system managers  
**Primary Responsibilities**: System configuration, user management, oversight

### 2. **HEALTH_WORKER** (Doctor/Nurse/Clinical Officer)
**Access Level**: Clinical operations  
**Typical Users**: Doctors, nurses, clinical officers  
**Primary Responsibilities**: Patient care, diagnosis, prescriptions

### 3. **CLINIC_STAFF** (Receptionist/Pharmacist)
**Access Level**: Administrative and pharmacy operations  
**Typical Users**: Receptionists, pharmacists, administrative staff  
**Primary Responsibilities**: Patient registration, appointments, medication dispensing

### 4. **SUPERVISOR** (Clinical Supervisor/Manager)
**Access Level**: Monitoring and reporting  
**Typical Users**: Clinic managers, health supervisors, MoH officials  
**Primary Responsibilities**: Quality assurance, reporting, oversight

---

## 📊 PERMISSIONS MATRIX

| Feature | Admin | Health Worker | Clinic Staff | Supervisor |
|---------|-------|---------------|--------------|------------|
| **Authentication** |
| Register/Login | ✅ | ✅ | ✅ | ✅ |
| **Patient Management** |
| View Patients | ✅ | ✅ | ✅ | ✅ |
| Create Patient | ✅ | ✅ | ✅ | ❌ |
| Update Patient | ✅ | ✅ | ✅ | ❌ |
| Delete Patient | ✅ | ❌ | ❌ | ❌ |
| **Diagnosis** |
| Create Diagnosis | ✅ | ✅ | ❌ | ❌ |
| View Diagnosis | ✅ | ✅ | ✅ | ✅ |
| Update Diagnosis | ✅ | ✅ | ❌ | ❌ |
| **Appointments** |
| Create Appointment | ✅ | ✅ | ✅ | ❌ |
| View Appointments | ✅ | ✅ | ✅ | ✅ |
| Update Status | ✅ | ✅ | ✅ | ❌ |
| Cancel Appointment | ✅ | ✅ | ❌ | ❌ |
| **Lab Orders** |
| Create Lab Order | ✅ | ✅ | ❌ | ❌ |
| View Lab Orders | ✅ | ✅ | ✅ | ✅ |
| Update Order Status | ✅ | ✅ | ✅ | ❌ |
| Create Lab Result | ✅ | ✅ | ❌ | ❌ |
| Review Lab Result | ✅ | ❌ | ❌ | ✅ |
| **Prescriptions** |
| Create Prescription | ✅ | ✅ | ❌ | ❌ |
| View Prescriptions | ✅ | ✅ | ✅ | ✅ |
| Dispense Medication | ✅ | ❌ | ✅ | ❌ |
| Update Status | ✅ | ✅ | ❌ | ❌ |
| Cancel Prescription | ✅ | ✅ | ❌ | ❌ |
| **Medications** |
| View Medications | ✅ | ✅ | ✅ | ✅ |
| Create Medication | ✅ | ❌ | ✅ | ❌ |
| Update Medication | ✅ | ❌ | ✅ | ❌ |
| Update Stock | ✅ | ❌ | ✅ | ❌ |
| **Pharmacy (e-LMIS)** |
| Check Availability | ✅ | ✅ | ✅ | ✅ |
| Search Medications | ✅ | ✅ | ✅ | ✅ |
| Reserve Stock | ✅ | ✅ | ✅ | ❌ |
| **FHIR Integration** |
| Access FHIR Resources | ✅ | ✅ | ✅ | ✅ |
| **Notifications** |
| View Notifications | ✅ | ✅ | ✅ | ✅ |
| Send Notifications | ✅ | ✅ | ✅ | ❌ |
| **Audit Logs** |
| View Audit Logs | ✅ | ❌ | ❌ | ✅ |
| View User Activity | ✅ | ❌ | ❌ | ✅ |
| **Reports** |
| MoH Reports | ✅ | ❌ | ❌ | ✅ |
| Surveillance Reports | ✅ | ❌ | ❌ | ✅ |
| Performance Reports | ✅ | ❌ | ❌ | ✅ |
| **Analytics** |
| View Dashboard | ✅ | ✅ | ✅ | ✅ |

---

## 🔄 DETAILED USER WORKFLOWS

### 1️⃣ ADMIN WORKFLOW

#### Primary Responsibilities:
- System configuration and maintenance
- User account management
- Data oversight and quality control
- System-wide reporting

#### Typical Daily Flow:

**Morning (8:00 AM - 10:00 AM)**
1. **Login** → `POST /api/v1/auth/login`
2. **Check System Health** → `GET /api/v1/health`
3. **Review Audit Logs** → `GET /api/v1/audit?startDate=today`
   - Monitor user activities
   - Check for security issues
   - Review system errors
4. **Check Low Stock Medications** → `GET /api/v1/medications/low-stock`
   - Identify medications below reorder level
   - Plan procurement

**Mid-Day (10:00 AM - 2:00 PM)**
5. **User Management**
   - Create new user accounts → `POST /api/v1/auth/register`
   - Deactivate/reactivate users (database operation)
6. **Patient Data Management**
   - Review patient records → `GET /api/v1/patients`
   - Delete duplicate/test records → `DELETE /api/v1/patients/:id`
7. **Medication Management**
   - Add new medications → `POST /api/v1/medications`
   - Update medication details → `PUT /api/v1/medications/:id`
   - Update stock levels → `PUT /api/v1/medications/:id/stock`

**Afternoon (2:00 PM - 5:00 PM)**
8. **Lab Results Review**
   - Review critical lab results → `GET /api/v1/lab/results/critical`
   - Approve lab results → `PUT /api/v1/lab/results/:id/review`
9. **Prescription Management**
   - Cancel invalid prescriptions → `DELETE /api/v1/prescriptions/:id`
   - Review prescription patterns
10. **Generate Reports**
    - Ministry of Health report → `GET /api/v1/reports/moh?month=2&year=2026`
    - Surveillance report → `GET /api/v1/reports/surveillance`
    - Performance metrics → `GET /api/v1/reports/performance`

**End of Day (5:00 PM - 6:00 PM)**
11. **System Maintenance**
    - Review error logs
    - Check sync status
    - Backup verification
12. **Logout** → `POST /api/v1/auth/logout`

---

### 2️⃣ HEALTH WORKER WORKFLOW (Doctor/Nurse)

#### Primary Responsibilities:
- Patient consultation and diagnosis
- AI-powered disease prediction
- Prescription management
- Lab test ordering
- Patient follow-up

#### Typical Patient Consultation Flow:

**Step 1: Patient Check-In**
1. **Login** → `POST /api/v1/auth/login`
2. **View Today's Appointments** → `GET /api/v1/appointments?date=2026-02-05`
3. **Search for Patient** → `GET /api/v1/patients/search?query=PatientName`
   - Or scan patient ID card
4. **View Patient History** → `GET /api/v1/patients/:id`
   - Previous diagnoses → `GET /api/v1/patients/:patientId/diagnoses`
   - Active prescriptions → `GET /api/v1/prescriptions/patient/:patientId`
   - Lab results → `GET /api/v1/lab/results/patient/:patientId`

**Step 2: Clinical Assessment**
5. **Record Vital Signs**
   - Temperature, BP, heart rate, respiratory rate, O2 saturation
6. **Document Symptoms**
   - Chief complaint
   - Symptom details (name, category, severity, duration)
7. **Review Medical History**
   - Chronic conditions
   - Allergies
   - Current medications

**Step 3: AI-Powered Diagnosis**
8. **Create Diagnosis** → `POST /api/v1/diagnosis`
   ```json
   {
     "patientId": "uuid",
     "symptoms": [
       { "name": "fever", "category": "general", "severity": "moderate" },
       { "name": "cough", "category": "respiratory", "severity": "mild" }
     ],
     "vitalSigns": {
       "temperature": 38.5,
       "bloodPressureSystolic": 120,
       "bloodPressureDiastolic": 80,
       "heartRate": 85,
       "respiratoryRate": 18,
       "oxygenSaturation": 97
     },
     "notes": "Patient reports symptoms for 3 days"
   }
   ```
9. **Review AI Predictions**
   - Top 3 disease predictions with confidence scores
   - ICD-10 codes
   - Clinical recommendations
10. **Select Final Diagnosis**
    - Update diagnosis with selected disease → `PUT /api/v1/diagnosis/:id`

**Step 4: Treatment Plan**
11. **Check Medication Availability** → `GET /api/v1/pharmacy/availability?medication=Amoxicillin`
    - Check local clinic stock
    - Check e-LMIS for nearby facilities
12. **Create Prescription** → `POST /api/v1/prescriptions`
    ```json
    {
      "patientId": "uuid",
      "diagnosisId": "uuid",
      "medications": [
        {
          "medicationId": "uuid",
          "dosage": "500mg",
          "frequency": "3 times daily",
          "duration": "7 days",
          "instructions": "Take with food"
        }
      ],
      "notes": "Complete full course"
    }
    ```

**Step 5: Lab Tests (if needed)**
13. **Order Lab Tests** → `POST /api/v1/lab/orders`
    ```json
    {
      "patientId": "uuid",
      "diagnosisId": "uuid",
      "tests": ["Blood Smear (Malaria)", "Complete Blood Count"],
      "priority": "routine",
      "notes": "Suspected malaria"
    }
    ```

**Step 6: Patient Education & Follow-Up**
14. **Schedule Follow-Up** → `POST /api/v1/appointments`
    ```json
    {
      "patientId": "uuid",
      "appointmentDate": "2026-02-12T10:00:00Z",
      "appointmentType": "follow-up",
      "reason": "Review treatment response"
    }
    ```
15. **Send Patient Notification** → `POST /api/v1/notifications`
    - Treatment instructions
    - Follow-up reminder
    - Medication schedule

**Step 7: Documentation**
16. **Update Appointment Status** → `PUT /api/v1/appointments/:id/status`
    - Mark as "completed"
17. **Update Patient Record** → `PUT /api/v1/patients/:id`
    - Update last visit date
    - Add to medical history

**End of Day**
18. **Review Pending Lab Results** → `GET /api/v1/lab/orders/pending`
19. **Check Critical Alerts** → `GET /api/v1/lab/results/critical`
20. **Logout** → `POST /api/v1/auth/logout`

---

### 3️⃣ CLINIC STAFF WORKFLOW (Receptionist/Pharmacist)

#### Primary Responsibilities:
- Patient registration and check-in
- Appointment scheduling
- Medication dispensing
- Stock management
- Administrative support

#### Typical Daily Flow:

**Morning (7:30 AM - 9:00 AM)**
1. **Login** → `POST /api/v1/auth/login`
2. **Open Clinic**
   - Check today's appointments → `GET /api/v1/appointments?date=2026-02-05`
   - Print appointment list
3. **Check Medication Stock** → `GET /api/v1/medications/low-stock`
   - Identify low stock items
   - Prepare reorder list

**Patient Registration (Throughout Day)**
4. **New Patient Registration** → `POST /api/v1/patients`
   ```json
   {
     "firstName": "Jean",
     "lastName": "Uwimana",
     "dateOfBirth": "1985-03-15",
     "gender": "male",
     "phoneNumber": "+250788123456",
     "nationalId": "1198580012345678",
     "address": "Kigali, Gasabo District",
     "emergencyContact": {
       "name": "Marie Uwimana",
       "relationship": "spouse",
       "phoneNumber": "+250788654321"
     }
   }
   ```
5. **Returning Patient Check-In**
   - Search patient → `GET /api/v1/patients/search?query=nationalId`
   - Verify patient details → `GET /api/v1/patients/:id`
   - Update contact info if needed → `PUT /api/v1/patients/:id`

**Appointment Management**
6. **Schedule New Appointment** → `POST /api/v1/appointments`
   ```json
   {
     "patientId": "uuid",
     "appointmentDate": "2026-02-06T14:00:00Z",
     "appointmentType": "consultation",
     "reason": "General checkup"
   }
   ```
7. **Check Available Slots** → `GET /api/v1/appointments/available-slots?date=2026-02-06`
8. **Reschedule Appointment** → `PUT /api/v1/appointments/:id/reschedule`
9. **Update Appointment Status** → `PUT /api/v1/appointments/:id/status`
   - Mark patient as "arrived"
   - Mark as "in-progress" when with doctor
   - Mark as "completed" after consultation

**Pharmacy Operations**
10. **View Pending Prescriptions** → `GET /api/v1/prescriptions?status=pending`
11. **Dispense Medication** → `PUT /api/v1/prescriptions/:id/dispense`
    ```json
    {
      "dispensedBy": "userId",
      "dispensedDate": "2026-02-05T10:30:00Z",
      "notes": "Patient counseled on usage"
    }
    ```
12. **Check e-LMIS for Out-of-Stock Items** → `GET /api/v1/pharmacy/availability?medication=Paracetamol`
13. **Reserve Stock from Other Facilities** → `POST /api/v1/pharmacy/reserve`
    ```json
    {
      "medicationId": "uuid",
      "facilityId": "FACILITY-002",
      "quantity": 100,
      "patientId": "uuid"
    }
    ```

**Stock Management**
14. **Add New Medication** → `POST /api/v1/medications`
    ```json
    {
      "genericName": "Amoxicillin",
      "brandName": "Amoxil",
      "form": "capsule",
      "strength": "500mg",
      "category": "antibiotic",
      "manufacturer": "GSK",
      "unitPrice": 500,
      "stockInfo": {
        "quantity": 500,
        "reorderLevel": 100,
        "expiryDate": "2027-12-31",
        "batchNumber": "BATCH-2024-001"
      }
    }
    ```
15. **Update Stock Levels** → `PUT /api/v1/medications/:id/stock`
    - After receiving new stock
    - After dispensing medications
16. **Update Medication Details** → `PUT /api/v1/medications/:id`
    - Price changes
    - Supplier changes

**Patient Communication**
17. **Send Appointment Reminders** → `POST /api/v1/notifications`
    - SMS reminders for next-day appointments
    - Follow-up reminders
18. **Send Prescription Ready Notifications**
    - Notify patients when medications are ready for pickup

**End of Day (5:00 PM - 6:00 PM)**
19. **Close Clinic**
    - Review completed appointments
    - Check pending prescriptions
    - Update stock records
20. **Generate Daily Summary**
    - Total patients seen
    - Medications dispensed
    - Stock movements
21. **Logout** → `POST /api/v1/auth/logout`

---

### 4️⃣ SUPERVISOR WORKFLOW (Clinical Manager/MoH Official)

#### Primary Responsibilities:
- Quality assurance and monitoring
- Report generation for Ministry of Health
- Disease surveillance
- Performance tracking
- Audit review

#### Typical Weekly/Monthly Flow:

**Weekly Review (Every Monday)**
1. **Login** → `POST /api/v1/auth/login`
2. **Review Audit Logs** → `GET /api/v1/audit?startDate=lastWeek&endDate=today`
   - Monitor user activities
   - Check for unusual patterns
   - Review access logs
3. **Check User Activity** → `GET /api/v1/audit/user/:userId`
   - Review individual staff performance
   - Identify training needs
4. **Review Critical Lab Results** → `GET /api/v1/lab/results/critical`
   - Ensure timely follow-up
   - Check for missed alerts
5. **Review Lab Result Quality** → `PUT /api/v1/lab/results/:id/review`
   - Approve or flag results
   - Provide feedback to lab technicians

**Disease Surveillance (Daily/Weekly)**
6. **Generate Surveillance Report** → `GET /api/v1/reports/surveillance?startDate=2026-02-01&endDate=2026-02-05`
   ```json
   {
     "period": { "startDate": "2026-02-01", "endDate": "2026-02-05" },
     "diseaseCount": {
       "Malaria": { "count": 45, "trend": "increasing" },
       "Common Cold": { "count": 78, "trend": "stable" },
       "Hypertension": { "count": 23, "trend": "stable" },
       "Gastroenteritis": { "count": 12, "trend": "decreasing" }
     },
     "alerts": [
       {
         "disease": "Malaria",
         "count": 45,
         "severity": "high",
         "message": "Malaria cases above threshold"
       }
     ]
   }
   ```
7. **Monitor Disease Trends**
   - Identify outbreaks
   - Alert health authorities
   - Recommend interventions

**Monthly Reporting (End of Month)**
8. **Generate Ministry of Health Report** → `GET /api/v1/reports/moh?month=2&year=2026`
   ```json
   {
     "period": { "month": 2, "year": 2026 },
     "summary": {
       "totalPatients": 1250,
       "newPatients": 180,
       "totalDiagnoses": 890
     },
     "diseaseBreakdown": {
       "Malaria": 145,
       "Common Cold": 234,
       "Hypertension": 89,
       "Gastroenteritis": 67,
       "Influenza": 123,
       "Other": 232
     },
     "generatedAt": "2026-03-01T08:00:00Z"
   }
   ```
9. **Generate Performance Report** → `GET /api/v1/reports/performance?startDate=2026-02-01&endDate=2026-02-28`
   ```json
   {
     "period": { "startDate": "2026-02-01", "endDate": "2026-02-28" },
     "metrics": {
       "appointments": {
         "total": 1100,
         "completed": 980,
         "completionRate": "89.09%"
       },
       "labOrders": 345,
       "prescriptions": 890
     }
   }
   ```

**Quality Assurance**
10. **Review Diagnosis Accuracy**
    - Compare AI predictions with final diagnoses
    - Identify patterns of agreement/disagreement
11. **Review Prescription Patterns**
    - Check for appropriate antibiotic use
    - Monitor controlled substance prescriptions
12. **Review Resource Utilization**
    - Lab test ordering patterns
    - Medication usage
    - Appointment efficiency

**Staff Performance Monitoring**
13. **View Individual Staff Activity** → `GET /api/v1/audit/user/:userId`
    - Number of patients seen
    - Diagnosis completion rate
    - Prescription patterns
14. **Identify Training Needs**
    - Areas of improvement
    - Best practices sharing

**Data Analysis**
15. **View Analytics Dashboard** → `GET /api/v1/analytics/dashboard`
    - Patient demographics
    - Disease prevalence
    - Treatment outcomes
16. **Export Data for Analysis**
    - FHIR format → `GET /api/v1/fhir/Patient`
    - Custom reports

**End of Review Period**
17. **Submit Reports to Ministry of Health**
    - Email or upload reports
    - Follow up on recommendations
18. **Logout** → `POST /api/v1/auth/logout`

---

## 🔐 AUTHENTICATION FLOW (All Roles)

### Initial Registration
```
1. Admin creates user account → POST /api/v1/auth/register
   {
     "email": "doctor@clinic.rw",
     "password": "SecurePassword123!",
     "firstName": "Dr. Jean",
     "lastName": "Mugabo",
     "role": "health_worker",
     "clinicId": "CLINIC-001",
     "phoneNumber": "+250788123456"
   }

2. User receives credentials (email/SMS)

3. User logs in → POST /api/v1/auth/login
   {
     "email": "doctor@clinic.rw",
     "password": "SecurePassword123!"
   }

4. System returns JWT token
   {
     "success": true,
     "data": {
       "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
       "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
       "user": {
         "id": "uuid",
         "email": "doctor@clinic.rw",
         "firstName": "Dr. Jean",
         "lastName": "Mugabo",
         "role": "health_worker",
         "clinicId": "CLINIC-001"
       }
     }
   }

5. User includes token in all subsequent requests
   Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Refresh
```
When token expires (24 hours):
POST /api/v1/auth/refresh
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Returns new access token
```

### Logout
```
POST /api/v1/auth/logout
Authorization: Bearer <token>

Invalidates refresh token
```

---

## 📱 COMMON WORKFLOWS ACROSS ROLES

### 1. Patient Search
**All Roles Can Search Patients**
```
GET /api/v1/patients/search?query=<searchTerm>

Search by:
- Name (first or last)
- National ID
- Phone number
- Patient ID
```

### 2. View Patient Details
**All Roles Can View Patient Information**
```
GET /api/v1/patients/:id

Returns:
- Demographics
- Medical history
- Chronic conditions
- Allergies
- Emergency contacts
- Last visit date
```

### 3. View Appointments
**All Roles Can View Appointments**
```
GET /api/v1/appointments?date=2026-02-05
GET /api/v1/appointments?patientId=<uuid>
GET /api/v1/appointments?status=scheduled
```

### 4. View Notifications
**All Roles Receive Notifications**
```
GET /api/v1/notifications
GET /api/v1/notifications/unread

Notification Types:
- Appointment reminders
- Lab results ready
- Critical alerts
- System messages
- Stock alerts
```

### 5. View Analytics Dashboard
**All Roles Can View Dashboard**
```
GET /api/v1/analytics/dashboard

Shows:
- Today's patient count
- Pending appointments
- Critical lab results
- Low stock medications
- Recent diagnoses
```

### 6. FHIR Data Access
**All Roles Can Access FHIR Resources**
```
GET /api/v1/fhir/Patient/:id
GET /api/v1/fhir/Observation/:id
GET /api/v1/fhir/Condition/:id
GET /api/v1/fhir/MedicationRequest/:id

For interoperability with other systems
```

---

## 🎯 ROLE-SPECIFIC USE CASES

### Use Case 1: Emergency Patient (Health Worker)
**Scenario**: Patient arrives with severe symptoms

1. **Quick Registration** (if new patient)
   - Clinic Staff: `POST /api/v1/patients` (minimal info)
2. **Immediate Triage**
   - Health Worker: Record vital signs
   - Assess severity
3. **Rapid Diagnosis**
   - Health Worker: `POST /api/v1/diagnosis` (with symptoms + vitals)
   - Review AI predictions immediately
4. **Urgent Treatment**
   - Health Worker: `POST /api/v1/prescriptions` (emergency medications)
   - Clinic Staff: `PUT /api/v1/prescriptions/:id/dispense` (immediate)
5. **Lab Tests**
   - Health Worker: `POST /api/v1/lab/orders` (priority: urgent)
6. **Referral** (if needed)
   - Update diagnosis with referral details
   - Send notification to referral facility

---

### Use Case 2: Routine Checkup (Health Worker + Clinic Staff)
**Scenario**: Patient scheduled for routine checkup

1. **Check-In**
   - Clinic Staff: Update appointment status to "arrived"
   - `PUT /api/v1/appointments/:id/status`
2. **Vital Signs**
   - Clinic Staff: Record basic vitals
3. **Consultation**
   - Health Worker: Review patient history
   - Perform examination
   - Create diagnosis if needed
4. **Preventive Care**
   - Health Worker: Schedule follow-up
   - Provide health education
5. **Checkout**
   - Clinic Staff: Mark appointment as "completed"
   - Schedule next routine visit

---

### Use Case 3: Medication Refill (Clinic Staff)
**Scenario**: Patient needs prescription refill

1. **Patient Arrives**
   - Clinic Staff: Search patient
   - `GET /api/v1/patients/search?query=nationalId`
2. **Check Previous Prescription**
   - `GET /api/v1/prescriptions/patient/:patientId`
   - Verify refill eligibility
3. **Request Refill**
   - `POST /api/v1/prescriptions/:id/refill`
4. **Check Stock**
   - `GET /api/v1/medications?search=medicationName`
   - If out of stock: `GET /api/v1/pharmacy/availability`
5. **Dispense**
   - `PUT /api/v1/prescriptions/:id/dispense`
6. **Update Stock**
   - `PUT /api/v1/medications/:id/stock`

---

### Use Case 4: Disease Outbreak Detection (Supervisor)
**Scenario**: Unusual increase in malaria cases

1. **Daily Surveillance**
   - Supervisor: `GET /api/v1/reports/surveillance?startDate=lastWeek`
2. **Identify Trend**
   - Notice 300% increase in malaria diagnoses
3. **Detailed Analysis**
   - `GET /api/v1/diagnosis?disease=Malaria&startDate=lastWeek`
   - Review geographic distribution
   - Check age groups affected
4. **Generate Alert Report**
   - `GET /api/v1/reports/moh?month=current`
   - Include outbreak details
5. **Notify Authorities**
   - Send report to Ministry of Health
   - Recommend interventions (mosquito nets, spraying)
6. **Monitor Response**
   - Track case numbers daily
   - Verify intervention effectiveness

---

### Use Case 5: Stock Management (Admin + Clinic Staff)
**Scenario**: Monthly stock reconciliation

1. **Check Low Stock**
   - Clinic Staff: `GET /api/v1/medications/low-stock`
2. **Review Usage Patterns**
   - Admin: Analyze prescription data
   - Identify high-demand medications
3. **Check e-LMIS Availability**
   - `GET /api/v1/pharmacy/availability?medication=Amoxicillin`
4. **Place Order**
   - Contact e-LMIS facility
   - Reserve stock: `POST /api/v1/pharmacy/reserve`
5. **Receive Stock**
   - Clinic Staff: `PUT /api/v1/medications/:id/stock`
   - Update quantity, batch number, expiry date
6. **Update Records**
   - Admin: Verify stock levels
   - Generate stock report

---

### Use Case 6: Quality Assurance Review (Supervisor)
**Scenario**: Monthly quality review

1. **Review Audit Logs**
   - `GET /api/v1/audit?startDate=lastMonth`
   - Check for policy violations
2. **Review Diagnosis Accuracy**
   - Compare AI predictions vs final diagnoses
   - Calculate agreement rate
3. **Review Prescription Patterns**
   - Check antibiotic prescribing
   - Identify inappropriate prescriptions
4. **Review Lab Results**
   - `GET /api/v1/lab/results/critical`
   - Verify timely follow-up
   - `PUT /api/v1/lab/results/:id/review`
5. **Staff Performance**
   - `GET /api/v1/audit/user/:userId`
   - Review individual metrics
6. **Generate QA Report**
   - Document findings
   - Recommend training
   - Share best practices

---

## 🚨 ERROR HANDLING & EDGE CASES

### Scenario 1: Offline Operation
**Problem**: Internet connection lost

**Solution**:
- System continues to work offline
- All operations stored locally
- Sync status tracked: `syncStatus.pendingSync = true`
- When connection restored:
  - `POST /api/v1/sync/push` (upload local changes)
  - `POST /api/v1/sync/pull` (download server changes)
  - `POST /api/v1/sync/resolve-conflicts` (handle conflicts)

### Scenario 2: Medication Out of Stock
**Problem**: Prescribed medication not available

**Health Worker Actions**:
1. Check e-LMIS: `GET /api/v1/pharmacy/availability?medication=Amoxicillin`
2. Find alternatives: `GET /api/v1/pharmacy/alternatives/:medicationId`
3. Options:
   - Reserve from nearby facility
   - Prescribe alternative medication
   - Partial dispensing with follow-up

### Scenario 3: Critical Lab Result
**Problem**: Lab result shows critical values

**Automatic Actions**:
- System flags result as critical
- Notification sent to Health Worker
- Notification sent to Supervisor

**Health Worker Actions**:
1. Review result: `GET /api/v1/lab/results/:id`
2. Contact patient immediately
3. Schedule urgent follow-up
4. Update treatment plan
5. Document actions in diagnosis notes

### Scenario 4: Duplicate Patient Record
**Problem**: Patient registered twice

**Admin Actions**:
1. Identify duplicates (manual review)
2. Merge records (manual process):
   - Keep primary record
   - Transfer diagnoses, prescriptions, appointments
3. Delete duplicate: `DELETE /api/v1/patients/:id`
4. Update references in related records

### Scenario 5: Unauthorized Access Attempt
**Problem**: User tries to access restricted resource

**System Response**:
- Return 403 Forbidden error
- Log attempt in audit log
- Notify admin if repeated attempts

**Admin Actions**:
1. Review audit logs: `GET /api/v1/audit?userId=suspiciousUser`
2. Investigate pattern
3. Take action (warning, suspension, training)

### Scenario 6: Token Expiration During Operation
**Problem**: JWT token expires mid-session

**User Actions**:
1. Receive 401 Unauthorized error
2. Automatically refresh token: `POST /api/v1/auth/refresh`
3. Retry failed request with new token
4. If refresh fails: redirect to login

---

## 📊 WORKFLOW METRICS & KPIs

### Health Worker Performance Metrics
- **Patients Seen per Day**: Target 20-30
- **Average Consultation Time**: Target 15-20 minutes
- **Diagnosis Completion Rate**: Target 95%+
- **Prescription Accuracy**: Target 98%+
- **Follow-up Compliance**: Target 80%+

### Clinic Staff Performance Metrics
- **Patient Registration Time**: Target <5 minutes
- **Appointment Scheduling Accuracy**: Target 98%+
- **Medication Dispensing Time**: Target <10 minutes
- **Stock Accuracy**: Target 99%+
- **Patient Satisfaction**: Target 90%+

### Supervisor Review Metrics
- **Audit Log Review Frequency**: Weekly
- **Report Generation Timeliness**: Monthly (by 5th of month)
- **Quality Assurance Reviews**: Monthly
- **Staff Training Sessions**: Quarterly
- **Outbreak Detection Time**: <24 hours

### System Performance Metrics
- **API Response Time**: Target <500ms
- **Uptime**: Target 99.9%
- **Sync Success Rate**: Target 99%+
- **Data Accuracy**: Target 99.9%+
- **Security Incidents**: Target 0

---

## 🎓 TRAINING RECOMMENDATIONS

### Admin Training (2 days)
**Day 1: System Administration**
- User management
- System configuration
- Database backup/restore
- Security best practices

**Day 2: Reporting & Analytics**
- Report generation
- Data analysis
- Audit log review
- Performance monitoring

### Health Worker Training (3 days)
**Day 1: Basic Operations**
- Login and navigation
- Patient search and registration
- Appointment management
- Basic documentation

**Day 2: Clinical Workflows**
- AI-powered diagnosis
- Interpreting AI predictions
- Prescription management
- Lab test ordering
- e-LMIS integration

**Day 3: Advanced Features**
- FHIR data exchange
- Offline operation
- Emergency protocols
- Quality documentation

### Clinic Staff Training (2 days)
**Day 1: Administrative Tasks**
- Patient registration
- Appointment scheduling
- Basic navigation
- Communication tools

**Day 2: Pharmacy Operations**
- Medication dispensing
- Stock management
- e-LMIS integration
- Inventory tracking

### Supervisor Training (1 day)
**Full Day: Monitoring & Reporting**
- Audit log review
- Report generation
- Quality assurance
- Performance monitoring
- Disease surveillance
- Data analysis

---

## 🔄 INTEGRATION WORKFLOWS

### FHIR Integration Workflow
**Purpose**: Exchange data with other healthcare systems

**Export Patient Data**:
```
1. Health Worker creates diagnosis
2. System converts to FHIR format
3. Export: GET /api/v1/fhir/Patient/:id
4. Send to external system (Epic, Cerner, OpenMRS)
```

**Import Patient Data**:
```
1. Receive FHIR resource from external system
2. Import: POST /api/v1/fhir/import
3. System converts to internal format
4. Create/update patient record
```

### e-LMIS Integration Workflow
**Purpose**: Check medication availability across Rwanda

**Check Stock Before Prescribing**:
```
1. Health Worker selects medication
2. System checks local stock
3. If low/out: GET /api/v1/pharmacy/availability
4. Display nearby facilities with stock
5. Option to reserve: POST /api/v1/pharmacy/reserve
6. Patient can pick up from nearest facility
```

### Notification Workflow
**Purpose**: Multi-channel patient communication

**Appointment Reminder**:
```
1. System checks appointments for next day
2. For each appointment:
   - Generate reminder message
   - POST /api/v1/notifications
   - Send via SMS (primary)
   - Send via email (if available)
   - Send in-app notification
3. Track delivery status
4. Retry if failed
```

### Sync Workflow (Offline-First)
**Purpose**: Enable offline operation in rural areas

**Offline Operation**:
```
1. User works normally without internet
2. All changes stored locally
3. syncStatus.pendingSync = true
4. Queue for synchronization
```

**Synchronization**:
```
1. Internet connection restored
2. Push local changes: POST /api/v1/sync/push
3. Pull server changes: POST /api/v1/sync/pull
4. Resolve conflicts: POST /api/v1/sync/resolve-conflicts
5. Update syncStatus.lastSynced
6. Mark syncStatus.pendingSync = false
```

---

## 📋 QUICK REFERENCE GUIDE

### Most Common Endpoints by Role

#### ADMIN
```
POST   /api/v1/auth/register          - Create user account
GET    /api/v1/audit                  - View audit logs
GET    /api/v1/medications/low-stock  - Check stock levels
POST   /api/v1/medications            - Add medication
PUT    /api/v1/medications/:id/stock  - Update stock
DELETE /api/v1/patients/:id           - Delete patient
GET    /api/v1/reports/moh            - Generate MoH report
```

#### HEALTH_WORKER
```
POST   /api/v1/auth/login             - Login
GET    /api/v1/patients/search        - Find patient
GET    /api/v1/patients/:id           - View patient details
POST   /api/v1/diagnosis              - Create AI diagnosis
POST   /api/v1/prescriptions          - Create prescription
POST   /api/v1/lab/orders             - Order lab tests
POST   /api/v1/appointments           - Schedule appointment
GET    /api/v1/pharmacy/availability  - Check medication stock
```

#### CLINIC_STAFF
```
POST   /api/v1/auth/login             - Login
POST   /api/v1/patients               - Register patient
POST   /api/v1/appointments           - Schedule appointment
PUT    /api/v1/appointments/:id/status - Update appointment
PUT    /api/v1/prescriptions/:id/dispense - Dispense medication
POST   /api/v1/medications            - Add medication
PUT    /api/v1/medications/:id/stock  - Update stock
GET    /api/v1/pharmacy/availability  - Check e-LMIS stock
```

#### SUPERVISOR
```
POST   /api/v1/auth/login             - Login
GET    /api/v1/audit                  - View audit logs
GET    /api/v1/reports/surveillance   - Disease surveillance
GET    /api/v1/reports/moh            - MoH report
GET    /api/v1/reports/performance    - Performance metrics
PUT    /api/v1/lab/results/:id/review - Review lab results
GET    /api/v1/audit/user/:userId     - User activity
```

---

## 🎯 SUCCESS CRITERIA

### For Health Workers
✅ Can complete patient consultation in <20 minutes  
✅ AI diagnosis accuracy >85%  
✅ Prescription completion rate >95%  
✅ Patient satisfaction >90%  
✅ Comfortable with offline operation  

### For Clinic Staff
✅ Patient registration time <5 minutes  
✅ Appointment scheduling accuracy >98%  
✅ Medication dispensing time <10 minutes  
✅ Stock accuracy >99%  
✅ Zero stock-outs of essential medications  

### For Supervisors
✅ Monthly reports submitted on time  
✅ Outbreak detection within 24 hours  
✅ Quality assurance reviews completed monthly  
✅ Staff training conducted quarterly  
✅ Audit compliance >95%  

### For Admins
✅ System uptime >99.9%  
✅ Data backup success rate 100%  
✅ Security incidents = 0  
✅ User account management <24 hour turnaround  
✅ System performance within targets  

---

## 📞 SUPPORT & ESCALATION

### Level 1: User Support (Clinic Staff)
- Password resets
- Basic navigation help
- Appointment scheduling issues
- Patient registration questions

### Level 2: Technical Support (Admin)
- System errors
- Integration issues
- Performance problems
- Data synchronization

### Level 3: Clinical Support (Supervisor)
- Diagnosis interpretation
- Treatment protocols
- Quality assurance
- Clinical guidelines

### Level 4: System Development (IT Team)
- Bug fixes
- Feature requests
- System upgrades
- Security patches

---

## ✨ SUMMARY

This AI-Powered Community Health Companion system provides:

✅ **Role-Based Access Control**: 4 distinct roles with appropriate permissions  
✅ **Complete Clinical Workflows**: From registration to follow-up  
✅ **AI-Powered Diagnosis**: Intelligent disease prediction with ICD-10 codes  
✅ **e-LMIS Integration**: Real-time medication availability across Rwanda  
✅ **Offline-First Design**: Works without internet in rural areas  
✅ **FHIR Compliance**: International interoperability standards  
✅ **Comprehensive Reporting**: MoH reports, surveillance, performance metrics  
✅ **Audit Trail**: HIPAA/GDPR compliant logging  

**Ready for deployment in rural clinics across Rwanda! 🇷🇼**

---

**Document Version**: 1.0  
**Last Updated**: February 5, 2026  
**Status**: Production Ready ✅
