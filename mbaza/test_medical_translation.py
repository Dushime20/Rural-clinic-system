import requests
import json

# Mbaza Translation Service URL
TRANSLATE_URL = "http://localhost:9000/translate"

def translate_text(text):
    """Send text to Mbaza translator and return Kinyarwanda translation"""
    try:
        response = requests.post(
            TRANSLATE_URL,
            json={"text": text},
            headers={"Content-Type": "application/json"}
        )
        if response.status_code == 200:
            result = response.json()
            return result.get("kinyarwanda", "")
        else:
            return f"ERROR: {response.status_code}"
    except Exception as e:
        return f"ERROR: {str(e)}"

# Test medical report sections
print("=" * 80)
print("MBAZA NLP TRANSLATION TEST - MEDICAL REPORT CONTENT")
print("=" * 80)
print()

# 1. Disease/Diagnosis
print("1. DISEASE/DIAGNOSIS")
print("-" * 80)
test_phrases = [
    "You have been diagnosed with Malaria",
    "Based on your symptoms, you may have Diabetes",
    "The AI diagnosis suggests you have Hypertension",
    "You are showing signs of Typhoid Fever"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 2. About the Disease
print("\n2. ABOUT THE DISEASE")
print("-" * 80)
test_phrases = [
    "Malaria is caused by parasites transmitted through mosquito bites",
    "This is a serious condition that requires immediate treatment",
    "The disease affects blood sugar levels in your body",
    "It can be prevented by using mosquito nets at night"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 3. Precautions
print("\n3. PRECAUTIONS")
print("-" * 80)
test_phrases = [
    "Avoid contact with infected individuals",
    "Wash your hands frequently with soap and water",
    "Use mosquito nets while sleeping",
    "Keep your environment clean and dry"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 4. Medication Instructions (not names)
print("\n4. PRESCRIBED MEDICATIONS INSTRUCTIONS")
print("-" * 80)
test_phrases = [
    "Take medications three times daily after meals",
    "Complete the full course of treatment",
    "Do not skip any doses",
    "Take one tablet in the morning and one at night",
    "Continue treatment for 7 days"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 5. Recommended Diet
print("\n5. RECOMMENDED DIET")
print("-" * 80)
test_phrases = [
    "Eat plenty of fresh fruits and vegetables",
    "Drink at least 8 glasses of water daily",
    "Avoid sugary and fatty foods",
    "Include protein-rich foods in every meal",
    "Eat small meals throughout the day"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 6. Lifestyle Changes
print("\n6. LIFESTYLE AND EXERCISES")
print("-" * 80)
test_phrases = [
    "Exercise regularly for at least 30 minutes daily",
    "Get enough sleep, at least 7-8 hours per night",
    "Avoid alcohol and smoking",
    "Reduce stress through meditation or yoga",
    "Walk for 20 minutes after each meal"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

# 7. Additional Recommendations
print("\n7. ADDITIONAL RECOMMENDATIONS")
print("-" * 80)
test_phrases = [
    "Follow up with your doctor in one week",
    "Monitor your symptoms daily",
    "Seek immediate medical attention if symptoms worsen",
    "Keep a record of your temperature and blood pressure",
    "Return to the clinic if you experience severe pain"
]
for phrase in test_phrases:
    translation = translate_text(phrase)
    print(f"EN: {phrase}")
    print(f"RW: {translation}")
    print()

print("=" * 80)
print("TEST COMPLETE")
print("=" * 80)
