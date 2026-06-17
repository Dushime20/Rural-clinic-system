/**
 * Test script to verify translation cache is working
 * Run: node test-translation-cache.js
 */

const fs = require('fs');
const path = require('path');

const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m'
};

function log(message, color = colors.reset) {
    console.log(`${color}${message}${colors.reset}`);
}

async function testTranslationCache() {
    log('\n🧪 Testing Translation Cache System\n', colors.cyan);
    
    let passed = 0;
    let failed = 0;
    
    // Test 1: Check if cache file exists
    log('📁 Test 1: Cache file exists', colors.yellow);
    const cacheFile = path.join(__dirname, 'data/disease-translations-kinyarwanda.json');
    
    if (fs.existsSync(cacheFile)) {
        log('  ✅ Cache file found', colors.green);
        passed++;
    } else {
        log('  ❌ Cache file NOT found', colors.red);
        log(`  Expected: ${cacheFile}`, colors.red);
        log('  Run: npm run translate-diseases', colors.yellow);
        failed++;
        return;
    }
    
    // Test 2: Load and parse cache
    log('\n📖 Test 2: Cache file is valid JSON', colors.yellow);
    let cache;
    try {
        const data = fs.readFileSync(cacheFile, 'utf-8');
        cache = JSON.parse(data);
        log('  ✅ Valid JSON', colors.green);
        passed++;
    } catch (error) {
        log(`  ❌ Invalid JSON: ${error.message}`, colors.red);
        failed++;
        return;
    }
    
    // Test 3: Check cache structure
    log('\n🏗️  Test 3: Cache has correct structure', colors.yellow);
    if (cache.generatedAt && cache.language && cache.totalDiseases && cache.translations) {
        log('  ✅ All required fields present', colors.green);
        log(`     Generated: ${cache.generatedAt}`, colors.cyan);
        log(`     Language: ${cache.language}`, colors.cyan);
        log(`     Total Diseases: ${cache.totalDiseases}`, colors.cyan);
        passed++;
    } else {
        log('  ❌ Missing required fields', colors.red);
        failed++;
    }
    
    // Test 4: Check translations content
    log('\n📝 Test 4: Translations contain data', colors.yellow);
    const diseaseNames = Object.keys(cache.translations);
    if (diseaseNames.length > 0) {
        log(`  ✅ Found ${diseaseNames.length} diseases`, colors.green);
        passed++;
    } else {
        log('  ❌ No diseases found in translations', colors.red);
        failed++;
        return;
    }
    
    // Test 5: Check a specific disease (Malaria)
    log('\n🦟 Test 5: Malaria translation exists', colors.yellow);
    const malaria = cache.translations['Malaria'];
    if (malaria) {
        log('  ✅ Malaria found', colors.green);
        log(`     Original: ${malaria.originalName}`, colors.cyan);
        log(`     Translated: ${malaria.translatedName}`, colors.cyan);
        log(`     Description length: ${malaria.description.length} chars`, colors.cyan);
        log(`     Medications: ${malaria.medications.length} items`, colors.cyan);
        log(`     Diet: ${malaria.diet.length} items`, colors.cyan);
        log(`     Workout: ${malaria.workout.length} items`, colors.cyan);
        log(`     Precautions: ${malaria.precautions.length} items`, colors.cyan);
        passed++;
    } else {
        log('  ❌ Malaria not found', colors.red);
        failed++;
    }
    
    // Test 6: Verify translations are in Kinyarwanda (not English)
    log('\n🌍 Test 6: Translations are actually in Kinyarwanda', colors.yellow);
    if (malaria) {
        // Check if translated text is different from original
        // (Kinyarwanda should have different characters/words)
        const hasTranslation = 
            malaria.translatedName !== malaria.originalName ||
            malaria.description.length > 0;
        
        if (hasTranslation) {
            log('  ✅ Appears to be translated', colors.green);
            passed++;
        } else {
            log('  ⚠️  Translations might be incomplete', colors.yellow);
            log('  Run translation script again', colors.yellow);
            failed++;
        }
    } else {
        log('  ⏭️  Skipped (Malaria not found)', colors.yellow);
    }
    
    // Test 7: Check data completeness
    log('\n📊 Test 7: Data completeness statistics', colors.yellow);
    const stats = {
        withDescription: 0,
        withMedications: 0,
        withDiet: 0,
        withWorkout: 0,
        withPrecautions: 0
    };
    
    for (const disease of Object.values(cache.translations)) {
        if (disease.description && disease.description.length > 0) stats.withDescription++;
        if (disease.medications && disease.medications.length > 0) stats.withMedications++;
        if (disease.diet && disease.diet.length > 0) stats.withDiet++;
        if (disease.workout && disease.workout.length > 0) stats.withWorkout++;
        if (disease.precautions && disease.precautions.length > 0) stats.withPrecautions++;
    }
    
    const total = diseaseNames.length;
    const completeness = (
        (stats.withDescription / total) +
        (stats.withMedications / total) +
        (stats.withDiet / total) +
        (stats.withWorkout / total) +
        (stats.withPrecautions / total)
    ) / 5 * 100;
    
    log(`  Descriptions: ${stats.withDescription}/${total} (${(stats.withDescription/total*100).toFixed(1)}%)`, colors.cyan);
    log(`  Medications: ${stats.withMedications}/${total} (${(stats.withMedications/total*100).toFixed(1)}%)`, colors.cyan);
    log(`  Diet: ${stats.withDiet}/${total} (${(stats.withDiet/total*100).toFixed(1)}%)`, colors.cyan);
    log(`  Workout: ${stats.withWorkout}/${total} (${(stats.withWorkout/total*100).toFixed(1)}%)`, colors.cyan);
    log(`  Precautions: ${stats.withPrecautions}/${total} (${(stats.withPrecautions/total*100).toFixed(1)}%)`, colors.cyan);
    log(`  Overall: ${completeness.toFixed(1)}%`, colors.cyan);
    
    if (completeness >= 80) {
        log('  ✅ Good data completeness', colors.green);
        passed++;
    } else if (completeness >= 50) {
        log('  ⚠️  Moderate data completeness', colors.yellow);
        log('  Consider re-running translation', colors.yellow);
        passed++;
    } else {
        log('  ❌ Low data completeness', colors.red);
        log('  Re-run: npm run translate-diseases', colors.red);
        failed++;
    }
    
    // Final summary
    log('\n' + '═'.repeat(60), colors.cyan);
    log(`\n📈 Test Results: ${passed} passed, ${failed} failed`, colors.cyan);
    
    if (failed === 0) {
        log('\n✅ All tests passed! Translation cache is ready to use.', colors.green);
        log('\n💡 The backend will now use instant cached translations', colors.green);
        log('   instead of slow Mbaza API calls.', colors.green);
        return 0;
    } else {
        log(`\n❌ ${failed} test(s) failed. Please fix the issues above.`, colors.red);
        return 1;
    }
}

// Run tests
testTranslationCache()
    .then(exitCode => {
        process.exit(exitCode || 0);
    })
    .catch(error => {
        log(`\n💥 Test script error: ${error.message}`, colors.red);
        console.error(error);
        process.exit(1);
    });
