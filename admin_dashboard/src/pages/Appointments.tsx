import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Search, Calendar, Clock } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import api from '../lib/api';
import { formatDateTime, capitalize } from '../lib/utils';
import type { Appointment } from '../types';

const STATUS_OPTIONS = [
  { value: '', label: 'All Statuses' },
  { value: 'scheduled', label: 'Scheduled' },
  { value: 'confirmed', label: 'Confirmed' },
  { value: 'checked_in', label: 'Checked In' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'no_show', label: 'No Show' },
];

const STATUS_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info' | 'purple'> = {
  scheduled: 'info', confirmed: 'info', checked_in: 'warning',
  in_progress: 'purple', completed: 'success', cancelled: 'danger',
  no_show: 'danger', rescheduled: 'warning',
};

export function Appointments() {
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');
  const [dateFilter, setDateFilter] = useState('');
  const [viewAppt, setViewAppt] = useState<Appointment | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['appointments', page, statusFilter, dateFilter],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (statusFilter) params.set('status', statusFilter);
      if (dateFilter) params.set('date', dateFilter);
      const { data } = await api.get(`/appointments?${params}`);
      // Response: { success, data: { appointments: [], count: number } }
      return {
        rows: (data.data?.appointments ?? []) as Appointment[],
        total: (data.data?.count ?? 0) as number,
      };
    },
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  const columns: Column[] = [
    {
      key: 'id',
      header: 'Appointment ID',
      render: (a: Appointment) => <span className="text-xs font-mono text-gray-500">{a.appointmentId}</span>,
    },
    {
      key: 'patient',
      header: 'Patient',
      render: (a: Appointment) => (
        <p className="font-medium text-gray-900">
          {a.patient ? `${a.patient.firstName} ${a.patient.lastName}` : a.patientId}
        </p>
      ),
    },
    {
      key: 'provider',
      header: 'Provider',
      render: (a: Appointment) => (
        <span className="text-gray-700">
          {a.provider ? `${a.provider.firstName} ${a.provider.lastName}` : a.providerId}
        </span>
      ),
    },
    {
      key: 'date',
      header: 'Date & Time',
      render: (a: Appointment) => (
        <div className="flex items-center gap-1.5 text-gray-700">
          <Clock className="w-3.5 h-3.5 text-gray-400" />
          <span className="text-sm">{formatDateTime(a.appointmentDate)}</span>
        </div>
      ),
    },
    {
      key: 'type',
      header: 'Type',
      render: (a: Appointment) => (
        <span className="text-sm text-gray-600 capitalize">{a.appointmentType.replace('_', ' ')}</span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (a: Appointment) => (
        <Badge variant={STATUS_BADGE[a.status] ?? 'default'}>{capitalize(a.status)}</Badge>
      ),
    },
    {
      key: 'duration',
      header: 'Duration',
      render: (a: Appointment) => <span className="text-sm text-gray-500">{a.durationMinutes} min</span>,
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Appointments</h1>
          <p className="text-sm text-gray-500 mt-1">View and manage all appointments</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <Calendar className="w-4 h-4" />
          <span>Total: {total}</span>
        </div>
      </div>

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input placeholder="Search by patient or provider..." leftIcon={<Search className="w-4 h-4" />} className="sm:w-64" />
          <Select options={STATUS_OPTIONS} value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }} className="sm:w-44" />
          <Input type="date" value={dateFilter}
            onChange={(e) => { setDateFilter(e.target.value); setPage(1); }} className="sm:w-44" />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No appointments found"
          onRowClick={(a) => setViewAppt(a as unknown as Appointment)} />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      <Modal isOpen={!!viewAppt} onClose={() => setViewAppt(null)} title="Appointment Details" size="md"
        footer={<Button variant="outline" onClick={() => setViewAppt(null)}>Close</Button>}>
        {viewAppt && (
          <div className="space-y-1">
            {([
              ['Appointment ID', viewAppt.appointmentId],
              ['Patient', viewAppt.patient ? `${viewAppt.patient.firstName} ${viewAppt.patient.lastName}` : viewAppt.patientId],
              ['Provider', viewAppt.provider ? `${viewAppt.provider.firstName} ${viewAppt.provider.lastName}` : viewAppt.providerId],
              ['Date & Time', formatDateTime(viewAppt.appointmentDate)],
              ['Duration', `${viewAppt.durationMinutes} minutes`],
              ['Type', capitalize(viewAppt.appointmentType)],
              ['Status', capitalize(viewAppt.status)],
              ['Clinic', viewAppt.clinicId],
              ['Reason', viewAppt.reason || '—'],
              ['Notes', viewAppt.notes || '—'],
              ['Telemedicine', viewAppt.isTelemedicine ? 'Yes' : 'No'],
            ] as [string, string][]).map(([label, value]) => (
              <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                <span className="text-sm text-gray-500">{label}</span>
                <span className="text-sm font-medium text-gray-900">{value}</span>
              </div>
            ))}
          </div>
        )}
      </Modal>
    </div>
  );
}
