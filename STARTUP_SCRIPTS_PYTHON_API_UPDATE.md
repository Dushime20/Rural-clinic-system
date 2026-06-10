# Startup Scripts - Python ML API Added

## Update Summary
Updated all startup scripts to include the Python ML API service that runs the machine learning prediction model.

## Changes Made

### 1. start-all-services.bat (Windows Batch)
**Added**:
- Check for `ai_health_companion_backend\model-training` directory
- Start Python ML API first: `python api.py` in `ai_health_companion_backend\model-training`
- Opens in separate window titled "Python ML API"
- Added to service list display

**Port**: 5001

### 2. start-all-services.ps1 (PowerShell)
**Added**:
- Check for `ai_health_companion_backend\model-training` directory
- Start Python ML API as background job
- Logs to `logs\ml-api.log`
- Added ML API status monitoring
- Added to service list and log viewing instructions

**Port**: 5001

## Service Startup Order

The scripts now start services in this order:

1. **Python ML API** (port 5001) - 2 seconds startup wait
   - Directory: `ai_health_companion_backend/model-training`
   - Command: `python api.py`
   - Purpose: Machine learning disease prediction service

2. **Backend Server** (port 5000) - 3 seconds startup wait
   - Directory: `ai_health_companion_backend`
   - Command: `npm run dev`
   - Purpose: Main Node.js/TypeScript API

3. **Admin Dashboard** (port 3000)
   - Directory: `admin_dashboard`
   - Command: `npm run dev`
   - Purpose: Admin web interface (React + Vite)

4. **Clinic Dashboard** (port 5175)
   - Directory: `clinic_dashboard`
   - Command: `npm run dev`
   - Purpose: Clinic web interface (React + Vite)

## Usage

### Windows Batch (Simplest):
```bash
start-all-services.bat
```

### PowerShell (Background Jobs):
```powershell
.\start-all-services.ps1
```

### Stop PowerShell Services:
```powershell
.\stop-all-services.ps1
```

## Requirements

### Python Environment:
- Python 3.x installed and in PATH
- Required packages (should be installed):
  - flask
  - flask-cors
  - numpy
  - pandas
  - scikit-learn
  - fuzzywuzzy

### Node.js Environment:
- Node.js and npm installed
- Dependencies auto-installed by scripts if `node_modules` missing

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Python ML API | http://localhost:5001 | Disease prediction |
| Backend | http://localhost:5000 | Main API |
| Admin Dashboard | http://localhost:3000 | Admin interface |
| Clinic Dashboard | http://localhost:5175 | Clinic interface |

## Logs (PowerShell only)

View logs in real-time:
```powershell
# ML API logs
Get-Content logs\ml-api.log -Wait

# Backend logs
Get-Content logs\backend.log -Wait

# Admin Dashboard logs
Get-Content logs\admin-dashboard.log -Wait

# Clinic Dashboard logs
Get-Content logs\clinic-dashboard.log -Wait
```

## Flutter App

Still needs to be started separately:
```bash
cd ai_health_companion
flutter run
```

---
**Date**: June 9, 2026
**Status**: Ready for use
