import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Search, Shield, CheckCircle, XCircle } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import api from '../lib/api';
import { formatDateTime } from '../lib/utils';
import type { AuditLog } from '../types';

const ACTION_OPTIONS = [
  { value: '', label: 'All Actions' },
  { value: 'create', label: 'Create' },
  { value: 'read', label: 'Read' },
  { value: 'update', label: 'Update' },
  { value: 'delete', label: 'Delete' },
  { value: 'login', label: 'Login' },
  { value: 'logout', label: 'Logout' },
  { value: 'export', label: 'Export' },
];

const RESOURCE_OPTIONS = [
  { value: '', label: 'All Resources' },
  { value: 'user', label: 'User' },
  { value: 'patient', label: 'Patient' },
  { value: 'diagnosis', label: 'Diagnosis' },
  { value: 'appointment', label: 'Appointment' },
  { value: 'lab_order', label: 'Lab Order' },
  { value: 'prescription', label: 'Prescription' },
  { value: 'medication', label: 'Medication' },
];

const ACTION_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info' | 'purple'> = {
  create: 'success', read: 'default', update: 'info', delete: 'danger',
  login: 'purple', logout: 'warning', export: 'info', print: 'default',
};

export function AuditLogs() {
  const [page, setPage] = useState(1);
  const [actionFilter, setActionFilter] = useState('');
  const [resourceFilter, setResourceFilter] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['audit-logs', page, actionFilter, resourceFilter, startDate, endDate],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '15' });
      if (actionFilter) params.set('action', actionFilter);
      if (resourceFilter) params.set('resource', resourceFilter);
      if (startDate) params.set('startDate', startDate);
      if (endDate) params.set('endDate', endDate);
      const { data } = await api.get(`/audit?${params}`);
      // Response: { success, data: { logs: [], pagination: { total } } }
      return {
        rows: (data.data?.logs ?? []) as AuditLog[],
        total: (data.data?.pagination?.total ?? 0) as number,
      };
    },
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  const columns: Column[] = [
    {
      key: 'timestamp',
      header: 'Timestamp',
      render: (l: AuditLog) => (
        <span className="text-xs text-gray-500 whitespace-nowrap">{formatDateTime(l.timestamp)}</span>
      ),
    },
    {
      key: 'user',
      header: 'User',
      render: (l: AuditLog) => <span className="text-sm text-gray-700">{l.userEmail || '—'}</span>,
    },
    {
      key: 'action',
      header: 'Action',
      render: (l: AuditLog) => (
        <Badge variant={ACTION_BADGE[l.action] ?? 'default'}>{l.action}</Badge>
      ),
    },
    {
      key: 'resource',
      header: 'Resource',
      render: (l: AuditLog) => (
        <div>
          <span className="text-sm text-gray-700 capitalize">{l.resource.replace('_', ' ')}</span>
          {l.resourceId && (
            <p className="text-xs font-mono text-gray-400 truncate max-w-[6rem]">{l.resourceId}</p>
          )}
        </div>
      ),
    },
    {
      key: 'description',
      header: 'Description',
      render: (l: AuditLog) => (
        <span className="text-sm text-gray-600 truncate max-w-[12rem] block">{l.description || '—'}</span>
      ),
    },
    {
      key: 'ip',
      header: 'IP Address',
      render: (l: AuditLog) => (
        <span className="text-xs font-mono text-gray-500">{l.ipAddress || '—'}</span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (l: AuditLog) => (
        <div className="flex items-center gap-1">
          {l.success
            ? <CheckCircle className="w-4 h-4 text-green-500" />
            : <XCircle className="w-4 h-4 text-red-500" />}
          <span className={`text-xs ${l.success ? 'text-green-600' : 'text-red-600'}`}>
            {l.success ? 'Success' : 'Failed'}
          </span>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Audit Logs</h1>
          <p className="text-sm text-gray-500 mt-1">Complete audit trail of all system actions</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <Shield className="w-4 h-4" />
          <span>{total.toLocaleString()} records</span>
        </div>
      </div>

      <Card>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <Input placeholder="Search by email..." leftIcon={<Search className="w-4 h-4" />}
            className="col-span-2 sm:col-span-1" />
          <Select options={ACTION_OPTIONS} value={actionFilter}
            onChange={(e) => { setActionFilter(e.target.value); setPage(1); }} />
          <Select options={RESOURCE_OPTIONS} value={resourceFilter}
            onChange={(e) => { setResourceFilter(e.target.value); setPage(1); }} />
          <Input type="date" value={startDate} onChange={(e) => { setStartDate(e.target.value); setPage(1); }} />
          <Input type="date" value={endDate} onChange={(e) => { setEndDate(e.target.value); setPage(1); }} />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No audit logs found" />
        <Pagination page={page} total={total} limit={15} onPageChange={setPage} />
      </Card>
    </div>
  );
}
