/**
 * Translate all symptoms to Kinyarwanda using Mbaza
 * This script translates the 132 symptoms used by the ML model
 * and stores them in a cache for instant lookups
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Configuration
const MBAZA_URL = process.env.MBAZA_TRANSLATION_URL || 'http://localhost:9000/translate';
const MBAZA_BATCH_URL = process.env.MBAZA_BATCH_URL || 'http://localhost:9000/translate/batch';
const OUTPUT_FILE = path.join(__dirname, '../data/symptom-translations-kinyarwanda.json');

// All 132 symptoms from the ML model
const ALL_SYMPTOMS = [
    'Abdominal Pain',
    'Abnormal Menstruation',
    'Acidity',
    'Acute Liver Failure',
    'Altered Sensorium',
    'Anxiety',
    'Back Pain',
    'Belly Pain',
    'Blackheads',
    'Bladder Discomfort',
    'Blister',
    'Blood In Sputum',
    'Bloody Stool',
    'Blurred And Distorted Vision',
    'Breathlessness',
    'Brittle Nails',
    'Bruising',
    'Burning Micturition',
    'Chest Pain',
    'Chills',
    'Cold Hands And Feets',
    'Coma',
    'Congestion',
    'Constipation',
    'Continuous Feel Of Urine',
    'Continuous Sneezing',
    'Cough',
    'Cramps',
    'Dark Urine',
    'Dehydration',
    'Depression',
    'Diarrhoea',
    'Dischromic Patches',
    'Distention Of Abdomen',
    'Dizziness',
    'Drying And Tingling Lips',
    'Enlarged Thyroid',
    'Excessive Hunger',
    'Extra Marital Contacts',
    'Family History',
    'Fast Heart Rate',
    'Fatigue',
    'Fluid Overload',
    'Foul Smell Of Urine',
    'Headache',
    'High Fever',
    'Hip Joint Pain',
    'History Of Alcohol Consumption',
    'Increased Appetite',
    'Indigestion',
    'Inflammatory Nails',
    'Internal Itching',
    'Irregular Sugar Level',
    'Irritability',
    'Irritation In Anus',
    'Itching',
    'Joint Pain',
    'Knee Pain',
    'Lack Of Concentration',
    'Lethargy',
    'Loss Of Appetite',
    'Loss Of Balance',
    'Loss Of Smell',
    'Malaise',
    'Mild Fever',
    'Mood Swings',
    'Movement Stiffness',
    'Mucoid Sputum',
    'Muscle Pain',
    'Muscle Wasting',
    'Muscle Weakness',
    'Nausea',
    'Neck Pain',
    'Nodal Skin Eruptions',
    'Obesity',
    'Pain Behind The Eyes',
    'Pain During Bowel Movements',
    'Pain In Anal Region',
    'Painful Walking',
    'Palpitations',
    'Passage Of Gases',
    'Patches In Throat',
    'Phlegm',
    'Polyuria',
    'Prominent Veins On Calf',
    'Puffy Face And Eyes',
    'Pus Filled Pimples',
    'Receiving Blood Transfusion',
    'Receiving Unsterile Injections',
    'Red Sore Around Nose',
    'Red Spots Over Body',
    'Redness Of Eyes',
    'Restlessness',
    'Runny Nose',
    'Rusty Sputum',
    'Scurring',
    'Shivering',
    'Silver Like Dusting',
    'Sinus Pressure',
    'Skin Peeling',
    'Skin Rash',
    'Slurred Speech',
    'Small Dents In Nails',
    'Spinning Movements',
    'Spotting Urination',
    'Stiff Neck',
    'Stomach Bleeding',
    'Stomach Pain',
    'Sunken Eyes',
    'Sweating',
    'Swelled Lymph Nodes',
    'Swelling Joints',
    'Swelling Of Stomach',
    'Swollen Blood Vessels',
    'Swollen Extremeties',
    'Swollen Legs',
    'Throat Irritation',
    'Toxic Look (Typhos)',
    'Ulcers On Tongue',
    'Unsteadiness',
    'Visual Disturbances',
    'Vomiting',
    'Watering From Eyes',
    'Weakness In Limbs',
    'Weakness Of One Body Side',
    'Weight Gain',
    'Weight Loss',
    'Yellow Crust Ooze',
    'Yellow Urine',
    'Yellowing Of Eyes',
    'Yellowish Skin',
];

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
 * Translate single text
 */
async function translateText(text) {
    try {
        const response = await axios.post(MBAZA_URL, { text }, { timeout: 60000 });
        if (response.status === 200 && response.data?.kinyarwanda) {
            return response.data.kinyarwanda;
        }
        return text; // Fallback to original
    } catch (error) {
        console.error(`Error translating: ${text}`, error.message);
        return text;
    }
}

/**
 * Main translation function
 */
async function translateSymptoms() {
    console.log('🌍 Starting symptom translation to Kinyarwanda...\n');

    const translations = {};
    const batchSize = 20; // Process 20 symptoms at a time
    const totalBatches = Math.ceil(ALL_SYMPTOMS.length / batchSize);

    console.log(`📋 Translating ${ALL_SYMPTOMS.length} symptoms in ${totalBatches} batches\n`);

    for (let i = 0; i < ALL_SYMPTOMS.length; i += batchSize) {
        const batch = ALL_SYMPTOMS.slice(i, i + batchSize);
        const batchNum = Math.floor(i / batchSize) + 1;

        console.log(`[Batch ${batchNum}/${totalBatches}] Translating symptoms ${i + 1}-${Math.min(i + batchSize, ALL_SYMPTOMS.length)}`);

        const translatedBatch = await translateBatch(batch);

        // Store translations
        batch.forEach((symptom, index) => {
            translations[symptom] = translatedBatch[index] || symptom;
        });

        console.log(`  ✅ Batch ${batchNum} complete\n`);

        // Small delay between batches
        if (i + batchSize < ALL_SYMPTOMS.length) {
            await new Promise(resolve => setTimeout(resolve, 500));
        }
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
            totalSymptoms: ALL_SYMPTOMS.length,
            translations
        }, null, 2)
    );

    console.log(`\n✅ Translation complete!`);
    console.log(`📄 Saved to: ${OUTPUT_FILE}`);
    console.log(`📊 Total symptoms translated: ${ALL_SYMPTOMS.length}`);

    // Sample translations
    console.log('\n📝 Sample translations:');
    const samples = Object.entries(translations).slice(0, 10);
    samples.forEach(([english, kinyarwanda]) => {
        console.log(`   ${english} → ${kinyarwanda}`);
    });
}

// Run translation if called directly
if (require.main === module) {
    translateSymptoms()
        .then(() => {
            console.log('\n✨ Symptom translation completed successfully!');
            process.exit(0);
        })
        .catch(error => {
            console.error('\n❌ Translation script failed:', error);
            process.exit(1);
        });
}

module.exports = { translateSymptoms };
