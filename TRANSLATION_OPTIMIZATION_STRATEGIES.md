# Translation Time Optimization Strategies

## Current Performance
- **Total Time:** 85 seconds for 26 items
- **Average:** ~3.3 seconds per item
- **Bottleneck:** Sequential processing (one at a time)

## Optimization Options (Ranked by Impact)

### 🚀 Option 1: Controlled Parallel Translation (RECOMMENDED)
**Impact:** Reduce time by 60-70% (from 85s to ~25-30s)

Instead of 1 request at a time (sequential), send **3-5 requests in parallel** batches. This balances speed with stability.

**Implementation:**
```typescript
// Process in batches of 3-5 concurrent requests
async translateArray(items: string[]): Promise<string[]> {
    const BATCH_SIZE = 3; // Test with 3, can increase to 5
    const results: string[] = [];
    
    for (let i = 0; i < items.length; i += BATCH_SIZE) {
        const batch = items.slice(i, i + BATCH_SIZE);
        const batchResults = await Promise.all(
            batch.map(item => this.translateToKinyarwanda(item))
        );
        results.push(...batchResults);
    }
    
    return results;
}
```

**Pros:**
- 3x faster (85s → ~30s)
- More stable than full parallel
- Easy to tune batch size

**Cons:**
- Need to test optimal batch size
- Slightly more complex code

**Risk:** Low (proven approach)

---

### 💾 Option 2: Database Caching (BEST LONG-TERM)
**Impact:** 99% reduction for repeated content (85s → <1s)

Cache translations in the database. Same disease → instant translation.

**Implementation:**
```sql
CREATE TABLE translation_cache (
    id UUID PRIMARY KEY,
    english_text TEXT NOT NULL,
    kinyarwanda_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(english_text)
);
```

**Benefits:**
- Disease names: Always the same → instant
- Common medications: Repeat often → instant
- Generic advice: Reused → instant
- Only NEW text needs translation

**Example:**
- First "Varicose veins" diagnosis: 85 seconds
- Second "Varicose veins" diagnosis: <1 second (all cached!)
- 80% of content typically repeats

**Pros:**
- Massive speed improvement
- Reduces Mbaza load
- Better UX for common diagnoses

**Cons:**
- Requires database schema update
- Cache management needed
- Initial translation still slow

**Risk:** Low (standard practice)

---

### 🎯 Option 3: Batch API Endpoint (FASTEST, REQUIRES MBAZA CHANGES)
**Impact:** 70-80% reduction (85s → ~15-20s)

Modify Mbaza to accept an **array of texts** in one request.

**Current Mbaza API:**
```python
# One text at a time
POST /translate
{ "text": "Hello" }
```

**Enhanced Mbaza API:**
```python
# Multiple texts at once
POST /translate/batch
{ "texts": ["Hello", "Goodbye", "Thank you"] }
```

**Implementation in Mbaza:**
```python
@app.route('/translate/batch', methods=['POST'])
def translate_batch():
    data = request.get_json()
    texts = data['texts']
    
    # Model can process batches efficiently
    inputs = tokenizer(texts, return_tensors="pt", padding=True).to(device)
    translated_tokens = model.generate(**inputs, ...)
    results = tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)
    
    return jsonify({"translations": results})
```

**Pros:**
- Native batch processing (faster)
- Single HTTP request overhead
- Model optimized for batches

**Cons:**
- Requires modifying Mbaza
- More complex error handling
- Risk of losing all if one fails

**Risk:** Medium (needs testing)

---

### ⚡ Option 4: Lazy Translation (PERCEIVED SPEED)
**Impact:** Instant page load, translate in background

Show English immediately, translate sections progressively.

**User Experience:**
1. Page loads instantly (English)
2. Sections translate one-by-one
3. "Disease" translates first (3s)
4. "Description" next (6s)
5. User can read while waiting

**Implementation:**
```dart
// Translate sections progressively
Future<void> _translateReportProgressive() async {
    // Show English immediately
    setState(() => _isTranslating = true);
    
    // Translate priority sections first
    final disease = await _translateSection('disease');
    setState(() => _translatedReport['disease'] = disease);
    
    final description = await _translateSection('description');
    setState(() => _translatedReport['description'] = description);
    
    // Continue with remaining sections...
}
```

**Pros:**
- Page loads instantly
- User sees progress
- Can read while translating

**Cons:**
- Content "jumps" as it translates
- Still takes 85s total
- More complex UI state

**Risk:** Low (UX pattern)

---

### 🔧 Option 5: Optimize Mbaza Model (REQUIRES ML EXPERTISE)
**Impact:** 20-30% faster per translation

Use a smaller/faster model or quantization.

**Options:**
- Use INT8 quantization (faster inference)
- Use smaller NLLB model variant
- Use ONNX runtime

**Pros:**
- Faster inference per item
- Reduces cost

**Cons:**
- May reduce quality
- Requires ML expertise
- Need to test quality

**Risk:** High (quality vs speed tradeoff)

---

## Recommended Approach: Hybrid Strategy

### Phase 1: Quick Win (This Week)
✅ **Implement Controlled Parallel Translation**
- Start with batch size of 3
- Test stability
- Increase to 5 if stable
- **Expected time: 85s → 30s** ✅

### Phase 2: Long-term (Next Sprint)
✅ **Add Database Caching**
- Cache all translations
- 99% of repeated content instant
- First diagnosis: 30s, subsequent: <1s

### Phase 3: Future Enhancement
⚡ **Progressive UI + Batch API**
- Lazy load translations
- Better UX during translation
- Batch API if Mbaza team agrees

## My Recommendation

**Start with Option 1 (Controlled Parallel) + Option 4 (Progressive UI)**

This gives you:
1. **3x faster translation** (85s → 30s)
2. **Instant page load** (show English first)
3. **Visual progress** (sections translate one by one)
4. **Low risk** (easy to implement)
5. **No external dependencies** (no Mbaza changes needed)

Then add caching (Option 2) for long-term speed.

---

## Implementation Priority

| Option | Effort | Impact | Risk | Priority |
|--------|--------|--------|------|----------|
| 1. Parallel (batch 3-5) | Low | High | Low | **DO NOW** ⭐⭐⭐ |
| 4. Progressive UI | Medium | High | Low | **DO NOW** ⭐⭐⭐ |
| 2. Database Cache | Medium | Very High | Low | **NEXT SPRINT** ⭐⭐ |
| 3. Batch API | High | Very High | Medium | Future |
| 5. Model Optimization | High | Medium | High | Future |

**Want me to implement Option 1 (Parallel Batches) right now?** It will reduce time from 85s to ~30s with minimal risk.
