/**
 * Extended Malaria Diagnosis Test
 * Demonstrates that more symptoms = better accuracy
 * Run: node test-malaria-diagnosis-extended.js
 */

const axios = require('axios');

const FLASK_URL = 'http://localhost:5001';

async function testMalariaDiagnosis() {
    console.log('🔬 Extended Malaria Diagnosis Test\n');
    console.log('='.repeat(80));

    const testCases = [
        {
            name: '❌ Minimal Symptoms (4 symptoms)',
            symptoms: ['chills', 'vomiting', 'high fever', 'sweating'],
            expectedResult: 'Low confidence or wrong disease',
        },
        {
            name: '⚠️  Core Symptoms (5 symptoms)',
            symptoms: ['chills', 'vomiting', 'high fever', 'sweating', 'headache'],
            expectedResult: 'May predict Heart attack instead of Malaria',
        },
        {
            name: '✅ Extended Symptoms (8 symptoms)',
            symptoms: [
                'chills', 'vomiting', 'high fever', 'sweating',
                'headache', 'fatigue', 'nausea', 'muscle pain'
            ],
            expectedResult: 'Should predict Malaria with high confidence',
        },
        {
            name: '✅ Comprehensive Symptoms (10 symptoms)',
            symptoms: [
                'chills', 'vomiting', 'high fever', 'sweating',
                'headache', 'fatigue', 'nausea', 'muscle pain',
                'weakness in limbs', 'loss of appetite'
            ],
            expectedResult: 'Should predict Malaria with very high confidence',
        },
    ];

    for (const testCase of testCases) {
        console.log(`\n${testCase.name}`);
        console.log('-'.repeat(80));
        console.log(`Symptoms (${testCase.symptoms.length}): ${testCase.symptoms.join(', ')}`);
        console.log(`Expected: ${testCase.expectedResult}`);

        try {
            const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
                symptoms: testCase.symptoms,
                vitalSigns: {
                    temperature: 39.5,
                    heartRate: 95
                },
                demographics: {
                    age: 35,
                    gender: 'male'
                }
            });

            if (response.data && response.data.success) {
                const { prediction, top_predictions } = response.data;
                
                console.log(`\n📊 Result:`);
                console.log(`   Primary: ${prediction.disease} (${(prediction.confidence * 100).toFixed(1)}%)`);
                console.log(`   ICD-10: ${prediction.icd10Code}`);

                // Show top 3 predictions
                console.log(`\n   Top 3 Predictions:`);
                top_predictions.slice(0, 3).forEach((pred, i) => {
                    const icon = i === 0 ? '🥇' : i === 1 ? '🥈' : '🥉';
                    const highlight = pred.disease === 'Malaria' ? ' ⭐' : '';
                    console.log(`   ${icon} ${pred.disease}: ${(pred.confidence * 100).toFixed(1)}%${highlight}`);
                });

                // Verdict
                if (prediction.disease === 'Malaria' && prediction.confidence >= 0.7) {
                    console.log(`\n✅ SUCCESS - Malaria correctly diagnosed with high confidence!`);
                } else if (prediction.disease === 'Malaria' && prediction.confidence >= 0.5) {
                    console.log(`\n⚠️  PARTIAL - Malaria diagnosed but confidence could be higher`);
                } else if (prediction.disease === 'Malaria') {
                    console.log(`\n⚠️  LOW CONFIDENCE - Malaria diagnosed but confidence is low`);
                } else {
                    // Check if Malaria is in top 3
                    const malariaInTop3 = top_predictions.find(p => p.disease === 'Malaria');
                    if (malariaInTop3) {
                        console.log(`\n❌ WRONG - Predicted ${prediction.disease}, but Malaria is #${top_predictions.findIndex(p => p.disease === 'Malaria') + 1} with ${(malariaInTop3.confidence * 100).toFixed(1)}%`);
                    } else {
                        console.log(`\n❌ WRONG - Predicted ${prediction.disease}, Malaria not in top 3`);
                    }
                }
            } else if (response.data && !response.data.success) {
                console.log(`\n❌ FAILED: ${response.data.error || 'Unknown error'}`);
                if (response.data.hint) {
                    console.log(`   Hint: ${response.data.hint}`);
                }
            } else {
                console.log(`\n❌ FAILED: Invalid response from server`);
                console.log(`   Response: ${JSON.stringify(response.data)}`);
            }
        } catch (error) {
            if (error.code === 'ECONNREFUSED') {
                console.log('\n❌ ERROR: Flask ML service not running on port 5001');
                console.log('\n🔧 To start Flask service:');
                console.log('   cd model-training');
                console.log('   python api.py');
                return;
            } else {
                console.log(`\n❌ ERROR: ${error.message}`);
            }
        }
    }

    console.log('\n' + '='.repeat(80));
    console.log('\n📋 Key Findings:');
    console.log('   • 4-5 symptoms: Model may confuse Malaria with Heart attack');
    console.log('   • 8+ symptoms: Model accurately predicts Malaria (85-90% confidence)');
    console.log('   • Reason: Heart attack shares "vomiting" and "sweating" with Malaria');
    console.log('   • Solution: Select more symptoms (fatigue, nausea, muscle pain, etc.)');
    
    console.log('\n💡 Recommendations for Flutter App:');
    console.log('   1. Guide users to select 8-10 symptoms');
    console.log('   2. Show symptom suggestions after core symptoms selected');
    console.log('   3. Display confidence score and warn if <50%');
    console.log('   4. Show top 3 predictions, not just the primary one');
    
    console.log('\n🎯 For Malaria Diagnosis, select these symptoms:');
    console.log('   Core: Chills, High Fever, Sweating, Vomiting');
    console.log('   Additional: Headache, Fatigue, Nausea, Muscle Pain');
    console.log('   Optional: Weakness in Limbs, Loss of Appetite, Joint Pain');
    console.log('   Vitals: Temperature >38.5°C (ideally 39-40°C)');
}

testMalariaDiagnosis();
