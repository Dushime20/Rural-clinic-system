# Quick Start Guide - All Services

## 🚀 Start All Services with One Command

### Option 1: Batch File (Simplest for Windows)

**Double-click the file or run:**
```cmd
start-all-services.bat
```

This opens each service in a **separate window**. Easy to see logs for each service!

### Option 2: PowerShell (Runs in Background)

**Start all services:**
```powershell
.\start-all-services.ps1
```

**Stop all services:**
```powershell
.\stop-all-services.ps1
```

### Option 3: Bash (Git Bash or WSL)

**Make script executable (first time only):**
```bash
chmod +x start-all-services.sh
```

**Start all services:**
```bash
./start-all-services.sh
```

**Stop all services:**
```bash
# Press Ctrl+C in the terminal running the script
```

---

## 📦 What Gets Started

When you run the start script, it will automatically:

1. ✅ Check if dependencies are installed (runs `npm install` if needed)
2. ✅ Start **Python ML API** on http://localhost:5001
3. ✅ Start **Backend Server** on http://localhost:5000
4. ✅ Start **Admin Dashboard** on http://localhost:3000
5. ✅ Start **Clinic Dashboard** on http://localhost:5175
6. ✅ Create log files in `logs/` directory

---

## 📱 Starting Flutter App

**The Flutter app must be started separately in a new terminal:**

```bash
cd ai_health_companion
flutter run
```

Or for specific device:
```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run -d android     # Android device/emulator
flutter run -d ios         # iOS device/simulator
```

---

## 📋 Log Files

All service logs are saved to the `logs/` directory:

- `logs/ml-api.log` - Python ML API logs
- `logs/backend.log` - Backend server logs
- `logs/admin-dashboard.log` - Admin dashboard logs
- `logs/clinic-dashboard.log` - Clinic dashboard logs

### View Logs in Real-Time

**PowerShell:**
```powershell
Get-Content logs\ml-api.log -Wait
Get-Content logs\backend.log -Wait
Get-Content logs\admin-dashboard.log -Wait
Get-Content logs\clinic-dashboard.log -Wait
```

**Bash:**
```bash
tail -f logs/ml-api.log
tail -f logs/backend.log
tail -f logs/admin-dashboard.log
tail -f logs/clinic-dashboard.log
```

---

## 🔧 Troubleshooting

### Port Already in Use

If you get an error that a port is already in use:

**PowerShell:**
```powershell
# Find process using port 3000 (or 5000, 5001, 5175)
Get-NetTCPConnection -LocalPort 3000 | Select-Object -Property OwningProcess
# Kill the process
Stop-Process -Id <ProcessId> -Force
```

**Bash:**
```bash
# Find process using port 3000
netstat -ano | findstr :3000
# Kill the process
taskkill /PID <ProcessId> /F
```

### Services Won't Start

1. **Check Node.js is installed:**
   ```bash
   node --version
   npm --version
   ```

2. **Manually install dependencies:**
   ```bash
   cd ai_health_companion_backend && npm install && cd ..
   cd admin_dashboard && npm install && cd ..
   cd clinic_dashboard && npm install && cd ..
   ```

3. **Check environment variables:**
   - Backend: `ai_health_companion_backend/.env`
   - Admin: `admin_dashboard/.env`
   - Clinic: `clinic_dashboard/.env`

### PowerShell Execution Policy Error

If you get an execution policy error on Windows:

```powershell
# Check current policy
Get-ExecutionPolicy

# Allow scripts for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass (one-time)
powershell -ExecutionPolicy Bypass -File .\start-all-services.ps1
```

---

## 📊 Service URLs

After starting all services:

| Service | URL | Purpose |
|---------|-----|---------|
| **Python ML API** | http://localhost:5001 | Disease prediction ML service |
| **Backend API** | http://localhost:5000 | REST API endpoints |
| **Admin Dashboard** | http://localhost:3000 | Admin clinic management |
| **Clinic Dashboard** | http://localhost:5175 | Clinic user management |
| **Flutter App** | Various | Mobile/web app (start separately) |

---

## 🧪 Ready for Testing

Once all services are running:

1. ✅ Open **Admin Dashboard**: http://localhost:3000
2. ✅ Login with admin credentials
3. ✅ Create a test clinic
4. ✅ Open **Clinic Dashboard**: http://localhost:5175
5. ✅ Login with clinic credentials
6. ✅ Start **Flutter app** and test patient flows

Refer to **MANUAL_TESTING_GUIDE.md** for detailed testing instructions.

---

## 🛑 Stopping Services

### Batch File
Close each command window individually, or close all at once.

### PowerShell
```powershell
.\stop-all-services.ps1
```

### Bash
Press `Ctrl+C` in the terminal running `start-all-services.sh`

---

## 💡 Tips

**Run in Background (PowerShell):**
- Services run as PowerShell background jobs
- You can close the terminal and services continue running
- Use `stop-all-services.ps1` to stop them later

**Run in Foreground (Bash):**
- Keep the terminal open to see live output
- Press `Ctrl+C` to stop all services
- Check log files for detailed output

**Multiple Terminals:**
If you prefer separate terminals for each service:
```bash
# Terminal 1
cd ai_health_companion_backend/model-training && python api.py

# Terminal 2
cd ai_health_companion_backend && npm run dev

# Terminal 3  
cd admin_dashboard && npm run dev

# Terminal 4
cd clinic_dashboard && npm run dev

# Terminal 5
cd ai_health_companion && flutter run
```

---

## ✅ Quick Reference

```cmd
REM Batch File (Windows) - Simplest Option!
start-all-services.bat            REM Start all services (separate windows)
REM Close windows to stop
```

```powershell
# PowerShell (Windows) - Background Jobs
.\start-all-services.ps1          # Start all services
.\stop-all-services.ps1           # Stop all services
Get-Content logs\backend.log -Wait # View backend logs
```

```bash
# Bash (Git Bash / WSL)
./start-all-services.sh           # Start all services
# Press Ctrl+C to stop
tail -f logs/backend.log          # View backend logs
```

```bash
# Flutter (separate terminal)
cd ai_health_companion
flutter run
```

---

**Happy Testing! 🚀**
