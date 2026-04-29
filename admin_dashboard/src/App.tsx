import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { Layout } from './components/layout/Layout';
import { PharmacyLayout } from './components/layout/PharmacyLayout';
import { Login } from './pages/Login';
// Admin pages
import { Dashboard } from './pages/Dashboard';
import { Users } from './pages/Users';
import { Patients } from './pages/Patients';
import { Medications } from './pages/Medications';
import { Appointments } from './pages/Appointments';
import { Diagnoses } from './pages/Diagnoses';
import { Prescriptions } from './pages/Prescriptions';
import { LabOrders } from './pages/LabOrders';
import { Reports } from './pages/Reports';
import { AuditLogs } from './pages/AuditLogs';
import { Notifications } from './pages/Notifications';
import { Settings } from './pages/Settings';
// Pharmacy pages
import { PharmacyDashboard } from './pages/pharmacy/PharmacyDashboard';
import { PharmacyProfile } from './pages/pharmacy/PharmacyProfile';
import { PharmacyMedicines } from './pages/pharmacy/PharmacyMedicines';
import { ChangePassword } from './pages/pharmacy/ChangePassword';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 30_000,
      refetchOnWindowFocus: false,
    },
  },
});

const Spinner = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="flex flex-col items-center gap-3">
      <div className="w-10 h-10 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
      <p className="text-sm text-gray-500">Loading...</p>
    </div>
  </div>
);

/** Requires authentication + specific role(s). Redirects to login if not authed. */
function RoleRoute({
  children,
  roles,
}: {
  children: React.ReactNode;
  roles: string[];
}) {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) return <Spinner />;
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (!roles.includes(user?.role ?? '')) return <Navigate to="/login" replace />;

  return <>{children}</>;
}

function AppRoutes() {
  const { isAuthenticated, user } = useAuth();

  // After login, redirect based on role
  const homeRedirect = () => {
    if (!isAuthenticated) return <Navigate to="/login" replace />;
    if (user?.role === 'pharmacist') return <Navigate to="/pharmacy-portal" replace />;
    return <Navigate to="/admin" replace />;
  };

  return (
    <Routes>
      {/* Login — redirect to role home if already authenticated */}
      <Route
        path="/login"
        element={
          isAuthenticated
            ? (user?.role === 'pharmacist'
                ? <Navigate to="/pharmacy-portal" replace />
                : <Navigate to="/admin" replace />)
            : <Login />
        }
      />

      {/* Root redirect */}
      <Route path="/" element={homeRedirect()} />

      {/* ── Pharmacist must change password ─────────────────────────────── */}
      <Route
        path="/change-password"
        element={
          <RoleRoute roles={['pharmacist']}>
            <ChangePassword />
          </RoleRoute>
        }
      />

      {/* ── Pharmacy portal (pharmacist role) ───────────────────────────── */}
      <Route
        path="/pharmacy-portal"
        element={
          <RoleRoute roles={['pharmacist']}>
            {user?.mustChangePassword
              ? <Navigate to="/change-password" replace />
              : <PharmacyLayout />}
          </RoleRoute>
        }
      >
        <Route index element={<PharmacyDashboard />} />
        <Route path="profile" element={<PharmacyProfile />} />
        <Route path="medicines" element={<PharmacyMedicines />} />
      </Route>

      {/* ── Admin portal (admin role) ────────────────────────────────────── */}
      <Route
        path="/admin"
        element={
          <RoleRoute roles={['admin']}>
            <Layout />
          </RoleRoute>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="users" element={<Users />} />
        <Route path="patients" element={<Patients />} />
        <Route path="medications" element={<Medications />} />
        <Route path="appointments" element={<Appointments />} />
        <Route path="diagnoses" element={<Diagnoses />} />
        <Route path="prescriptions" element={<Prescriptions />} />
        <Route path="lab" element={<LabOrders />} />
        <Route path="reports" element={<Reports />} />
        <Route path="audit" element={<AuditLogs />} />
        <Route path="notifications" element={<Notifications />} />
        <Route path="settings" element={<Settings />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AuthProvider>
          <AppRoutes />
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                borderRadius: '10px',
                background: '#1e293b',
                color: '#f8fafc',
                fontSize: '14px',
              },
              success: { iconTheme: { primary: '#10b981', secondary: '#f8fafc' } },
              error: { iconTheme: { primary: '#ef4444', secondary: '#f8fafc' } },
            }}
          />
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
