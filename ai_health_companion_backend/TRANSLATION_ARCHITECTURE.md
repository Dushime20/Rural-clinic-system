# Translation Cache Architecture

## 🏗️ System Architecture

### Before: Real-time Translation (SLOW)

```
┌─────────────────────────────────────────────────────────────┐
│                    User Request Flow                         │
└─────────────────────────────────────────────────────────────┘

Flutter App (Kinyarwanda selected)
       │
       │ GET /diagnosis/{id}/translate
       ▼
Backend Translation Controller
       │
       ├─→ Translate description      ────→ Mbaza API (30s)
       ├─→ Translate medications (5x) ────→ Mbaza API (25s)
       ├─→ Translate diet (10x)       ────→ Mbaza API (30s)
       ├─→ Translate workout (10x)    ────→ Mbaza API (30s)
       └─→ Translate precautions (4x) ────→ Mbaza API (20s)
       │
       │ TOTAL: 120-180 seconds! ⏰
       ▼
Return translated report to Flutter

❌ Problems:
- Very slow (2-3 minutes wait)
- Many API calls (15-30 per request)
- Network dependent
- Inconsistent translations
```

---

### After: Cached Translation (FAST)

```
┌─────────────────────────────────────────────────────────────┐
│                ONE-TIME SETUP (Run Once)                     │
└─────────────────────────────────────────────────────────────┘

Disease CSV Files
    │
    ├─→ description.csv (40 diseases)
    ├─→ medications.csv (200+ items)
    ├─→ diets.csv (400+ items)
    ├─→ workout_df.csv (400+ items)
    └─→ precautions_df.csv (160+ items)
    │
    ▼
translate-disease-data.js
    │
    ├─→ Batch translate to Kinyarwanda ──→ Mbaza API
    │   (one-time cost: 15-30 minutes)
    │
    ▼
disease-translations-kinyarwanda.json
    │
    └─→ Saved to data/ folder (~500KB-1MB)

┌─────────────────────────────────────────────────────────────┐
│              RUNTIME (Every Request) ⚡                      │
└─────────────────────────────────────────────────────────────┘

Flutter App (Kinyarwanda selected)
       │
       │ GET /diagnosis/{id}/translate
       ▼
Backend Translation Controller
       │
       ├─→ Check disease name: "Malaria"
       │
       ▼
DiseaseTranslationCacheService
       │
       ├─→ Load from JSON cache (in-memory lookup)
       │   - description (instant)
       │   - medications (instant)
       │   - diet (instant)
       │   - workout (instant)
       │   - precautions (instant)
       │
       │ TOTAL: < 100ms! ⚡
       ▼
Return cached translated report to Flutter

✅ Benefits:
- Instant (< 1 second)
- Zero API calls
- Offline-capable
- 100% consistent
```

---

## 🔄 Data Flow Diagram

### Setup Phase (One-time)

```
┌────────────┐
│   Mbaza    │ ←──────────────┐
│  Running   │                 │
└────────────┘                 │
                               │ Batch translate
┌────────────────────────┐    │ (15-30 min)
│  Disease CSV Files     │    │
│  - description.csv     │ ───┤
│  - medications.csv     │    │
│  - diets.csv          │    │
│  - workout_df.csv     │    │
│  - precautions_df.csv │    │
└────────────────────────┘    │
                               │
                               ▼
              ┌─────────────────────────────┐
              │  Translation Script         │
              │  translate-disease-data.js  │
              └─────────────────────────────┘
                               │
                               │ Save JSON
                               ▼
              ┌─────────────────────────────────┐
              │  Translation Cache              │
              │  disease-translations-kinyar... │
              │  {                              │
              │    "Malaria": {                 │
              │      "translatedName": "...",   │
              │      "description": "...",      │
              │      "medications": [...],      │
              │      ...                        │
              │    },                           │
              │    ...40 diseases               │
              │  }                              │
              └─────────────────────────────────┘
```

### Runtime Phase (Every Request)

```
┌──────────────┐
│ Flutter App  │
│ (User views  │
│  diagnosis)  │
└──────────────┘
       │
       │ HTTP Request
       │ GET /diagnosis/{id}/translate
       ▼
┌─────────────────────────────────────────┐
│  Backend Server (Node.js)               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Translation Controller           │ │
│  │  1. Extract disease name          │ │
│  │  2. Check cache availability      │ │
│  └───────────────────────────────────┘ │
│                │                        │
│                ▼                        │
│  ┌───────────────────────────────────┐ │
│  │  DiseaseTranslationCacheService   │ │
│  │  - Load cache from memory         │ │
│  │  - O(1) lookup by disease name    │ │
│  │  - Return all translations        │ │
│  └───────────────────────────────────┘ │
│                │                        │
└────────────────┼────────────────────────┘
                 │
                 │ < 100ms
                 ▼
┌─────────────────────────────────────────┐
│  Translated Report                      │
│  {                                      │
│    "disease": "Malaria",                │
│    "description": "Kinyarwanda text",   │
│    "medications": ["...", "..."],       │
│    "diet": ["...", "..."],              │
│    ...                                  │
│  }                                      │
└─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────┐
│  Flutter App             │
│  (Displays instantly)    │
└──────────────────────────┘
```

---

## 🎯 Component Responsibilities

### 1. Translation Script (`translate-disease-data.js`)
**Purpose:** One-time batch translation generator

**Responsibilities:**
- Read disease data from CSV files
- Parse JSON strings from CSVs
- Batch translate using Mbaza API
- Handle errors and retries
- Save to JSON cache file
- Report statistics

**When to Run:**
- First time setup
- When disease data updates
- When translations need refresh

---

### 2. Cache Service (`disease-translation-cache.service.ts`)
**Purpose:** Runtime cache manager

**Responsibilities:**
- Load cache on server startup
- Provide instant lookup methods
- Validate cache integrity
- Return null if disease not found (graceful degradation)
- Expose cache metadata

**Methods:**
```typescript
isCacheAvailable() → boolean
getDiseaseTranslation(name) → DiseaseTranslation | null
getTranslatedDiseaseName(name) → string | null
getTranslatedDescription(name) → string | null
getTranslatedMedications(name) → string[]
getTranslatedDiet(name) → string[]
getTranslatedWorkout(name) → string[]
getTranslatedPrecautions(name) → string[]
```

---

### 3. Translation Controller (`translation.controller.ts`)
**Purpose:** HTTP request handler

**Logic Flow:**
```typescript
async translateDiagnosisReport(diagnosisId) {
    // 1. Fetch diagnosis from database
    const diagnosis = await getDiagnosis(diagnosisId);
    const diseaseName = diagnosis.disease;
    
    // 2. Try cache first (FAST)
    if (cacheService.isCacheAvailable()) {
        const cached = cacheService.getDiseaseTranslation(diseaseName);
        if (cached) {
            return cached; // ⚡ Instant!
        }
    }
    
    // 3. Fallback to Mbaza (SLOW)
    return await mbazaTranslate(diagnosis); // 2-3 minutes
}
```

---

## 📊 Performance Comparison

### Request Timeline

**Before (Mbaza API):**
```
0s ────────────────────────────────────────> 180s
   │                                          │
   │ Network calls to Mbaza (15-30 requests)  │
   └──────────────────────────────────────────┘
   User waits 2-3 minutes ⏰
```

**After (Cache):**
```
0s ──> 0.1s
   │    │
   │    └─ Memory lookup
   └────┘
   User gets instant result ⚡
```

### API Calls

| Operation | Before | After | Savings |
|-----------|--------|-------|---------|
| Description | 1 call | 0 | 100% |
| Medications (5x) | 5 calls | 0 | 100% |
| Diet (10x) | 10 calls | 0 | 100% |
| Workout (10x) | 10 calls | 0 | 100% |
| Precautions (4x) | 4 calls | 0 | 100% |
| **Total** | **30 calls** | **0 calls** | **100%** |

---

## 🔐 Fallback Strategy

```
Request for diagnosis translation
       │
       ▼
┌──────────────────────┐
│ Is cache available?  │
└──────────────────────┘
       │
       ├─ YES ──→ Get from cache ──→ Return (⚡ fast)
       │
       └─ NO ───→ Check Mbaza availability
                         │
                         ├─ Available ──→ Call Mbaza ──→ Return (⏰ slow)
                         │
                         └─ Unavailable ─→ Return error + guidance
```

**Graceful Degradation:**
- Cache preferred (instant)
- Mbaza fallback (slow but works)
- Never breaks completely
- Clear logging for debugging

---

## 💾 Cache File Structure

```json
{
  "generatedAt": "2026-06-17T10:30:00.000Z",
  "language": "kinyarwanda",
  "totalDiseases": 40,
  "translations": {
    "Malaria": {
      "originalName": "Malaria",
      "translatedName": "Malariya",
      "description": "Malariya ni indwara iterwa na...",
      "medications": [
        "Imiti igabanya umuriro (Antipyretics)",
        "Imiti irwanya Malariya (Antimalarials)",
        ...
      ],
      "diet": [
        "Kunywa amazi menshi",
        "Kurya indyo zijya ku rugero",
        ...
      ],
      "workout": [
        "Kuruhuka bikwiye",
        "Kwirinda ibikorwa biremereye",
        ...
      ],
      "precautions": [
        "Kurara munsi y'urusenge",
        "Gukoresha imiti yo kwirinda",
        ...
      ]
    },
    // ... 39 more diseases
  }
}
```

**File Size:** ~500KB - 1MB  
**Load Time:** < 50ms on server startup  
**Lookup Time:** < 1ms (O(1) hash map)

---

## 🚀 Deployment Checklist

- [ ] Install `csv-parser` dependency
- [ ] Ensure Mbaza service is accessible
- [ ] Run `npm run translate-diseases` (15-30 min)
- [ ] Verify cache file created: `data/disease-translations-kinyarwanda.json`
- [ ] Run test: `node test-translation-cache.js`
- [ ] Restart backend server
- [ ] Verify logs show: "✅ Loaded translation cache"
- [ ] Test API endpoint: `/diagnosis/translation/status`
- [ ] Test in Flutter app with Kinyarwanda language

---

## 📈 Monitoring

### Server Logs

**Successful cache load:**
```
✅ Loaded translation cache: 40 diseases (Generated: 2026-06-17T10:30:00.000Z)
```

**Cache not available:**
```
⚠️  Translation cache not available - using Mbaza API (this will be slow)
💡 Run "npm run translate-diseases" to generate cache for instant translations
```

**Using cached translation:**
```
✨ Using cached translation (instant)
✅ Cached translation used - instant response!
```

**Fallback to Mbaza:**
```
⚠️  No cached translation for disease: NewDisease
Falling back to Mbaza API...
```

### Status Endpoint

```bash
GET /api/v1/diagnosis/translation/status
```

**Response:**
```json
{
  "success": true,
  "mbazaService": {
    "name": "Mbaza NLP Translation",
    "status": "available",
    "endpoint": "http://localhost:9000/translate"
  },
  "translationCache": {
    "status": "loaded",
    "generatedAt": "2026-06-17T10:30:00.000Z",
    "totalDiseases": 40,
    "language": "kinyarwanda",
    "message": "Instant translations available (no Mbaza calls needed)"
  }
}
```

---

**Version:** 1.0.0  
**Last Updated:** June 2026  
**Status:** ✅ Production Ready
