# Stop All Services Script (PowerShell)
# This script stops all running background jobs for the services

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Stopping All Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get all running jobs
$jobs = Get-Job

if ($jobs.Count -eq 0) {
    Write-Host "No background jobs found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If services are running in separate terminals, close those terminals." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($jobs.Count) background job(s):" -ForegroundColor White
$jobs | Format-Table -Property Id, Name, State

Write-Host ""
Write-Host "Stopping jobs..." -ForegroundColor Yellow

# Stop all jobs
$jobs | Stop-Job

# Remove all jobs
$jobs | Remove-Job -Force

Write-Host ""
Write-Host "✅ All background jobs stopped and removed." -ForegroundColor Green
Write-Host ""

# Also try to kill processes by port (in case they're still running)
Write-Host "Checking for processes on ports 3000, 5173, 5175..." -ForegroundColor Yellow

$ports = @(3000, 5173, 5175)

foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    
    if ($connection) {
        $processId = $connection.OwningProcess
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        
        if ($process) {
            Write-Host "  Killing process on port ${port}: $($process.ProcessName) (PID: $processId)" -ForegroundColor Yellow
            Stop-Process -Id $processId -Force
        }
    }
}

Write-Host ""
Write-Host "✅ All services stopped." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
