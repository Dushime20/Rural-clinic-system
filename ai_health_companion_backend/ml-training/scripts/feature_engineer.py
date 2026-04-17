"""
Feature Engineering Module

Converts raw medical data into normalized feature vectors for neural network training.
"""

import numpy as np
import pandas as pd
from typing import Dict, List, Tuple
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FeatureEngineer:
    """Converts raw medical data to feature vectors."""
    
    def __init__(self, config: Dict):
        self.config = config
        self.symptom_categories = config['features']['symptom_categories']
        self.vital_ranges = config['features']['vital_ranges']
        self.age_range = config['features']['age_range']
        
        # Calculate feature dimensions
        self.vital_dim = 6  # temperature, BP systolic, BP diastolic, HR, RR, O2
        self.demographic_dim = 3  # age, gender_male, gender_female
        self.symptom_dim = len(self.symptom_categories)
        self.input_dim = self.vital_dim + self.demographic_dim + self.symptom_dim
        
        logger.info(f"Feature dimensions: vitals={self.vital_dim}, demographics={self.demographic_dim}, symptoms={self.symptom_dim}, total={self.input_dim}")
    
    def encode_symptoms(self, symptoms: List[Dict]) -> np.ndarray:
        """Convert symptoms to multi-hot encoding."""
        encoding = np.zeros(len(self.symptom_categories))
        
        for symptom in symptoms:
            category = symptom.get('category', '').lower()
            if category in self.symptom_categories:
                idx = self.symptom_categories.index(category)
                encoding[idx] = 1
        
        return encoding
    
    def normalize_vitals(self, vitals: Dict[str, float]) -> np.ndarray:
        """Normalize vital signs to [0, 1] range."""
        normalized = np.zeros(self.vital_dim)
        
        vital_keys = [
            'temperature',
            'bloodPressureSystolic',
            'bloodPressureDiastolic',
            'heartRate',
            'respiratoryRate',
            'oxygenSaturation'
        ]
        
        for i, key in enumerate(vital_keys):
            value = vitals.get(key, None)
            if value is not None and key in self.vital_ranges:
                min_val = self.vital_ranges[key]['min']
                max_val = self.vital_ranges[key]['max']
                normalized[i] = (value - min_val) / (max_val - min_val)
                # Clip to [0, 1] range
                normalized[i] = np.clip(normalized[i], 0, 1)
            else:
                # Use default middle value if missing
                normalized[i] = 0.5
        
        return normalized
    
    def encode_demographics(self, age: int, gender: str) -> np.ndarray:
        """Encode age (normalized) and gender (one-hot)."""
        encoding = np.zeros(self.demographic_dim)
        
        # Normalize age to [0, 1]
        min_age = self.age_range['min']
        max_age = self.age_range['max']
        encoding[0] = (age - min_age) / (max_age - min_age)
        encoding[0] = np.clip(encoding[0], 0, 1)
        
        # One-hot encode gender
        gender_lower = gender.lower()
        if gender_lower == 'male':
            encoding[1] = 1
            encoding[2] = 0
        elif gender_lower == 'female':
            encoding[1] = 0
            encoding[2] = 1
        else:
            # Other/unknown
            encoding[1] = 0
            encoding[2] = 0
        
        return encoding
    
    def encode_medical_history(self, history: List[str]) -> np.ndarray:
        """Encode medical history as binary features."""
        # For now, we'll use a simple presence/absence encoding
        # In production, this could be expanded to specific conditions
        common_conditions = [
            'diabetes', 'hypertension', 'asthma', 'heart_disease',
            'kidney_disease', 'liver_disease', 'cancer', 'hiv'
        ]
        
        encoding = np.zeros(len(common_conditions))
        
        if history:
            history_lower = [h.lower() for h in history]
            for i, condition in enumerate(common_conditions):
                if any(condition in h for h in history_lower):
                    encoding[i] = 1
        
        return encoding
    
    def create_feature_vector(self, patient_data: Dict) -> np.ndarray:
        """Create complete feature vector from patient data."""
        # Extract components
        vitals = patient_data.get('vitalSigns', {})
        symptoms = patient_data.get('symptoms', [])
        age = patient_data.get('age', 30)
        gender = patient_data.get('gender', 'other')
        
        # Encode each component
        vital_features = self.normalize_vitals(vitals)
        demographic_features = self.encode_demographics(age, gender)
        symptom_features = self.encode_symptoms(symptoms)
        
        # Concatenate all features
        feature_vector = np.concatenate([
            vital_features,
            demographic_features,
            symptom_features
        ])
        
        assert len(feature_vector) == self.input_dim, \
            f"Feature vector size mismatch: expected {self.input_dim}, got {len(feature_vector)}"
        
        return feature_vector
    
    def process_dataframe(self, df: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray, List[str]]:
        """Process entire dataframe into feature matrix and labels."""
        logger.info(f"Processing {len(df)} records into feature vectors")
        
        features = []
        labels = []
        disease_labels = sorted(df['diagnosis'].unique().tolist())
        label_to_idx = {label: idx for idx, label in enumerate(disease_labels)}
        
        for idx, row in df.iterrows():
            # Create patient data dict
            patient_data = {
                'age': row.get('age', 30),
                'gender': row.get('gender', 'other'),
                'vitalSigns': {
                    'temperature': row.get('temperature', 37.0),
                    'bloodPressureSystolic': row.get('bloodPressureSystolic', 120),
                    'bloodPressureDiastolic': row.get('bloodPressureDiastolic', 80),
                    'heartRate': row.get('heartRate', 75),
                    'respiratoryRate': row.get('respiratoryRate', 16),
                    'oxygenSaturation': row.get('oxygenSaturation', 98)
                },
                'symptoms': []  # Would need to parse from dataset
            }
            
            # Create feature vector
            feature_vector = self.create_feature_vector(patient_data)
            features.append(feature_vector)
            
            # Get label index
            diagnosis = row['diagnosis']
            label_idx = label_to_idx[diagnosis]
            labels.append(label_idx)
        
        features_array = np.array(features)
        labels_array = np.array(labels)
        
        logger.info(f"Created feature matrix: shape={features_array.shape}")
        logger.info(f"Created label array: shape={labels_array.shape}, num_classes={len(disease_labels)}")
        
        return features_array, labels_array, disease_labels
    
    def get_feature_specs(self) -> Dict:
        """Return feature specifications for metadata."""
        return {
            'inputDim': self.input_dim,
            'vitalDim': self.vital_dim,
            'demographicDim': self.demographic_dim,
            'symptomDim': self.symptom_dim,
            'symptomCategories': self.symptom_categories,
            'vitalRanges': self.vital_ranges,
            'ageRange': self.age_range
        }
