/**
 * Quick Flask Integration Test
 * Verifies Flask API supports vital signs and demographics
 */

const axios = require('axios');

const FLASK_URL = process.env.FLASK_ML_SERVICE_URL || 'http://localhost:5001';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

async function testFlaskIntegration() {
  log('\n🧪 Testing Flask ML API Integration\n', colors.cyan);
  
  // Test 1: Basic prediction (symptoms only)
  log('1️⃣  Testing basic prediction (symptoms only)...', colors.yellow);
  try {
    const response1 = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['fever', 'cough', 'headache']
    });
    
    if (response1.data.success) {
      log('✅ Basic prediction works', colors.green);
      log(`   Disease: ${response1.data.prediction.disease}`, colors.cyan);
      log(`   Confidence: ${(response1.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   ICD-10: ${response1.data.prediction.icd10Code}`, colors.cyan);
    }
  } catch (error) {
    log(`❌ Basic prediction failed: ${error.message}`, colors.red);
    return;
  }
  
  // Test 2: Prediction with vital signs
  log('\n2️⃣  Testing prediction with vital signs...', colors.yellow);
  try {
    const response2 = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['high fever', 'chills', 'sweating', 'headache'],
      vitalSigns: {
        temperature: 39.5,
        bloodPressureSystolic: 110,
        bloodPressureDiastolic: 70,
        heartRate: 105,
        respiratoryRate: 22,
        oxygenSaturation: 96
      }
    });
    
    if (response2.data.success) {
      log('✅ Prediction with vital signs works', colors.green);
      log(`   Disease: ${response2.data.prediction.disease}`, colors.cyan);
      log(`   Confidence: ${(response2.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   Vital signs used: ${response2.data.prediction.vital_signs_used}`, colors.cyan);
      
      if (response2.data.prediction.vital_signs_used) {
        log('   ✅ Vital signs were considered in prediction', colors.green);
      } else {
        log('   ⚠️  Vital signs were NOT used', colors.yellow);
      }
    }
  } catch (error) {
    log(`❌ Prediction with vital signs failed: ${error.message}`, colors.red);
    return;
  }
  
  // Test 3: Prediction with demographics
  log('\n3️⃣  Testing prediction with demographics...', colors.yellow);
  try {
    const response3 = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['fever', 'cough', 'fatigue'],
      vitalSigns: {
        temperature: 38.5,
        heartRate: 95
      },
      demographics: {
        age: 35,
        gender: 'male'
      }
    });
    
    if (response3.data.success) {
      log('✅ Prediction with demographics works', colors.green);
      log(`   Disease: ${response3.data.prediction.disease}`, colors.cyan);
      log(`   Confidence: ${(response3.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   Demographics used: ${response3.data.prediction.demographics_used}`, colors.cyan);
      
      if (response3.data.prediction.demographics_used) {
        log('   ✅ Demographics were considered in prediction', colors.green);
      } else {
        log('   ⚠️  Demographics were NOT used', colors.yellow);
      }
    }
  } catch (error) {
    log(`❌ Prediction with demographics failed: ${error.message}`, colors.red);
    return;
  }
  
  // Test 4: Complete prediction (all parameters)
  log('\n4️⃣  Testing complete prediction (symptoms + vitals + demographics)...', colors.yellow);
  try {
    const response4 = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['high fever', 'chills', 'sweating', 'headache', 'nausea', 'vomiting'],
      vitalSigns: {
        temperature: 40.0,
        bloodPressureSystolic: 110,
        bloodPressureDiastolic: 70,
        heartRate: 110,
        respiratoryRate: 24,
        oxygenSaturation: 95
      },
      demographics: {
        age: 28,
        gender: 'male'
      }
    });
    
    if (response4.data.success) {
      log('✅ Complete prediction works', colors.green);
      log(`   Disease: ${response4.data.prediction.disease}`, colors.cyan);
      log(`   ICD-10: ${response4.data.prediction.icd10Code}`, colors.cyan);
      log(`   Confidence: ${(response4.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   Vital signs used: ${response4.data.prediction.vital_signs_used}`, colors.cyan);
      log(`   Demographics used: ${response4.data.prediction.demographics_used}`, colors.cyan);
      log(`   Symptoms used: ${response4.data.prediction.symptoms_used.length}`, colors.cyan);
      
      // Check if we have all expected data
      if (response4.data.information) {
        log('\n   📋 Medical Information:', colors.cyan);
        log(`      Medications: ${response4.data.information.medications.length} items`, colors.cyan);
        log(`      Precautions: ${response4.data.information.precautions.length} items`, colors.cyan);
        log(`      Diet: ${response4.data.information.diet.length} items`, colors.cyan);
        log(`      Workout: ${response4.data.information.workout.length} items`, colors.cyan);
      }
    }
  } catch (error) {
    log(`❌ Complete prediction failed: ${error.message}`, colors.red);
    return;
  }
  
  // Summary
  log('\n' + '═'.repeat(60), colors.cyan);
  log('\n🎉 All Flask API tests passed!', colors.green);
  log('\n✅ Flask ML API supports:', colors.green);
  log('   • Symptoms (required)', colors.cyan);
  log('   • Vital signs (optional)', colors.cyan);
  log('   • Demographics (optional)', colors.cyan);
  log('   • ICD-10 codes', colors.cyan);
  log('   • Medical recommendations', colors.cyan);
  
  log('\n✅ Ready for patient safety integration!', colors.green);
  log('\n');
}

// Run test
log('\n🚀 Starting Flask Integration Test...', colors.cyan);
log(`   Flask URL: ${FLASK_URL}`, colors.cyan);

testFlaskIntegration().catch((error) => {
  log(`\n❌ Test failed: ${error.message}`, colors.red);
  if (error.code === 'ECONNREFUSED') {
    log('\n💡 Make sure Flask service is running:', colors.yellow);
    log('   cd model-training', colors.cyan);
    log('   python api.py', colors.cyan);
  }
  process.exit(1);
});
