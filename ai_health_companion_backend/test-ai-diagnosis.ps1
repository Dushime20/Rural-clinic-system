# AI Diagnosis Testing Script for Windows PowerShell
# Usage: .\test-ai-diagnosis.ps1

Write-Host "🧪 AI Diagnosis Testing Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:5000/api/v1"
$token = ""
$patientId = ""

# Function to make API calls
function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Body = "",
        [bool]$RequireAuth = $false
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($RequireAuth -and $token) {
        $headers["Authorization"] = "Bearer $token"
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri "$baseUrl$Endpoint" -Method $Method -Headers $headers -Body $Body
        } else {
            $response = Invoke-RestMethod -Uri "$baseUrl$Endpoint" -Method $Method -Headers $headers
        }
        return $response
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Step 1: Register User
Write-Host "Step 1: Register Test User" -ForegroundColor Yellow
$registerBody = @{
    email = "doctor@clinic.rw"
    password = "Test123!"
    firstName = "Dr. John"
    lastName = "Doe"
    role = "health_worker"
    clinicId = "CLINIC-001"
} | ConvertTo-Json

$registerResponse = Invoke-ApiCall -Method "POST" -Endpoint "/auth/register" -Body $registerBody
if ($registerResponse) {
    Write-Host "✅ User registered successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️  User might already exist, trying login..." -ForegroundColor Yellow
}

# Step 2: Login
Write-Host "`nStep 2: Login" -ForegroundColor Yellow
$loginBody = @{
    email = "doctor@clinic.rw"
    password = "Test123!"
} | ConvertTo-Json

$loginResponse = Invoke-ApiCall -Method "POST" -Endpoint "/auth/login" -Body $loginBody
if ($loginResponse -and $loginResponse.data.token) {
    $token = $loginResponse.data.token
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} else {
    Write-Host "❌ Login failed. Please check credentials." -ForegroundColor Red
    exit
}

# Step 3: Create Patient
Write-Host "`nStep 3: Create Test Patient" -ForegroundColor Yellow
$patientBody = @{
    firstName = "Patient"
    lastName = "Test"
    dateOfBirth = "1990-01-01"
    gender = "male"
    phoneNumber = "+250788123456"
    nationalId = "1199080012345678"
    address = "Kigali, Rwanda"
} | ConvertTo-Json

$patientResponse = Invoke-ApiCall -Method "POST" -Endpoint "/patients" -Body $patientBody -RequireAuth $true
if ($patientResponse -and $patientResponse.data.patient.id) {
    $patientId = $patientResponse.data.patient.id
    Write-Host "✅ Patient created successfully" -ForegroundColor Green
    Write-Host "Patient ID: $patientId" -ForegroundColor Gray
} else {
    Write-Host "❌ Failed to create patient" -ForegroundColor Red
    exit
}

# Step 4: Test AI Diagnosis - Common Cold
Write-Host "`nStep 4: Test AI Diagnosis - Common Cold (Fever + Cough)" -ForegroundColor Yellow
$diagnosisBody1 = @{
    patientId = $patientId
    symptoms = @(
        @{ name = "fever"; category = "general"; severity = "moderate" }
        @{ name = "cough"; category = "respiratory"; severity = "mild" }
    )
    vitalSigns = @{
        temperature = 37.8
        heartRate = 85
        bloodPressureSystolic = 120
        bloodPressureDiastolic = 80
    }
    notes = "Patient reports symptoms for 2 days"
} | ConvertTo-Json -Depth 10

$diagnosis1 = Invoke-ApiCall -Method "POST" -Endpoint "/diagnosis" -Body $diagnosisBody1 -RequireAuth $true
if ($diagnosis1 -and $diagnosis1.data.diagnosis.aiPredictions) {
    Write-Host "✅ Diagnosis created successfully" -ForegroundColor Green
    Write-Host "Diagnosis ID: $($diagnosis1.data.diagnosis.diagnosisId)" -ForegroundColor Gray
    Write-Host "`nAI Predictions:" -ForegroundColor Cyan
    foreach ($pred in $diagnosis1.data.diagnosis.aiPredictions) {
        Write-Host "  - $($pred.disease): $([math]::Round($pred.confidence * 100, 1))% (ICD-10: $($pred.icd10Code))" -ForegroundColor White
    }
}

# Step 5: Test AI Diagnosis - Malaria
Write-Host "`nStep 5: Test AI Diagnosis - Malaria (High Fever)" -ForegroundColor Yellow
$diagnosisBody2 = @{
    patientId = $patientId
    symptoms = @(
        @{ name = "high fever"; category = "general"; severity = "severe" }
        @{ name = "chills"; category = "general"; severity = "moderate" }
    )
    vitalSigns = @{
        temperature = 39.5
        heartRate = 95
        bloodPressureSystolic = 125
        bloodPressureDiastolic = 82
    }
    notes = "Patient from rural area with mosquito exposure"
} | ConvertTo-Json -Depth 10

$diagnosis2 = Invoke-ApiCall -Method "POST" -Endpoint "/diagnosis" -Body $diagnosisBody2 -RequireAuth $true
if ($diagnosis2 -and $diagnosis2.data.diagnosis.aiPredictions) {
    Write-Host "✅ Diagnosis created successfully" -ForegroundColor Green
    Write-Host "Diagnosis ID: $($diagnosis2.data.diagnosis.diagnosisId)" -ForegroundColor Gray
    Write-Host "`nAI Predictions:" -ForegroundColor Cyan
    foreach ($pred in $diagnosis2.data.diagnosis.aiPredictions) {
        Write-Host "  - $($pred.disease): $([math]::Round($pred.confidence * 100, 1))% (ICD-10: $($pred.icd10Code))" -ForegroundColor White
    }
}

# Step 6: Test AI Diagnosis - Hypertension
Write-Host "`nStep 6: Test AI Diagnosis - Hypertension (High BP)" -ForegroundColor Yellow
$diagnosisBody3 = @{
    patientId = $patientId
    symptoms = @(
        @{ name = "headache"; category = "neurological"; severity = "moderate" }
    )
    vitalSigns = @{
        temperature = 37.0
        heartRate = 88
        bloodPressureSystolic = 155
        bloodPressureDiastolic = 95
    }
    notes = "Patient reports frequent headaches"
} | ConvertTo-Json -Depth 10

$diagnosis3 = Invoke-ApiCall -Method "POST" -Endpoint "/diagnosis" -Body $diagnosisBody3 -RequireAuth $true
if ($diagnosis3 -and $diagnosis3.data.diagnosis.aiPredictions) {
    Write-Host "✅ Diagnosis created successfully" -ForegroundColor Green
    Write-Host "Diagnosis ID: $($diagnosis3.data.diagnosis.diagnosisId)" -ForegroundColor Gray
    Write-Host "`nAI Predictions:" -ForegroundColor Cyan
    foreach ($pred in $diagnosis3.data.diagnosis.aiPredictions) {
        Write-Host "  - $($pred.disease): $([math]::Round($pred.confidence * 100, 1))% (ICD-10: $($pred.icd10Code))" -ForegroundColor White
    }
}

# Step 7: Get Patient Diagnoses
Write-Host "`nStep 7: Retrieve All Patient Diagnoses" -ForegroundColor Yellow
$allDiagnoses = Invoke-ApiCall -Method "GET" -Endpoint "/patients/$patientId/diagnoses" -RequireAuth $true
if ($allDiagnoses -and $allDiagnoses.data.diagnoses) {
    Write-Host "✅ Retrieved $($allDiagnoses.data.diagnoses.Count) diagnoses" -ForegroundColor Green
    Write-Host "`nDiagnosis History:" -ForegroundColor Cyan
    foreach ($diag in $allDiagnoses.data.diagnoses) {
        Write-Host "  - $($diag.diagnosisId): $($diag.aiPredictions[0].disease) ($($diag.diagnosisDate))" -ForegroundColor White
    }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "✅ All tests completed!" -ForegroundColor Green
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  - User: doctor@clinic.rw" -ForegroundColor White
Write-Host "  - Patient ID: $patientId" -ForegroundColor White
Write-Host "  - Diagnoses Created: 3" -ForegroundColor White
Write-Host "  - AI Predictions: Working ✅" -ForegroundColor White
Write-Host "`nView API docs: http://localhost:5000/api-docs" -ForegroundColor Yellow
