from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pandas as pd
import pickle
from fuzzywuzzy import process
import ast
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for Node.js communication

# Load datasets
try:
    sym_des = pd.read_csv("dataset/symptoms_df.csv")
    precautions = pd.read_csv("dataset/precautions_df.csv")
    workout = pd.read_csv("dataset/workout_df.csv")
    description = pd.read_csv("dataset/description.csv")
    medications = pd.read_csv("dataset/medications.csv")
    diets = pd.read_csv("dataset/diets.csv")
    
    # Load model
    Rf = pickle.load(open('model/RandomForest.pkl', 'rb'))
    logger.info("Model and datasets loaded successfully")
except Exception as e:
    logger.error(f"Failed to load model or datasets: {e}")
    raise

# Symptoms and diseases dictionaries
symptoms_list = {'itching': 0, 'skin_rash': 1, 'nodal_skin_eruptions': 2, 'continuous_sneezing': 3, 'shivering': 4, 'chills': 5, 'joint_pain': 6, 'stomach_pain': 7, 'acidity': 8, 'ulcers_on_tongue': 9, 'muscle_wasting': 10, 'vomiting': 11, 'burning_micturition': 12, 'spotting_ urination': 13, 'fatigue': 14, 'weight_gain': 15, 'anxiety': 16, 'cold_hands_and_feets': 17, 'mood_swings': 18, 'weight_loss': 19, 'restlessness': 20, 'lethargy': 21, 'patches_in_throat': 22, 'irregular_sugar_level': 23, 'cough': 24, 'high_fever': 25, 'sunken_eyes': 26, 'breathlessness': 27, 'sweating': 28, 'dehydration': 29, 'indigestion': 30, 'headache': 31, 'yellowish_skin': 32, 'dark_urine': 33, 'nausea': 34, 'loss_of_appetite': 35, 'pain_behind_the_eyes': 36, 'back_pain': 37, 'constipation': 38, 'abdominal_pain': 39, 'diarrhoea': 40, 'mild_fever': 41, 'yellow_urine': 42, 'yellowing_of_eyes': 43, 'acute_liver_failure': 44, 'fluid_overload': 45, 'swelling_of_stomach': 46, 'swelled_lymph_nodes': 47, 'malaise': 48, 'blurred_and_distorted_vision': 49, 'phlegm': 50, 'throat_irritation': 51, 'redness_of_eyes': 52, 'sinus_pressure': 53, 'runny_nose': 54, 'congestion': 55, 'chest_pain': 56, 'weakness_in_limbs': 57, 'fast_heart_rate': 58, 'pain_during_bowel_movements': 59, 'pain_in_anal_region': 60, 'bloody_stool': 61, 'irritation_in_anus': 62, 'neck_pain': 63, 'dizziness': 64, 'cramps': 65, 'bruising': 66, 'obesity': 67, 'swollen_legs': 68, 'swollen_blood_vessels': 69, 'puffy_face_and_eyes': 70, 'enlarged_thyroid': 71, 'brittle_nails': 72, 'swollen_extremeties': 73, 'excessive_hunger': 74, 'extra_marital_contacts': 75, 'drying_and_tingling_lips': 76, 'slurred_speech': 77, 'knee_pain': 78, 'hip_joint_pain': 79, 'muscle_weakness': 80, 'stiff_neck': 81, 'swelling_joints': 82, 'movement_stiffness': 83, 'spinning_movements': 84, 'loss_of_balance': 85, 'unsteadiness': 86, 'weakness_of_one_body_side': 87, 'loss_of_smell': 88, 'bladder_discomfort': 89, 'foul_smell_of urine': 90, 'continuous_feel_of_urine': 91, 'passage_of_gases': 92, 'internal_itching': 93, 'toxic_look_(typhos)': 94, 'depression': 95, 'irritability': 96, 'muscle_pain': 97, 'altered_sensorium': 98, 'red_spots_over_body': 99, 'belly_pain': 100, 'abnormal_menstruation': 101, 'dischromic _patches': 102, 'watering_from_eyes': 103, 'increased_appetite': 104, 'polyuria': 105, 'family_history': 106, 'mucoid_sputum': 107, 'rusty_sputum': 108, 'lack_of_concentration': 109, 'visual_disturbances': 110, 'receiving_blood_transfusion': 111, 'receiving_unsterile_injections': 112, 'coma': 113, 'stomach_bleeding': 114, 'distention_of_abdomen': 115, 'history_of_alcohol_consumption': 116, 'fluid_overload.1': 117, 'blood_in_sputum': 118, 'prominent_veins_on_calf': 119, 'palpitations': 120, 'painful_walking': 121, 'pus_filled_pimples': 122, 'blackheads': 123, 'scurring': 124, 'skin_peeling': 125, 'silver_like_dusting': 126, 'small_dents_in_nails': 127, 'inflammatory_nails': 128, 'blister': 129, 'red_sore_around_nose': 130, 'yellow_crust_ooze': 131}

diseases_list = {15: 'Fungal infection', 4: 'Allergy', 16: 'GERD', 9: 'Chronic cholestasis', 14: 'Drug Reaction', 33: 'Peptic ulcer diseae', 1: 'AIDS', 12: 'Diabetes ', 17: 'Gastroenteritis', 6: 'Bronchial Asthma', 23: 'Hypertension ', 30: 'Migraine', 7: 'Cervical spondylosis', 32: 'Paralysis (brain hemorrhage)', 28: 'Jaundice', 29: 'Malaria', 8: 'Chicken pox', 11: 'Dengue', 37: 'Typhoid', 40: 'hepatitis A', 19: 'Hepatitis B', 20: 'Hepatitis C', 21: 'Hepatitis D', 22: 'Hepatitis E', 3: 'Alcoholic hepatitis', 36: 'Tuberculosis', 10: 'Common Cold', 34: 'Pneumonia', 13: 'Dimorphic hemmorhoids(piles)', 18: 'Heart attack', 39: 'Varicose veins', 26: 'Hypothyroidism', 24: 'Hyperthyroidism', 25: 'Hypoglycemia', 31: 'Osteoarthristis', 5: 'Arthritis', 0: '(vertigo) Paroymsal  Positional Vertigo', 2: 'Acne', 38: 'Urinary tract infection', 35: 'Psoriasis', 27: 'Impetigo'}

symptoms_list_processed = {symptom.replace('_', ' ').lower(): value for symptom, value in symptoms_list.items()}

# ICD-10 code mapping
icd10_codes = {
    'Fungal infection': 'B35.9',
    'Allergy': 'T78.40',
    'GERD': 'K21.9',
    'Chronic cholestasis': 'K83.1',
    'Drug Reaction': 'T88.7',
    'Peptic ulcer diseae': 'K27.9',
    'AIDS': 'B24',
    'Diabetes ': 'E11.9',
    'Gastroenteritis': 'K52.9',
    'Bronchial Asthma': 'J45.909',
    'Hypertension ': 'I10',
    'Migraine': 'G43.909',
    'Cervical spondylosis': 'M47.812',
    'Paralysis (brain hemorrhage)': 'I61.9',
    'Jaundice': 'R17',
    'Malaria': 'B54',
    'Chicken pox': 'B01.9',
    'Dengue': 'A97.9',
    'Typhoid': 'A01.00',
    'hepatitis A': 'B15.9',
    'Hepatitis B': 'B16.9',
    'Hepatitis C': 'B17.10',
    'Hepatitis D': 'B17.0',
    'Hepatitis E': 'B17.2',
    'Alcoholic hepatitis': 'K70.10',
    'Tuberculosis': 'A15.9',
    'Common Cold': 'J00',
    'Pneumonia': 'J18.9',
    'Dimorphic hemmorhoids(piles)': 'K64.9',
    'Heart attack': 'I21.9',
    'Varicose veins': 'I83.90',
    'Hypothyroidism': 'E03.9',
    'Hyperthyroidism': 'E05.90',
    'Hypoglycemia': 'E16.2',
    'Osteoarthristis': 'M19.90',
    'Arthritis': 'M13.9',
    '(vertigo) Paroymsal  Positional Vertigo': 'H81.10',
    'Acne': 'L70.0',
    'Urinary tract infection': 'N39.0',
    'Psoriasis': 'L40.9',
    'Impetigo': 'L01.00'
}

# Helper functions
def get_icd10_code(disease):
    """Get ICD-10 code for disease"""
    return icd10_codes.get(disease, 'Unknown')
def correct_spelling(symptom):
    """Correct symptom spelling using fuzzy matching"""
    closest_match, score = process.extractOne(symptom, symptoms_list_processed.keys())
    return closest_match if score >= 80 else None

def get_disease_information(predicted_disease):
    """Retrieve comprehensive disease information"""
    try:
        # Description
        disease_desc = description[description['Disease'] == predicted_disease]['Description']
        disease_desc = " ".join([w for w in disease_desc])

        # Precautions
        disease_prec = precautions[precautions['Disease'] == predicted_disease][['Precaution_1', 'Precaution_2', 'Precaution_3', 'Precaution_4']]
        disease_prec = [col for col in disease_prec.values]

        # Medications
        disease_meds = medications[medications['Disease'] == predicted_disease]['Medication']
        disease_meds = [med for med in disease_meds.values]

        # Diet
        disease_diet = diets[diets['Disease'] == predicted_disease]['Diet']
        disease_diet = [die for die in disease_diet.values]

        # Workout
        disease_workout = workout[workout['disease'] == predicted_disease]['workout']

        return {
            'description': disease_desc,
            'precautions': disease_prec[0].tolist() if len(disease_prec) > 0 else [],
            'medications': ast.literal_eval(disease_meds[0]) if len(disease_meds) > 0 else [],
            'diet': ast.literal_eval(disease_diet[0]) if len(disease_diet) > 0 else [],
            'workout': disease_workout.tolist() if len(disease_workout) > 0 else []
        }
    except Exception as e:
        logger.error(f"Error retrieving disease information: {e}")
        return None

def predict_disease(symptoms):
    """Predict disease from symptoms"""
    try:
        # Create symptom vector
        symptom_vector = np.zeros(len(symptoms_list_processed))
        for symptom in symptoms:
            if symptom in symptoms_list_processed:
                symptom_vector[symptoms_list_processed[symptom]] = 1
        
        # Predict
        prediction = Rf.predict([symptom_vector])[0]
        disease = diseases_list[prediction]
        
        # Get confidence (probability)
        probabilities = Rf.predict_proba([symptom_vector])[0]
        confidence = float(max(probabilities))
        
        return disease, confidence
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise

def predict_disease_with_vitals(symptoms, vital_signs, demographics):
    """
    Predict disease from symptoms with optional vital signs and demographics
    
    This function enhances prediction by considering:
    - Symptoms (primary)
    - Vital signs (temperature, BP, heart rate, etc.)
    - Demographics (age, gender)
    
    If vital signs are provided, they influence the confidence score
    """
    try:
        # Base prediction from symptoms
        disease, base_confidence = predict_disease(symptoms)
        
        # If no vital signs, return base prediction
        if not vital_signs and not demographics:
            return disease, base_confidence
        
        # Adjust confidence based on vital signs
        confidence_adjustment = 0.0
        
        # Temperature analysis
        temp = vital_signs.get('temperature')
        if temp:
            if disease in ['Malaria', 'Typhoid', 'Dengue', 'Influenza'] and temp > 38.0:
                confidence_adjustment += 0.05  # Fever supports these diseases
            elif disease == 'Hypothyroidism' and temp < 36.5:
                confidence_adjustment += 0.03  # Low temp supports hypothyroidism
        
        # Blood pressure analysis
        bp_sys = vital_signs.get('bloodPressureSystolic')
        bp_dia = vital_signs.get('bloodPressureDiastolic')
        if bp_sys and bp_dia:
            if disease == 'Hypertension ' and (bp_sys > 140 or bp_dia > 90):
                confidence_adjustment += 0.10  # High BP strongly supports hypertension
            elif disease == 'Hypoglycemia' and bp_sys < 90:
                confidence_adjustment += 0.05  # Low BP supports hypoglycemia
        
        # Heart rate analysis
        hr = vital_signs.get('heartRate')
        if hr:
            if disease in ['Heart attack', 'Hyperthyroidism'] and hr > 100:
                confidence_adjustment += 0.05  # Tachycardia supports these
            elif disease == 'Hypothyroidism' and hr < 60:
                confidence_adjustment += 0.03  # Bradycardia supports hypothyroidism
        
        # Oxygen saturation analysis
        o2 = vital_signs.get('oxygenSaturation')
        if o2:
            if disease in ['Pneumonia', 'Bronchial Asthma'] and o2 < 95:
                confidence_adjustment += 0.08  # Low O2 supports respiratory diseases
        
        # Age-based adjustments
        age = demographics.get('age')
        if age:
            if disease == 'Heart attack' and age > 50:
                confidence_adjustment += 0.03  # Higher risk with age
            elif disease in ['Chicken pox', 'Common Cold'] and age < 18:
                confidence_adjustment += 0.02  # More common in children
        
        # Calculate final confidence (cap at 0.99)
        final_confidence = min(base_confidence + confidence_adjustment, 0.99)
        
        logger.info(f"Vital signs adjustment: +{confidence_adjustment:.3f} (base: {base_confidence:.3f}, final: {final_confidence:.3f})")
        
        return disease, final_confidence
        
    except Exception as e:
        logger.error(f"Prediction with vitals error: {e}")
        # Fallback to base prediction
        return predict_disease(symptoms)

# API Endpoints

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'ml-prediction-service',
        'timestamp': datetime.utcnow().isoformat(),
        'model_loaded': Rf is not None
    }), 200

@app.route('/api/v1/symptoms', methods=['GET'])
def get_symptoms():
    """Get list of all available symptoms"""
    return jsonify({
        'success': True,
        'count': len(symptoms_list_processed),
        'symptoms': list(symptoms_list_processed.keys())
    }), 200

@app.route('/api/v1/diseases', methods=['GET'])
def get_diseases():
    """Get list of all predictable diseases"""
    return jsonify({
        'success': True,
        'count': len(diseases_list),
        'diseases': list(diseases_list.values())
    }), 200

@app.route('/api/v1/predict', methods=['POST'])
def predict():
    """
    Predict disease from symptoms and vital signs
    
    Request body:
    {
        "symptoms": ["fever", "cough", "headache"],
        "vitalSigns": {
            "temperature": 38.5,
            "bloodPressureSystolic": 120,
            "bloodPressureDiastolic": 80,
            "heartRate": 85,
            "respiratoryRate": 18,
            "oxygenSaturation": 96
        },
        "demographics": {
            "age": 35,
            "gender": "male"
        }
    }
    """
    try:
        # Validate request
        if not request.json or 'symptoms' not in request.json:
            return jsonify({
                'success': False,
                'error': 'Missing symptoms in request body'
            }), 400
        
        input_symptoms = request.json['symptoms']
        vital_signs = request.json.get('vitalSigns', {})
        demographics = request.json.get('demographics', {})
        
        if not isinstance(input_symptoms, list) or len(input_symptoms) == 0:
            return jsonify({
                'success': False,
                'error': 'Symptoms must be a non-empty array'
            }), 400
        
        # Process and correct symptoms
        corrected_symptoms = []
        invalid_symptoms = []
        
        for symptom in input_symptoms:
            symptom_clean = symptom.strip().lower()
            corrected = correct_spelling(symptom_clean)
            
            if corrected:
                corrected_symptoms.append(corrected)
            else:
                invalid_symptoms.append(symptom)
        
        if len(corrected_symptoms) == 0:
            return jsonify({
                'success': False,
                'error': 'No valid symptoms found',
                'invalid_symptoms': invalid_symptoms
            }), 400
        
        # Predict disease (with vital signs if available)
        predicted_disease, confidence = predict_disease_with_vitals(
            corrected_symptoms, 
            vital_signs, 
            demographics
        )
        
        # Get disease information
        disease_info = get_disease_information(predicted_disease)
        
        if not disease_info:
            return jsonify({
                'success': False,
                'error': 'Failed to retrieve disease information'
            }), 500
        
        # Add ICD-10 code
        icd10_code = get_icd10_code(predicted_disease)
        
        # Build response
        response = {
            'success': True,
            'prediction': {
                'disease': predicted_disease,
                'icd10Code': icd10_code,
                'confidence': confidence,
                'symptoms_used': corrected_symptoms,
                'invalid_symptoms': invalid_symptoms,
                'vital_signs_used': bool(vital_signs),
                'demographics_used': bool(demographics)
            },
            'information': disease_info,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        logger.info(f"Prediction: {predicted_disease} (confidence: {confidence:.2f}, ICD-10: {icd10_code})")
        
        return jsonify(response), 200
        
    except Exception as e:
        logger.error(f"Prediction endpoint error: {e}")
        return jsonify({
            'success': False,
            'error': 'Internal server error',
            'message': str(e)
        }), 500

@app.route('/api/v1/validate-symptoms', methods=['POST'])
def validate_symptoms():
    """
    Validate and correct symptom spellings
    
    Request body:
    {
        "symptoms": ["fver", "coff", "headache"]
    }
    """
    try:
        if not request.json or 'symptoms' not in request.json:
            return jsonify({
                'success': False,
                'error': 'Missing symptoms in request body'
            }), 400
        
        input_symptoms = request.json['symptoms']
        results = []
        
        for symptom in input_symptoms:
            symptom_clean = symptom.strip().lower()
            corrected = correct_spelling(symptom_clean)
            
            results.append({
                'original': symptom,
                'corrected': corrected,
                'valid': corrected is not None
            })
        
        return jsonify({
            'success': True,
            'results': results
        }), 200
        
    except Exception as e:
        logger.error(f"Validation endpoint error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=False)
