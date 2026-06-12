# Mbaza Translation Service Startup Integration

## Summary
Added Mbaza NLP Translation Service to the `start-all-services` scripts to automatically start the translation service alongside other application services.

## Changes Made

### 1. PowerShell Script (`start-all-services.ps1`)
- Added check for `mbaza` directory existence
- Starts Mbaza service as a background job on port 9000
- Includes 15-second wait for NLP model loading
- Monitors Mbaza job status for failures
- Logs output to `logs/mbaza.log`

### 2. Batch Script (`start-all-services.bat`)
- Added check for `mbaza` directory existence
- Opens Mbaza service in a separate command window
- Includes 15-second wait for NLP model loading
- Logs to console in the dedicated window

### 3. Bash Script (`start-all-services.sh`)
- Added check for `mbaza` directory existence
- Starts Mbaza as background process
- Includes 15-second wait for NLP model loading
- Logs output to `logs/mbaza.log`

## Service Startup Order

1. **Mbaza Translation Service** (port 9000)
   - Loads first because other services depend on it
   - 15-second delay for model initialization
   
2. **Python ML API** (port 5001)
   - Starts after Mbaza is ready
   
3. **Backend Server** (port 5000)
   - Starts after ML API
   
4. **Admin Dashboard** (port 3000)
   - Starts after backend
   
5. **Clinic Dashboard** (port 5175)
   - Starts after backend

## Service Information

**Mbaza Translation Service:**
- **Port:** 9000
- **Endpoints:**
  - `POST /translate` - Single text translation
  - `POST /translate/batch` - Batch translation (multiple texts)
  - `GET /health` - Health check
- **Command:** `python app_optimized.py`
- **Directory:** `mbaza/`
- **Log File:** `logs/mbaza.log`

## Model Loading Time

The Mbaza NLP model takes approximately **10-20 seconds** to load into memory on startup. The scripts include a 15-second wait to ensure the service is ready before starting dependent services.

## Usage

### Windows (PowerShell)
```powershell
.\start-all-services.ps1
```

### Windows (Command Prompt)
```bat
start-all-services.bat
```

### Linux/Mac
```bash
./start-all-services.sh
```

## Viewing Logs

### PowerShell
```powershell
Get-Content logs\mbaza.log -Wait
```

### Bash
```bash
tail -f logs/mbaza.log
```

## Stopping Services

### PowerShell
```powershell
.\stop-all-services.ps1
```

### Batch
Close the individual command windows

### Bash
Press `Ctrl+C` to stop all services

## Error Handling

If Mbaza service fails to start:
1. Check that Python is installed and in PATH
2. Verify `mbaza` directory exists
3. Ensure required Python packages are installed
4. Check `logs/mbaza.log` for error messages
5. Verify port 9000 is not already in use

## Benefits

✅ **Automatic Startup** - No need to manually start Mbaza in a separate terminal
✅ **Proper Sequencing** - Services start in correct dependency order
✅ **Centralized Logging** - All logs in one `logs/` directory
✅ **Error Monitoring** - Failed services are detected and reported
✅ **Cross-Platform** - Works on Windows, Linux, and Mac

## Related Files

- `mbaza/app_optimized.py` - Mbaza translation service
- `ai_health_companion_backend/src/services/translation.service.ts` - Translation client
- `ai_health_companion_backend/src/controllers/translation.controller.ts` - API endpoints
- `BATCH_API_IMPLEMENTATION.md` - Batch translation documentation
