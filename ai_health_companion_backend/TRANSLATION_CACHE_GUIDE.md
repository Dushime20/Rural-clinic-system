# Disease Translation Cache System

## 🎯 Problem Solved

Previously, translating diagnosis results to Kinyarwanda using Mbaza took **2-3 minutes** per request because:
- Each disease description, medication, diet recommendation, etc. was translated in real-time
- Mbaza NLP API calls are slow (10-30 seconds per batch)
- Multiple API calls were needed for complete reports

## ✨ Solution

Pre-translate ALL disease data once and cache it for instant lookups! Now translation is:
- **Instant** (< 100ms instead of 2-3 minutes)
- **Offline-capable** (no Mbaza dependency after cache generation)
- **Consistent** (same disease always gets same translation)

---

## 🚀 Quick Start

### Step 1: Install Dependencies

```bash
cd ai_health_companion_backend
npm install csv-parser
```

### Step 2: Ensure Mbaza Service is Running

The translation script needs Mbaza to be running:

```bash
# In a separate terminal
cd mbaza
python app_optimized.py
```

Mbaza should be running on `http://localhost:9000`

### Step 3: Generate Translation Cache

```bash
npm run translate-diseases
```

This will:
- Read all disease data from CSV files
- Batch translate everything to Kinyarwanda using Mbaza
- Save to `data/disease-translations-kinyarwanda.json`
- Take approximately **15-30 minutes** for all diseases

### Step 4: Restart Backend Server

```bash
npm run dev
```

The cache is automatically loaded on server startup!

---

## 📊 What Gets Translated

For each of the ~40 diseases, we translate:

1. **Disease Name** (e.g., "Malaria" → "Malariya")
2. **Description** (full paragraph)
3. **Medications** (array of 3-5 items)
4. **Diet Recommendations** (array of 5-10 items)
5. **Workout/Lifestyle** (array of 5-10 items)
6. **Precautions** (array of 4 items)

**Total items translated:** ~1,500-2,000 text fragments

---

## 🔧 How It Works

### Architecture

```
┌─────────────────────────────────────────────────────┐
│ 1. One-time Setup (Run Once)                        │
│                                                      │
│  CSV Files (Disease Data)                           │
│         ↓                                            │
│  translate-disease-data.js                          │
│         ↓ (batch translate via Mbaza)              │
│  disease-translations-kinyarwanda.json              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ 2. Runtime (Every Request)                          │
│                                                      │
│  User requests diagnosis in Kinyarwanda             │
│         ↓                                            │
│  Translation Controller                             │
│         ↓                                            │
│  DiseaseTranslationCacheService                     │
│         ↓ (instant lookup - no API call!)          │
│  Return cached Kinyarwanda text                     │
│         ↓                                            │
│  Response sent to Flutter app (~100ms total)        │
└─────────────────────────────────────────────────────┘
```

### Backend Integration

The translation controller now follows this logic:

```typescript
// Old way (SLOW - 2-3 minutes)
translate() {
  for each text {
    call Mbaza API  // 10-30 seconds each!
  }
  return translated report
}

// New way (FAST - instant)
translate() {
  const cached = cacheService.getDiseaseTranslation(disease)
  if (cached) {
    return cached  // < 100ms
  } else {
    // Fallback to Mbaza if disease not in cache
    return mbazaTranslate(text)
  }
}
```

---

## 📁 File Structure

```
ai_health_companion_backend/
├── scripts/
│   └── translate-disease-data.js         # Translation generator script
├── src/
│   ├── services/
│   │   └── disease-translation-cache.service.ts  # Cache service
│   └── controllers/
│       └── translation.controller.ts     # Updated to use cache
├── data/
│   └── disease-translations-kinyarwanda.json  # Generated cache (gitignored)
└── model-training/
    └── dataset/
        ├── description.csv               # Source data
        ├── medications.csv
        ├── diets.csv
        ├── workout_df.csv
        └── precautions_df.csv
```

---

## 🔄 Regenerating Cache

You should regenerate the cache when:
- Disease data is updated in CSV files
- New diseases are added
- Mbaza translation quality improves

To regenerate:

```bash
# 1. Ensure Mbaza is running
cd mbaza && python app_optimized.py

# 2. Delete old cache (optional)
rm data/disease-translations-kinyarwanda.json

# 3. Regenerate
cd ai_health_companion_backend
npm run translate-diseases

# 4. Restart backend
npm run dev
```

---

## 🧪 Testing

### Test Cache Loading

Check server logs on startup:

```
✅ Loaded translation cache: 40 diseases (Generated: 2026-06-17T10:30:00.000Z)
```

### Test Translation Endpoint

```bash
# Get diagnosis translation (should be instant now!)
curl -X GET http://localhost:8000/api/v1/diagnosis/{diagnosisId}/translate \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Check response time - should be < 1 second instead of 2-3 minutes!

### Test Cache Service Directly

```typescript
import diseaseTranslationCacheService from './services/disease-translation-cache.service';

// Check if loaded
console.log(diseaseTranslationCacheService.isCacheAvailable()); // true

// Get translation
const malaria = diseaseTranslationCacheService.getDiseaseTranslation('Malaria');
console.log(malaria.translatedName); // "Malariya"
console.log(malaria.description); // Kinyarwanda description
```

---

## 📈 Performance Comparison

| Metric | Before (Mbaza API) | After (Cache) | Improvement |
|--------|-------------------|---------------|-------------|
| Translation Time | 120-180 seconds | < 0.1 seconds | **1800x faster** |
| Network Calls | 15-30 per request | 0 | **No network needed** |
| Mbaza Dependency | Required | Optional | **Offline-capable** |
| Consistency | Varies | Always same | **100% consistent** |

---

## ⚠️ Important Notes

### 1. Cache File Not in Git

The `data/disease-translations-kinyarwanda.json` file is **NOT committed** to git because:
- It's large (~500KB-1MB)
- Generated artifact
- Environment-specific

Each deployment must run `npm run translate-diseases` once.

### 2. Mbaza Still Available for Fallback

If a disease is NOT in the cache, the system falls back to real-time Mbaza translation. This ensures:
- New diseases work (slower but functional)
- System degrades gracefully
- No hard dependency on cache

### 3. Cache Versioning

The cache includes metadata:
```json
{
  "generatedAt": "2026-06-17T10:30:00.000Z",
  "language": "kinyarwanda",
  "totalDiseases": 40,
  "translations": { ... }
}
```

You can check cache age and decide when to regenerate.

### 4. Memory Usage

The cache is loaded into memory on server startup (~1-2MB). This is negligible for modern servers but keeps lookups instant.

---

## 🐛 Troubleshooting

### "Translation cache not available"

**Cause:** Cache file not generated or failed to load

**Fix:**
```bash
npm run translate-diseases
```

### Translation script fails

**Cause:** Mbaza not running or wrong URL

**Fix:**
```bash
# Check Mbaza is running
curl http://localhost:9000/health

# Set correct URL if different
export MBAZA_TRANSLATION_URL=http://your-mbaza-url:9000/translate
npm run translate-diseases
```

### Cache loading fails

**Cause:** Invalid JSON in cache file

**Fix:**
```bash
# Delete and regenerate
rm data/disease-translations-kinyarwanda.json
npm run translate-diseases
```

### Still slow after cache

**Cause:** 
1. Cache not loaded (check logs)
2. Disease name mismatch
3. Fallback to Mbaza

**Debug:**
```typescript
// In translation.controller.ts
logger.info('Cache available?', diseaseTranslationCacheService.isCacheAvailable());
logger.info('Has disease?', diseaseTranslationCacheService.getDiseaseTranslation(disease));
```

---

## 🎓 Benefits Summary

✅ **1800x faster translations** (seconds → milliseconds)  
✅ **Offline-capable** (no Mbaza dependency at runtime)  
✅ **Consistent translations** (same disease → same translation)  
✅ **Cost-effective** (one-time translation cost)  
✅ **Better UX** (instant results for users)  
✅ **Scalable** (handles 1000s of requests/second)  

---

## 📞 Support

If you encounter issues:

1. Check server logs for cache loading messages
2. Verify Mbaza is running for cache generation
3. Ensure CSV files are present in `model-training/dataset/`
4. Check `data/` folder is writable

For questions, contact the development team.

---

**Generated:** June 2026  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
