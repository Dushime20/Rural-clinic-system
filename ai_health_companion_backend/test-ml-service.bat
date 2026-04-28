@echo off
REM AI/ML Service Test Script for Windows
REM Tests the Flask ML service endpoints

echo.
echo ========================================
echo   Testing AI/ML Model Service
echo ========================================
echo.

set FLASK_URL=http://localhost:5001

REM Test 1: Health Check
echo 1. Testing Health Check...
curl -s %FLASK_URL%/health
if %ERRORLEVEL% EQU 0 (
    echo [OK] Health check passed
) else (
    echo [FAIL] Health check failed
    exit /b 1
)
echo.

REM Test 2: Get Symptoms
echo 2. Testing Get Symptoms...
curl -s %FLASK_URL%/api/v1/symptoms > temp_symptoms.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Got symptoms list
    type temp_symptoms.json
    del temp_symptoms.json
) else (
    echo [FAIL] Get symptoms failed
)
echo.

REM Test 3: Get Diseases
echo 3. Testing Get Diseases...
curl -s %FLASK_URL%/api/v1/diseases > temp_diseases.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Got diseases list
    type temp_diseases.json
    del temp_diseases.json
) else (
    echo [FAIL] Get diseases failed
)
echo.

REM Test 4: Simple Prediction
echo 4. Testing Disease Prediction...
curl -s -X POST %FLASK_URL%/api/v1/predict ^
  -H "Content-Type: application/json" ^
  -d "{\"symptoms\": [\"fever\", \"cough\", \"headache\"]}" > temp_prediction.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Prediction successful
    type temp_prediction.json
    del temp_prediction.json
) else (
    echo [FAIL] Prediction failed
)
echo.

REM Test 5: Prediction with Vital Signs
echo 5. Testing Prediction with Vital Signs...
curl -s -X POST %FLASK_URL%/api/v1/predict ^
  -H "Content-Type: application/json" ^
  -d "{\"symptoms\": [\"high fever\", \"chills\", \"sweating\"], \"vitalSigns\": {\"temperature\": 39.5, \"heartRate\": 105}, \"demographics\": {\"age\": 35}}" > temp_vitals.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Prediction with vitals successful
    type temp_vitals.json
    del temp_vitals.json
) else (
    echo [FAIL] Prediction with vitals failed
)
echo.

REM Test 6: Symptom Validation
echo 6. Testing Symptom Validation...
curl -s -X POST %FLASK_URL%/api/v1/validate-symptoms ^
  -H "Content-Type: application/json" ^
  -d "{\"symptoms\": [\"fver\", \"coff\", \"hedache\"]}" > temp_validation.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Symptom validation successful
    type temp_validation.json
    del temp_validation.json
) else (
    echo [FAIL] Symptom validation failed
)
echo.

echo ========================================
echo   All tests completed!
echo ========================================
echo.
echo Next steps:
echo   1. Check that all tests passed [OK]
echo   2. Review the prediction results
echo   3. Test from Node.js backend
echo.

pause
