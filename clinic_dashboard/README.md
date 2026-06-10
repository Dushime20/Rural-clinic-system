# Clinic Dashboard

A React-based dashboard application for clinic managers to manage their profiles, specialties, and view recommendations.

## Features

- **Authentication**: Secure login with temporary password support and mandatory password change
- **Dashboard**: Overview of clinic profile, statistics, and quick actions
- **Profile Management**: Update clinic information including location and contact details
- **Specialties Management**: Manage medical specialties offered by the clinic
- **Responsive Design**: Mobile-friendly interface with indigo/blue theme

## Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **TanStack Query** - Server state management
- **React Router** - Routing
- **Axios** - HTTP client
- **React Hook Form** - Form management
- **Zod** - Schema validation
- **Tailwind CSS** - Utility-first CSS
- **Lucide React** - Icon library

## Prerequisites

- Node.js 18+ and npm
- Backend API server running (default: http://localhost:5000)

## Installation

1. Navigate to the clinic dashboard directory:
```bash
cd clinic_dashboard
```

2. Install dependencies:
```bash
npm install
```

3. Create environment configuration:
```bash
cp .env.example .env
```

4. Update `.env` with your backend API URL:
```
VITE_API_BASE_URL=http://localhost:5000/api/v1
```

## Development

Start the development server:
```bash
npm run dev
```

The application will be available at http://localhost:5175

## Build for Production

Build the application:
```bash
npm run build
```

Preview the production build:
```bash
npm run preview
```

## Project Structure

```
clinic_dashboard/
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── layout/        # Layout components (Sidebar, Header)
│   │   └── ui/            # UI primitives (Button, Input, Card)
│   ├── contexts/          # React contexts
│   │   └── AuthContext.tsx
│   ├── lib/               # Utility libraries
│   │   ├── api.ts         # Axios API client
│   │   └── utils.ts       # Helper functions
│   ├── pages/             # Page components
│   │   ├── Login.tsx
│   │   ├── ChangePassword.tsx
│   │   ├── Dashboard.tsx
│   │   ├── Profile.tsx
│   │   └── Specialties.tsx
│   ├── types/             # TypeScript type definitions
│   │   └── index.ts
│   ├── App.tsx            # Main app component with routing
│   ├── main.tsx           # Application entry point
│   └── index.css          # Global styles and Tailwind
├── public/                # Static assets
├── .env.example           # Environment variables template
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## Available Routes

- `/login` - Clinic user login
- `/change-password` - First-time password change (redirected automatically)
- `/` - Dashboard home
- `/profile` - Clinic profile management
- `/specialties` - Medical specialties management

## Authentication Flow

1. **First Login**: Clinic receives temporary credentials via email from admin
2. **Password Change**: User must change password on first login
3. **Session Management**: JWT token stored in localStorage with automatic refresh
4. **Role Verification**: Only users with 'clinic' role can access the dashboard

## API Integration

The dashboard integrates with the following backend endpoints:

### Authentication
- `POST /api/v1/auth/login` - Login with email and password
- `POST /api/v1/auth/change-password` - Change password
- `POST /api/v1/auth/refresh` - Refresh access token

### Clinic Manager
- `GET /api/v1/clinic-manager/my` - Get clinic profile
- `PUT /api/v1/clinic-manager/my/profile` - Update clinic profile
- `PUT /api/v1/clinic-manager/my/specialties` - Update specialties

## Features Detail

### Dashboard Page
- Displays clinic name, address, and status
- Shows statistics: specialties count, days since registration
- Profile completion notice if specialties or address missing
- Quick action cards for profile and specialties management
- Lists current specialties as badges

### Profile Page
- View/edit clinic name, manager name, phone, and address
- Location fields with coordinate validation (lat: -90 to 90, lon: -180 to 180)
- Real-time form validation
- Success/error notifications

### Specialties Page
- Multi-select checkboxes for 11 medical specialties
- Visual selection feedback with indigo theme
- Validation requiring at least one specialty
- Selection count display

## Color Theme

The clinic dashboard uses a blue/indigo color scheme to differentiate from:
- Admin Dashboard (neutral gray/slate)
- Pharmacy Dashboard (green/orange)

Primary colors:
- Primary: Indigo (indigo-600: #4f46e5)
- Accent: Blue (blue-600: #2563eb)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| VITE_API_BASE_URL | Backend API base URL | http://localhost:5000/api/v1 |

## Local Storage Keys

The dashboard uses the following localStorage keys:
- `clinic_token` - JWT access token
- `clinic_refresh_token` - JWT refresh token
- `clinic_user` - User profile information

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Security

- Secure token storage in localStorage
- Automatic token refresh on expiration
- Protected routes with authentication guards
- Input validation and sanitization
- CORS configuration in backend

## Troubleshooting

### Cannot connect to backend
- Verify backend server is running
- Check VITE_API_BASE_URL in .env
- Ensure CORS is properly configured in backend

### Authentication errors
- Clear localStorage and try logging in again
- Verify clinic user exists in backend
- Check that user role is set to 'clinic'

### Build errors
- Delete node_modules and package-lock.json
- Run `npm install` again
- Check Node.js version (should be 18+)

## Contributing

This dashboard is part of the AI Health Companion project. Follow the project's contributing guidelines.

## License

Part of the AI Health Companion project.
