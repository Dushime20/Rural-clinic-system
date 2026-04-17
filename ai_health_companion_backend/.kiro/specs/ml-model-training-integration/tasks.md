# Implementation Plan: ML Model Training Integration

## Overview

This implementation plan converts the ML model training integration design into actionable coding tasks. The plan is organized into two main phases: (1) Python-based ML training pipeline, and (2) TypeScript-based backend integration. Each task builds incrementally, with testing integrated throughout to validate correctness early.

## Tasks

- [ ] 1. Set up ML training pipeline project structure
  - Create `ml-training/` directory in project root
  - Create subdirectories: `data/`, `models/`, `scripts/`, `tests/`, `config/`
  - Create `requirements.txt` with TensorFlow 2.x, Pandas, NumPy, Scikit-learn, Hypothesis
  - Create `README.md` documenting setup and usage
  - Create `.gitignore` for Python artifacts and large data files
  - _Requirements: 13.1, 13.2_

- [ ] 2. Implement data preprocessing module
  - [ ] 2.1 Create DataPreprocessor class in `ml-training/scripts/data_preprocessor.py`
    - Implement `load_ddxplus()` to load DDXPlus dataset from CSV
    - Implement `load_afrimedqa()` to load AfriMedQA dataset from CSV
    - Implement `merge_datasets()` to combine datasets with consistent schema
    - Implement `handle_missing_values()` with median imputation for vitals, zero-fill for symptoms
    - Implement `split_data()` to create 70/15/15 train/val/test splits
    - _Requirements: 1.1, 1.2, 1.3, 2.5_
  
  - [ ]* 2.2 Write property test for data preprocessing
    - **Property 1: Data preprocessing produces valid feature vectors**
    - **Validates: Requirements 1.1, 1.2, 2.1, 2.2, 2.3, 2.4, 2.6**
  
  - [ ]* 2.3 Write property test for data split
    - **Property 2: Data split maintains proportions and no overlap**
    - **Validates: Requirements 1.3**
  
  - [ ]* 2.4 Write property test for missing value imputation
    - **Property 3: Missing value imputation is consistent**
    - **Validates: Requirements 2.5**

- [ ] 3. Implement feature engineering module
  - [ ] 3.1 Create FeatureEngineer class in `ml-training/scripts/feature_engineer.py`
    - Implement `encode_symptoms()` for multi-hot encoding across symptom categories
    - Implement `normalize_vitals()` for min-max normalization to [0, 1]
    - Implement `encode_demographics()` for age normalization and gender one-hot encoding
    - Implement `encode_medical_history()` for binary feature encoding
    - Implement `create_feature_vector()` to combine all features
    - Implement `get_feature_specs()` to return metadata about features
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.6_
  
  - [ ]* 3.2 Write property test for feature vector preprocessing consistency
    - **Property 14: Feature vector preprocessing is consistent with training**
    - **Validates: Requirements 6.3**
  
  - [ ]* 3.3 Write unit tests for edge cases
    - Test empty symptoms list
    - Test missing vital signs
    - Test extreme age values (0, 100)
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 4. Checkpoint - Verify data pipeline
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement model training module
  - [ ] 5.1 Create ModelTrainer class in `ml-training/scripts/model_trainer.py`
    - Implement `build_model()` with feedforward architecture (256→128→64→num_diseases neurons)
    - Add dropout layers (0.3, 0.2) for regularization
    - Use softmax activation for output layer
    - Configure with Adam optimizer and categorical cross-entropy loss
    - Implement `train()` with early stopping and model checkpointing
    - Implement `save_model()` to export in SavedModel format
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 1.5_
  
  - [ ]* 5.2 Write property test for model output validity
    - **Property 6: Model output is valid probability distribution**
    - **Validates: Requirements 3.2**
  
  - [ ]* 5.3 Write property test for model size constraint
    - **Property 7: Model size constraint is satisfied**
    - **Validates: Requirements 3.6, 5.4**
  
  - [ ]* 5.4 Write property test for inference time
    - **Property 8: Inference time meets performance requirement**
    - **Validates: Requirements 3.8**

- [ ] 6. Implement model evaluation module
  - [ ] 6.1 Create ModelEvaluator class in `ml-training/scripts/model_evaluator.py`
    - Implement `evaluate()` to calculate accuracy, precision, recall, F1-score per disease
    - Implement `generate_confusion_matrix()` using sklearn
    - Implement `measure_inference_time()` on sample batches
    - Implement `check_model_size()` to verify <50MB constraint
    - Implement `generate_report()` to create evaluation report with visualizations
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ]* 6.2 Write property test for evaluation metrics
    - **Property 9: Evaluation metrics are calculated correctly**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**
  
  - [ ]* 6.3 Write property test for low accuracy warnings
    - **Property 10: Low accuracy triggers warnings**
    - **Validates: Requirements 4.6**

- [ ] 7. Implement model conversion module
  - [ ] 7.1 Create ModelConverter class in `ml-training/scripts/model_converter.py`
    - Implement `convert_to_tfjs()` using tensorflowjs_converter CLI
    - Implement `validate_conversion()` to compare TF and TFJS predictions
    - Implement `generate_metadata()` to create metadata JSON with disease labels, ICD-10 codes, feature specs
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 1.6_
  
  - [ ]* 7.2 Write property test for conversion round-trip
    - **Property 11: TensorFlow.js conversion preserves predictions**
    - **Validates: Requirements 5.3**
  
  - [ ]* 7.3 Write property test for conversion output files
    - **Property 12: TFJS conversion produces required files**
    - **Validates: Requirements 5.2**
  
  - [ ]* 7.4 Write property test for metadata completeness
    - **Property 5: Metadata generation is complete**
    - **Validates: Requirements 1.6, 5.5**
  
  - [ ]* 7.5 Write property test for ICD-10 mapping
    - **Property 13: ICD-10 mapping is complete**
    - **Validates: Requirements 12.1, 12.5**

- [ ] 8. Create main training script
  - [ ] 8.1 Create `ml-training/scripts/train.py` main script
    - Load configuration from `config/training_config.json`
    - Instantiate DataPreprocessor, FeatureEngineer, ModelTrainer, ModelEvaluator, ModelConverter
    - Execute full pipeline: load data → preprocess → train → evaluate → convert → export
    - Log all hyperparameters and random seeds for reproducibility
    - Save training history (loss/accuracy curves)
    - Generate final evaluation report
    - _Requirements: 13.4, 13.5_
  
  - [ ]* 8.2 Write integration test for full training pipeline
    - Test with small synthetic dataset (100 samples)
    - Verify all artifacts are created (model, metadata, report)
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.6_

- [ ] 9. Checkpoint - Verify training pipeline
  - Ensure all tests pass, ask the user if questions arise.



- [ ] 10. Set up backend model infrastructure
  - [ ] 10.1 Create model versioning directory structure
    - Create `models/` directory in project root
    - Create `models/v1.0.0/` subdirectory for first model version
    - Create `models/config.json` for active version configuration
    - Create `models/changelog.md` for version history
    - _Requirements: 9.1, 9.6_
  
  - [ ] 10.2 Update TypeScript types for ML integration
    - Add `ModelMetadata` interface to `src/types/ml.types.ts`
    - Add `FeatureVector` interface
    - Add `PredictionResult` interface with method flag
    - Add `ABTestConfig` and `ABTestResult` interfaces
    - Add `ModelVersion` interface
    - _Requirements: 6.8_

- [ ] 11. Implement ModelLoader class
  - [ ] 11.1 Create ModelLoader in `src/services/ml/model-loader.ts`
    - Implement `loadModel()` to load TFJS model from local file system
    - Implement `loadMetadata()` to parse metadata JSON
    - Implement `getModel()` and `getMetadata()` accessors
    - Implement `reloadModel()` for hot-reloading
    - Add error handling for missing files and invalid formats
    - _Requirements: 6.1, 6.2, 11.2_
  
  - [ ]* 11.2 Write unit tests for ModelLoader
    - Test successful model loading
    - Test metadata parsing
    - Test error handling for missing files
    - _Requirements: 6.1, 6.2_

- [ ] 12. Implement InferenceEngine class
  - [ ] 12.1 Create InferenceEngine in `src/services/ml/inference-engine.ts`
    - Implement `preprocessInput()` to convert DiagnosisInput to FeatureVector
    - Implement `encodeSymptoms()` for multi-hot encoding
    - Implement `normalizeVitals()` using metadata normalization params
    - Implement `encodeDemographics()` for age and gender
    - Implement `encodeMedicalHistory()` for binary features
    - Implement `predict()` as main entry point
    - Implement `runInference()` to execute TFJS model
    - Implement `filterByConfidence()` to apply threshold
    - Implement `mapToDiseases()` to convert indices to disease objects with ICD-10 codes
    - _Requirements: 6.3, 6.4, 6.5, 6.6, 6.7_
  
  - [ ]* 12.2 Write property test for inference pipeline
    - **Property 15: Inference pipeline produces valid predictions**
    - **Validates: Requirements 6.4, 6.5, 6.6, 6.7**
  
  - [ ]* 12.3 Write property test for confidence filtering
    - **Property 16: Confidence threshold filtering works correctly**
    - **Validates: Requirements 6.5**
  
  - [ ]* 12.4 Write unit tests for preprocessing
    - Test symptom encoding with various inputs
    - Test vital normalization with edge cases
    - Test demographic encoding
    - _Requirements: 6.3_

- [ ] 13. Implement FallbackMechanism class
  - [ ] 13.1 Create FallbackMechanism in `src/services/ml/fallback-mechanism.ts`
    - Implement `predict()` as main entry point with try-catch
    - Implement `tryMLPrediction()` to attempt ML inference
    - Implement `fallbackToRuleBased()` to use existing rule-based system
    - Implement `logFallback()` to log fallback events with error details
    - Ensure response includes method flag ('ml' or 'rule-based')
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 13.2 Write property test for fallback mechanism
    - **Property 17: Fallback mechanism activates on errors**
    - **Validates: Requirements 7.2, 7.3, 7.4**
  
  - [ ]* 13.3 Write property test for method flag
    - **Property 18: Prediction method flag is always present**
    - **Validates: Requirements 7.5**
  
  - [ ]* 13.4 Write unit tests for error scenarios
    - Test ML failure triggers fallback
    - Test fallback logging
    - Test response format consistency
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 14. Checkpoint - Verify core ML integration
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Implement ABTestingFramework class
  - [ ] 15.1 Create ABTestingFramework in `src/services/ml/ab-testing-framework.ts`
    - Implement `predict()` to generate both ML and rule-based predictions when enabled
    - Implement `generateBothPredictions()` to run both systems
    - Implement `selectPredictionMethod()` based on configured split ratio
    - Implement `logComparison()` to store comparison data in database
    - Implement `getABTestResults()` to retrieve comparison data for analysis
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [ ]* 15.2 Write property test for A/B testing
    - **Property 19: A/B testing generates both prediction types**
    - **Validates: Requirements 8.1, 8.2, 8.3, 8.4**
  
  - [ ]* 15.3 Write property test for comparison data storage
    - **Property 20: A/B testing stores comparison data**
    - **Validates: Requirements 8.5**
  
  - [ ]* 15.4 Write unit tests for traffic splitting
    - Test 50/50 split over 100 requests
    - Test 80/20 split over 100 requests
    - Test logging behavior
    - _Requirements: 8.3, 8.4, 8.5_

- [ ] 16. Implement ModelVersioningSystem class
  - [ ] 16.1 Create ModelVersioningSystem in `src/services/ml/model-versioning-system.ts`
    - Implement `listVersions()` to read available model versions
    - Implement `getActiveVersion()` to read from config
    - Implement `validateModel()` to check size, test inference, verify metadata
    - Implement `activateVersion()` to update config and trigger reload
    - Implement `rollbackToPreviousVersion()` for emergency rollback
    - Implement `addVersion()` to register new model version
    - Implement `updateConfig()` to persist version changes
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_
  
  - [ ]* 16.2 Write property test for model validation
    - **Property 21: Model validation before activation**
    - **Validates: Requirements 9.3**
  
  - [ ]* 16.3 Write property test for version updates
    - **Property 22: Model version update triggers reload**
    - **Validates: Requirements 9.4, 9.5**
  
  - [ ]* 16.4 Write property test for changelog maintenance
    - **Property 23: Changelog is maintained for version changes**
    - **Validates: Requirements 9.6**

- [ ] 17. Implement PerformanceMonitor class
  - [ ] 17.1 Create PerformanceMonitor in `src/services/ml/performance-monitor.ts`
    - Implement `logPrediction()` to store prediction logs in database
    - Implement `logConfirmedDiagnosis()` to link confirmations to predictions
    - Implement `calculateRollingAccuracy()` over configurable time window
    - Implement `getMetrics()` to retrieve performance metrics
    - Implement `checkAccuracyThreshold()` to detect accuracy drops
    - Implement `sendAlert()` to notify administrators
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_
  
  - [ ]* 17.2 Write property test for prediction logging
    - **Property 24: Prediction logging is complete**
    - **Validates: Requirements 10.1**
  
  - [ ]* 17.3 Write property test for confirmed diagnosis logging
    - **Property 25: Confirmed diagnosis logging**
    - **Validates: Requirements 10.2**
  
  - [ ]* 17.4 Write property test for rolling accuracy
    - **Property 26: Rolling accuracy calculation is correct**
    - **Validates: Requirements 10.3**
  
  - [ ]* 17.5 Write property test for accuracy alerts
    - **Property 27: Accuracy alerts trigger at threshold**
    - **Validates: Requirements 10.4**
  
  - [ ]* 17.6 Write property test for inference time tracking
    - **Property 28: Inference time tracking and warnings**
    - **Validates: Requirements 10.5**

- [ ] 18. Create database migrations for ML features
  - [ ] 18.1 Create migration for A/B testing logs table
    - Add `ab_test_logs` table with columns: id, diagnosis_id, timestamp, ml_predictions, rule_based_predictions, selected_method, patient_age, patient_gender
    - _Requirements: 8.5_
  
  - [ ] 18.2 Create migration for prediction accuracy logs table
    - Add `prediction_accuracy_logs` table with columns: id, diagnosis_id, predicted_disease, predicted_confidence, confirmed_disease, is_correct, timestamp, model_version
    - _Requirements: 10.2, 10.3_
  
  - [ ] 18.3 Update diagnoses table for ML metadata
    - Add `prediction_metadata` JSONB column to store model_version, prediction_method, inference_time, confidence_scores, fallback_reason
    - _Requirements: 10.1_

- [ ] 19. Update AI Service to use ML model
  - [ ] 19.1 Refactor AIService in `src/services/ai.service.ts`
    - Instantiate ModelLoader, InferenceEngine, FallbackMechanism, ABTestingFramework
    - Update `initializeModel()` to load TFJS model instead of mock
    - Update `predictDisease()` to use InferenceEngine with fallback
    - Add configuration flag to enable/disable A/B testing
    - Maintain backward compatibility with existing API
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4_
  
  - [ ]* 19.2 Write integration test for updated AI Service
    - Test ML prediction flow end-to-end
    - Test fallback activation
    - Test A/B testing when enabled
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_
  
  - [ ]* 19.3 Write property test for offline operation
    - **Property 29: Offline model loading (no network requests)**
    - **Validates: Requirements 11.2, 11.3**

- [ ] 20. Update Diagnosis Controller for ML integration
  - [ ] 20.1 Update createDiagnosis in `src/controllers/diagnosis.controller.ts`
    - Integrate PerformanceMonitor to log predictions
    - Add prediction metadata to diagnosis records
    - Ensure FHIR R4 compliance in response format
    - _Requirements: 10.1, 12.3, 12.4_
  
  - [ ] 20.2 Add endpoint for confirming diagnoses
    - Create `POST /diagnosis/:id/confirm` endpoint
    - Call PerformanceMonitor.logConfirmedDiagnosis()
    - _Requirements: 10.2_
  
  - [ ] 20.3 Add endpoint for performance metrics
    - Create `GET /diagnosis/metrics` endpoint
    - Return metrics from PerformanceMonitor
    - _Requirements: 10.6_
  
  - [ ]* 20.4 Write property test for FHIR R4 compliance
    - **Property 30: FHIR R4 compliance in predictions**
    - **Validates: Requirements 12.3**

- [ ] 21. Checkpoint - Verify full integration
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 22. Create configuration and documentation
  - [ ] 22.1 Create ML configuration file
    - Create `src/config/ml.config.ts` with model paths, confidence thresholds, A/B testing settings
    - Add environment variables for ML feature flags
    - _Requirements: 8.3, 9.2_
  
  - [ ] 22.2 Update API documentation
    - Update Swagger docs for diagnosis endpoints with ML metadata
    - Document new endpoints (confirm diagnosis, metrics)
    - Add examples showing ML vs rule-based responses
    - _Requirements: 6.8_
  
  - [ ] 22.3 Create ML deployment guide
    - Document how to train and deploy new models
    - Document model versioning workflow
    - Document A/B testing setup and analysis
    - Document monitoring and alerting setup
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 13.1_

- [ ] 23. Create data validation and EDA scripts
  - [ ] 23.1 Create data validation script in `ml-training/scripts/validate_data.py`
    - Check for required columns
    - Validate data types and ranges
    - Report missing values and outliers
    - Generate data quality report
    - _Requirements: 13.6_
  
  - [ ] 23.2 Create EDA script in `ml-training/scripts/exploratory_analysis.py`
    - Generate distribution plots for vital signs
    - Analyze symptom frequency
    - Analyze disease distribution
    - Generate correlation matrices
    - _Requirements: 13.6_

- [ ] 24. Final integration testing and validation
  - [ ]* 24.1 Write end-to-end integration tests
    - Test complete flow: Load model → Make prediction → Store result → Confirm diagnosis → Calculate accuracy
    - Test model update flow: Deploy new version → Validate → Activate → Verify predictions use new version
    - Test A/B testing flow: Enable A/B → Make requests → Verify logging → Retrieve results
    - Test fallback flow: Simulate ML failure → Verify rule-based activation → Verify logging
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3_
  
  - [ ]* 24.2 Write property test for training reproducibility
    - **Property 31: Training reproducibility through logging**
    - **Validates: Requirements 13.4**
  
  - [ ]* 24.3 Write property test for training history
    - **Property 32: Training history is saved**
    - **Validates: Requirements 13.5**

- [ ] 25. Final checkpoint - Complete system validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at major milestones
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples, edge cases, and error conditions
- Integration tests validate end-to-end workflows
- The training pipeline (tasks 1-9) can be developed independently from backend integration (tasks 10-25)
- Model training requires DDXPlus and AfriMedQA datasets to be available in `ml-training/data/`
- Backend integration assumes a trained model is available in `models/v1.0.0/`
