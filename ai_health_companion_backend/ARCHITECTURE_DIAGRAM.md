# Microservices Architecture Diagrams

## 1. High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Flutter App  │  │  Admin Web   │  │  Mobile Web  │          │
│  │   (Mobile)   │  │  Dashboard   │  │   Browser    │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼─────────────────┘
          │                  │                  │
          └──────────────────┴──────────────────┘
                             │
                    HTTPS/REST API
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                    API GATEWAY (Optional)                         │
│                    Nginx / Traefik / AWS ALB                      │
└────────────────────────────┬─────────────────────────────────────┘
                             │
          ┌──────────────────┴──────────────────┐
          │                                     │
          ▼                                     ▼
┌─────────────────────┐              ┌─────────────────────┐
│   NODE.JS BACKEND   │              │   FLASK ML SERVICE  │
│    (Port 5000)      │◄────HTTP────►│    (Port 5001)      │
│                     │   REST API   │                     │
│ ┌─────────────────┐ │              │ ┌─────────────────┐ │
│ │ Authentication  │ │              │ │   ML Model      │ │
│ │ Authorization   │ │              │ │   (Random       │ │
│ │ Rate Limiting   │ │              │ │    Forest)      │ │
│ └─────────────────┘ │              │ └─────────────────┘ │
│                     │              │                     │
│ ┌─────────────────┐ │              │ ┌─────────────────┐ │
│ │ Business Logic  │ │              │ │  Symptom        │ │
│ │ FHIR Integration│ │              │ │  Processing     │ │
│ │ Validation      │ │              │ │  Spell Check    │ │
│ └─────────────────┘ │              │ └─────────────────┘ │
│                     │              │                     │
│ ┌─────────────────┐ │              │ ┌─────────────────┐ │
│ │ Flask ML Client │ │              │ │  Medical Data   │ │
│ │ Retry Logic     │ │              │ │  Retrieval      │ │
│ │ Fallback        │ │              │ │  (CSV Datasets) │ │
│ └─────────────────┘ │              │ └─────────────────┘ │
└──────────┬──────────┘              └─────────────────────┘
           │
           ├──────────────┬──────────────┐
           │              │              │
           ▼              ▼              ▼
    ┌───────────┐  ┌───────────┐  ┌───────────┐
    │PostgreSQL │  │   Redis   │  │  Socket   │
    │ Database  │  │   Cache   │  │    IO     │
    └───────────┘  └───────────┘  └───────────┘
```

## 2. Request Flow Diagram

```
┌─────────┐
│ Client  │
└────┬────┘
     │ 1. POST /api/v1/diagnosis/predict
     │    {symptoms, vitalSigns, age, gender}
     ▼
┌─────────────────────────────────────────────────┐
│           NODE.JS API (Port 5000)               │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │ 2. Authentication Middleware             │  │
│  │    - Verify JWT token                    │  │
│  │    - Check user permissions              │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 3. Validation Middleware                 │  │
│  │    - Validate request body               │  │
│  │    - Check required fields               │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 4. AI Service                            │  │
│  │    - Extract symptoms                    │  │
│  │    - Check if Flask service enabled      │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│                 │ 5. HTTP POST /api/v1/predict  │
│                 │    {symptoms: ["fever",...]}  │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│         FLASK ML SERVICE (Port 5001)            │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │ 6. Request Validation                    │  │
│  │    - Check JSON format                   │  │
│  │    - Validate symptoms array             │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 7. Symptom Processing                    │  │
│  │    - Fuzzy matching (spell correction)   │  │
│  │    - Symptom vectorization (132 dims)    │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 8. ML Model Inference                    │  │
│  │    - Random Forest prediction            │  │
│  │    - Calculate confidence                │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 9. Medical Data Retrieval                │  │
│  │    - Description from CSV                │  │
│  │    - Precautions, medications, diet      │  │
│  │    - Workout recommendations             │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│                 │ 10. JSON Response             │
│                 │     {success, prediction,     │
│                 │      information}             │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│           NODE.JS API (Port 5000)               │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │ 11. Response Transformation              │  │
│  │     - Map Flask response to API format   │  │
│  │     - Add ICD-10 codes                   │  │
│  │     - Format recommendations             │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│  ┌──────────────▼───────────────────────────┐  │
│  │ 12. Database Operations                  │  │
│  │     - Save diagnosis record              │  │
│  │     - Update patient history             │  │
│  │     - Log prediction                     │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                               │
│                 │ 13. Final Response            │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
             ┌─────────┐
             │ Client  │
             └─────────┘
```

## 3. Data Flow Diagram

```
INPUT SYMPTOMS
["fever", "cough", "headache"]
         │
         ▼
┌────────────────────────┐
│  Spell Correction      │
│  (Fuzzy Matching)      │
│  Threshold: 80%        │
└────────┬───────────────┘
         │
         ▼
CORRECTED SYMPTOMS
["fever", "cough", "headache"]
         │
         ▼
┌────────────────────────┐
│  Symptom Vectorization │
│  132-dimensional       │
│  Binary vector         │
└────────┬───────────────┘
         │
         ▼
SYMPTOM VECTOR
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,...]
         │
         ▼
┌────────────────────────┐
│  Random Forest Model   │
│  41 disease classes    │
│  Trained classifier    │
└────────┬───────────────┘
         │
         ▼
PREDICTION
Disease: "Common Cold"
Confidence: 0.85
         │
         ▼
┌────────────────────────┐
│  Medical Data Lookup   │
│  - Description         │
│  - Precautions (4)     │
│  - Medications         │
│  - Diet                │
│  - Workout             │
└────────┬───────────────┘
         │
         ▼
COMPLETE RESPONSE
{
  disease: "Common Cold",
  confidence: 0.85,
  description: "...",
  precautions: [...],
  medications: [...],
  diet: [...],
  workout: [...]
}
```

## 4. Error Handling Flow

```
┌─────────────────┐
│ Node.js Request │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ Try: Call Flask Service │
└────────┬────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
SUCCESS    FAILURE
    │         │
    │    ┌────▼─────────────────┐
    │    │ Retry Attempt 1      │
    │    │ Wait: 1 second       │
    │    └────┬─────────────────┘
    │         │
    │    ┌────┴────┐
    │    │         │
    │    ▼         ▼
    │ SUCCESS   FAILURE
    │    │         │
    │    │    ┌────▼─────────────────┐
    │    │    │ Retry Attempt 2      │
    │    │    │ Wait: 2 seconds      │
    │    │    └────┬─────────────────┘
    │    │         │
    │    │    ┌────┴────┐
    │    │    │         │
    │    │    ▼         ▼
    │    │ SUCCESS   FAILURE
    │    │    │         │
    │    │    │    ┌────▼─────────────────┐
    │    │    │    │ Retry Attempt 3      │
    │    │    │    │ Wait: 3 seconds      │
    │    │    │    └────┬─────────────────┘
    │    │    │         │
    │    │    │    ┌────┴────┐
    │    │    │    │         │
    │    │    │    ▼         ▼
    │    │    │ SUCCESS   FAILURE
    │    │    │    │         │
    └────┴────┴────┘         │
         │                   │
         ▼                   ▼
┌─────────────────┐   ┌──────────────────┐
│ Return Flask    │   │ Use Fallback     │
│ Response        │   │ (Rule-based)     │
└─────────────────┘   └──────────────────┘
```

## 5. Deployment Architecture

### Development Environment
```
┌──────────────────────────────────────────┐
│         Developer Machine                 │
│                                          │
│  ┌────────────┐      ┌────────────┐    │
│  │  Terminal  │      │  Terminal  │    │
│  │     1      │      │     2      │    │
│  │            │      │            │    │
│  │  Flask     │      │  Node.js   │    │
│  │  python    │      │  npm run   │    │
│  │  api.py    │      │  dev       │    │
│  │            │      │            │    │
│  │ Port 5001  │      │ Port 5000  │    │
│  └────────────┘      └────────────┘    │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │     PostgreSQL (Local)             │ │
│  │     Port 5432                      │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │     Redis (Local)                  │ │
│  │     Port 6379                      │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

### Docker Compose Environment
```
┌──────────────────────────────────────────────────┐
│              Docker Host                          │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │  Docker Network: health-network             │ │
│  │                                             │ │
│  │  ┌──────────────┐    ┌──────────────┐     │ │
│  │  │   postgres   │    │    redis     │     │ │
│  │  │  Container   │    │  Container   │     │ │
│  │  │  Port: 5432  │    │  Port: 6379  │     │ │
│  │  └──────────────┘    └──────────────┘     │ │
│  │                                             │ │
│  │  ┌──────────────┐    ┌──────────────┐     │ │
│  │  │  flask-ml    │    │  nodejs-api  │     │ │
│  │  │  Container   │◄───┤  Container   │     │ │
│  │  │  Port: 5001  │    │  Port: 5000  │     │ │
│  │  └──────────────┘    └──────────────┘     │ │
│  │                                             │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
│  Exposed Ports:                                   │
│  - 5000 → nodejs-api                             │
│  - 5001 → flask-ml (optional, for testing)       │
└──────────────────────────────────────────────────┘
```

### Production Kubernetes Environment
```
┌────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                     │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Ingress Controller                   │  │
│  │         (Nginx / Traefik / AWS ALB)              │  │
│  │              HTTPS / SSL Termination              │  │
│  └────────────────┬─────────────────────────────────┘  │
│                   │                                     │
│       ┌───────────┴───────────┐                        │
│       │                       │                        │
│       ▼                       ▼                        │
│  ┌─────────────┐       ┌─────────────┐                │
│  │  Node.js    │       │  Flask ML   │                │
│  │  Service    │       │  Service    │                │
│  │  (ClusterIP)│       │  (ClusterIP)│                │
│  └──────┬──────┘       └──────┬──────┘                │
│         │                     │                        │
│    ┌────┴────┐           ┌────┴────┐                  │
│    │         │           │         │                  │
│    ▼         ▼           ▼         ▼                  │
│  ┌───┐     ┌───┐       ┌───┐     ┌───┐               │
│  │Pod│     │Pod│       │Pod│     │Pod│               │
│  │ 1 │     │ 2 │       │ 1 │     │ 2 │               │
│  └───┘     └───┘       └───┘     └───┘               │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           PostgreSQL StatefulSet                  │  │
│  │           Persistent Volume                       │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Redis Deployment                        │  │
│  │           (or Managed Service)                    │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

## 6. Security Architecture

```
┌─────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                     │
│                                                      │
│  Layer 1: Network Security                          │
│  ┌────────────────────────────────────────────────┐ │
│  │ - Firewall rules                               │ │
│  │ - Private subnets for Flask                    │ │
│  │ - VPC / Security groups                        │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Layer 2: API Gateway                               │
│  ┌────────────────────────────────────────────────┐ │
│  │ - Rate limiting                                │ │
│  │ - DDoS protection                              │ │
│  │ - SSL/TLS termination                          │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Layer 3: Authentication                            │
│  ┌────────────────────────────────────────────────┐ │
│  │ - JWT token validation                         │ │
│  │ - User permissions check                       │ │
│  │ - Session management                           │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Layer 4: Service-to-Service                        │
│  ┌────────────────────────────────────────────────┐ │
│  │ - API key authentication                       │ │
│  │ - Internal network only                        │ │
│  │ - Request signing                              │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Layer 5: Input Validation                          │
│  ┌────────────────────────────────────────────────┐ │
│  │ - Schema validation                            │ │
│  │ - Sanitization                                 │ │
│  │ - Type checking                                │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Layer 6: Data Protection                           │
│  ┌────────────────────────────────────────────────┐ │
│  │ - Encryption at rest                           │ │
│  │ - Encryption in transit                        │ │
│  │ - PII protection                               │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 7. Monitoring & Observability

```
┌─────────────────────────────────────────────────────┐
│              MONITORING STACK                        │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           Application Metrics                   │ │
│  │  - Request count                               │ │
│  │  - Response time                               │ │
│  │  - Error rate                                  │ │
│  │  - Prediction confidence                       │ │
│  └────────────┬───────────────────────────────────┘ │
│               │                                      │
│               ▼                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           Prometheus                            │ │
│  │           (Metrics Collection)                  │ │
│  └────────────┬───────────────────────────────────┘ │
│               │                                      │
│               ▼                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           Grafana                               │ │
│  │           (Visualization)                       │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           Logging                               │ │
│  │  - Winston (Node.js)                           │ │
│  │  - Python logging (Flask)                      │ │
│  └────────────┬───────────────────────────────────┘ │
│               │                                      │
│               ▼                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           ELK Stack / CloudWatch                │ │
│  │           (Log Aggregation)                     │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │           Health Checks                         │ │
│  │  - /health endpoints                           │ │
│  │  - Liveness probes                             │ │
│  │  - Readiness probes                            │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

These diagrams provide a visual representation of how the Flask ML service integrates with your Node.js backend as microservices. Use them as reference when implementing and explaining the architecture to your team.
