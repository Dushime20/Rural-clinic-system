@echo off
REM Start All Services Script (Batch)
REM This script starts backend, admin dashboard, and clinic dashboard in separate windows

echo ==========================================
echo Starting All Services
echo ==========================================
echo.

REM Check if required directories exist
if not exist "ai_health_companion_backend" (
    echo Error: ai_health_companion_backend directory not found
    pause
    exit /b 1
)

if not exist "admin_dashboard" (
    echo Error: admin_dashboard directory not found
    pause
    exit /b 1
)

if not exist "clinic_dashboard" (
    echo Error: clinic_dashboard directory not found
    pause
    exit /b 1
)

if not exist "ai_health_companion_backend\model-training" (
    echo Error: ai_health_companion_backend\model-training directory not found
    pause
    exit /b 1
)

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

echo Installing dependencies if needed...
echo.

REM Install backend dependencies if needed
if not exist "ai_health_companion_backend\node_modules" (
    echo Installing backend dependencies...
    cd ai_health_companion_backend
    call npm install
    cd ..
)

REM Install admin dashboard dependencies if needed
if not exist "admin_dashboard\node_modules" (
    echo Installing admin dashboard dependencies...
    cd admin_dashboard
    call npm install
    cd ..
)

REM Install clinic dashboard dependencies if needed
if not exist "clinic_dashboard\node_modules" (
    echo Installing clinic dashboard dependencies...
    cd clinic_dashboard
    call npm install
    cd ..
)

echo.
echo ==========================================
echo Starting services in separate windows...
echo ==========================================
echo.

REM Start Python ML API in new window
echo Starting Python ML API (http://localhost:5001)...
start "Python ML API" cmd /k "cd ai_health_companion_backend\model-training && python api.py"

REM Wait a moment for ML API to start
timeout /t 2 /nobreak >nul

REM Start backend server in new window
echo Starting Backend Server (http://localhost:5000)...
start "Backend Server" cmd /k "cd ai_health_companion_backend && npm run dev"

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

REM Start admin dashboard in new window
echo Starting Admin Dashboard (http://localhost:3000)...
start "Admin Dashboard" cmd /k "cd admin_dashboard && npm run dev"

REM Start clinic dashboard in new window
echo Starting Clinic Dashboard (http://localhost:5175)...
start "Clinic Dashboard" cmd /k "cd clinic_dashboard && npm run dev"

echo.
echo ==========================================
echo All services started successfully!
echo ==========================================
echo.
echo Services running in separate windows:
echo   - Python ML API:    http://localhost:5001
echo   - Backend:          http://localhost:5000
echo   - Admin Dashboard:  http://localhost:3000
echo   - Clinic Dashboard: http://localhost:5175
echo.
echo To start Flutter app (in new terminal):
echo   cd ai_health_companion
echo   flutter run
echo.
echo To stop services: Close the individual command windows
echo ==========================================
echo.
pause
