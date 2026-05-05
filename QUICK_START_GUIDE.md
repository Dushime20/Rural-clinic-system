# AI Health Companion - Quick Start Guide

## 🚀 Getting Started

This guide will help you quickly start all services and test the complete AI diagnosis flow with pharmacy recommendations.

---

## 📋 Prerequisites

### Required Software:
- ✅ Node.js (v18+)
- ✅ Python (v3.8+)
- ✅ PostgreSQL (running)
- ✅ Flutter SDK (v3.7+)
- ✅ Git

### Required Accounts:
- PostgreSQL database (Neon or local)
- SMTP email account (Gmail recommended)

---

## 🎯 Quick Start (5 Minutes)

### Step 1: Start Backend Services

```bash
# Terminal 1: Start Flask ML Service
cd ai_health_companion_backend/model-training
pip install -r requirements.txt
python api.py

# Expected output:
# INFO:__main__:Model and datasets loaded successfully
# * Running on http://127.0.0.1:5001

# Terminal 2: Start Node.js Backend
cd ai_health_companion_backend
npm install
npm run dev

# Expected output:
# 🚀 Server running on port 5000 in development mode
# 📚 API Documentation: http://localhost:5000/api-docs
# 🏥 Health Check: http://localhost:5000/health

# Terminal 3: Start Admin Dashboard
cd admin_dashboard
npm install
npm run dev

# Expected output:
# VITE ready in XXXms
# ➜  Local:   http://localhost:3000/
```

### Step 2: Access Dashboards

#### Admin Dashboard
- **URL**: http://localhost:3000
- **Login**: admin@clinic.rw / Admin@1234
- **Features**:
  - View all pharmacies
  - View all medicines
  - Manage users
  - View diagnoses

#### Pharmacy Portal
- **URL**: http://localhost:3000/pharmacy-portal
- **Login**: Create pharmacist user first
- **Features**:
  - Register pharmacy
  - Add medicines
  - View prescriptions

### Step 3: Run Flutter App

```bash
cd ai_health_companion
flutter pub get
flutter run

# Or for specific device:
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

---

## 🔑 Default Credentials

### Admin User
```
Email: admin@clinic.rw
Password: Admin@1234
Role: ADMIN
```

### Create Pharmacist User
1. Login as admin
2. Go to "User Management"
3. Click "Add User"
4. Fill details:
   - Email: pharmacist@example.com
   - Password: Pharmacist@123
   - Role: PHARMACIST
5. Click "Create"

### Create Health Worker User
1. Login as admin
2. Go to "User Management"
3. Click "Add User"
4. Fill details:
   - Email: healthworker@example.com
   - Password: Worker@123
   - Role: HEALTH_WORKER
5. Click "Create"

---

## 📱 Complete Diagnosis Flow

### 1. Setup (One-time)

#### A. Register Pharmacy
1. Login as pharmacist
2. Go to "My Pharmacy"
3. Fill pharmacy details:
   - Name: City Pharmacy
   - Address: 123 Main St, Kigali
   - Phone: +250 788 123 456
   - GPS: -1.9441, 30.0619 (Kigali coordinates)
   - Opening Hours: Mon-Sat 8AM-8PM
4. Click "Register"

#### B. Add Medicines
1. Go to "Medicines & Prices"
2. Click "Add Medicine"
3. Add common medicines:
   - Artemether-Lumefantrine (Malaria)
   - Paracetamol (Pain/Fever)
   - Amoxicillin (Antibiotic)
   - ORS (Diarrhea)
4. Set prices and stock quantities

### 2. Create Diagnosis (Flutter App)

#### A. Login as Health Worker
```
Email: healthworker@example.com
Password: Worker@123
```

#### B. Select Patient
1. Tap "AI Diagnosis" from home
2. Search for patient or create new
3. Select patient

#### C. Enter Symptoms
1. Go to "Symptoms" tab
2. Select symptoms:
   - Fever
   - Headache
   - Body aches
   - Chills
3. Add medical history if any

#### D. Record Vital Signs
1. Go to "Vital Signs" tab
2. Enter measurements:
   - Temperature: 38.5°C
   - Blood Pressure: 120/80
   - Heart Rate: 85 bpm
   - Oxygen Saturation: 98%

#### E. Review & Submit
1. Go to "Review" tab
2. Check all information
3. Tap "Run AI Diagnosis"

#### F. View Results
- **AI Predictions**: Top 3 diseases with confidence
- **Selected Diagnosis**: Confirmed disease
- **Prescriptions**: Medications with dosage
- **Nearby Pharmacies**: Pharmacies with medicines
  - Distance from patient
  - Available medicines
  - Stock quantity
  - Prices
  - Call button
  - Navigate button

### 3. View Prescription (Pharmacy Portal)

1. Login as pharmacist
2. Go to "Prescriptions" tab
3. See patient diagnosis
4. View prescribed medicines
5. Check inventory
6. Prepare medicines
7. Call patient when ready

---

## 🧪 Testing Scenarios

### Scenario 1: Malaria Diagnosis
```
Symptoms: Fever, Headache, Chills, Body aches
Vital Signs: Temperature 38.5°C
Expected: Malaria diagnosis
Prescription: Artemether-Lumefantrine
```

### Scenario 2: Common Cold
```
Symptoms: Cough, Sore throat, Runny nose
Vital Signs: Temperature 37.2°C
Expected: Common Cold diagnosis
Prescription: Paracetamol, Rest
```

### Scenario 3: Hypertension
```
Symptoms: Headache, Dizziness
Vital Signs: BP 150/95, Heart Rate 90
Expected: Hypertension diagnosis
Prescription: Antihypertensive medication
```

---

## 🔧 API Testing

### Test AI Diagnosis API

```bash
# 1. Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "healthworker@example.com",
    "password": "Worker@123"
  }'

# Save the token from response

# 2. Create Diagnosis
curl -X POST http://localhost:5000/api/v1/diagnosis \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "patientId": "patient-id",
    "symptoms": [
      {"name": "fever", "severity": "moderate"},
      {"name": "headache", "severity": "mild"}
    ],
    "vitalSigns": {
      "temperature": 38.5,
      "heartRate": 85
    },
    "age": 30,
    "gender": "male"
  }'

# 3. Find Nearby Pharmacies
curl -X GET "http://localhost:5000/api/v1/pharmacy-manager/nearby?latitude=-1.9441&longitude=30.0619&medicineName=Artemether-Lumefantrine" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 Service URLs

### Backend Services
- **Node.js API**: http://localhost:5000
- **API Docs**: http://localhost:5000/api-docs
- **Health Check**: http://localhost:5000/health
- **Flask ML**: http://localhost:5001
- **ML Health**: http://localhost:5001/health

### Frontend Services
- **Admin Dashboard**: http://localhost:3000
- **Pharmacy Portal**: http://localhost:3000/pharmacy-portal

### Database
- **PostgreSQL**: Check .env for DATABASE_URL

---

## 🐛 Troubleshooting

### Backend Won't Start

**Problem**: Port already in use
```bash
# Find process using port 5000
lsof -i :5000  # Mac/Linux
netstat -ano | findstr :5000  # Windows

# Kill process
kill -9 PID  # Mac/Linux
taskkill /PID PID /F  # Windows
```

**Problem**: Database connection failed
```bash
# Check DATABASE_URL in .env
# Verify PostgreSQL is running
# Test connection:
psql $DATABASE_URL -c "SELECT 1;"
```

### Flask ML Service Issues

**Problem**: Model not found
```bash
cd model-training
python main.py  # Train model first
```

**Problem**: TensorFlow errors
```bash
# See model-training/PYTHON_VERSION_FIX.md
pip install --upgrade scikit-learn
```

### Admin Dashboard Issues

**Problem**: Login fails
```bash
# Create admin user
cd ai_health_companion_backend
npm run seed:admin
```

**Problem**: API calls fail
- Check backend is running on port 5000
- Check CORS settings in backend .env
- Check browser console for errors

### Flutter App Issues

**Problem**: Location permission denied
- Enable location in device settings
- Grant permission when prompted
- Check AndroidManifest.xml / Info.plist

**Problem**: API calls fail
- Check backend URL in app constants
- Verify network connectivity
- Check API token is valid

**Problem**: Dependencies error
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
AI_health/
├── ai_health_companion_backend/     # Node.js Backend
│   ├── src/
│   │   ├── controllers/             # API controllers
│   │   ├── models/                  # Database models
│   │   ├── routes/                  # API routes
│   │   └── services/                # Business logic
│   ├── model-training/              # Flask ML Service
│   │   ├── api.py                   # Flask API
│   │   ├── model/                   # Trained models
│   │   └── requirements.txt
│   └── .env                         # Environment variables
│
├── admin_dashboard/                 # React Admin Dashboard
│   ├── src/
│   │   ├── pages/                   # Dashboard pages
│   │   ├── components/              # React components
│   │   └── lib/                     # Utilities
│   └── package.json
│
└── ai_health_companion/             # Flutter Mobile App
    ├── lib/
    │   ├── features/
    │   │   ├── diagnosis/           # Diagnosis feature
    │   │   ├── pharmacy/            # Pharmacy feature
    │   │   └── auth/                # Authentication
    │   ├── core/                    # Core utilities
    │   └── shared/                  # Shared widgets
    └── pubspec.yaml
```

---

## 🎯 Key Features

### ✅ Implemented
- AI-powered disease diagnosis
- Prescription management
- Pharmacy finder with medicine availability
- Admin dashboard
- Pharmacist portal
- Mobile app with location services
- Call/Navigate to pharmacy
- Real-time stock checking
- Multi-user roles (Admin, Pharmacist, Health Worker)

### ⏳ In Progress
- Enhanced result page UI
- Offline mode
- Push notifications
- Analytics dashboard

---

## 📞 Support

### Documentation
- `PROJECT_COMPLETION_SUMMARY.md` - Complete feature list
- `FLUTTER_IMPLEMENTATION_COMPLETE.md` - Flutter implementation
- `START_SERVICES.md` - Detailed service startup
- `ADMIN_CREDENTIALS.md` - Admin user guide

### Common Issues
- Check all services are running
- Verify database connection
- Check environment variables
- Review logs for errors

---

## 🎉 Success Checklist

- [ ] Backend services running (Node.js + Flask)
- [ ] Admin dashboard accessible
- [ ] Admin user can login
- [ ] Pharmacist user created
- [ ] Pharmacy registered
- [ ] Medicines added to pharmacy
- [ ] Flutter app running
- [ ] Health worker can login
- [ ] Patient selected
- [ ] Symptoms entered
- [ ] AI diagnosis runs successfully
- [ ] Prescriptions displayed
- [ ] Nearby pharmacies found
- [ ] Medicine availability shown
- [ ] Call/Navigate buttons work
- [ ] Pharmacist can view prescriptions

---

**Status**: Ready for Testing ✅
**Date**: 2026-05-05
**Version**: 1.0.0

---

## 🚀 Next Steps

1. **Test Complete Flow**
   - Create diagnosis
   - View results
   - Find pharmacies
   - Test call/navigate

2. **Add Sample Data**
   - Create multiple pharmacies
   - Add various medicines
   - Create test patients

3. **UI Enhancement**
   - Polish result page
   - Add animations
   - Improve error messages

4. **Production Deployment**
   - Build for production
   - Deploy backend
   - Deploy dashboards
   - Publish mobile app

**Happy Testing! 🎊**
