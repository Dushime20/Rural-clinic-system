# Quick Start: Translation Cache

## ⚡ 3-Step Setup (15-30 minutes)

### Step 1: Install Dependencies (30 seconds)

```bash
cd ai_health_companion_backend
npm install csv-parser
```

### Step 2: Start Mbaza & Generate Cache (15-30 minutes)

```bash
# Terminal 1: Start Mbaza
cd mbaza
python app_optimized.py

# Terminal 2: Generate translations
cd ai_health_companion_backend
npm run translate-diseases
```

**Wait for completion** - you'll see:
```
✅ Translation complete!
📄 Saved to: .../data/disease-translations-kinyarwanda.json
📊 Total diseases translated: 40
```

### Step 3: Test & Run (1 minute)

```bash
# Test cache
node test-translation-cache.js
# Should show: ✅ All tests passed!

# Start backend
npm run dev
# Should show: ✅ Loaded translation cache: 40 diseases
```

---

## ✅ Verify It Works

### Check in Logs
Server startup should show:
```
✅ Loaded translation cache: 40 diseases (Generated: ...)
```

### Test API Endpoint
```bash
curl http://localhost:8000/api/v1/diagnosis/translation/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Response should show:
```json
{
  "success": true,
  "translationCache": {
    "status": "loaded",
    "totalDiseases": 40,
    "message": "Instant translations available"
  }
}
```

### Test in App
1. Set language to Kinyarwanda in Flutter app
2. View a diagnosis result
3. Should load **instantly** (< 1 second instead of 2-3 minutes!)

---

## 🎉 Done!

Translation time reduced from **2-3 minutes → < 100ms** (1800x faster!)

For detailed docs, see: `TRANSLATION_CACHE_GUIDE.md`
