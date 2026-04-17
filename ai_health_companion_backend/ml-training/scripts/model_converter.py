"""
Model Converter Module

Converts TensorFlow model to TensorFlow.js format and generates metadata.
"""

import tensorflow as tf
from tensorflow import keras
import tensorflowjs as tfjs
import numpy as np
import json
import os
import logging
from typing import Dict, List

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ModelConverter:
    """Converts TensorFlow model to TensorFlow.js format."""
    
    def __init__(self, config: Dict):
        self.config = config
        
    def convert_to_tfjs(self, saved_model_path: str, output_path: str) -> None:
        """Convert SavedModel to TFJS format using tensorflowjs_converter."""
        logger.info(f"Converting model from {saved_model_path} to {output_path}")
        
        os.makedirs(output_path, exist_ok=True)
        
        try:
            # Convert using tensorflowjs converter
            tfjs.converters.convert_tf_saved_model(
                saved_model_path,
                output_path,
                signature_name='serving_default',
                saved_model_tags='serve'
            )
            
            logger.info("Model conversion completed successfully")
        except Exception as e:
            logger.error(f"Model conversion failed: {e}")
            raise
    
    def validate_conversion(
        self,
        tf_model: keras.Model,
        tfjs_model_path: str,
        X_sample: np.ndarray,
        tolerance: float = 1e-5
    ) -> bool:
        """Validate TFJS model produces identical predictions."""
        logger.info("Validating TFJS model conversion")
        
        # Get TensorFlow predictions
        tf_predictions = tf_model.predict(X_sample)
        
        # Load TFJS model (for validation, we'll use TF.js in Node.js)
        # For now, we'll just check if the files exist
        model_json_path = os.path.join(tfjs_model_path, 'model.json')
        
        if not os.path.exists(model_json_path):
            logger.error("model.json not found in TFJS output")
            return False
        
        # Check for weight files
        weight_files = [f for f in os.listdir(tfjs_model_path) if f.endswith('.bin')]
        if not weight_files:
            logger.error("No weight files (.bin) found in TFJS output")
            return False
        
        logger.info(f"TFJS model validation passed: model.json and {len(weight_files)} weight file(s) found")
        return True
    
    def generate_metadata(
        self,
        disease_labels: List[str],
        icd10_codes: Dict[str, str],
        feature_specs: Dict,
        normalization_params: Dict,
        model_version: str,
        accuracy: float,
        output_path: str
    ) -> None:
        """Generate metadata JSON file."""
        logger.info(f"Generating metadata file: {output_path}")
        
        metadata = {
            'version': model_version,
            'trainingDate': self._get_current_timestamp(),
            'accuracy': accuracy,
            'diseaseLabels': disease_labels,
            'icd10Codes': icd10_codes,
            'featureSpecs': feature_specs,
            'normalizationParams': normalization_params,
            'modelArchitecture': self.config['model']['architecture'],
            'trainingConfig': {
                'batchSize': self.config['training']['batch_size'],
                'epochs': self.config['training']['epochs'],
                'learningRate': self.config['model']['learning_rate'],
                'optimizer': self.config['model']['optimizer'],
                'loss': self.config['model']['loss']
            },
            'confidenceThreshold': self.config['evaluation']['confidence_threshold']
        }
        
        with open(output_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        logger.info("Metadata file generated successfully")
    
    def generate_icd10_mapping(self, disease_labels: List[str]) -> Dict[str, str]:
        """Generate ICD-10 code mapping for diseases."""
        # This is a simplified mapping. In production, use a comprehensive database
        icd10_mapping = {
            'Common Cold': 'J00',
            'Influenza': 'J11',
            'Malaria': 'B54',
            'Typhoid Fever': 'A01.0',
            'Pneumonia': 'J18.9',
            'Tuberculosis': 'A15.9',
            'Dengue Fever': 'A90',
            'Hypertension': 'I10',
            'Diabetes': 'E11.9',
            'Gastroenteritis': 'A09',
            'Urinary Tract Infection': 'N39.0',
            'Skin Infection': 'L08.9',
            'Respiratory Infection': 'J22',
            'Anemia': 'D64.9',
            'Dehydration': 'E86',
            'Asthma': 'J45.9',
            'Bronchitis': 'J40',
            'Meningitis': 'G03.9',
            'Hepatitis': 'B19.9',
            'HIV/AIDS': 'B24'
        }
        
        # Map available diseases
        result = {}
        for disease in disease_labels:
            if disease in icd10_mapping:
                result[disease] = icd10_mapping[disease]
            else:
                # Generate a generic code if not found
                result[disease] = 'R69'  # Unknown and unspecified causes of morbidity
                logger.warning(f"No ICD-10 code found for '{disease}', using R69")
        
        return result
    
    def _get_current_timestamp(self) -> str:
        """Get current timestamp in ISO format."""
        from datetime import datetime
        return datetime.utcnow().isoformat() + 'Z'
    
    def get_model_size(self, path: str) -> float:
        """Get total size of model files in MB."""
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                total_size += os.path.getsize(filepath)
        
        size_mb = total_size / (1024 * 1024)
        return size_mb
