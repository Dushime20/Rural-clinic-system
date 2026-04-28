#!/bin/bash

# AI/ML Service Test Script
# Tests the Flask ML service endpoints

echo "🧪 Testing AI/ML Model Service"
echo "================================"
echo ""

FLASK_URL="http://localhost:5001"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "1️⃣  Testing Health Check..."
response=$(curl -s -w "\n%{http_code}" $FLASK_URL/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed${NC}"
    echo "$body" | python -m json.tool 2>/dev/null || echo "$body"
else
    echo -e "${RED}❌ Health check failed (HTTP $http_code)${NC}"
    echo "$body"
    exit 1
fi
echo ""

# Test 2: Get Symptoms
echo "2️⃣  Testing Get Symptoms..."
response=$(curl -s -w "\n%{http_code}" $FLASK_URL/api/v1/symptoms)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    count=$(echo "$body" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Got $count symptoms${NC}"
else
    echo -e "${RED}❌ Get symptoms failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 3: Get Diseases
echo "3️⃣  Testing Get Diseases..."
response=$(curl -s -w "\n%{http_code}" $FLASK_URL/api/v1/diseases)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    count=$(echo "$body" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Got $count diseases${NC}"
else
    echo -e "${RED}❌ Get diseases failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 4: Simple Prediction
echo "4️⃣  Testing Disease Prediction..."
response=$(curl -s -w "\n%{http_code}" -X POST $FLASK_URL/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{"symptoms": ["fever", "cough", "headache"]}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Prediction successful${NC}"
    echo "$body" | python -m json.tool 2>/dev/null || echo "$body"
else
    echo -e "${RED}❌ Prediction failed (HTTP $http_code)${NC}"
    echo "$body"
fi
echo ""

# Test 5: Prediction with Vital Signs
echo "5️⃣  Testing Prediction with Vital Signs..."
response=$(curl -s -w "\n%{http_code}" -X POST $FLASK_URL/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["high fever", "chills", "sweating", "headache"],
    "vitalSigns": {
      "temperature": 39.5,
      "heartRate": 105
    },
    "demographics": {
      "age": 35,
      "gender": "male"
    }
  }')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Prediction with vitals successful${NC}"
    disease=$(echo "$body" | grep -o '"disease":"[^"]*"' | cut -d'"' -f4)
    confidence=$(echo "$body" | grep -o '"confidence":[0-9.]*' | cut -d':' -f2)
    echo "   Disease: $disease"
    echo "   Confidence: $confidence"
else
    echo -e "${RED}❌ Prediction with vitals failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 6: Symptom Validation
echo "6️⃣  Testing Symptom Validation..."
response=$(curl -s -w "\n%{http_code}" -X POST $FLASK_URL/api/v1/validate-symptoms \
  -H "Content-Type: application/json" \
  -d '{"symptoms": ["fver", "coff", "hedache"]}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Symptom validation successful${NC}"
    echo "$body" | python -m json.tool 2>/dev/null || echo "$body"
else
    echo -e "${RED}❌ Symptom validation failed (HTTP $http_code)${NC}"
fi
echo ""

# Summary
echo "================================"
echo -e "${GREEN}🎉 All tests completed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Check that all tests passed ✅"
echo "  2. Review the prediction results"
echo "  3. Test from Node.js backend"
echo ""
