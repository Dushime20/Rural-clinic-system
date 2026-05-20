import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { BarChart3, Download, Calendar, Users, Activity, TrendingUp } from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend
} from 'recharts';
import { Card, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import api from '../lib/api';
import toast from 'react-hot-toast';

const DISEASE_COLORS = ['#3b82f6', '#ef4444', '#10b981', '#f59e0b', '#8b5cf6', '#06b6d4'];

export function Reports() {
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  // Fetch analytics data for reports
  const { data: stats, isLoading, refetch } = useQuery({
    queryKey: ['report-data', startDate, endDate],
    queryFn: async () => {
      const { data } = await api.get('/analytics/dashboard');
      return data.data;
    },
    enabled: false, // Only fetch when user clicks Generate
  });

  const handleGenerate = () => {
    if (!startDate || !endDate) {
      toast.error('Please select both start and end dates');
      return;
    }
    if (new Date(startDate) > new Date(endDate)) {
      toast.error('Start date must be before end date');
      return;
    }
    refetch();
  };

  const handleExport = (type: string) => {
    if (!stats) {
      toast.error('Please generate a report first');
      return;
    }
    
    // Create CSV content based on report type
    let csvContent = '';
    let filename = '';

    if (type === 'summary') {
      filename = `patient-diagnosis-summary-${startDate}-to-${endDate}.csv`;
      csvContent = `Patient & Diagnosis Summary Report\n`;
      csvContent += `Period: ${startDate} to ${endDate}\n\n`;
      csvContent += `Metric,Value\n`;
      csvContent += `Total Patients,${stats.totalPatients}\n`;
      csvContent += `Total Diagnoses,${stats.totalDiagnoses}\n`;
      csvContent += `Total Users,${stats.totalUsers}\n`;
      csvContent += `Active Users,${stats.activeUsers}\n`;
      csvContent += `Total Pharmacies,${stats.totalPharmacies}\n`;
    } else if (type === 'diseases') {
      filename = `disease-distribution-${startDate}-to-${endDate}.csv`;
      csvContent = `Disease Distribution Report\n`;
      csvContent += `Period: ${startDate} to ${endDate}\n\n`;
      csvContent += `Disease,Count\n`;
      (stats.topDiseases || []).forEach((disease: { name: string }, index: number) => {
        const diseaseData = stats.diseaseTrends?.[stats.diseaseTrends.length - 1];
        const count = diseaseData?.[disease.name.toLowerCase().replace(/\s+/g, '_')] || 0;
        csvContent += `${disease.name},${count}\n`;
      });
    }

    // Create and download CSV file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    toast.success(`${type} report exported successfully`);
  };

  // Prepare chart data
  const diseaseChartData = stats?.topDiseases
    ? stats.topDiseases.map((disease: { name: string; key: string }) => {
        const latestMonth = stats.diseaseTrends?.[stats.diseaseTrends.length - 1];
        return {
          name: disease.name,
          count: latestMonth?.[disease.key] || 0,
        };
      })
    : [];

  const roleChartData = stats?.roleDistribution || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reports</h1>
          <p className="text-sm text-gray-500 mt-1">Generate system reports and analytics</p>
        </div>
        <BarChart3 className="w-6 h-6 text-gray-400" />
      </div>

      {/* Date Range Selector */}
      <Card>
        <div className="flex flex-col sm:flex-row gap-3 items-end">
          <Input
            label="Start Date"
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            className="sm:w-44"
          />
          <Input
            label="End Date"
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            className="sm:w-44"
          />
          <Button
            onClick={handleGenerate}
            isLoading={isLoading}
            leftIcon={<Calendar className="w-4 h-4" />}
          >
            Generate Reports
          </Button>
        </div>
      </Card>

      {stats && (
        <>
          {/* Summary Report */}
          <Card>
            <CardHeader>
              <CardTitle>Patient & Diagnosis Summary</CardTitle>
              <Button
                size="sm"
                variant="outline"
                leftIcon={<Download className="w-3.5 h-3.5" />}
                onClick={() => handleExport('summary')}
              >
                Export CSV
              </Button>
            </CardHeader>
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-4">
              {[
                { label: 'Total Patients', value: stats.totalPatients, icon: Users, color: 'text-green-600' },
                { label: 'Total Diagnoses', value: stats.totalDiagnoses, icon: Activity, color: 'text-purple-600' },
                { label: 'Total Users', value: stats.totalUsers, icon: Users, color: 'text-blue-600' },
                { label: 'Active Users', value: stats.activeUsers, icon: TrendingUp, color: 'text-teal-600' },
                { label: 'Pharmacies', value: stats.totalPharmacies, icon: BarChart3, color: 'text-orange-600' },
              ].map(({ label, value, icon: Icon, color }) => (
                <div key={label} className="bg-gray-50 rounded-xl p-4 text-center">
                  <Icon className={`w-5 h-5 mx-auto mb-2 ${color}`} />
                  <p className="text-2xl font-bold text-gray-900">{value?.toLocaleString()}</p>
                  <p className="text-xs text-gray-500 mt-1">{label}</p>
                </div>
              ))}
            </div>
          </Card>

          {/* Disease Distribution Report */}
          <Card>
            <CardHeader>
              <CardTitle>Disease Distribution</CardTitle>
              <Button
                size="sm"
                variant="outline"
                leftIcon={<Download className="w-3.5 h-3.5" />}
                onClick={() => handleExport('diseases')}
              >
                Export CSV
              </Button>
            </CardHeader>
            {diseaseChartData.length > 0 ? (
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div>
                  <p className="text-sm font-medium text-gray-700 mb-3">Top Diseases (Bar Chart)</p>
                  <ResponsiveContainer width="100%" height={240}>
                    <BarChart data={diseaseChartData}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                      <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                      <YAxis tick={{ fontSize: 11 }} />
                      <Tooltip />
                      <Bar dataKey="count" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-700 mb-3">Disease Distribution (Pie Chart)</p>
                  <ResponsiveContainer width="100%" height={240}>
                    <PieChart>
                      <Pie
                        data={diseaseChartData}
                        cx="50%"
                        cy="50%"
                        outerRadius={80}
                        dataKey="count"
                        nameKey="name"
                        label
                      >
                        {diseaseChartData.map((_, i) => (
                          <Cell key={i} fill={DISEASE_COLORS[i % DISEASE_COLORS.length]} />
                        ))}
                      </Pie>
                      <Tooltip />
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
              </div>
            ) : (
              <div className="text-center py-8 text-gray-400">
                <p>No disease data available for the selected period</p>
              </div>
            )}
          </Card>

          {/* User Distribution Report */}
          <Card>
            <CardHeader>
              <CardTitle>User Distribution by Role</CardTitle>
            </CardHeader>
            {roleChartData.length > 0 ? (
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <ResponsiveContainer width="100%" height={240}>
                  <PieChart>
                    <Pie
                      data={roleChartData}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={90}
                      dataKey="value"
                      nameKey="name"
                    >
                      {roleChartData.map((entry: { color: string }, i: number) => (
                        <Cell key={i} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                    <Legend />
                  </PieChart>
                </ResponsiveContainer>
                <div className="flex flex-col justify-center space-y-3">
                  {roleChartData.map((role: { name: string; value: number; color: string }) => (
                    <div key={role.name} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-4 h-4 rounded-full"
                          style={{ backgroundColor: role.color }}
                        />
                        <span className="text-sm font-medium text-gray-700">{role.name}</span>
                      </div>
                      <span className="text-lg font-bold text-gray-900">{role.value}</span>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="text-center py-8 text-gray-400">
                <p>No user data available</p>
              </div>
            )}
          </Card>

          {/* Disease Trends Over Time */}
          {stats.diseaseTrends && stats.diseaseTrends.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Disease Trends (Last 6 Months)</CardTitle>
              </CardHeader>
              <ResponsiveContainer width="100%" height={280}>
                <BarChart data={stats.diseaseTrends}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                  <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip />
                  <Legend />
                  {(stats.topDiseases || []).map((disease: { name: string; key: string }, i: number) => (
                    <Bar
                      key={disease.key}
                      dataKey={disease.key}
                      fill={DISEASE_COLORS[i % DISEASE_COLORS.length]}
                      name={disease.name}
                      radius={[4, 4, 0, 0]}
                    />
                  ))}
                </BarChart>
              </ResponsiveContainer>
            </Card>
          )}
        </>
      )}

      {!stats && !isLoading && (
        <Card>
          <div className="text-center py-12">
            <BarChart3 className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">Select a date range and click "Generate Reports" to view analytics</p>
          </div>
        </Card>
      )}
    </div>
  );
}
