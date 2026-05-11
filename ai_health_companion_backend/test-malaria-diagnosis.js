/**
 * Test Malaria diagnosis with different symptom formats
 * Run: node test-malaria-diagnosis.js
 */

const axios = require('axios');

const FLASK_URL = 'http://localhost:5001';
const NODE_URL = 'http://localhost:5000';

async function testMalariaDiagnosis() {
    console.log('Testing Malaria Diagnosis\n');
    console.log('='.repeat(70));

    const testCases = [
        {
            name: 'Exact Match (lowercase with spaces)',
            symptoms: ['chills', 'vomiting', 'high fever', 'sweating', 'headache'],
        },
        {
            name: 'Title Case (from Flutter app)',
            symptoms: ['Chills', 'Vomiting', 'High Fever', 'Sweating', 'Headache'],
        },
        {
            name: 'Mixed Case',
            symptoms: ['CHILLS', 'vomiting', 'High Fever', 'SWEATING', 'headache'],
        },
        {
            name: 'With underscores',
            symptoms: ['chills', 'vomiting', 'high_fever', 'sweating', 'headache'],
        },
    ];

    for (const testCase of testCases) {
        console.log(`\nTest: ${testCase.name}`);
        console.log('-'.repeat(70));
        console.log(`Symptoms: ${testCase.symptoms.join(', ')}`);

        try {
            const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
                symptoms: testCase.symptoms,
                vitalSigns: {
                    temperature: 39.2,
                    heartRate: 95
                },
                demographics: {
                    age: 35,
                    gender: 'male'
                }
            });

            if (response.data.success) {
                const { prediction, top_predictions } = response.data;
                
                console.log(`\nPrimary: ${prediction.disease} (${(prediction.confidence * 100).toFixed(1)}%)`);
                console.log(`Symptoms matched: ${prediction.symptoms_used.join(', ')}`);
                if (prediction.invalid_symptoms.length > 0) {
                    console.log(`Invalid symptoms: ${prediction.invalid_symptoms.join(', ')}`);
                }

                if (prediction.disease === 'Malaria') {
                    console.log('SUCCESS - Malaria detected!');
                } else {
                    console.log(`WARNING - Got ${prediction.disease} instead of Malaria`);
                    console.log('\nTop 3 predictions:');
                    top_predictions.forEach((pred, i) => {
                        console.log(`  ${i + 1}. ${pred.disease} (${(pred.confidence * 100).toFixed(1)}%)`);
                    });
                }
            } else {
                console.log(`FAILED: ${response.data.error}`);
            }
        } catch (error) {
            if (error.code === 'ECONNREFUSED') {
                console.log('ERROR: Flask ML service not running');
                console.log('\nTo start: cd model-training && python api.py');
                return;
            } else {
                console.log(`ERROR: ${error.message}`);
            }
        }
    }

    console.log('\n' + '='.repeat(70));
    console.log('\nDiagnostic Information:');
    console.log('- Flask expects lowercase symptoms with spaces');
    console.log('- Fuzzy matching should handle Title Case');
    console.log('- Score threshold: 80% similarity');
    console.log('\nIf Malaria is not detected:');
    console.log('1. Check which symptoms were actually matched');
    console.log('2. Verify temperature is >38.5°C');
    console.log('3. Ensure all 4-5 key symptoms are selected');
}

testMalariaDiagnosis();
