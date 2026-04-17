import { useQuery } from '@tanstack/react-query';
import {
  Users, UserCheck, Activity, Calendar, Pill,
  AlertTriangle, ClipboardList, FlaskConical, TrendingUp, Clock
} from 'lucide-react';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, BarChart, Bar, Legend
} from 'recharts';
import { StatCard } from '../components/ui/StatCard';
import { Card, CardHeader, CardTitle } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import api from '../lib/api';
import { formatDateTime } from '../lib/utils';

// Mock data for charts (replace with real API calls)
const diagnosisData = [
  { month: 'Oct', malaria: 45, cold: 78, hypertension: 23 },
  { month: 'Nov', malaria: 52, cold: 65, hypertension: 28 },
  { month: 'Dec', malaria: 38, cold: 90, hypertension: 31 },
  { month: 'Jan', malaria: 61, cold: 55, hypertension: 25 },
  { month: 'Feb', malaria: 48, cold: 72, hypertension: 29 },
  { month: 'Mar', malaria: 55, cold: 68, hypertension: 33 },
  { month: 'Apr', malaria: 42, cold: 81, hypertension: 27 },
];

const roleData = [
  { name: 'Health Workers', value: 12, color: '#3b82f6' },
  { name: 'Clinic Staff', value: 8, color: '#10b981' },
  { name: 'Supervisors', value: 3, color: '#f59e0b' },
  { name: 'Admins', value: 2, color: '#8b5cf6' },
];

const appointmentData = [
  { day: 'Mon', scheduled: 24, completed: 20, cancelled: 4 },
  { day: 'Tue', scheduled: 31, completed: 28, cancelled: 3 },
  { day: 'Wed', scheduled: 18, completed: 16, cancelled: 2 },
  { day: 'Thu', scheduled: 27, completed: 25, cancelled: 2 },
  { day: 'Fri', scheduled: 35, completed: 30, cancelled: 5 },
];

export function Dashboard() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      try {
        const { data } = await api.get('/analytics/dashboard');
        return data.data;
      } catch {
        // Return mock data if API not available
        return {
          totalUsers: 25,
          totalPatients: 1842,
          totalDiagnoses: 3210,
          totalAppointments: 892,
          totalMedications: 156,
          lowStockCount: 8,
          pendingPrescriptions: 23,
          criticalLabResults: 3,
          activeUsers: 18,
          todayAppointments: 35,
        };
      }
    },
    staleTime: 60_000,
  });

  const { data: recentAudit } = useQuery({
    queryKey: ['recent-audit'],
    queryFn: async () => {
      try {
        const { data } = await api.get('/audit?limit=5');
        return data.data;
      } catch {
        return [];
      }
    },
  });

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">
          Overview of the Rural Clinic Health System
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Users"
          value={stats?.totalUsers ?? 0}
          icon={Users}
          color="blue"
          isLoading={isLoading}
          trend={{ value: 12, label: 'this month' }}
        />
        <StatCard
          title="Total Patients"
          value={stats?.totalPatients ?? 0}
          icon={UserCheck}
          color="green"
          isLoading={isLoading}
          trend={{ value: 8, label: 'this month' }}
        />
        <StatCard
          title="Diagnoses"
          value={stats?.totalDiagnoses ?? 0}
          icon={Activity}
          color="purple"
          isLoading={isLoading}
        />
        <StatCard
          title="Today's Appointments"
          value={stats?.todayAppointments ?? 0}
          icon={Calendar}
          color="teal"
          isLoading={isLoading}
        />
        <StatCard
          title="Medications"
          value={stats?.totalMedications ?? 0}
          icon={Pill}
          color="orange"
          isLoading={isLoading}
        />
        <StatCard
          title="Low Stock Alerts"
          value={stats?.lowStockCount ?? 0}
          icon={AlertTriangle}
          color="red"
          isLoading={isLoading}
        />
        <StatCard
          title="Pending Prescriptions"
          value={stats?.pendingPrescriptions ?? 0}
          icon={ClipboardList}
          color="blue"
          isLoading={isLoading}
        />
        <StatCard
          title="Critical Lab Results"
          value={stats?.criticalLabResults ?? 0}
          icon={FlaskConical}
          color="red"
          isLoading={isLoading}
        />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Disease trends */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Disease Trends (Last 7 Months)</CardTitle>
            <TrendingUp className="w-4 h-4 text-gray-400" />
          </CardHeader>
          <ResponsiveContainer width="100%" height={240}>
            <AreaChart data={diagnosisData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="month" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              <Area type="monotone" dataKey="malaria" stroke="#ef4444" fill="#fee2e2" name="Malaria" />
              <Area type="monotone" dataKey="cold" stroke="#3b82f6" fill="#dbeafe" name="Common Cold" />
              <Area type="monotone" dataKey="hypertension" stroke="#8b5cf6" fill="#ede9fe" name="Hypertension" />
            </AreaChart>
          </ResponsiveContainer>
        </Card>

        {/* User roles */}
        <Card>
          <CardHeader>
            <CardTitle>Users by Role</CardTitle>
            <Users className="w-4 h-4 text-gray-400" />
          </CardHeader>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie
                data={roleData}
                cx="50%"
                cy="50%"
                innerRadius={55}
                outerRadius={80}
                paddingAngle={3}
                dataKey="value"
              >
                {roleData.map((entry, i) => (
                  <Cell key={i} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
          <div className="space-y-2 mt-2">
            {roleData.map((r) => (
              <div key={r.name} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: r.color }} />
                  <span className="text-gray-600">{r.name}</span>
                </div>
                <span className="font-medium text-gray-900">{r.value}</span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Appointments chart + Recent activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Weekly Appointments</CardTitle>
            <Calendar className="w-4 h-4 text-gray-400" />
          </CardHeader>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={appointmentData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="day" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              <Bar dataKey="scheduled" fill="#3b82f6" name="Scheduled" radius={[4, 4, 0, 0]} />
              <Bar dataKey="completed" fill="#10b981" name="Completed" radius={[4, 4, 0, 0]} />
              <Bar dataKey="cancelled" fill="#ef4444" name="Cancelled" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </Card>

        {/* Recent audit */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
            <Clock className="w-4 h-4 text-gray-400" />
          </CardHeader>
          <div className="space-y-3">
            {recentAudit && recentAudit.length > 0 ? (
              recentAudit.map((log: { id: string; action: string; resource: string; userEmail?: string; timestamp: string; success: boolean }) => (
                <div key={log.id} className="flex items-start gap-3">
                  <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 ${log.success ? 'bg-green-500' : 'bg-red-500'}`} />
                  <div className="min-w-0">
                    <p className="text-sm text-gray-700 truncate">
                      <span className="font-medium capitalize">{log.action}</span>{' '}
                      {log.resource}
                    </p>
                    <p className="text-xs text-gray-400">{log.userEmail}</p>
                    <p className="text-xs text-gray-400">{formatDateTime(log.timestamp)}</p>
                  </div>
                </div>
              ))
            ) : (
              [
                { action: 'create', resource: 'user', email: 'admin@clinic.rw', time: '2 min ago', ok: true },
                { action: 'update', resource: 'medication', email: 'staff@clinic.rw', time: '15 min ago', ok: true },
                { action: 'login', resource: 'auth', email: 'doctor@clinic.rw', time: '1 hr ago', ok: true },
                { action: 'delete', resource: 'patient', email: 'admin@clinic.rw', time: '2 hr ago', ok: false },
                { action: 'export', resource: 'report', email: 'super@clinic.rw', time: '3 hr ago', ok: true },
              ].map((item, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 ${item.ok ? 'bg-green-500' : 'bg-red-500'}`} />
                  <div>
                    <p className="text-sm text-gray-700">
                      <span className="font-medium capitalize">{item.action}</span>{' '}
                      {item.resource}
                    </p>
                    <p className="text-xs text-gray-400">{item.email}</p>
                    <p className="text-xs text-gray-400">{item.time}</p>
                  </div>
                </div>
              ))
            )}
          </div>
        </Card>
      </div>

      {/* Quick alerts */}
      {(stats?.lowStockCount > 0 || stats?.criticalLabResults > 0) && (
        <Card className="border-orange-200 bg-orange-50">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-orange-500 flex-shrink-0 mt-0.5" />
            <div>
              <p className="font-medium text-orange-800">Action Required</p>
              <div className="flex flex-wrap gap-2 mt-2">
                {stats?.lowStockCount > 0 && (
                  <Badge variant="warning">{stats.lowStockCount} medications low on stock</Badge>
                )}
                {stats?.criticalLabResults > 0 && (
                  <Badge variant="danger">{stats.criticalLabResults} critical lab results pending review</Badge>
                )}
              </div>
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}
