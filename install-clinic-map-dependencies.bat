@echo off
REM Install Leaflet Map Dependencies for Clinic Dashboard

echo ==========================================
echo Installing Leaflet Map Dependencies
echo ==========================================
echo.

cd clinic_dashboard

echo Installing leaflet, react-leaflet, and TypeScript types...
call npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8

echo.
echo ==========================================
echo Installation Complete!
echo ==========================================
echo.
echo Next steps:
echo 1. Restart your clinic dashboard dev server
echo 2. Navigate to Profile page
echo 3. Click "Edit Profile" to see the interactive map
echo.
pause
