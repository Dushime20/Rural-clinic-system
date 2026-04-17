# Requirements Document

## Introduction

This document specifies the requirements for upgrading the AI-Powered Community Health Companion system from a rule-based diagnosis system (75-85% accuracy) to a machine learning-based prediction system (90-95% accuracy target). The system serves rural clinics in Rwanda and must maintain offline-first capabilities while integrating trained ML models using DDXPlus (1.3M cases, 49 diseases) and AfriMedQA (African-specific diseases) datasets.

## Glossary

- **ML_Training_Pipeline**: The Python-based system that preprocesses data, trains the neural network model, and exports it for deployment
- **DDXPlus_Dataset**: A medical dataset containing 1.3 million diagnostic cases covering 49 diseases
- **AfriMedQA_Dataset**: A medical dataset containing African-specific disease information and diagnostic patterns
- **TensorFlow_Model**: The trained neural network model in native TensorFlow format
- **TFJS_Model**: The converted model in TensorFlow.js format for offline browser/Node.js deployment
- **AI_Service**: The existing TypeScript service (src/services/ai.service.ts) that performs disease predictions
- **Diagnosis_Controller**: The existing TypeScript controller that handles diagnosis API endpoints
- **Rule_Based_System**: The current prediction system using hardcoded logic and symptom matching
- **Model_Inference**: The process of using the trained model to predict diseases from patient symptoms and vital signs
- **A/B_Testing_Framework**: System component that compares ML predictions against rule-based predictions
- **Model_Versioning_System**: Component that manages different versions of trained models and enables updates
- **Fallback_Mechanism**: Logic that reverts to rule-based predictions when ML model fails or is unavailable
- **Feature_Vector**: Normalized numerical representation of patient symptoms, vital signs, and demographics
- **Confidence_Threshold**: Minimum prediction confidence (0.0-1.0) required to return a diagnosis
- **ICD10_Code**: International Classification of Diseases 10th Revision diagnostic code
- **FHIR_R4**: Fast Healthcare Interoperability Resources Release 4 standard

## Requirements

### Requirement 1: ML Model Training Pipeline

**User Story:** As a data scientist, I want to train a neural network model on medical datasets, so that the system can provide accurate disease predictions based on patient symptoms and vital signs.

#### Acceptance Criteria

1. WHEN the training pipeline receives DDXPlus dataset THEN THE ML_Training_Pipeline SHALL preprocess the data into feature vectors and disease labels
2. WHEN the training pipeline receives AfriMedQA dataset THEN THE ML_Training_Pipeline SHALL preprocess the data and merge it with DDXPlus data
3. WHEN preprocessing is complete THEN THE ML_Training_Pipeline SHALL split data into training (70%), validation (15%), and test (15%) sets
4. THE ML_Training_Pipeline SHALL train a neural network model with at least 90% accuracy on the test set
5. WHEN training is complete THEN THE ML_Training_Pipeline SHALL export the model in TensorFlow SavedModel format
6. WHEN the model is exported THEN THE ML_Training_Pipeline SHALL generate metadata including disease labels, feature specifications, and model version
7. THE ML_Training_Pipeline SHALL support 49 diseases from DDXPlus plus additional African-specific diseases from AfriMedQA

### Requirement 2: Data Preprocessing and Feature Engineering

**User Story:** As a data scientist, I want to convert raw medical data into normalized feature vectors, so that the neural network can learn patterns effectively.

#### Acceptance Criteria

1. WHEN processing patient data THEN THE ML_Training_Pipeline SHALL normalize vital signs (temperature, blood pressure, heart rate, respiratory rate, oxygen saturation) to 0-1 range
2. WHEN processing symptoms THEN THE ML_Training_Pipeline SHALL encode symptoms using multi-hot encoding across symptom categories
3. WHEN processing demographics THEN THE ML_Training_Pipeline SHALL encode age as normalized value and gender as one-hot encoding
4. WHEN processing medical history THEN THE ML_Training_Pipeline SHALL encode chronic conditions and allergies as binary features
5. THE ML_Training_Pipeline SHALL handle missing values by using median imputation for vital signs and zero-filling for symptoms
6. WHEN feature engineering is complete THEN THE ML_Training_Pipeline SHALL produce feature vectors compatible with the existing AI_Service input format

### Requirement 3: Model Architecture and Training

**User Story:** As a data scientist, I want to design an optimal neural network architecture, so that the model achieves high accuracy while remaining deployable on resource-constrained devices.

#### Acceptance Criteria

1. THE TensorFlow_Model SHALL use a feedforward neural network architecture with at least 2 hidden layers
2. THE TensorFlow_Model SHALL produce output probabilities for all supported diseases using softmax activation
3. WHEN training THEN THE ML_Training_Pipeline SHALL use categorical cross-entropy loss and Adam optimizer
4. WHEN training THEN THE ML_Training_Pipeline SHALL implement early stopping based on validation loss
5. WHEN training THEN THE ML_Training_Pipeline SHALL use dropout regularization to prevent overfitting
6. THE TensorFlow_Model SHALL be smaller than 50MB in size when exported
7. THE TensorFlow_Model SHALL achieve 90-95% accuracy on the test set
8. THE TensorFlow_Model SHALL complete inference in less than 2 seconds per prediction

### Requirement 4: Model Evaluation and Validation

**User Story:** As a data scientist, I want to thoroughly evaluate the trained model, so that I can verify it meets accuracy and performance requirements before deployment.

#### Acceptance Criteria

1. WHEN evaluation runs THEN THE ML_Training_Pipeline SHALL calculate accuracy, precision, recall, and F1-score for each disease
2. WHEN evaluation runs THEN THE ML_Training_Pipeline SHALL generate a confusion matrix showing prediction patterns
3. WHEN evaluation runs THEN THE ML_Training_Pipeline SHALL measure inference time on sample inputs
4. WHEN evaluation runs THEN THE ML_Training_Pipeline SHALL verify model size is under 50MB
5. THE ML_Training_Pipeline SHALL generate an evaluation report with all metrics and visualizations
6. WHEN accuracy is below 90% THEN THE ML_Training_Pipeline SHALL log warnings and recommend retraining

### Requirement 5: TensorFlow.js Model Conversion

**User Story:** As a developer, I want to convert the trained TensorFlow model to TensorFlow.js format, so that it can run offline in the Node.js backend.

#### Acceptance Criteria

1. WHEN conversion starts THEN THE ML_Training_Pipeline SHALL use tensorflowjs_converter to convert the SavedModel to TFJS format
2. WHEN conversion completes THEN THE TFJS_Model SHALL include model.json and binary weight files
3. WHEN conversion completes THEN THE ML_Training_Pipeline SHALL verify the TFJS_Model produces identical predictions to the TensorFlow_Model
4. THE TFJS_Model SHALL be smaller than 50MB in total size
5. WHEN conversion completes THEN THE ML_Training_Pipeline SHALL generate a metadata file with disease labels, feature specifications, and normalization parameters

### Requirement 6: AI Service Integration

**User Story:** As a backend developer, I want to integrate the trained ML model into the existing AI_Service, so that the system uses ML predictions instead of rule-based logic.

#### Acceptance Criteria

1. WHEN the AI_Service initializes THEN THE AI_Service SHALL load the TFJS_Model from the models directory
2. WHEN the AI_Service initializes THEN THE AI_Service SHALL load disease labels and metadata from the metadata file
3. WHEN a prediction request arrives THEN THE AI_Service SHALL convert the DiagnosisInput to a Feature_Vector using the same preprocessing as training
4. WHEN the Feature_Vector is ready THEN THE AI_Service SHALL perform Model_Inference using the TFJS_Model
5. WHEN Model_Inference completes THEN THE AI_Service SHALL filter predictions by Confidence_Threshold (default 0.6)
6. WHEN predictions are filtered THEN THE AI_Service SHALL return the top 5 predictions sorted by confidence
7. WHEN predictions are returned THEN THE AI_Service SHALL include ICD10_Code and recommendations for each disease
8. THE AI_Service SHALL maintain the existing API interface without breaking changes

### Requirement 7: Fallback Mechanism

**User Story:** As a system administrator, I want the system to fall back to rule-based predictions when the ML model fails, so that the service remains available even during model issues.

#### Acceptance Criteria

1. WHEN the TFJS_Model fails to load THEN THE AI_Service SHALL log an error and activate the Fallback_Mechanism
2. WHEN Model_Inference throws an error THEN THE AI_Service SHALL catch the error and use the Rule_Based_System
3. WHEN the Fallback_Mechanism activates THEN THE AI_Service SHALL log the fallback event with error details
4. WHEN using the Rule_Based_System THEN THE AI_Service SHALL return predictions in the same format as ML predictions
5. THE AI_Service SHALL include a flag in the response indicating whether ML or rule-based predictions were used

### Requirement 8: A/B Testing Framework

**User Story:** As a product manager, I want to compare ML predictions against rule-based predictions, so that I can measure the improvement and validate the ML system before full rollout.

#### Acceptance Criteria

1. WHEN A/B testing is enabled THEN THE AI_Service SHALL generate both ML and rule-based predictions for each request
2. WHEN both predictions are generated THEN THE AI_Service SHALL log both prediction sets with request metadata
3. WHEN A/B testing is enabled THEN THE AI_Service SHALL return predictions based on a configurable split ratio (default 50/50)
4. WHEN A/B testing is enabled THEN THE AI_Service SHALL include metadata indicating which prediction method was used
5. THE A/B_Testing_Framework SHALL store comparison data for analysis including prediction differences and confidence scores

### Requirement 9: Model Versioning and Updates

**User Story:** As a system administrator, I want to manage multiple model versions and update models without downtime, so that the system can continuously improve while maintaining service availability.

#### Acceptance Criteria

1. THE Model_Versioning_System SHALL store models in versioned directories (e.g., models/v1.0.0/, models/v1.1.0/)
2. WHEN the AI_Service starts THEN THE AI_Service SHALL load the model version specified in configuration
3. WHEN a new model version is deployed THEN THE Model_Versioning_System SHALL validate the model before activation
4. WHEN model validation passes THEN THE Model_Versioning_System SHALL update the active model version in configuration
5. WHEN the active model version changes THEN THE AI_Service SHALL reload the new model without requiring server restart
6. THE Model_Versioning_System SHALL maintain a changelog documenting model versions, accuracy metrics, and deployment dates

### Requirement 10: Performance Monitoring and Accuracy Tracking

**User Story:** As a system administrator, I want to monitor model performance in production, so that I can detect accuracy degradation and trigger retraining when needed.

#### Acceptance Criteria

1. WHEN a prediction is made THEN THE AI_Service SHALL log the prediction with timestamp, input features, and output predictions
2. WHEN a diagnosis is confirmed by a healthcare provider THEN THE Diagnosis_Controller SHALL log the confirmed diagnosis
3. THE AI_Service SHALL calculate rolling accuracy by comparing predictions against confirmed diagnoses
4. WHEN rolling accuracy drops below 85% THEN THE AI_Service SHALL send alerts to administrators
5. THE AI_Service SHALL track inference time for each prediction and log warnings when exceeding 2 seconds
6. THE AI_Service SHALL provide an API endpoint to retrieve performance metrics including accuracy, average confidence, and inference time

### Requirement 11: Offline Operation and Model Deployment

**User Story:** As a field technician, I want the ML model to work completely offline, so that rural clinics can use the system without internet connectivity.

#### Acceptance Criteria

1. THE TFJS_Model SHALL be bundled with the application and stored locally in the models directory
2. WHEN the AI_Service initializes THEN THE AI_Service SHALL load the model from local storage without network requests
3. WHEN Model_Inference runs THEN THE AI_Service SHALL perform all computations locally without external API calls
4. THE TFJS_Model SHALL include all necessary metadata and disease labels in local files
5. WHEN the application is deployed THEN THE deployment package SHALL include the complete TFJS_Model and metadata

### Requirement 12: FHIR R4 and ICD-10 Compliance

**User Story:** As a healthcare compliance officer, I want the ML predictions to maintain FHIR R4 compliance and include ICD-10 codes, so that the system meets international healthcare standards.

#### Acceptance Criteria

1. WHEN the ML_Training_Pipeline processes disease labels THEN THE ML_Training_Pipeline SHALL map each disease to its corresponding ICD10_Code
2. WHEN predictions are returned THEN THE AI_Service SHALL include the ICD10_Code for each predicted disease
3. THE AI_Service SHALL format diagnosis data according to FHIR_R4 Condition resource structure
4. WHEN storing diagnoses THEN THE Diagnosis_Controller SHALL maintain FHIR_R4 compliance in the database schema
5. THE AI_Service SHALL support all 49 diseases from DDXPlus with valid ICD-10 codes

### Requirement 13: Training Pipeline Documentation and Reproducibility

**User Story:** As a data scientist, I want comprehensive documentation and reproducible training pipelines, so that I can retrain models and improve them over time.

#### Acceptance Criteria

1. THE ML_Training_Pipeline SHALL include a README documenting dataset requirements, preprocessing steps, and training commands
2. THE ML_Training_Pipeline SHALL use a requirements.txt file specifying all Python dependencies with exact versions
3. THE ML_Training_Pipeline SHALL include configuration files for hyperparameters (learning rate, batch size, epochs, etc.)
4. WHEN training runs THEN THE ML_Training_Pipeline SHALL log all hyperparameters and random seeds for reproducibility
5. THE ML_Training_Pipeline SHALL save training history including loss and accuracy curves
6. THE ML_Training_Pipeline SHALL include scripts for data validation and exploratory data analysis
