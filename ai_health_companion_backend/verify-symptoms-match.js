/**
 * Verify that Flutter app symptoms match Flask ML service symptoms
 * Run: node verify-symptoms-match.js
 */

const axios = require('axios');

const FLASK_URL = 'http://localhost:5001';

// Flutter app symptoms (from symptoms_constants.dart)
const flutterSymptoms = [
  'Abdominal Pain', 'Abnormal Menstruation', 'Acidity', 'Acute Liver Failure',
  'Altered Sensorium', 'Anxiety', 'Back Pain', 'Belly Pain', 'Blackheads',
  'Bladder Discomfort', 'Blister', 'Blood In Sputum', 'Bloody Stool',
  'Blurred And Distorted Vision', 'Breathlessness', 'Brittle Nails', 'Bruising',
  'Burning Micturition', 'Chest Pain', 'Chills', 'Cold Hands And Feets', 'Coma',
  'Congestion', 'Constipation', 'Continuous Feel Of Urine', 'Continuous Sneezing',
  'Cough', 'Cramps', 'Dark Urine', 'Dehydration', 'Depression', 'Diarrhoea',
  'Dischromic Patches', 'Distention Of Abdomen', 'Dizziness', 'Drying And Tingling Lips',
  'Enlarged Thyroid', 'Excessive Hunger', 'Extra Marital Contacts', 'Family History',
  'Fast Heart Rate', 'Fatigue', 'Fluid Overload', 'Foul Smell Of Urine', 'Headache',
  'High Fever', 'Hip Joint Pain', 'History Of Alcohol Consumption', 'Increased Appetite',
  'Indigestion', 'Inflammatory Nails', 'Internal Itching', 'Irregular Sugar Level',
  'Irritability', 'Irritation In Anus', 'Itching', 'Joint Pain', 'Knee Pain',
  'Lack Of Concentration', 'Lethargy', 'Loss Of Appetite', 'Loss Of Balance',
  'Loss Of Smell', 'Malaise', 'Mild Fever', 'Mood Swings', 'Movement Stiffness',
  'Mucoid Sputum', 'Muscle Pain', 'Muscle Wasting', 'Muscle Weakness', 'Nausea',
  'Neck Pain', 'Nodal Skin Eruptions', 'Obesity', 'Pain Behind The Eyes',
  'Pain During Bowel Movements', 'Pain In Anal Region', 'Painful Walking',
  'Palpitations', 'Passage Of Gases', 'Patches In Throat', 'Phlegm', 'Polyuria',
  'Prominent Veins On Calf', 'Puffy Face And Eyes', 'Pus Filled Pimples',
  'Receiving Blood Transfusion', 'Receiving Unsterile Injections', 'Red Sore Around Nose',
  'Red Spots Over Body', 'Redness Of Eyes', 'Restlessness', 'Runny Nose',
  'Rusty Sputum', 'Scurring', 'Shivering', 'Silver Like Dusting', 'Sinus Pressure',
  'Skin Peeling', 'Skin Rash', 'Slurred Speech', 'Small Dents In Nails',
  'Spinning Movements', 'Spotting Urination', 'Stiff Neck', 'Stomach Bleeding',
  'Stomach Pain', 'Sunken Eyes', 'Sweating', 'Swelled Lymph Nodes', 'Swelling Joints',
  'Swelling Of Stomach', 'Swollen Blood Vessels', 'Swollen Extremeties', 'Swollen Legs',
  'Throat Irritation', 'Toxic Look (Typhos)', 'Ulcers On Tongue', 'Unsteadiness',
  'Visual Disturbances', 'Vomiting', 'Watering From Eyes', 'Weakness In Limbs',
  'Weakness Of One Body Side', 'Weight Gain', 'Weight Loss', 'Yellow Crust Ooze',
  'Yellow Urine', 'Yellowing Of Eyes', 'Yellowish Skin'
];

async function verifySymptoms() {
    console.log('Verifying Flutter symptoms match Flask ML service...\n');
    console.log('='.repeat(70));

    try {
        // Get symptoms from Flask ML service
        const response = await axios.get(`${FLASK_URL}/api/v1/symptoms`);
        const flaskSymptoms = response.data.symptoms;

        console.log(`\nFlutter App Symptoms: ${flutterSymptoms.length}`);
        console.log(`Flask ML Service Symptoms: ${flaskSymptoms.length}`);

        // Convert Flutter symptoms to lowercase for comparison
        const flutterLower = flutterSymptoms.map(s => s.toLowerCase());
        const flaskLower = flaskSymptoms.map(s => s.toLowerCase());

        // Find missing symptoms
        const missingInFlutter = flaskLower.filter(s => !flutterLower.includes(s));
        const missingInFlask = flutterLower.filter(s => !flaskLower.includes(s));

        if (missingInFlutter.length === 0 && missingInFlask.length === 0) {
            console.log('\n SUCCESS! All symptoms match perfectly!');
            console.log('='.repeat(70));
            return;
        }

        if (missingInFlutter.length > 0) {
            console.log(`\n MISSING IN FLUTTER (${missingInFlutter.length}):`);
            missingInFlutter.forEach(s => console.log(`  - ${s}`));
        }

        if (missingInFlask.length > 0) {
            console.log(`\n EXTRA IN FLUTTER (${missingInFlask.length}):`);
            missingInFlask.forEach(s => console.log(`  - ${s}`));
        }

        console.log('\n='.repeat(70));

    } catch (error) {
        if (error.code === 'ECONNREFUSED') {
            console.log('\n ERROR: Flask ML service is not running');
            console.log('\n To start Flask ML service:');
            console.log('   cd model-training');
            console.log('   python api.py');
        } else {
            console.log('\n ERROR:', error.message);
        }
    }
}

verifySymptoms();
