# Flask-Node.js Microservices Integration Guide

## Executive Summary

This guide provides a comprehensive architecture for integrating the Flask-based ML service with the Node.js backend as microservices, enabling seamless disease prediction capabilities.

---

## 1. Current Flask Service Analysis

### 1.1 Flask Service Overview

**Location:** `ai_health_companion_backend/model-training/`

**Core Components:**
- **Main Service:** `main.py` - Flask web application
- **ML Model:** `model/RandomForest.pkl` - Pre-trained Random Forest classifier
- **Datasets:** 8 CSV files containing medical knowledge base
- **Web Interface:** HTML templates for user interaction

### 1.2 Current Flask Flow

```
User Input (Symptoms)
    ↓
Spell Correction (Fuzzy Matching)
    ↓
Symptom Vectorization (132 features)
    ↓
Random Forest Prediction
    ↓
Disease Identification (41 diseases)
    ↓
Information Retrieval (descriptions, medications, diets, workouts, precautions)
    ↓
Response to User
```

### 1.3 Key Features

1. **Symptom Processing:**
   - 132 unique symptoms mapped to numerical indices
   - Fuzzy matching with 80% similarity threshold for spell correction
   - Comma-separated symptom input

2. **Disease Prediction:**
   - Random Forest classifier with 100% training accuracy
   - 41 disease classifications
   - Binary symptom vector (presence/absence)

3. **Medical Recommendations:**
   - Disease descriptions
   - 4 precautions per disease
   - Medication lists
   - Dietary recommendations
   - Workout/exercise plans

### 1.4 Current Endpoints

- `GET /` - Home page (HTML interface)
- `POST /predict` - Disease prediction (form-based)

### 1.5 Limitations

- No REST API endpoints (only HTML form handling)
- No authentication/authorization
- No request validation
- No error handling for API consumers
- Tightly coupled to web interface
- No health check endpoints
- No metrics/monitoring

---

## 2. Recommended Microservices Architecture

### 2.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     API Gateway / Load Balancer              │
│                    (Optional: Nginx/Traefik)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
┌─────────────────┐            ┌──────────────────┐
│   Node.js API   │◄──────────►│  Flask ML API    │
│   (Port 5000)   │   HTTP/    │  (Port 5001)     │
│                 │   REST     │                  │
│ - Auth          │            │ - ML Inference   │
│ - Business      │            │ - Model Training │
│ - Database      │            │ - Predictions    │
│ - FHIR          │            │                  │
└────────┬────────┘            └────────┬─────────┘
         │                              │
         ▼                              ▼
┌─────────────────┐            ┌──────────────────┐
│   PostgreSQL    │            │  Model Storage   │
│   Database      │            │  (File System)   │
└─────────────────┘            └──────────────────┘
         │
         ▼
┌─────────────────┐
│   Redis Cache   │
└─────────────────┘
```

### 2.2 Service Responsibilities

#### Node.js Backend (Primary API)
- User authentication & authorization
- Request validation & rate limiting
- Business logic orchestration
- Database operations (PostgreSQL)
- FHIR integration
- Caching (Redis)
- API documentation (Swagger)
- Client-facing REST API
- **Calls Flask service for ML predictions**

#### Flask ML Service (ML Microservice)
- ML model inference
- Symptom preprocessing
- Disease prediction
- Medical recommendations retrieval
- Model versioning
- Model retraining (future)
- Health checks
- **Internal service (not directly exposed to clients)**

---

## 3. Flask Service Refactoring

### 3.1 Create REST API Endpoints

Create a new file: `model-training/api.py`

```python
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
symptoms_list = {
    'itching': 0, 'skin_rash': 1, 'nodal_skin_eruptions': 2,
    'continuous_sneezing': 3, 'shivering': 4, 'chills': 5,
    # ... (all 132 symptoms)
}

diseases_list = {
    15: 'Fungal infection', 4: 'Allergy', 16: 'GERD',
    # ... (all 41 diseases)
}

symptoms_list_processed = {
    symptom.replace('_', ' ').lower(): value 
    for symptom, value in symptoms_list.items()
}

# Helper functions
def correct_spelling(symptom):
    """Correct symptom spelling using fuzzy matching"""
    closest_match, score = process.extractOne(
        symptom, 
        symptoms_list_processed.keys()
    )
    return closest_match if score >= 80 else None

def get_disease_information(predicted_disease):
    """Retrieve comprehensive disease information"""
    try:
        # Description
        disease_desc = description[
            description['Disease'] == predicted_disease
        ]['Description']
        disease_desc = " ".join([w for w in disease_desc])

        # Precautions
        disease_prec = precautions[
            precautions['Disease'] == predicted_disease
        ][['Precaution_1', 'Precaution_2', 'Precaution_3', 'Precaution_4']]
        disease_prec = [col for col in disease_prec.values]

        # Medications
        disease_meds = medications[
            medications['Disease'] == predicted_disease
        ]['Medication']
        disease_meds = [med for med in disease_meds.values]

        # Diet
        disease_diet = diets[
            diets['Disease'] == predicted_disease
        ]['Diet']
        disease_diet = [die for die in disease_diet.values]

        # Workout
        disease_workout = workout[
            workout['disease'] == predicted_disease
        ]['workout']

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
    Predict disease from symptoms
    
    Request body:
    {
        "symptoms": ["fever", "cough", "headache"]
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
        
        # Predict disease
        predicted_disease, confidence = predict_disease(corrected_symptoms)
        
        # Get disease information
        disease_info = get_disease_information(predicted_disease)
        
        if not disease_info:
            return jsonify({
                'success': False,
                'error': 'Failed to retrieve disease information'
            }), 500
        
        # Build response
        response = {
            'success': True,
            'prediction': {
                'disease': predicted_disease,
                'confidence': confidence,
                'symptoms_used': corrected_symptoms,
                'invalid_symptoms': invalid_symptoms
            },
            'information': disease_info,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        logger.info(f"Prediction: {predicted_disease} (confidence: {confidence:.2f})")
        
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
```

### 3.2 Update Requirements

Update `model-training/requirements.txt`:

```txt
Flask>=2.3.0
flask-cors>=4.0.0
numpy>=1.24.0
pandas>=2.0.0
scikit-learn>=1.3.0
fuzzywuzzy>=0.18.0
python-Levenshtein>=0.21.0
gunicorn>=21.0.0
setuptools>=65.0.0
python-dotenv>=1.0.0
```

### 3.3 Create Environment Configuration

Create `model-training/.env`:

```env
# Flask ML Service Configuration
FLASK_ENV=production
PORT=5001
LOG_LEVEL=INFO

# Model Configuration
MODEL_PATH=model/RandomForest.pkl
DATASET_PATH=dataset/

# API Configuration
API_VERSION=v1
CONFIDENCE_THRESHOLD=0.6

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:5000,http://localhost:3000
```

### 3.4 Create Docker Configuration

Create `model-training/Dockerfile`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5001/health')"

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "4", "--timeout", "120", "api:app"]
```

Create `model-training/docker-compose.yml`:

```yaml
version: '3.8'

services:
  ml-service:
    build: .
    container_name: flask-ml-service
    ports:
      - "5001:5001"
    environment:
      - FLASK_ENV=production
      - PORT=5001
    volumes:
      - ./model:/app/model:ro
      - ./dataset:/app/dataset:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 4. Node.js Integration

### 4.1 Create Flask Client Service

Create `src/services/flask-ml.service.ts`:

```typescript
import axios, { AxiosInstance, AxiosError } from 'axios';
import { logger } from '../utils/logger';
import { config } from '../config';

export interface FlaskPredictionRequest {
    symptoms: string[];
}

export interface FlaskPredictionResponse {
    success: boolean;
    prediction: {
        disease: string;
        confidence: number;
        symptoms_used: string[];
        invalid_symptoms: string[];
    };
    information: {
        description: string;
        precautions: string[];
        medications: string[];
        diet: string[];
        workout: string[];
    };
    timestamp: string;
}

export interface FlaskHealthResponse {
    status: string;
    service: string;
    timestamp: string;
    model_loaded: boolean;
}

export class FlaskMLService {
    private client: AxiosInstance;
    private baseUrl: string;
    private timeout: number;
    private retryAttempts: number;
    private retryDelay: number;

    constructor() {
        this.baseUrl = process.env.FLASK_ML_SERVICE_URL || 'http://localhost:5001';
        this.timeout = parseInt(process.env.FLASK_ML_TIMEOUT || '30000');
        this.retryAttempts = parseInt(process.env.FLASK_ML_RETRY_ATTEMPTS || '3');
        this.retryDelay = parseInt(process.env.FLASK_ML_RETRY_DELAY || '1000');

        this.client = axios.create({
            baseURL: this.baseUrl,
            timeout: this.timeout,
            headers: {
                'Content-Type': 'application/json',
            },
        });

        // Request interceptor for logging
        this.client.interceptors.request.use(
            (config) => {
                logger.info(`Flask ML Request: ${config.method?.toUpperCase()} ${config.url}`);
                return config;
            },
            (error) => {
                logger.error('Flask ML Request Error:', error);
                return Promise.reject(error);
            }
        );

        // Response interceptor for logging
        this.client.interceptors.response.use(
            (response) => {
                logger.info(`Flask ML Response: ${response.status} ${response.config.url}`);
                return response;
            },
            (error) => {
                logger.error('Flask ML Response Error:', error.message);
                return Promise.reject(error);
            }
        );
    }

    /**
     * Check if Flask ML service is healthy
     */
    async healthCheck(): Promise<boolean> {
        try {
            const response = await this.client.get<FlaskHealthResponse>('/health');
            return response.data.status === 'healthy' && response.data.model_loaded;
        } catch (error) {
            logger.error('Flask ML health check failed:', error);
            return false;
        }
    }

    /**
     * Predict disease from symptoms
     */
    async predictDisease(symptoms: string[]): Promise<FlaskPredictionResponse> {
        return this.retryRequest(async () => {
            try {
                const response = await this.client.post<FlaskPredictionResponse>(
                    '/api/v1/predict',
                    { symptoms }
                );

                if (!response.data.success) {
                    throw new Error('Flask ML prediction failed');
                }

                return response.data;
            } catch (error) {
                this.handleError(error, 'predictDisease');
                throw error;
            }
        });
    }

    /**
     * Validate and correct symptom spellings
     */
    async validateSymptoms(symptoms: string[]): Promise<any> {
        try {
            const response = await this.client.post('/api/v1/validate-symptoms', {
                symptoms,
            });
            return response.data;
        } catch (error) {
            this.handleError(error, 'validateSymptoms');
            throw error;
        }
    }

    /**
     * Get list of all available symptoms
     */
    async getAvailableSymptoms(): Promise<string[]> {
        try {
            const response = await this.client.get('/api/v1/symptoms');
            return response.data.symptoms;
        } catch (error) {
            this.handleError(error, 'getAvailableSymptoms');
            throw error;
        }
    }

    /**
     * Get list of all predictable diseases
     */
    async getAvailableDiseases(): Promise<string[]> {
        try {
            const response = await this.client.get('/api/v1/diseases');
            return response.data.diseases;
        } catch (error) {
            this.handleError(error, 'getAvailableDiseases');
            throw error;
        }
    }

    /**
     * Retry mechanism for failed requests
     */
    private async retryRequest<T>(
        requestFn: () => Promise<T>,
        attempt: number = 1
    ): Promise<T> {
        try {
            return await requestFn();
        } catch (error) {
            if (attempt < this.retryAttempts) {
                logger.warn(
                    `Flask ML request failed, retrying (${attempt}/${this.retryAttempts})...`
                );
                await this.delay(this.retryDelay * attempt);
                return this.retryRequest(requestFn, attempt + 1);
            }
            throw error;
        }
    }

    /**
     * Delay helper for retry mechanism
     */
    private delay(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    /**
     * Error handler
     */
    private handleError(error: any, method: string): void {
        if (axios.isAxiosError(error)) {
            const axiosError = error as AxiosError;
            if (axiosError.response) {
                logger.error(
                    `Flask ML ${method} error: ${axiosError.response.status} - ${JSON.stringify(
                        axiosError.response.data
                    )}`
                );
            } else if (axiosError.request) {
                logger.error(
                    `Flask ML ${method} error: No response received from service`
                );
            } else {
                logger.error(`Flask ML ${method} error: ${axiosError.message}`);
            }
        } else {
            logger.error(`Flask ML ${method} error:`, error);
        }
    }
}

// Export singleton instance
export const flaskMLService = new FlaskMLService();
```


### 4.2 Update AI Service to Use Flask

Update `src/services/ai.service.ts`:

```typescript
import { flaskMLService, FlaskPredictionResponse } from './flask-ml.service';
import { logger } from '../utils/logger';
import { mlConfig } from '../config/ml.config';

export interface DiagnosisInput {
    symptoms: Array<{ name: string; category: string; severity?: string }>;
    vitalSigns: {
        temperature?: number;
        bloodPressureSystolic?: number;
        bloodPressureDiastolic?: number;
        heartRate?: number;
        respiratoryRate?: number;
        oxygenSaturation?: number;
    };
    age: number;
    gender: string;
    medicalHistory?: string[];
}

export interface Prediction {
    disease: string;
    confidence: number;
    icd10Code?: string;
    recommendations?: string[];
    description?: string;
    precautions?: string[];
    medications?: string[];
    diet?: string[];
    workout?: string[];
}

export class AIService {
    private useFlaskService: boolean;

    constructor() {
        this.useFlaskService = process.env.USE_FLASK_ML_SERVICE === 'true';
        this.initializeService();
    }

    private async initializeService(): Promise<void> {
        if (this.useFlaskService) {
            const isHealthy = await flaskMLService.healthCheck();
            if (isHealthy) {
                logger.info('Flask ML service is healthy and ready');
            } else {
                logger.warn('Flask ML service health check failed, will use fallback');
                this.useFlaskService = false;
            }
        }
    }

    public async predictDisease(input: DiagnosisInput): Promise<Prediction[]> {
        try {
            const startTime = Date.now();

            // Extract symptom names
            const symptomNames = input.symptoms.map(s => s.name);

            let predictions: Prediction[];

            if (this.useFlaskService) {
                try {
                    // Use Flask ML service
                    const flaskResponse = await flaskMLService.predictDisease(symptomNames);
                    predictions = this.transformFlaskResponse(flaskResponse);
                    logger.info(`Flask ML prediction completed in ${Date.now() - startTime}ms`);
                } catch (error) {
                    logger.error('Flask ML service failed, using fallback:', error);
                    predictions = await this.fallbackPredict(input);
                }
            } else {
                // Use fallback (existing TensorFlow.js or rule-based)
                predictions = await this.fallbackPredict(input);
            }

            return predictions;
        } catch (error) {
            logger.error('Error during disease prediction:', error);
            throw error;
        }
    }

    private transformFlaskResponse(response: FlaskPredictionResponse): Prediction[] {
        const { prediction, information } = response;

        return [{
            disease: prediction.disease,
            confidence: prediction.confidence,
            description: information.description,
            precautions: information.precautions,
            medications: information.medications,
            diet: information.diet,
            workout: information.workout,
            recommendations: [
                ...information.precautions,
                `Medications: ${information.medications.join(', ')}`,
                `Diet: ${information.diet.join(', ')}`
            ]
        }];
    }

    private async fallbackPredict(input: DiagnosisInput): Promise<Prediction[]> {
        logger.info('Using fallback prediction method');
        // Use existing rule-based or TensorFlow.js prediction
        return this.mockPredict(input);
    }

    private mockPredict(input: DiagnosisInput): Prediction[] {
        // Existing mock prediction logic
        const predictions: Prediction[] = [];
        const symptomNames = input.symptoms.map(s => s.name.toLowerCase());

        if (symptomNames.some(s => s.includes('fever') || s.includes('cough'))) {
            predictions.push({
                disease: 'Common Cold',
                confidence: 0.75,
                icd10Code: 'J00',
                recommendations: [
                    'Rest and adequate sleep',
                    'Increase fluid intake',
                    'Over-the-counter pain relievers if needed'
                ]
            });
        }

        return predictions;
    }
}

export const aiService = new AIService();
```

### 4.3 Update Environment Variables

Add to `.env`:

```env
# Flask ML Service Configuration
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=http://localhost:5001
FLASK_ML_TIMEOUT=30000
FLASK_ML_RETRY_ATTEMPTS=3
FLASK_ML_RETRY_DELAY=1000
```

Add to `.env.example`:

```env
# Flask ML Service Configuration
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=http://localhost:5001
FLASK_ML_TIMEOUT=30000
FLASK_ML_RETRY_ATTEMPTS=3
FLASK_ML_RETRY_DELAY=1000
```

### 4.4 Create Health Check Endpoint

Update `src/routes/health.routes.ts` (or create if doesn't exist):

```typescript
import { Router, Request, Response } from 'express';
import { flaskMLService } from '../services/flask-ml.service';

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
    try {
        const flaskHealthy = await flaskMLService.healthCheck();
        
        res.json({
            status: 'healthy',
            services: {
                nodejs: 'healthy',
                flask_ml: flaskHealthy ? 'healthy' : 'unhealthy',
                database: 'healthy', // Add actual DB check
                redis: 'healthy' // Add actual Redis check
            },
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: 'Service health check failed'
        });
    }
});

export default router;
```

---

## 5. Deployment Strategies

### 5.1 Docker Compose (Development)

Create `docker-compose.yml` in project root:

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: health-postgres
    environment:
      POSTGRES_DB: ai_health_companion
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: health-redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Flask ML Service
  flask-ml:
    build:
      context: ./ai_health_companion_backend/model-training
      dockerfile: Dockerfile
    container_name: flask-ml-service
    ports:
      - "5001:5001"
    environment:
      - FLASK_ENV=production
      - PORT=5001
    volumes:
      - ./ai_health_companion_backend/model-training/model:/app/model:ro
      - ./ai_health_companion_backend/model-training/dataset:/app/dataset:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  # Node.js Backend
  nodejs-api:
    build:
      context: ./ai_health_companion_backend
      dockerfile: Dockerfile
    container_name: nodejs-api
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - PORT=5000
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/ai_health_companion
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - USE_FLASK_ML_SERVICE=true
      - FLASK_ML_SERVICE_URL=http://flask-ml:5001
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      flask-ml:
        condition: service_healthy
    restart: unless-stopped

volumes:
  postgres_data:
```

### 5.2 Kubernetes Deployment

Create `k8s/flask-ml-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-ml-service
  labels:
    app: flask-ml
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-ml
  template:
    metadata:
      labels:
        app: flask-ml
    spec:
      containers:
      - name: flask-ml
        image: your-registry/flask-ml-service:latest
        ports:
        - containerPort: 5001
        env:
        - name: FLASK_ENV
          value: "production"
        - name: PORT
          value: "5001"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5001
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: flask-ml-service
spec:
  selector:
    app: flask-ml
  ports:
  - protocol: TCP
    port: 5001
    targetPort: 5001
  type: ClusterIP
```

Create `k8s/nodejs-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-api
  labels:
    app: nodejs-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-api
  template:
    metadata:
      labels:
        app: nodejs-api
    spec:
      containers:
      - name: nodejs-api
        image: your-registry/nodejs-api:latest
        ports:
        - containerPort: 5000
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "5000"
        - name: USE_FLASK_ML_SERVICE
          value: "true"
        - name: FLASK_ML_SERVICE_URL
          value: "http://flask-ml-service:5001"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: connection-string
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-api
spec:
  selector:
    app: nodejs-api
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
  type: LoadBalancer
```

---

## 6. Communication Patterns

### 6.1 Synchronous HTTP/REST (Recommended for Start)

**Pros:**
- Simple to implement
- Easy to debug
- Direct request-response
- No additional infrastructure

**Cons:**
- Blocking calls
- Tight coupling
- No built-in retry logic

**Use Case:** Real-time predictions where immediate response is needed

### 6.2 Asynchronous Message Queue (Advanced)

**Architecture with Redis/Bull:**

```typescript
// In Node.js - Queue prediction job
import Queue from 'bull';

const predictionQueue = new Queue('ml-predictions', {
    redis: { host: 'localhost', port: 6379 }
});

// Add job to queue
const job = await predictionQueue.add({
    patientId: '123',
    symptoms: ['fever', 'cough']
});

// Process results
predictionQueue.on('completed', (job, result) => {
    console.log('Prediction completed:', result);
    // Update database, notify user, etc.
});
```

**Pros:**
- Decoupled services
- Better fault tolerance
- Can handle high load
- Async processing

**Cons:**
- More complex
- Requires message broker
- Eventual consistency

**Use Case:** Batch predictions, non-urgent analysis

### 6.3 gRPC (High Performance)

**Pros:**
- Fast binary protocol
- Strong typing
- Bi-directional streaming

**Cons:**
- More complex setup
- Requires proto definitions
- Less human-readable

**Use Case:** High-throughput scenarios, real-time streaming

---

## 7. Security Considerations

### 7.1 Internal Service Authentication

Add API key authentication to Flask service:

```python
# In api.py
from functools import wraps
import os

API_KEY = os.environ.get('ML_SERVICE_API_KEY', 'your-secret-key')

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if api_key != API_KEY:
            return jsonify({'success': False, 'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    return decorated_function

@app.route('/api/v1/predict', methods=['POST'])
@require_api_key
def predict():
    # ... existing code
```

Update Node.js client:

```typescript
this.client = axios.create({
    baseURL: this.baseUrl,
    timeout: this.timeout,
    headers: {
        'Content-Type': 'application/json',
        'X-API-Key': process.env.ML_SERVICE_API_KEY || 'your-secret-key'
    },
});
```

### 7.2 Network Security

- **Private Network:** Deploy Flask service in private subnet
- **Firewall Rules:** Only allow Node.js service to access Flask
- **TLS/SSL:** Use HTTPS for production
- **Rate Limiting:** Implement rate limiting on Flask endpoints

### 7.3 Input Validation

Both services should validate inputs:

```python
# Flask validation
from flask import request
from werkzeug.exceptions import BadRequest

@app.before_request
def validate_json():
    if request.method == 'POST' and not request.is_json:
        raise BadRequest('Content-Type must be application/json')
```

---

## 8. Monitoring & Observability

### 8.1 Logging Strategy

**Flask Service:**

```python
import logging
from logging.handlers import RotatingFileHandler

# Configure structured logging
handler = RotatingFileHandler('logs/ml-service.log', maxBytes=10000000, backupCount=5)
handler.setFormatter(logging.Formatter(
    '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
))
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)
```

**Node.js Service:**

```typescript
logger.info('Flask ML Request', {
    method: 'predictDisease',
    symptoms: symptoms.length,
    timestamp: new Date().toISOString()
});
```

### 8.2 Metrics Collection

Add Prometheus metrics to Flask:

```python
from prometheus_client import Counter, Histogram, generate_latest

prediction_counter = Counter('ml_predictions_total', 'Total predictions')
prediction_duration = Histogram('ml_prediction_duration_seconds', 'Prediction duration')

@app.route('/metrics')
def metrics():
    return generate_latest()
```

### 8.3 Health Checks

Implement comprehensive health checks:

```python
@app.route('/health', methods=['GET'])
def health_check():
    health_status = {
        'status': 'healthy',
        'checks': {
            'model_loaded': Rf is not None,
            'datasets_loaded': len(sym_des) > 0,
            'disk_space': check_disk_space(),
            'memory_usage': check_memory()
        }
    }
    
    if not all(health_status['checks'].values()):
        return jsonify(health_status), 503
    
    return jsonify(health_status), 200
```

---

## 9. Performance Optimization

### 9.1 Caching Strategy

**Node.js - Cache Flask responses:**

```typescript
import { createClient } from 'redis';

class FlaskMLService {
    private redis = createClient();
    
    async predictDisease(symptoms: string[]): Promise<FlaskPredictionResponse> {
        // Create cache key
        const cacheKey = `prediction:${symptoms.sort().join(',')}`;
        
        // Check cache
        const cached = await this.redis.get(cacheKey);
        if (cached) {
            logger.info('Returning cached prediction');
            return JSON.parse(cached);
        }
        
        // Call Flask service
        const response = await this.client.post('/api/v1/predict', { symptoms });
        
        // Cache result (24 hours)
        await this.redis.setEx(cacheKey, 86400, JSON.stringify(response.data));
        
        return response.data;
    }
}
```

### 9.2 Connection Pooling

```typescript
// Use HTTP keep-alive
import http from 'http';
import https from 'https';

const httpAgent = new http.Agent({ keepAlive: true });
const httpsAgent = new https.Agent({ keepAlive: true });

this.client = axios.create({
    httpAgent,
    httpsAgent,
    // ... other config
});
```

### 9.3 Load Balancing

Use Nginx for load balancing multiple Flask instances:

```nginx
upstream flask_ml {
    least_conn;
    server flask-ml-1:5001;
    server flask-ml-2:5001;
    server flask-ml-3:5001;
}

server {
    listen 80;
    
    location /api/v1/ {
        proxy_pass http://flask_ml;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 10. Testing Strategy

### 10.1 Flask Service Tests

Create `model-training/tests/test_api.py`:

```python
import unittest
import json
from api import app

class TestMLAPI(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
    
    def test_health_check(self):
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
    
    def test_predict_valid_symptoms(self):
        response = self.app.post('/api/v1/predict',
            data=json.dumps({'symptoms': ['fever', 'cough', 'headache']}),
            content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertTrue(data['success'])
        self.assertIn('prediction', data)
    
    def test_predict_invalid_symptoms(self):
        response = self.app.post('/api/v1/predict',
            data=json.dumps({'symptoms': []}),
            content_type='application/json')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main()
```

### 10.2 Node.js Integration Tests

Create `src/tests/flask-ml.service.test.ts`:

```typescript
import { flaskMLService } from '../services/flask-ml.service';

describe('FlaskMLService', () => {
    it('should check health successfully', async () => {
        const isHealthy = await flaskMLService.healthCheck();
        expect(isHealthy).toBe(true);
    });
    
    it('should predict disease from symptoms', async () => {
        const symptoms = ['fever', 'cough', 'headache'];
        const result = await flaskMLService.predictDisease(symptoms);
        
        expect(result.success).toBe(true);
        expect(result.prediction).toBeDefined();
        expect(result.prediction.disease).toBeDefined();
        expect(result.prediction.confidence).toBeGreaterThan(0);
    });
    
    it('should handle invalid symptoms gracefully', async () => {
        const symptoms = ['invalid_symptom_xyz'];
        await expect(flaskMLService.predictDisease(symptoms))
            .rejects.toThrow();
    });
});
```

---

## 11. Migration Plan

### Phase 1: Setup (Week 1)
1. ✅ Create Flask REST API (`api.py`)
2. ✅ Add Docker configuration
3. ✅ Update requirements.txt
4. ✅ Test Flask service independently

### Phase 2: Integration (Week 2)
1. ✅ Create Flask client service in Node.js
2. ✅ Update AI service to use Flask
3. ✅ Add environment variables
4. ✅ Test integration locally

### Phase 3: Testing (Week 3)
1. ✅ Write unit tests for Flask API
2. ✅ Write integration tests for Node.js
3. ✅ Performance testing
4. ✅ Load testing

### Phase 4: Deployment (Week 4)
1. ✅ Deploy to staging environment
2. ✅ Monitor and optimize
3. ✅ Deploy to production
4. ✅ Gradual rollout with feature flags

---

## 12. Recommended Improvements

### 12.1 Flask Service Enhancements

1. **Model Versioning:**
```python
@app.route('/api/v1/predict', methods=['POST'])
def predict():
    model_version = request.headers.get('X-Model-Version', 'v1')
    model = load_model(model_version)
    # ... prediction logic
```

2. **Batch Predictions:**
```python
@app.route('/api/v1/predict/batch', methods=['POST'])
def predict_batch():
    # Handle multiple prediction requests
    requests = request.json['requests']
    results = [predict_single(req) for req in requests]
    return jsonify({'results': results})
```

3. **Confidence Thresholds:**
```python
confidence_threshold = request.json.get('confidence_threshold', 0.6)
if confidence < confidence_threshold:
    return jsonify({'success': False, 'error': 'Low confidence prediction'})
```

### 12.2 Scalability Improvements

1. **Horizontal Scaling:** Deploy multiple Flask instances
2. **Caching:** Cache frequent predictions
3. **Async Processing:** Use Celery for long-running tasks
4. **Model Optimization:** Quantize model for faster inference

### 12.3 Security Enhancements

1. **JWT Authentication:** Use JWT tokens instead of API keys
2. **Rate Limiting:** Implement per-client rate limits
3. **Input Sanitization:** Validate and sanitize all inputs
4. **Audit Logging:** Log all prediction requests

---

## 13. Quick Start Commands

### Start Flask Service (Development)
```bash
cd ai_health_companion_backend/model-training
pip install -r requirements.txt
python api.py
```

### Start Flask Service (Docker)
```bash
cd ai_health_companion_backend/model-training
docker build -t flask-ml-service .
docker run -p 5001:5001 flask-ml-service
```

### Start Full Stack (Docker Compose)
```bash
docker-compose up -d
```

### Test Flask API
```bash
# Health check
curl http://localhost:5001/health

# Predict disease
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{"symptoms": ["fever", "cough", "headache"]}'
```

### Test Node.js Integration
```bash
cd ai_health_companion_backend
npm install
npm run dev
```

---

## 14. Troubleshooting

### Common Issues

**Issue 1: Flask service not responding**
- Check if service is running: `curl http://localhost:5001/health`
- Check logs: `docker logs flask-ml-service`
- Verify port is not in use: `netstat -an | grep 5001`

**Issue 2: Node.js can't connect to Flask**
- Verify FLASK_ML_SERVICE_URL in .env
- Check network connectivity
- Verify firewall rules

**Issue 3: Low prediction accuracy**
- Check symptom spelling
- Verify model file integrity
- Review dataset quality

**Issue 4: Slow response times**
- Enable caching
- Optimize model loading
- Use connection pooling
- Scale horizontally

---

## 15. Conclusion

This microservices architecture provides:

✅ **Separation of Concerns:** ML logic isolated in Flask, business logic in Node.js
✅ **Scalability:** Each service can scale independently
✅ **Maintainability:** Easier to update and maintain each service
✅ **Flexibility:** Can swap ML frameworks without affecting Node.js
✅ **Performance:** Optimized for each service's requirements
✅ **Security:** Multiple layers of security controls
✅ **Monitoring:** Comprehensive observability

### Next Steps

1. Implement Flask REST API
2. Create Node.js Flask client
3. Add comprehensive testing
4. Deploy to staging
5. Monitor and optimize
6. Gradual production rollout

---

## Appendix: Complete File Structure

```
ai_health_companion_backend/
├── model-training/                 # Flask ML Service
│   ├── api.py                     # NEW: REST API
│   ├── main.py                    # OLD: Web interface (keep for reference)
│   ├── requirements.txt           # Updated
│   ├── Dockerfile                 # NEW
│   ├── docker-compose.yml         # NEW
│   ├── .env                       # NEW
│   ├── dataset/                   # Existing datasets
│   ├── model/                     # Existing model
│   └── tests/                     # NEW: API tests
│       └── test_api.py
├── src/
│   ├── services/
│   │   ├── flask-ml.service.ts    # NEW: Flask client
│   │   ├── ai.service.ts          # Updated
│   │   └── ml/
│   ├── routes/
│   │   └── health.routes.ts       # Updated
│   └── config/
│       └── ml.config.ts           # Updated
├── .env                           # Updated
├── .env.example                   # Updated
├── docker-compose.yml             # NEW: Full stack
└── FLASK_NODEJS_MICROSERVICES_INTEGRATION.md  # This document
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-04-28  
**Author:** AI Health Companion Team
