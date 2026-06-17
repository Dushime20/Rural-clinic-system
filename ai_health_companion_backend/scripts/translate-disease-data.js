/**
 * Pre-translate all disease information to Kinyarwanda
 * This script translates all diseases and their supplementary information
 * and stores them in a cache to avoid real-time translation delays
 */

const axios = require('axios');
const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

// Configuration
const MBAZA_URL = process.env.MBAZA_TRANSLATION_URL || 'http://localhost:9000/translate';
const MBAZA_BATCH_URL = process.env.MBAZA_BATCH_URL || 'http://localhost:9000/translate/batch';
const OUTPUT_FILE = path.join(__dirname, '../data/disease-translations-kinyarwanda.json');

// Dataset paths
const DATASET_PATH = path.join(__dirname, '../model-training/dataset');
const DESCRIPTION_CSV = path.join(DATASET_PATH, 'description.csv');
const MEDICATIONS_CSV = path.join(DATASET_PATH, 'medications.csv');
const DIETS_CSV = path.join(DATASET_PATH, 'diets.csv');
const WORKOUT_CSV = path.join(DATASET_PATH, 'workout_df.csv');
const PRECAUTIONS_CSV = path.join(DATASET_PATH, 'precautions_df.csv');

/**
 * Translate text to Kinyarwanda using Mbaza
 */
async function translateText(text) {
  try {
    const response = await axios.post(MBAZA_URL, { text }, { timeout: 60000 });
    if (response.status === 200 && response.data?.kinyarwanda) {
      return response.data.kinyarwanda;
    }
    return text; // Fallback to original
  } catch (error) {
    console.error(`Error translating: ${text.substring(0, 50)}...`, error.message);
    return text;
  }
}

/**
 * Translate array of texts using batch API
 */
async function translateBatch(texts) {
  try {
    console.log(`  Batch translating ${texts.length} items...`);
    const response = await axios.post(
      MBAZA_BATCH_URL,
      { texts },
      { timeout: 180000 } // 3 minutes for batch
    );
    
    if (response.status === 200 && response.data?.translations) {
      return response.data.translations.map(t => t.kinyarwanda || t.english);
    }
    
    // Fallback to individual translation
    console.warn('  Batch translation failed, falling back to individual translations...');
    const results = [];
    for (const text of texts) {
      const translated = await translateText(text);
      results.push(translated);
      // Small delay to avoid overwhelming the service
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    return results;
  } catch (error) {
    console.error('Batch translation error:', error.message);
    // Fallback to individual translation
    const results = [];
    for (const text of texts) {
      const translated = await translateText(text);
      results.push(translated);
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    return results;
  }
}

/**
 * Parse JSON-like string from CSV (e.g., "['item1', 'item2']")
 */
function parseJsonString(str) {
  try {
    // Replace single quotes with double quotes and parse
    const normalized = str.replace(/'/g, '"');
    return JSON.parse(normalized);
  } catch (error) {
    return [];
  }
}

/**
 * Read CSV file and return as array
 */
function readCSV(filePath) {
  return new Promise((resolve, reject) => {
    const results = [];
    fs.createReadStream(filePath)
      .pipe(csv())
      .on('data', (data) => results.push(data))
      .on('end', () => resolve(results))
      .on('error', reject);
  });
}

/**
 * Main translation function
 */
async function translateDiseaseData() {
  console.log('🌍 Starting disease data translation to Kinyarwanda...\n');
  
  const translations = {};
  
  // 1. Load all datasets
  console.log('📚 Loading disease datasets...');
  const descriptions = await readCSV(DESCRIPTION_CSV);
  const medications = await readCSV(MEDICATIONS_CSV);
  const diets = await readCSV(DIETS_CSV);
  const workouts = await readCSV(WORKOUT_CSV);
  const precautions = await readCSV(PRECAUTIONS_CSV);
  
  console.log(`  - ${descriptions.length} disease descriptions`);
  console.log(`  - ${medications.length} medication lists`);
  console.log(`  - ${diets.length} diet recommendations`);
  console.log(`  - ${workouts.length} workout recommendations`);
  console.log(`  - ${precautions.length} precaution lists\n`);
  
  // Get unique disease names
  const diseaseNames = [...new Set(descriptions.map(d => d.Disease))];
  console.log(`📋 Found ${diseaseNames.length} unique diseases\n`);
  
  let progress = 0;
  const total = diseaseNames.length;
  
  for (const diseaseName of diseaseNames) {
    progress++;
    console.log(`[${progress}/${total}] Translating: ${diseaseName}`);
    
    const diseaseTranslation = {
      originalName: diseaseName,
      translatedName: await translateText(diseaseName),
      description: '',
      medications: [],
      diet: [],
      workout: [],
      precautions: []
    };
    
    // Translate description
    const descRow = descriptions.find(d => d.Disease === diseaseName);
    if (descRow?.Description) {
      console.log('  - Translating description...');
      diseaseTranslation.description = await translateText(descRow.Description);
    }
    
    // Translate medications (array)
    const medRow = medications.find(m => m.Disease === diseaseName);
    if (medRow?.Medication) {
      const medList = parseJsonString(medRow.Medication);
      if (medList.length > 0) {
        console.log(`  - Translating ${medList.length} medications...`);
        diseaseTranslation.medications = await translateBatch(medList);
      }
    }
    
    // Translate diet (array)
    const dietRow = diets.find(d => d.Disease === diseaseName);
    if (dietRow?.Diet) {
      const dietList = parseJsonString(dietRow.Diet);
      if (dietList.length > 0) {
        console.log(`  - Translating ${dietList.length} diet items...`);
        diseaseTranslation.diet = await translateBatch(dietList);
      }
    }
    
    // Translate workout (array) - group all workouts for this disease
    const workoutRows = workouts.filter(w => w.disease === diseaseName);
    if (workoutRows.length > 0) {
      const workoutList = workoutRows.map(w => w.workout).filter(Boolean);
      if (workoutList.length > 0) {
        console.log(`  - Translating ${workoutList.length} workout recommendations...`);
        diseaseTranslation.workout = await translateBatch(workoutList);
      }
    }
    
    // Translate precautions (array)
    const precRow = precautions.find(p => p.Disease === diseaseName);
    if (precRow) {
      const precList = [
        precRow.Precaution_1,
        precRow.Precaution_2,
        precRow.Precaution_3,
        precRow.Precaution_4
      ].filter(p => p && p !== 'nan');
      
      if (precList.length > 0) {
        console.log(`  - Translating ${precList.length} precautions...`);
        diseaseTranslation.precautions = await translateBatch(precList);
      }
    }
    
    translations[diseaseName] = diseaseTranslation;
    console.log('  ✅ Complete\n');
    
    // Small delay between diseases
    await new Promise(resolve => setTimeout(resolve, 200));
  }
  
  // Save to JSON file
  console.log('💾 Saving translations...');
  const outputDir = path.dirname(OUTPUT_FILE);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  fs.writeFileSync(
    OUTPUT_FILE,
    JSON.stringify({
      generatedAt: new Date().toISOString(),
      language: 'kinyarwanda',
      totalDiseases: diseaseNames.length,
      translations
    }, null, 2)
  );
  
  console.log(`\n✅ Translation complete!`);
  console.log(`📄 Saved to: ${OUTPUT_FILE}`);
  console.log(`📊 Total diseases translated: ${diseaseNames.length}`);
  
  // Summary statistics
  const stats = {
    withDescription: Object.values(translations).filter(t => t.description).length,
    withMedications: Object.values(translations).filter(t => t.medications.length > 0).length,
    withDiet: Object.values(translations).filter(t => t.diet.length > 0).length,
    withWorkout: Object.values(translations).filter(t => t.workout.length > 0).length,
    withPrecautions: Object.values(translations).filter(t => t.precautions.length > 0).length
  };
  
  console.log('\n📈 Translation Statistics:');
  console.log(`  - Diseases with descriptions: ${stats.withDescription}`);
  console.log(`  - Diseases with medications: ${stats.withMedications}`);
  console.log(`  - Diseases with diet recommendations: ${stats.withDiet}`);
  console.log(`  - Diseases with workout recommendations: ${stats.withWorkout}`);
  console.log(`  - Diseases with precautions: ${stats.withPrecautions}`);
}

// Run translation if called directly
if (require.main === module) {
  translateDiseaseData()
    .then(() => {
      console.log('\n✨ Translation script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n❌ Translation script failed:', error);
      process.exit(1);
    });
}

module.exports = { translateDiseaseData };
