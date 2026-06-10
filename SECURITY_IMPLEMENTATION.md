# Security Implementation - Clinic Specialized Recommendations

## Overview

This document outlines the security measures implemented for the Clinic Specialized Recommendations feature and the overall AI Health Companion backend.

---

## 1. Rate Limiting

### Implementation

All API endpoints are protected with rate limiting to prevent abuse and ensure system stability.

**File**: `ai_health_companion_backend/src/middleware/rate-limiter.ts`

### Rate Limits Applied

| Endpoint Category | Window | Max Requests | Key | Applied To |
|-------------------|--------|--------------|-----|------------|
| Authentication | 15 min | 5 | IP | `/api/auth/login`, `/api/auth/register`, `/api/auth/forgot-password` |
| Password Change | 15 min | 3 | User ID | `/api/auth/change-password` |
| Diagnosis | 1 hour | 20 | User ID | `/api/diagnosis` |
| Clinic Search | 1 minute | 100 | IP | `/api/clinics/search` |
| Clinic Creation | 1 minute | 10 | Admin User ID | `/api/admin/clinics` (POST) |
| Admin Operations | 15 min | 200 | Admin User ID | All `/api/admin/*` routes |
| General API | 15 min | 100 | IP | All other routes |

### Benefits

- **Brute Force Protection**: Limits failed login attempts
- **DoS Prevention**: Prevents overwhelming the server
- **Resource Management**: Ensures fair usage across users
- **Abuse Prevention**: Limits automated scraping or data harvesting

### Response Format

When rate limit is exceeded:
```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again later.",
  "retryAfter": "2024-01-10T15:30:00Z"
}
```

HTTP Status: `429 Too Many Requests`

---

## 2. Input Validation

### Implementation

All user inputs are validated using **express-validator** before processing.

**Files**:
- `ai_health_companion_backend/src/controllers/admin-clinic.controller.ts`
- `ai_health_companion_backend/src/controllers/clinic-manager.controller.ts`
- `ai_health_companion_backend/src/controllers/clinics.controller.ts`

### Validation Rules

#### Clinic Creation (`POST /api/admin/clinics`)

| Field | Validation |
|-------|-----------|
| `name` | Required, non-empty string |
| `managerName` | Required, non-empty string |
| `email` | Required, valid email format |
| `phoneNumber` | Optional, string |
| `latitude` | Required, float between -90 and 90 |
| `longitude` | Required, float between -180 and 180 |
| `specialties` | Required array with at least 1 valid specialty enum value |
| `openingHours` | Optional, valid JSON object |

#### Clinic Profile Update (`PUT /api/clinic-manager/my/profile`)

| Field | Validation |
|-------|-----------|
| `name` | Optional, non-empty string |
| `latitude` | Optional, float between -90 and 90 |
| `longitude` | Optional, float between -180 and 180 |
| `specialties` | Optional array with valid specialty enum values |

#### Clinic Search (`POST /api/clinics/search`)

| Field | Validation |
|-------|-----------|
| `diseaseName` | Required, non-empty string |
| `latitude` | Optional, float between -90 and 90 |
| `longitude` | Optional, float between -180 and 180 |
| `radiusKm` | Optional, integer between 1 and 500 |
| `limit` | Optional, integer between 1 and 50 |

### Validation Error Response

```json
{
  "error": "Validation failed",
  "message": "Invalid input data",
  "details": [
    {
      "field": "latitude",
      "message": "Latitude must be between -90 and 90"
    }
  ]
}
```

HTTP Status: `400 Bad Request`

---

## 3. Input Sanitization

### Implementation

Additional sanitization layer to prevent injection attacks.

**File**: `ai_health_companion_backend/src/middleware/input-sanitization.ts`

### Sanitization Functions

#### HTML Escaping
- Converts `< > & " ' /` to HTML entities
- Prevents XSS (Cross-Site Scripting) attacks
- Applied to all string inputs by default

#### SQL Injection Prevention
- Removes SQL comments (`--`, `/* */`)
- Removes semicolons to prevent query chaining
- **Note**: TypeORM uses parameterized queries (primary defense)
- This is a defense-in-depth measure

#### Coordinate Sanitization
- Validates latitude: -90 to 90
- Validates longitude: -180 to 180
- Ensures numeric values

#### Email Sanitization
- Converts to lowercase
- Trims whitespace

#### Phone Number Sanitization
- Removes non-digit characters
- Preserves leading `+` for international format

### Usage

```typescript
import { sanitizeRequestBody, sanitizeQueryParams } from './middleware/input-sanitization';

// Apply to routes that accept user input
router.post('/api/clinics', sanitizeRequestBody, validateClinic, createClinic);
router.get('/api/clinics/search', sanitizeQueryParams, searchClinics);
```

---

## 4. SQL Injection Protection

### Primary Defense: TypeORM Parameterized Queries

TypeORM automatically uses parameterized queries, which prevent SQL injection.

**Example**:
```typescript
// Safe - TypeORM parameterizes the query
const clinics = await clinicRepository.find({
  where: { name: userInput }
});

// Safe - TypeORM query builder uses parameters
const result = await clinicRepository
  .createQueryBuilder('clinic')
  .where('clinic.name = :name', { name: userInput })
  .getMany();
```

### Secondary Defense: Input Sanitization

The `input-sanitization.ts` middleware provides an additional layer by removing SQL-dangerous characters.

### What to Avoid

```typescript
// UNSAFE - Raw query with string concatenation
const query = `SELECT * FROM clinics WHERE name = '${userInput}'`;
await connection.query(query);
```

**Always use TypeORM's query builder or repository methods.**

---

## 5. Authentication & Authorization

### JWT Authentication

- **Token Storage**: JWT tokens are used for authentication
- **Token Expiration**: 7 days (configurable)
- **Token Refresh**: Refresh endpoint available
- **Secret Key**: Strong, unique secret stored in environment variables

### Password Security

- **Hashing Algorithm**: bcrypt with salt rounds = 10
- **Temporary Passwords**: 12 characters (uppercase, lowercase, numbers, symbols)
- **Password Change Required**: Clinic users must change password on first login
- **Password Validation**: Minimum 8 characters required

### Role-Based Access Control (RBAC)

| Role | Access |
|------|--------|
| `ADMIN` | Full access to all endpoints |
| `CLINIC` | Access to own clinic profile and data only |
| `HEALTH_WORKER` | Access to diagnosis and patient data |
| `PHARMACIST` | Access to pharmacy profile and prescription data |

### Middleware

```typescript
// Require authentication
router.use(authenticate);

// Require specific roles
router.use(authorize(UserRole.ADMIN));

// Example: Clinic can only access own data
router.get('/my', authenticate, authorize(UserRole.CLINIC), getMyProfile);
```

---

## 6. HTTPS/TLS

### Production Requirements

- **HTTPS Only**: All traffic must use HTTPS in production
- **TLS Version**: Minimum TLS 1.2
- **Certificate**: Valid SSL/TLS certificate from trusted CA
- **HSTS**: HTTP Strict Transport Security header enabled

### Configuration

```typescript
// helmet middleware for security headers
import helmet from 'helmet';
app.use(helmet());
```

---

## 7. CORS Configuration

### Settings

```typescript
import cors from 'cors';

app.use(cors({
  origin: [
    'https://admin.healthcompanion.com',
    'https://clinic.healthcompanion.com',
    'https://app.healthcompanion.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### Benefits

- Prevents unauthorized cross-origin requests
- Whitelists only trusted domains
- Protects against CSRF attacks

---

## 8. Error Handling

### Principle: Don't Expose Internals

```typescript
// Good - Generic error message
res.status(500).json({
  error: 'Internal server error',
  message: 'An error occurred while processing your request'
});

// Bad - Exposes database structure
res.status(500).json({
  error: 'Database error',
  message: 'Column "clinic_name" does not exist in table "clinics"'
});
```

### Implementation

**File**: `ai_health_companion_backend/src/middleware/error-handler.ts`

- Logs detailed errors to server logs
- Returns generic messages to clients
- Includes request ID for debugging
- Different messages for development vs. production

---

## 9. Logging & Monitoring

### What to Log

✅ **Do Log**:
- Authentication attempts (success/failure)
- Clinic creation events
- Clinic search operations (without PII)
- Password changes
- Admin actions
- Error events with stack traces

❌ **Don't Log**:
- Passwords (temporary or permanent)
- JWT tokens
- Sensitive patient data (unless required for debugging, then redact)
- Credit card numbers
- Social security numbers

### Log Format

```json
{
  "timestamp": "2024-01-10T10:30:00Z",
  "level": "info",
  "message": "Clinic created successfully",
  "clinicId": "uuid",
  "adminId": "uuid",
  "ip": "192.168.1.1"
}
```

---

## 10. Environment Variables

### Required Variables

```bash
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=health_companion
DATABASE_USER=db_user
DATABASE_PASSWORD=strong_password

# JWT
JWT_SECRET=very-long-random-secret-key-minimum-32-characters
JWT_EXPIRES_IN=7d

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@healthcompanion.com
SMTP_PASSWORD=smtp_password

# URLs
CLINIC_DASHBOARD_URL=https://clinic.healthcompanion.com
```

### Security Best Practices

1. **Never commit `.env` file to version control**
2. **Use strong, unique values for production**
3. **Rotate secrets regularly (JWT secret, database passwords)**
4. **Use environment-specific variables** (development, staging, production)
5. **Limit access to production environment variables**

---

## 11. Dependency Security

### Npm Audit

Run regularly to check for vulnerabilities:

```bash
npm audit
npm audit fix
```

### Dependency Updates

- Keep dependencies up to date
- Review changelogs for security patches
- Test thoroughly after updates

### Known Vulnerabilities

Check the npm audit report before deployment.

---

## 12. Security Checklist for Deployment

### Pre-Deployment

- [ ] All rate limiters enabled
- [ ] Input validation on all endpoints
- [ ] HTTPS enforced
- [ ] CORS configured for production domains only
- [ ] Environment variables set and secured
- [ ] Database credentials strong and unique
- [ ] JWT secret is strong (32+ characters)
- [ ] Error messages don't expose internals
- [ ] Logging configured (without sensitive data)
- [ ] npm audit shows no high/critical vulnerabilities

### Post-Deployment

- [ ] Monitor error rates
- [ ] Check for unusual traffic patterns
- [ ] Review authentication failure logs
- [ ] Verify rate limiting is working
- [ ] Test HTTPS certificate validity
- [ ] Confirm CORS is blocking unauthorized origins

---

## 13. Incident Response

### If a Security Breach Occurs

1. **Immediately disable affected systems** if necessary
2. **Rotate all credentials** (JWT secret, database passwords, API keys)
3. **Review logs** for unauthorized access
4. **Notify affected users** (if data was compromised)
5. **Patch vulnerability** and deploy fix
6. **Conduct post-mortem** to prevent recurrence
7. **Document incident** for compliance

---

## 14. Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [TypeORM Security](https://typeorm.io/#/security)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Node.js Security Checklist](https://blog.risingstack.com/node-js-security-checklist/)

---

## Conclusion

The Clinic Specialized Recommendations feature implements comprehensive security measures including:

- ✅ Rate limiting on all sensitive endpoints
- ✅ Input validation with express-validator
- ✅ Input sanitization to prevent injection attacks
- ✅ SQL injection protection via TypeORM parameterized queries
- ✅ JWT authentication with role-based access control
- ✅ Password hashing with bcrypt
- ✅ HTTPS/TLS in production
- ✅ CORS configuration
- ✅ Secure error handling
- ✅ Comprehensive logging (without sensitive data)

These measures provide defense-in-depth security, protecting against common vulnerabilities and attacks.

---

**Document Version**: 1.0  
**Last Updated**: January 2024  
**Prepared By**: Development Team
