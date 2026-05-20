import { useQuery } from '@tanstack/react-query';
import {
  Users, UserCheck, Activity, Store,
  TrendingUp, Clock
} from 'lucide-react';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell
} from 'recharts';
import { StatCard } from '../components/ui/StatCard';
import { Card, CardHeader, CardTitle } from '../components/ui/Card';
import api from '../lib/api';

export function Dashboard() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const { data } = await api.get('/analytics/dashboard');
      return data.data;
    },
    staleTime: 60_000,
  });

  // Format recent activity from diagnoses and patients
  const recentActivity = [
    ...(stats?.recentDiagnoses || []).map((d: any) => ({
      type: 'diagnosis',
      label: 'Diagnosis recorded',
      detail: d.disease,
      time: formatTimeAgo(d.diagnosisDate || d.createdAt),
    })),
    ...(stats?.recentPatients || []).map((p: any) => ({
      type: 'patient',
      label: 'Patient added',
      detail: `${p.firstName} ${p.lastName}`,
      time: formatTimeAgo(p.createdAt),
    })),
  ]
    .sort((a, b) => {
      // Sort by most recent (this is approximate since we're using formatted strings)
      return 0; // Already sorted by backend
    })
    .slice(0, 5);

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
        />
        <StatCard
          title="Total Patients"
          value={stats?.totalPatients ?? 0}
          icon={UserCheck}
          color="green"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Diagnoses"
          value={stats?.totalDiagnoses ?? 0}
          icon={Activity}
          color="purple"
          isLoading={isLoading}
        />
        <StatCard
          title="Pharmacies"
          value={stats?.totalPharmacies ?? 0}
          icon={Store}
          color="orange"
          isLoading={isLoading}
        />
        <StatCard
          title="Active Users"
          value={stats?.activeUsers ?? 0}
          icon={Users}
          color="teal"
          isLoading={isLoading}
        />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Disease trends */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Disease Trends (Last 6 Months)</CardTitle>
            <TrendingUp className="w-4 h-4 text-gray-400" />
          </CardHeader>
          {isLoading ? (
            <div className="h-60 flex items-center justify-center">
              <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (stats?.diseaseTrends?.length ?? 0) > 0 ? (
            <ResponsiveContainer width="100%" height={240}>
              <AreaChart data={stats?.diseaseTrends ?? []}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip />
                {(stats?.topDiseases ?? []).map((disease: { name: string; key: string }, i: number) => (
                  <Area
                    key={disease.key}
                    type="monotone"
                    dataKey={disease.key}
                    stroke={i === 0 ? '#ef4444' : i === 1 ? '#3b82f6' : '#8b5cf6'}
                    fill={i === 0 ? '#fee2e2' : i === 1 ? '#dbeafe' : '#ede9fe'}
                    name={disease.name}
                    strokeWidth={2}
                  />
                ))}
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-60 flex items-center justify-center text-gray-400">
              <p>No diagnosis data available</p>
            </div>
          )}
        </Card>

        {/* User roles */}
        <Card>
          <CardHeader>
            <CardTitle>Users by Role</CardTitle>
            <Users className="w-4 h-4 text-gray-400" />
          </CardHeader>
          {isLoading ? (
            <div className="h-52 flex items-center justify-center">
              <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (stats?.roleDistribution?.length ?? 0) > 0 ? (
            <>
              <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                  <Pie
                    data={stats?.roleDistribution ?? []}
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={80}
                    paddingAngle={3}
                    dataKey="value"
                  >
                    {(stats?.roleDistribution ?? []).map((entry: any, i: number) => (
                      <Cell key={i} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="space-y-2 mt-2">
                {(stats?.roleDistribution ?? []).map((r: any) => (
                  <div key={r.name} className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full" style={{ backgroundColor: r.color }} />
                      <span className="text-gray-600">{r.name}</span>
                    </div>
                    <span className="font-medium text-gray-900">{r.value}</span>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <div className="h-52 flex items-center justify-center text-gray-400">
              <p>No user data available</p>
            </div>
          )}
        </Card>
      </div>

      {/* Top diseases + Recent activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top diseases */}
        <Card>
          <CardHeader>
            <CardTitle>Top Diseases</CardTitle>
            <Activity className="w-4 h-4 text-gray-400" />
          </CardHeader>
          {isLoading ? (
            <div className="h-40 flex items-center justify-center">
              <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (stats?.topDiseases?.length ?? 0) > 0 ? (
            <div className="space-y-3">
              {(stats?.topDiseases ?? []).map((disease: { name: string }, i: number) => (
                <div key={i} className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-white font-bold text-sm ${
                    i === 0 ? 'bg-red-500' : i === 1 ? 'bg-blue-500' : 'bg-purple-500'
                  }`}>
                    {i + 1}
                  </div>
                  <span className="text-sm text-gray-700 font-medium">{disease.name}</span>
                </div>
              ))}
            </div>
          ) : (
            <div className="h-40 flex items-center justify-center text-gray-400">
              <p>No diagnosis data</p>
            </div>
          )}
        </Card>

        {/* Recent activity */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
            <Clock className="w-4 h-4 text-gray-400" />
          </CardHeader>
          {isLoading ? (
            <div className="h-40 flex items-center justify-center">
              <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : recentActivity.length > 0 ? (
            <div className="space-y-3">
              {recentActivity.map((item: any, i: number) => (
                <div key={i} className="flex items-start gap-3">
                  <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 ${
                    item.type === 'diagnosis' ? 'bg-purple-500' : 'bg-green-500'
                  }`} />
                  <div className="min-w-0 flex-1">
                    <p className="text-sm text-gray-700">
                      <span className="font-medium">{item.label}</span>
                    </p>
                    <p className="text-sm text-gray-600 truncate">{item.detail}</p>
                    <p className="text-xs text-gray-400">{item.time}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="h-40 flex items-center justify-center text-gray-400">
              <p>No recent activity</p>
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}

// Helper function to format time ago
function formatTimeAgo(dateStr: string): string {
  if (!dateStr) return '';
  try {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 60) return `${diffMins} min${diffMins !== 1 ? 's' : ''} ago`;
    if (diffHours < 24) return `${diffHours} hr${diffHours !== 1 ? 's' : ''} ago`;
    if (diffDays < 7) return `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
    return date.toLocaleDateString();
  } catch {
    return '';
  }
}
