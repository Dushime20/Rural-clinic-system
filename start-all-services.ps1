# Start All Services Script (PowerShell)
# This script starts backend, admin dashboard, and clinic dashboard concurrently
# Flutter app needs to be started separately: cd ai_health_companion; flutter run

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting All Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if required directories exist
if (-not (Test-Path "ai_health_companion_backend")) {
    Write-Host "❌ Error: ai_health_companion_backend directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "admin_dashboard")) {
    Write-Host "❌ Error: admin_dashboard directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "clinic_dashboard")) {
    Write-Host "❌ Error: clinic_dashboard directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "ai_health_companion_backend\model-training")) {
    Write-Host "❌ Error: ai_health_companion_backend\model-training directory not found" -ForegroundColor Red
    exit 1
}

# Create logs directory if it doesn't exist
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

Write-Host "📦 Installing dependencies if needed..." -ForegroundColor Yellow
Write-Host ""

# Install backend dependencies if needed
if (-not (Test-Path "ai_health_companion_backend\node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    Push-Location ai_health_companion_backend
    npm install
    Pop-Location
}

# Install admin dashboard dependencies if needed
if (-not (Test-Path "admin_dashboard\node_modules")) {
    Write-Host "Installing admin dashboard dependencies..." -ForegroundColor Yellow
    Push-Location admin_dashboard
    npm install
    Pop-Location
}

# Install clinic dashboard dependencies if needed
if (-not (Test-Path "clinic_dashboard\node_modules")) {
    Write-Host "Installing clinic dashboard dependencies..." -ForegroundColor Yellow
    Push-Location clinic_dashboard
    npm install
    Pop-Location
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting services..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Start Python ML API
Write-Host "🚀 Starting Python ML API (http://localhost:5001)..." -ForegroundColor Green
$mlJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\ai_health_companion_backend\model-training
    python api.py 2>&1 | Out-File -FilePath ..\..\logs\ml-api.log -Append
}
Write-Host "   ML API Job ID: $($mlJob.Id)" -ForegroundColor Gray
Write-Host "   Logs: logs\ml-api.log" -ForegroundColor Gray

# Wait a moment for ML API to start
Start-Sleep -Seconds 2

# Start backend server
Write-Host ""
Write-Host "🚀 Starting Backend Server (http://localhost:5000)..." -ForegroundColor Green
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\ai_health_companion_backend
    npm run dev 2>&1 | Out-File -FilePath ..\logs\backend.log -Append
}
Write-Host "   Backend Job ID: $($backendJob.Id)" -ForegroundColor Gray
Write-Host "   Logs: logs\backend.log" -ForegroundColor Gray

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Start admin dashboard
Write-Host ""
Write-Host "🚀 Starting Admin Dashboard (http://localhost:3000)..." -ForegroundColor Green
$adminJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\admin_dashboard
    npm run dev 2>&1 | Out-File -FilePath ..\logs\admin-dashboard.log -Append
}
Write-Host "   Admin Dashboard Job ID: $($adminJob.Id)" -ForegroundColor Gray
Write-Host "   Logs: logs\admin-dashboard.log" -ForegroundColor Gray

# Start clinic dashboard
Write-Host ""
Write-Host "🚀 Starting Clinic Dashboard (http://localhost:5175)..." -ForegroundColor Green
$clinicJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\clinic_dashboard
    npm run dev 2>&1 | Out-File -FilePath ..\logs\clinic-dashboard.log -Append
}
Write-Host "   Clinic Dashboard Job ID: $($clinicJob.Id)" -ForegroundColor Gray
Write-Host "   Logs: logs\clinic-dashboard.log" -ForegroundColor Gray

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ All services started successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services running:" -ForegroundColor White
Write-Host "  • Python ML API:    http://localhost:5001" -ForegroundColor White
Write-Host "  • Backend:          http://localhost:5000" -ForegroundColor White
Write-Host "  • Admin Dashboard:  http://localhost:3000" -ForegroundColor White
Write-Host "  • Clinic Dashboard: http://localhost:5175" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  • ML API:           Get-Content logs\ml-api.log -Wait" -ForegroundColor Gray
Write-Host "  • Backend:          Get-Content logs\backend.log -Wait" -ForegroundColor Gray
Write-Host "  • Admin Dashboard:  Get-Content logs\admin-dashboard.log -Wait" -ForegroundColor Gray
Write-Host "  • Clinic Dashboard: Get-Content logs\clinic-dashboard.log -Wait" -ForegroundColor Gray
Write-Host ""
Write-Host "To start Flutter app (in new terminal):" -ForegroundColor Yellow
Write-Host "  cd ai_health_companion; flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "To stop all services, run:" -ForegroundColor Yellow
Write-Host "  .\stop-all-services.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to exit (services will continue running in background)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Keep script running and show job status
Write-Host ""
Write-Host "Monitoring services... (Press Ctrl+C to exit)" -ForegroundColor Yellow
Write-Host ""

try {
    while ($true) {
        Start-Sleep -Seconds 5
        
        # Check job statuses
        $mlStatus = (Get-Job -Id $mlJob.Id).State
        $backendStatus = (Get-Job -Id $backendJob.Id).State
        $adminStatus = (Get-Job -Id $adminJob.Id).State
        $clinicStatus = (Get-Job -Id $clinicJob.Id).State
        
        # If any job fails, show error
        if ($mlStatus -eq "Failed") {
            Write-Host "❌ ML API service failed! Check logs\ml-api.log" -ForegroundColor Red
            Receive-Job -Id $mlJob.Id
        }
        if ($backendStatus -eq "Failed") {
            Write-Host "❌ Backend service failed! Check logs\backend.log" -ForegroundColor Red
            Receive-Job -Id $backendJob.Id
        }
        if ($adminStatus -eq "Failed") {
            Write-Host "❌ Admin Dashboard failed! Check logs\admin-dashboard.log" -ForegroundColor Red
            Receive-Job -Id $adminJob.Id
        }
        if ($clinicStatus -eq "Failed") {
            Write-Host "❌ Clinic Dashboard failed! Check logs\clinic-dashboard.log" -ForegroundColor Red
            Receive-Job -Id $clinicJob.Id
        }
    }
}
finally {
    Write-Host ""
    Write-Host "Script exited. Services are still running in background." -ForegroundColor Yellow
    Write-Host "To stop services, run: .\stop-all-services.ps1" -ForegroundColor Yellow
}
