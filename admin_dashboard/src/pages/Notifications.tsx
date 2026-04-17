import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Bell, Search } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import api from '../lib/api';
import { formatDateTime } from '../lib/utils';

interface Notification {
  id: string;
  userId: string;
  type: string;
  channel: string;
  status: string;
  title: string;
  message: string;
  sentAt?: string;
  readAt?: string;
  createdAt: string;
}

const TYPE_OPTIONS = [
  { value: '', label: 'All Types' },
  { value: 'appointment_reminder', label: 'Appointment Reminder' },
  { value: 'lab_result_ready', label: 'Lab Result Ready' },
  { value: 'prescription_ready', label: 'Prescription Ready' },
  { value: 'critical_result', label: 'Critical Result' },
  { value: 'system_alert', label: 'System Alert' },
];

const STATUS_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  pending: 'warning', sent: 'info', delivered: 'success', read: 'success', failed: 'danger',
};

const CHANNEL_BADGE: Record<string, 'default' | 'info' | 'success' | 'purple'> = {
  in_app: 'default', email: 'info', sms: 'success', push: 'purple',
};

export function Notifications() {
  const [page, setPage] = useState(1);
  const [typeFilter, setTypeFilter] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['notifications', page, typeFilter],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (typeFilter) params.set('type', typeFilter);
      const { data } = await api.get(`/notifications?${params}`);
      // Response: { success, data: { notifications: [], unreadCount: number } }
      return {
        rows: (data.data?.notifications ?? []) as Notification[],
        total: (data.data?.notifications?.length ?? 0) as number,
      };
    },
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  const columns: Column[] = [
    {
      key: 'title',
      header: 'Notification',
      render: (n: Notification) => (
        <div>
          <p className="font-medium text-gray-900">{n.title}</p>
          <p className="text-xs text-gray-500 truncate max-w-[16rem]">{n.message}</p>
        </div>
      ),
    },
    {
      key: 'type',
      header: 'Type',
      render: (n: Notification) => (
        <span className="text-xs text-gray-600 capitalize">{n.type.replace(/_/g, ' ')}</span>
      ),
    },
    {
      key: 'channel',
      header: 'Channel',
      render: (n: Notification) => (
        <Badge variant={CHANNEL_BADGE[n.channel] ?? 'default'}>{n.channel.replace('_', ' ')}</Badge>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (n: Notification) => (
        <Badge variant={STATUS_BADGE[n.status] ?? 'default'}>{n.status}</Badge>
      ),
    },
    {
      key: 'sentAt',
      header: 'Sent At',
      render: (n: Notification) => (
        <span className="text-xs text-gray-500">{n.sentAt ? formatDateTime(n.sentAt) : '—'}</span>
      ),
    },
    {
      key: 'createdAt',
      header: 'Created',
      render: (n: Notification) => (
        <span className="text-xs text-gray-500">{formatDateTime(n.createdAt)}</span>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
          <p className="text-sm text-gray-500 mt-1">System notification history</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <Bell className="w-4 h-4" />
          <span>Total: {total}</span>
        </div>
      </div>

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input placeholder="Search notifications..." leftIcon={<Search className="w-4 h-4" />} className="sm:w-64" />
          <Select options={TYPE_OPTIONS} value={typeFilter}
            onChange={(e) => { setTypeFilter(e.target.value); setPage(1); }} className="sm:w-52" />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No notifications found" />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>
    </div>
  );
}
