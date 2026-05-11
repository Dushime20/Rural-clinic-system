@echo off
echo Starting AI Health Companion Backend...
echo.
npx ts-node -r reflect-metadata src/server.ts
pause
