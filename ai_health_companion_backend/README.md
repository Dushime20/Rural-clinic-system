# AI Health Companion - Backend API

Backend REST API for the AI Health Companion mobile application, providing disease diagnosis, patient management, and data synchronization services for rural clinics.

## 🚀 Features

- **RESTful API** - Clean, well-documented API endpoints
- **AI Disease Diagnosis** - TensorFlow-powered disease prediction
- **Offline-First Sync** - Intelligent data synchronization
- **FHIR/HL7 Compliant** - Healthcare data standards
- **HIPAA Compliant** - Healthcare privacy and security
- **Role-Based Access Control** - Secure user permissions
- **Real-time Updates** - WebSocket support for live data
- **Comprehensive Logging** - Winston-based logging system
- **API Documentation** - Swagger/OpenAPI documentation

## 📋 Prerequisites

- Node.js >= 18.0.0
- MongoDB >= 6.0
- Redis >= 7.0
- npm >= 9.0.0

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/ai-health-companion-backend.git
   cd ai-health-companion-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run database migrations**
   ```bash
   npm run migrate
   ```

5. **Seed initial data (optional)**
   ```bash
   npm run seed
   ```

## 🏃 Running the Application

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm run build
npm start
```

### Running Tests
```bash
npm test
npm run test:watch
```

## 📁 Project Structure

```
src/
├── config/              # Configuration files
├── controllers/         # Request handlers
├── models/             # Database models
├── routes/             # API routes
├── services/           # Business logic
├── middleware/         # Express middleware
├── utils/              # Utility functions
├── validators/         # Input validation
├── types/              # TypeScript types
├── database/           # Database setup & migrations
├── ai/                 # AI model integration
└── server.ts           # Application entry point
```

## 🔌 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout

### Patients
- `GET /api/v1/patients` - List all patients
- `POST /api/v1/patients` - Create new patient
- `GET /api/v1/patients/:id` - Get patient details
- `PUT /api/v1/patients/:id` - Update patient
- `DELETE /api/v1/patients/:id` - Delete patient

### Diagnosis
- `POST /api/v1/diagnosis` - Create AI diagnosis
- `GET /api/v1/diagnosis/:id` - Get diagnosis details
- `GET /api/v1/patients/:patientId/diagnoses` - Get patient diagnoses

### Sync
- `POST /api/v1/sync/push` - Push local changes
- `GET /api/v1/sync/pull` - Pull server changes
- `GET /api/v1/sync/status` - Get sync status

### Analytics
- `GET /api/v1/analytics/dashboard` - Dashboard statistics
- `GET /api/v1/analytics/diagnoses` - Diagnosis trends
- `GET /api/v1/analytics/patients` - Patient demographics

## 🔒 Security

- **Encryption**: AES-256-GCM for data at rest
- **Authentication**: JWT-based authentication
- **Authorization**: Role-based access control (RBAC)
- **Rate Limiting**: Protection against abuse
- **Input Validation**: Comprehensive request validation
- **HTTPS**: TLS 1.3 in production
- **CORS**: Configurable cross-origin policies

## 📊 Database Schema

See [docs/database-schema.md](docs/database-schema.md) for detailed schema documentation.

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm test -- --coverage
```

## 📚 API Documentation

Access Swagger documentation at: `http://localhost:5000/api-docs`

## 🚀 Deployment

See [docs/deployment.md](docs/deployment.md) for deployment instructions.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 📞 Support

- **Email**: tech-support@ruralclinic.health
- **Documentation**: https://docs.ruralclinic.health
- **Issues**: https://github.com/ruralclinic/ai-health-companion-backend/issues
