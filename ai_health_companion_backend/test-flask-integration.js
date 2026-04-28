/**
 * Flask ML Service Integration Test
 * Tests the connection between Node.js backend and Flask ML service
 */

const axios = require('axios');

const FLASK_URL = process.env.FLASK_ML_SERVICE_URL || 'http://localhost:5001';

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

async function testFlaskIntegration() {
  log('\n🧪 Testing Flask ML Service Integration\n', colors.cyan);
  log('━'.repeat(60), colors.blue);

  let passedTests = 0;
  let totalTests = 0;

  // Test 1: Health Check
  totalTests++;
  log('\n1️⃣  Testing Health Check', colors.yellow);
  try {
    const response = await axios.get(`${FLASK_URL}/health`);
    if (response.data.status === 'healthy' && response.data.model_loaded) {
      log('✅ Health check passed', colors.green);
      log(`   Status: ${response.data.status}`, colors.cyan);
      log(`   Model loaded: ${response.data.model_loaded}`, colors.cyan);
      log(`   Service: ${response.data.service}`, colors.cyan);
      passedTests++;
    } else {
      log('❌ Health check failed: Model not loaded', colors.red);
    }
  } catch (error) {
    log(`❌ Health check failed: ${error.message}`, colors.red);
    log('   Make sure Flask service is running on port 5001', colors.yellow);
    return;
  }

  // Test 2: Get Symptoms
  totalTests++;
  log('\n2️⃣  Testing Get Symptoms', colors.yellow);
  try {
    const response = await axios.get(`${FLASK_URL}/api/v1/symptoms`);
    if (response.data.success && response.data.symptoms) {
      log(`✅ Got ${response.data.count} symptoms`, colors.green);
      log(`   Sample symptoms: ${response.data.symptoms.slice(0, 5).join(', ')}...`, colors.cyan);
      passedTests++;
    } else {
      log('❌ Get symptoms failed', colors.red);
    }
  } catch (error) {
    log(`❌ Get symptoms failed: ${error.message}`, colors.red);
  }

  // Test 3: Get Diseases
  totalTests++;
  log('\n3️⃣  Testing Get Diseases', colors.yellow);
  try {
    const response = await axios.get(`${FLASK_URL}/api/v1/diseases`);
    if (response.data.success && response.data.diseases) {
      log(`✅ Got ${response.data.count} diseases`, colors.green);
      log(`   Sample diseases: ${response.data.diseases.slice(0, 5).join(', ')}...`, colors.cyan);
      passedTests++;
    } else {
      log('❌ Get diseases failed', colors.red);
    }
  } catch (error) {
    log(`❌ Get diseases failed: ${error.message}`, colors.red);
  }

  // Test 4: Simple Prediction
  totalTests++;
  log('\n4️⃣  Testing Simple Disease Prediction', colors.yellow);
  try {
    const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['fever', 'cough', 'headache']
    });
    
    if (response.data.success && response.data.prediction) {
      log('✅ Prediction successful', colors.green);
      log(`   Disease: ${response.data.prediction.disease}`, colors.cyan);
      log(`   ICD-10: ${response.data.prediction.icd10Code}`, colors.cyan);
      log(`   Confidence: ${(response.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   Symptoms used: ${response.data.prediction.symptoms_used.join(', ')}`, colors.cyan);
      passedTests++;
    } else {
      log('❌ Prediction failed', colors.red);
    }
  } catch (error) {
    log(`❌ Prediction failed: ${error.message}`, colors.red);
  }

  // Test 5: Prediction with Vital Signs
  totalTests++;
  log('\n5️⃣  Testing Prediction with Vital Signs', colors.yellow);
  try {
    const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['high fever', 'chills', 'sweating', 'headache', 'nausea'],
      vitalSigns: {
        temperature: 39.5,
        bloodPressureSystolic: 110,
        bloodPressureDiastolic: 70,
        heartRate: 105,
        respiratoryRate: 22,
        oxygenSaturation: 96
      },
      demographics: {
        age: 35,
        gender: 'male'
      }
    });
    
    if (response.data.success && response.data.prediction) {
      log('✅ Prediction with vitals successful', colors.green);
      log(`   Disease: ${response.data.prediction.disease}`, colors.cyan);
      log(`   ICD-10: ${response.data.prediction.icd10Code}`, colors.cyan);
      log(`   Confidence: ${(response.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      log(`   Vital signs used: ${response.data.prediction.vital_signs_used}`, colors.cyan);
      log(`   Demographics used: ${response.data.prediction.demographics_used}`, colors.cyan);
      
      if (response.data.information) {
        log(`   Precautions: ${response.data.information.precautions.length} items`, colors.cyan);
        log(`   Medications: ${response.data.information.medications.length} items`, colors.cyan);
        log(`   Diet recommendations: ${response.data.information.diet.length} items`, colors.cyan);
      }
      passedTests++;
    } else {
      log('❌ Prediction with vitals failed', colors.red);
    }
  } catch (error) {
    log(`❌ Prediction with vitals failed: ${error.message}`, colors.red);
  }

  // Test 6: Symptom Validation
  totalTests++;
  log('\n6️⃣  Testing Symptom Validation (Spell Correction)', colors.yellow);
  try {
    const response = await axios.post(`${FLASK_URL}/api/v1/validate-symptoms`, {
      symptoms: ['fver', 'coff', 'hedache', 'nausea']
    });
    
    if (response.data.success && response.data.results) {
      log('✅ Symptom validation successful', colors.green);
      response.data.results.forEach(result => {
        if (result.valid) {
          log(`   "${result.original}" → "${result.corrected}" ✓`, colors.cyan);
        } else {
          log(`   "${result.original}" → Invalid ✗`, colors.yellow);
        }
      });
      passedTests++;
    } else {
      log('❌ Symptom validation failed', colors.red);
    }
  } catch (error) {
    log(`❌ Symptom validation failed: ${error.message}`, colors.red);
  }

  // Test 7: Malaria Prediction
  totalTests++;
  log('\n7️⃣  Testing Specific Disease (Malaria)', colors.yellow);
  try {
    const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['high fever', 'chills', 'sweating', 'headache', 'nausea', 'vomiting', 'fatigue'],
      vitalSigns: {
        temperature: 40.0,
        heartRate: 110
      },
      demographics: {
        age: 28
      }
    });
    
    if (response.data.success && response.data.prediction) {
      log('✅ Malaria prediction test successful', colors.green);
      log(`   Disease: ${response.data.prediction.disease}`, colors.cyan);
      log(`   ICD-10: ${response.data.prediction.icd10Code}`, colors.cyan);
      log(`   Confidence: ${(response.data.prediction.confidence * 100).toFixed(1)}%`, colors.cyan);
      
      if (response.data.information.medications.length > 0) {
        log(`   Medications: ${response.data.information.medications.slice(0, 3).join(', ')}`, colors.cyan);
      }
      passedTests++;
    } else {
      log('❌ Malaria prediction failed', colors.red);
    }
  } catch (error) {
    log(`❌ Malaria prediction failed: ${error.message}`, colors.red);
  }

  // Test 8: Error Handling (Invalid Symptoms)
  totalTests++;
  log('\n8️⃣  Testing Error Handling (Invalid Symptoms)', colors.yellow);
  try {
    const response = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['xyz', 'abc', 'invalid']
    });
    log('❌ Should have failed with invalid symptoms', colors.red);
  } catch (error) {
    if (error.response && error.response.status === 400) {
      log('✅ Error handling works correctly', colors.green);
      log(`   Error: ${error.response.data.error}`, colors.cyan);
      passedTests++;
    } else {
      log(`❌ Unexpected error: ${error.message}`, colors.red);
    }
  }

  // Test 9: Performance Test
  totalTests++;
  log('\n9️⃣  Testing Response Time', colors.yellow);
  try {
    const startTime = Date.now();
    await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['fever', 'cough', 'headache']
    });
    const endTime = Date.now();
    const responseTime = endTime - startTime;
    
    if (responseTime < 1000) {
      log(`✅ Response time: ${responseTime}ms (Good)`, colors.green);
      passedTests++;
    } else if (responseTime < 2000) {
      log(`⚠️  Response time: ${responseTime}ms (Acceptable)`, colors.yellow);
      passedTests++;
    } else {
      log(`❌ Response time: ${responseTime}ms (Too slow)`, colors.red);
    }
  } catch (error) {
    log(`❌ Performance test failed: ${error.message}`, colors.red);
  }

  // Summary
  log('\n' + '━'.repeat(60), colors.blue);
  log('\n📊 Test Summary', colors.cyan);
  log(`   Total tests: ${totalTests}`, colors.cyan);
  log(`   Passed: ${passedTests}`, colors.green);
  log(`   Failed: ${totalTests - passedTests}`, colors.red);
  log(`   Success rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`, colors.cyan);

  if (passedTests === totalTests) {
    log('\n🎉 All tests passed! Flask ML service is working correctly!', colors.green);
    log('\n✅ Next steps:', colors.cyan);
    log('   1. The AI model is ready to use', colors.cyan);
    log('   2. Node.js backend can now integrate with Flask service', colors.cyan);
    log('   3. Test from the mobile app or admin dashboard', colors.cyan);
  } else {
    log('\n⚠️  Some tests failed. Please review the errors above.', colors.yellow);
  }

  log('\n');
}

// Run tests
log('\n🚀 Starting Flask ML Service Integration Tests...', colors.cyan);
log(`   Flask URL: ${FLASK_URL}`, colors.cyan);
log(`   Timestamp: ${new Date().toISOString()}`, colors.cyan);

testFlaskIntegration().catch((error) => {
  log(`\n❌ Unexpected error: ${error.message}`, colors.red);
  console.error(error);
  process.exit(1);
});
