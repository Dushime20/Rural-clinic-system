# AI Health Companion — Admin Dashboard

React + TypeScript admin web app for managing the Rural Clinic Health System.

## Stack

- **React 18** + **TypeScript** + **Vite**
- **Tailwind CSS v4** — utility-first styling
- **React Router v6** — client-side routing
- **TanStack Query v5** — server state management
- **React Hook Form** + **Zod** — form validation
- **Recharts** — analytics charts
- **Lucide React** — icons
- **React Hot Toast** — notifications
- **Axios** — HTTP client with JWT interceptors

## Pages

| Route | Page | Description |
|-------|------|-------------|
| `/` | Dashboard | Stats, charts, recent activity |
| `/users` | User Management | Create/edit/toggle users by role |
| `/patients` | Patients | Register, view, delete patient records |
| `/medications` | Medications | Catalog management, stock updates |
| `/appointments` | Appointments | View all appointments with filters |
| `/diagnoses` | Diagnoses | AI diagnosis records with predictions |
| `/prescriptions` | Prescriptions | View and cancel prescriptions |
| `/lab` | Lab Orders | Lab orders + critical result review |
| `/reports` | Reports | MoH, surveillance, performance reports |
| `/audit` | Audit Logs | Full audit trail with filters |
| `/notifications` | Notifications | System notification history |
| `/settings` | Settings | Profile, password, preferences |

## Getting Started

```bash
# Install dependencies
npm install

# Copy env file
cp .env.example .env
# Edit VITE_API_URL to point to your backend

# Development
npm run dev

# Production build
npm run build
```

## Environment Variables

```
VITE_API_URL=http://localhost:5000/api/v1
```

## Authentication

- Admin-only access (role check on login)
- JWT access + refresh token flow
- Auto token refresh on 401 responses
- Session persisted in localStorage

## API Integration

All API calls proxy to the backend via Axios. The `src/lib/api.ts` client:
- Attaches `Authorization: Bearer <token>` to every request
- Auto-refreshes expired tokens
- Redirects to `/login` on auth failure

The dashboard gracefully falls back to mock data when the backend is unavailable, so you can develop the UI independently.
