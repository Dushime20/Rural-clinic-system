# Clinic Specialized Recommendations - API Documentation

## Overview

This document describes all new API endpoints added for the Clinic Specialized Recommendations feature. All endpoints require authentication unless otherwise specified.

**Base URL**: `http://localhost:3000/api` (development)

**Authentication**: Bearer token in Authorization header
```
Authorization: Bearer <token>
```

---

## Table of Contents

1. [Admin Clinic Management](#admin-clinic-management)
2. [Clinic Manager Profile](#clinic-manager-profile)
3. [Clinic Search](#clinic-search)
4. [Disease-Specialty Mapping](#disease-specialty-mapping)
5. [Authentication Extensions](#authentication-extensions)
6. [Diagnosis Extensions](#diagnosis-extensions)
7. [Analytics](#analytics)

---

## Admin Clinic Management

### Create Clinic User

Creates a new clinic user with profile and generates temporary credentials.

**Endpoint**: `POST /api/admin/clinics`

**Authorization**: Admin only

**Request Body**:
```json
{
  "name": "Central Medical Clinic",
  "managerName": "Dr. Jane Smith",
  "email": "manager@centralmedical.com",
  "phoneNumber": "+1234567890",
  "address": "123 Main Street",
  "city": "New York",
  "district": "Manhattan",
  "country": "USA",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "specialties": ["CARDIOLOGY", "GENERAL_MEDICINE"],
  "openingHours": {
    "monday": { "open": "09:00", "close": "17:00" },
    "tuesday": { "open": "09:00", "close": "17:00" },
    "wednesday": { "open": "09:00", "close": "17:00" },
    "thursday": { "open": "09:00", "close": "17:00" },
    "friday": { "open": "09:00", "close": "17:00" },
    "saturday": { "open": "10:00", "close": "14:00" },
    "sunday": { "open": null, "close": null }
  }
}
```

**Response**: `201 Created`
```json
{
  "success": true,
  "message": "Clinic user created successfully",
  "data": {
    "clinic": {
      "id": "uuid",
      "managerId": "uuid",
      "name": "Central Medical Clinic",
      "managerName": "Dr. Jane Smith",
      "email": "manager@centralmedical.com",
      "phoneNumber": "+1234567890",
      "address": "123 Main Street",
      "city": "New York",
      "district": "Manhattan",
      "country": "USA",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "isActive": true,
      "specialties": [
        { "specialty": "CARDIOLOGY" },
        { "specialty": "GENERAL_MEDICINE" }
      ],
      "openingHours": { "..." },
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    "credentials": {
      "email": "manager@centralmedical.com",
      "temporaryPassword": "Abc123XyzDef"
    }
  }
}
```

**Validation Rules**:
- `name`: Required, 2-200 characters
- `managerName`: Required, 2-100 characters
- `email`: Required, valid email format
- `phoneNumber`: Required, valid phone format
- `latitude`: Required, -90 to 90
- `longitude`: Required, -180 to 180
- `specialties`: Required, at least 1, valid enum values
- `openingHours`: Optional

**Specialties Enum**:
- `GENERAL_MEDICINE`
- `CARDIOLOGY`
- `DERMATOLOGY`
- `ENDOCRINOLOGY`
- `GASTROENTEROLOGY`
- `NEUROLOGY`
- `ONCOLOGY`
- `ORTHOPEDICS`
- `PEDIATRICS`
- `PSYCHIATRY`
- `PULMONOLOGY`

---

### List Clinics

Retrieves a paginated list of all clinics with search and filter capabilities.

**Endpoint**: `GET /api/admin/clinics`

**Authorization**: Admin only

**Query Parameters**:
- `page` (number, default: 1): Page number
- `limit` (number, default: 10): Items per page
- `search` (string, optional): Search by name, manager, email
- `specialty` (string, optional): Filter by specialty
- `isActive` (boolean, optional): Filter by active status
- `city` (string, optional): Filter by city

**Example Request**:
```
GET /api/admin/clinics?page=1&limit=10&search=medical&specialty=CARDIOLOGY&isActive=true
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "clinics": [
      {
        "id": "uuid",
        "name": "Central Medical Clinic",
        "managerName": "Dr. Jane Smith",
        "email": "manager@centralmedical.com",
        "phoneNumber": "+1234567890",
        "city": "New York",
        "isActive": true,
        "specialties": ["CARDIOLOGY", "GENERAL_MEDICINE"],
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "pages": 3
    }
  }
}
```

---

### Get Clinic Details

Retrieves detailed information about a specific clinic.

**Endpoint**: `GET /api/admin/clinics/:id`

**Authorization**: Admin only

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "clinic": {
      "id": "uuid",
      "managerId": "uuid",
      "name": "Central Medical Clinic",
      "managerName": "Dr. Jane Smith",
      "email": "manager@centralmedical.com",
      "phoneNumber": "+1234567890",
      "address": "123 Main Street",
      "city": "New York",
      "district": "Manhattan",
      "country": "USA",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "isActive": true,
      "specialties": [
        { "id": "uuid", "specialty": "CARDIOLOGY" },
        { "id": "uuid", "specialty": "GENERAL_MEDICINE" }
      ],
      "openingHours": {
        "monday": { "open": "09:00", "close": "17:00" },
        "...": "..."
      },
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

---

### Update Clinic Status

Activates or deactivates a clinic.

**Endpoint**: `PUT /api/admin/clinics/:id/status`

**Authorization**: Admin only

**Request Body**:
```json
{
  "isActive": false
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Clinic status updated successfully",
  "data": {
    "clinic": {
      "id": "uuid",
      "isActive": false,
      "updatedAt": "2024-01-15T11:00:00Z"
    }
  }
}
```

---

## Clinic Manager Profile

### Get Clinic Profile

Retrieves the authenticated clinic user's profile.

**Endpoint**: `GET /api/clinic-manager/my`

**Authorization**: Clinic user only

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "clinic": {
      "id": "uuid",
      "managerId": "uuid",
      "name": "Central Medical Clinic",
      "managerName": "Dr. Jane Smith",
      "email": "manager@centralmedical.com",
      "phoneNumber": "+1234567890",
      "address": "123 Main Street",
      "city": "New York",
      "district": "Manhattan",
      "country": "USA",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "isActive": true,
      "specialties": ["CARDIOLOGY", "GENERAL_MEDICINE"],
      "openingHours": { "..." },
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

---

### Update Clinic Profile

Updates the authenticated clinic user's profile information.

**Endpoint**: `PUT /api/clinic-manager/my/profile`

**Authorization**: Clinic user only

**Request Body**:
```json
{
  "name": "Central Medical Clinic",
  "phoneNumber": "+1234567890",
  "address": "123 Main Street",
  "city": "New York",
  "district": "Manhattan",
  "country": "USA",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "openingHours": {
    "monday": { "open": "09:00", "close": "17:00" },
    "...": "..."
  }
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Clinic profile updated successfully",
  "data": {
    "clinic": { "..." }
  }
}
```

---

### Update Clinic Specialties

Updates the clinic's medical specialties.

**Endpoint**: `PUT /api/clinic-manager/my/specialties`

**Authorization**: Clinic user only

**Request Body**:
```json
{
  "specialties": ["CARDIOLOGY", "GENERAL_MEDICINE", "PULMONOLOGY"]
}
```

**Validation**: At least one specialty required

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Clinic specialties updated successfully",
  "data": {
    "clinic": {
      "id": "uuid",
      "specialties": ["CARDIOLOGY", "GENERAL_MEDICINE", "PULMONOLOGY"],
      "updatedAt": "2024-01-15T11:00:00Z"
    }
  }
}
```

---

## Clinic Search

### Search Clinics by Disease

Searches for clinics based on disease name and optional location. Used by the recommendation engine.

**Endpoint**: `POST /api/clinics/search`

**Authorization**: Authenticated user

**Request Body**:
```json
{
  "diseaseName": "Diabetes",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "radiusKm": 100,
  "onlyOpen": false,
  "limit": 10
}
```

**Parameters**:
- `diseaseName` (string, required): Disease to search for
- `latitude` (number, optional): User latitude
- `longitude` (number, optional): User longitude
- `radiusKm` (number, optional, default: 100): Search radius
- `onlyOpen` (boolean, optional, default: false): Only show currently open clinics
- `limit` (number, optional, default: 10): Maximum results

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "clinics": [
      {
        "id": "uuid",
        "name": "Central Medical Clinic",
        "specialties": ["ENDOCRINOLOGY", "GENERAL_MEDICINE"],
        "phoneNumber": "+1234567890",
        "address": "123 Main Street",
        "city": "New York",
        "district": "Manhattan",
        "latitude": 40.7128,
        "longitude": -74.0060,
        "distance": 2.5,
        "isOpenNow": true,
        "openingHours": { "..." }
      }
    ],
    "mappedSpecialties": ["ENDOCRINOLOGY", "GENERAL_MEDICINE"],
    "totalFound": 5
  }
}
```

**Notes**:
- If no disease mapping exists, defaults to `GENERAL_MEDICINE`
- Distance calculated using Haversine formula
- Results sorted by distance (nearest first)
- 5-second timeout protection
- Returns empty array on errors (graceful degradation)

---

### Get Specialties for Disease

Retrieves medical specialties mapped to a disease.

**Endpoint**: `GET /api/disease-mappings/search`

**Authorization**: Authenticated user

**Query Parameters**:
- `disease` (string, required): Disease name

**Example Request**:
```
GET /api/disease-mappings/search?disease=Diabetes
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "disease": "Diabetes",
    "specialties": ["ENDOCRINOLOGY", "GENERAL_MEDICINE"],
    "hasMapping": true
  }
}
```

---

## Disease-Specialty Mapping

### List Disease Mappings

Retrieves all disease-specialty mappings.

**Endpoint**: `GET /api/admin/disease-mappings`

**Authorization**: Admin only

**Query Parameters**:
- `page` (number, default: 1)
- `limit` (number, default: 20)
- `search` (string, optional): Search by disease name

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "mappings": [
      {
        "id": "uuid",
        "diseaseName": "Diabetes",
        "primarySpecialty": "ENDOCRINOLOGY",
        "secondarySpecialties": ["GENERAL_MEDICINE"],
        "createdAt": "2024-01-15T10:00:00Z"
      }
    ],
    "pagination": { "..." }
  }
}
```

---

### Create Disease Mapping

Creates a new disease-specialty mapping.

**Endpoint**: `POST /api/admin/disease-mappings`

**Authorization**: Admin only

**Request Body**:
```json
{
  "diseaseName": "Asthma",
  "primarySpecialty": "PULMONOLOGY",
  "secondarySpecialties": ["GENERAL_MEDICINE"]
}
```

**Response**: `201 Created`
```json
{
  "success": true,
  "message": "Disease mapping created successfully",
  "data": {
    "mapping": {
      "id": "uuid",
      "diseaseName": "Asthma",
      "primarySpecialty": "PULMONOLOGY",
      "secondarySpecialties": ["GENERAL_MEDICINE"],
      "createdAt": "2024-01-15T11:00:00Z"
    }
  }
}
```

---

### Update Disease Mapping

Updates an existing disease-specialty mapping.

**Endpoint**: `PUT /api/admin/disease-mappings/:id`

**Authorization**: Admin only

**Request Body**:
```json
{
  "primarySpecialty": "PULMONOLOGY",
  "secondarySpecialties": ["GENERAL_MEDICINE", "PEDIATRICS"]
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Disease mapping updated successfully",
  "data": {
    "mapping": { "..." }
  }
}
```

---

## Authentication Extensions

### Change Password

Allows clinic users to change their password (required on first login).

**Endpoint**: `POST /api/auth/change-password`

**Authorization**: Authenticated user (clinic)

**Request Body**:
```json
{
  "currentPassword": "TempPassword123",
  "newPassword": "MyNewSecurePassword123"
}
```

**Validation**:
- `newPassword`: Minimum 8 characters

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Password changed successfully",
  "data": {
    "mustChangePassword": false
  }
}
```

---

### Login Response Extensions

The existing login endpoint now includes clinic-specific flags.

**Endpoint**: `POST /api/auth/login`

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt-token",
    "user": {
      "id": "uuid",
      "email": "manager@centralmedical.com",
      "role": "clinic",
      "mustChangePassword": true
    }
  }
}
```

---

## Diagnosis Extensions

### Create Diagnosis with Clinic Recommendations

The diagnosis endpoint now returns clinic recommendations when applicable.

**Endpoint**: `POST /api/diagnosis`

**Authorization**: Authenticated user

**Request Body**:
```json
{
  "patientId": "uuid",
  "symptoms": ["fever", "cough", "fatigue"],
  "vitalSigns": {
    "temperature": 38.5,
    "bloodPressure": "120/80",
    "heartRate": 80
  },
  "latitude": 40.7128,
  "longitude": -74.0060,
  "medicalHistory": [],
  "notes": "Patient reports symptoms for 3 days"
}
```

**Response**: `201 Created`
```json
{
  "success": true,
  "message": "Diagnosis created successfully",
  "data": {
    "diagnosis": {
      "diagnosisId": "DX-ABC123",
      "patientId": "uuid",
      "aiPredictions": [ "..." ],
      "prescriptions": [ "..." ],
      "diagnosisDate": "2024-01-15T12:00:00Z"
    },
    "recommendations": {
      "pharmacies": [ "..." ],
      "clinics": [
        {
          "id": "uuid",
          "name": "Central Medical Clinic",
          "specialties": ["GENERAL_MEDICINE"],
          "phoneNumber": "+1234567890",
          "address": "123 Main Street",
          "city": "New York",
          "distance": 2.5,
          "isOpenNow": true,
          "openingHours": { "..." }
        }
      ],
      "clinicRecommendationReason": "recurring_disease"
    },
    "patternAnalysis": {
      "isRecurring": true,
      "isPersistent": false,
      "matchesChronicCondition": false,
      "occurrenceCount": 4,
      "durationDays": null
    }
  }
}
```

**Clinic Recommendation Reasons**:
- `recurring_disease`: 3+ occurrences in 90 days
- `persistent_disease`: Active > 30 days
- `chronic_condition`: Matches chronic condition (80% similarity)
- `no_pharmacy_found`: No pharmacies available (fallback)

**Notes**:
- `clinics` field only present when recommendations exist
- `clinicRecommendationReason` only present with clinics
- `patternAnalysis` only present when pattern detected
- Backward compatible: clients ignoring new fields work unchanged

---

## Analytics

### Get Clinic Recommendation Statistics

Retrieves analytics for clinic recommendations.

**Endpoint**: `GET /api/admin/analytics/clinic-recommendations`

**Authorization**: Admin only

**Query Parameters**:
- `startDate` (date, optional): Start of date range
- `endDate` (date, optional): End of date range
- `reason` (string, optional): Filter by recommendation reason

**Example Request**:
```
GET /api/admin/analytics/clinic-recommendations?startDate=2024-01-01&endDate=2024-01-31&reason=recurring_disease
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "statistics": {
      "totalRecommendations": 1250,
      "byReason": {
        "recurring_disease": 450,
        "persistent_disease": 320,
        "chronic_condition": 280,
        "no_pharmacy_found": 200
      },
      "averageClinicsPerRecommendation": 3.5,
      "uniquePatients": 890,
      "dateRange": {
        "start": "2024-01-01",
        "end": "2024-01-31"
      }
    }
  }
}
```

---

## Error Responses

All endpoints follow a consistent error response format:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "latitude",
      "message": "Latitude must be between -90 and 90"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Insufficient permissions"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Clinic not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## Rate Limits

**Recommended limits** (to be implemented):
- Clinic search: 100 requests/minute per IP
- Admin clinic creation: 10 requests/minute per admin
- Authentication: 5 failed attempts per 15 minutes

---

## Postman Collection

A Postman collection with example requests is available at:
`/docs/postman/clinic-recommendations.json`

---

## Changelog

### Version 1.0.0 (2024-01-15)
- Initial release
- All clinic management endpoints
- Clinic search and recommendations
- Disease-specialty mapping
- Authentication extensions
- Diagnosis endpoint extensions
- Analytics endpoints

---

## Support

For API support, contact: api-support@healthcompanion.com

For bug reports: https://github.com/your-org/health-companion/issues
