# AI Health Companion Backend - Project Structure

## 📁 Complete Directory Structure

```
ai_health_companion_backend/
├── src/
│   ├── config/
│   │   ├── index.ts                 # Main configuration
│   │   └── swagger.ts               # API documentation config
│   ├── controllers/
│   │   ├── auth.controller.ts       # Authentication logic
│   │   ├── patient.controller.ts    # Patient management
│   │   └── diagnosis.controller.ts  # AI diagnosis
│   ├── database/
│   │   ├── data-source.ts           # TypeORM DataSource
│   │   └── migrations/              # Database migrations
│   ├── middleware/
│   │   ├── auth.ts                  # JWT authentication
│   │   ├── error-handler.ts         # Error handling
│   │   ├── not-found.ts             # 404 handler
│   │   └── rate-limiter.ts          # Rate limiting
│   ├── models/
│   │   ├── User.ts                  # User schema
│   │   ├── Patient.ts               # Patient schema
│   │   └── Diagnosis.ts             # Diagnosis schema
│   ├── routes/
│   │   ├── index.ts                 # Route aggregator
│   │   ├── auth.routes.ts           # Auth endpoints
│   │   ├── patient.routes.ts        # Patient endpoints
│   │   ├── diagnosis.routes.ts      # Diagnosis endpoints
│   │   ├── sync.routes.ts           # Sync endpoints
│   │   └── analytics.routes.ts      # Analytics endpoints
│   ├── services/
│   │   └── ai.service.ts            # AI prediction service
│   ├── utils/
│   │   └── logger.ts                # Winston logger
│   ├── app.ts                       # Express application setup
│   └── server.ts                    # Application entry point
├── logs/                            # Log files (auto-created)
├── uploads/                         # File uploads (auto-created)
├── models/                          # AI model files
├── .env.example                     # Environment template
├── .gitignore                       # Git ignore rules
├── package.json                     # Dependencies
├── tsconfig.json                    # TypeScript config
└── README.md                        # Documentation
```

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd ai_health_companion_backend
npm install
```

### 2. Set Up Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Start PostgreSQL
```bash
# Make sure PostgreSQL is running on localhost:5432
# Create database: createdb ai_health_companion
# Or update DATABASE_URL in .env
```

### 4. Run Database Migrations
```bash
npm run migration:run
```

### 5. Run Development Server
```bash
npm run dev
```

### 6. Access API Documentation
```
http://localhost:5000/api-docs
```

## 📊 Database Models

### User Model
- Authentication and authorization
- Role-based access control (Admin, Health Worker, Clinic Staff, Supervisor)
- Password hashing with bcrypt
- JWT token management

### Patient Model
- Complete patient demographics
- Medical history and allergies
- Vital signs tracking
- Sync status for offline-first functionality

### Diagnosis Model
- AI-powered disease predictions
- Symptom and vital signs recording
- Treatment recommendations
- Prescription management
- Follow-up tracking

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt with configurable rounds
- **Rate Limiting**: Protection against brute force attacks
- **CORS**: Configurable cross-origin resource sharing
- **Helmet**: Security headers
- **Input Validation**: Request validation and sanitization
- **Role-Based Access**: Granular permission control

## 🧠 AI Service

The AI service provides:
- Disease prediction based on symptoms and vital signs
- Confidence scoring for predictions
- Treatment recommendations
- ICD-10 code mapping
- Extensible for TensorFlow Lite model integration

## 🔄 Sync Architecture

Offline-first design with:
- Push/pull synchronization
- Conflict resolution based on version numbers
- Batch processing for efficiency
- Sync status tracking
- Automatic retry mechanism

## 📈 Analytics

Dashboard provides:
- Patient demographics (age, gender distribution)
- Disease distribution and trends
- AI prediction accuracy metrics
- Clinic performance statistics

## 🛠️ API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Logout

### Patients
- `GET /api/v1/patients` - List patients (with pagination & search)
- `POST /api/v1/patients` - Create patient
- `GET /api/v1/patients/:id` - Get patient details
- `PUT /api/v1/patients/:id` - Update patient
- `DELETE /api/v1/patients/:id` - Soft delete patient

### Diagnosis
- `POST /api/v1/diagnosis` - Create AI diagnosis
- `GET /api/v1/diagnosis/:id` - Get diagnosis
- `PUT /api/v1/diagnosis/:id` - Update diagnosis
- `GET /api/v1/patients/:patientId/diagnoses` - Patient diagnosis history

### Sync
- `POST /api/v1/sync/push` - Push local changes
- `GET /api/v1/sync/pull` - Pull server changes
- `GET /api/v1/sync/status` - Get sync status

### Analytics
- `GET /api/v1/analytics/dashboard` - Dashboard statistics
- `GET /api/v1/analytics/diagnoses` - Diagnosis trends
- `GET /api/v1/analytics/patients` - Patient demographics

## 🔧 Configuration

Key environment variables:
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret
- `ENCRYPTION_KEY` - Data encryption key
- `AI_MODEL_PATH` - Path to AI model file

## 📝 Development Commands

```bash
# Development mode with hot reload
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run lint:fix
```

## 🎯 Next Steps

1. **Install dependencies**: `npm install`
2. **Configure environment**: Copy `.env.example` to `.env`
3. **Start MongoDB**: Ensure MongoDB is running
4. **Run development server**: `npm run dev`
5. **Test API**: Visit `http://localhost:5000/api-docs`

## 📚 Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [TypeORM Documentation](https://typeorm.io/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [JWT Best Practices](https://jwt.io/)
- [FHIR Standards](https://www.hl7.org/fhir/)

---

**Built with ❤️ for rural healthcare workers worldwide**
