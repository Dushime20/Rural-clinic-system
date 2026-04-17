import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, FlaskConical, CheckCircle } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import api, { getErrorMessage } from '../lib/api';
import { formatDateTime } from '../lib/utils';
import type { LabOrder } from '../types';
import toast from 'react-hot-toast';

const STATUS_OPTIONS = [
  { value: '', label: 'All Statuses' },
  { value: 'pending', label: 'Pending' },
  { value: 'collected', label: 'Collected' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
];

const PRIORITY_BADGE: Record<string, 'default' | 'warning' | 'danger'> = {
  routine: 'default', urgent: 'warning', stat: 'danger',
};

const STATUS_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  pending: 'warning', collected: 'info', in_progress: 'info',
  completed: 'success', cancelled: 'danger', rejected: 'danger',
};

export function LabOrders() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');
  const [viewOrder, setViewOrder] = useState<LabOrder | null>(null);

  // Pending orders (the only list endpoint available)
  const { data, isLoading } = useQuery({
    queryKey: ['lab-orders-pending', page, statusFilter],
    queryFn: async () => {
      const { data } = await api.get('/lab/orders/pending');
      // Response: { success, data: { orders: [] } } or similar
      const all = (data.data?.orders ?? data.data ?? []) as LabOrder[];
      const filtered = statusFilter ? all.filter((o) => o.status === statusFilter) : all;
      const start = (page - 1) * 10;
      return {
        rows: filtered.slice(start, start + 10),
        total: filtered.length,
      };
    },
  });

  // Critical results
  const { data: criticalResults } = useQuery({
    queryKey: ['critical-lab-results'],
    queryFn: async () => {
      try {
        const { data } = await api.get('/lab/results/critical');
        return (data.data?.results ?? data.data ?? []) as { id: string }[];
      } catch {
        return [] as { id: string }[];
      }
    },
  });

  const reviewMutation = useMutation({
    mutationFn: (id: string) => api.put(`/lab/results/${id}/review`, { approved: true }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['critical-lab-results'] });
      toast.success('Lab result reviewed');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to review result')),
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  const columns: Column[] = [
    {
      key: 'id',
      header: 'Order ID',
      render: (o: LabOrder) => <span className="text-xs font-mono text-gray-500">{o.orderId}</span>,
    },
    {
      key: 'patient',
      header: 'Patient',
      render: (o: LabOrder) => (
        <span className="font-medium text-gray-900">
          {o.patient ? `${o.patient.firstName} ${o.patient.lastName}` : o.patientId}
        </span>
      ),
    },
    {
      key: 'tests',
      header: 'Tests',
      render: (o: LabOrder) => (
        <div>
          <p className="text-gray-700">{o.tests?.[0]?.testName || '—'}</p>
          {o.tests?.length > 1 && <p className="text-xs text-gray-400">+{o.tests.length - 1} more</p>}
        </div>
      ),
    },
    {
      key: 'priority',
      header: 'Priority',
      render: (o: LabOrder) => <Badge variant={PRIORITY_BADGE[o.priority] ?? 'default'}>{o.priority}</Badge>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (o: LabOrder) => (
        <Badge variant={STATUS_BADGE[o.status] ?? 'default'}>{o.status.replace('_', ' ')}</Badge>
      ),
    },
    {
      key: 'date',
      header: 'Order Date',
      render: (o: LabOrder) => <span className="text-xs text-gray-500">{formatDateTime(o.orderDate)}</span>,
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Lab Orders</h1>
          <p className="text-sm text-gray-500 mt-1">Pending lab orders and critical results</p>
        </div>
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <FlaskConical className="w-4 h-4" />
          <span>Total: {total}</span>
        </div>
      </div>

      {/* Critical results alert */}
      {criticalResults && criticalResults.length > 0 && (
        <Card className="border-red-200 bg-red-50">
          <div className="flex items-start justify-between">
            <div>
              <p className="font-semibold text-red-800">
                {criticalResults.length} Critical Lab Result{criticalResults.length > 1 ? 's' : ''} Pending Review
              </p>
              <p className="text-sm text-red-600 mt-1">These require immediate attention</p>
            </div>
            <div className="flex gap-2">
              {criticalResults.slice(0, 2).map((r) => (
                <Button key={r.id} size="sm" variant="danger"
                  leftIcon={<CheckCircle className="w-3.5 h-3.5" />}
                  onClick={() => reviewMutation.mutate(r.id)}>Review</Button>
              ))}
            </div>
          </div>
        </Card>
      )}

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input placeholder="Search lab orders..." leftIcon={<Search className="w-4 h-4" />} className="sm:w-64" />
          <Select options={STATUS_OPTIONS} value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }} className="sm:w-44" />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No lab orders found"
          onRowClick={(o) => setViewOrder(o as unknown as LabOrder)} />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      <Modal isOpen={!!viewOrder} onClose={() => setViewOrder(null)} title="Lab Order Details" size="md"
        footer={<Button variant="outline" onClick={() => setViewOrder(null)}>Close</Button>}>
        {viewOrder && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              {([
                ['Order ID', viewOrder.orderId],
                ['Status', viewOrder.status.replace('_', ' ')],
                ['Priority', viewOrder.priority],
                ['Clinic', viewOrder.clinicId],
                ['Order Date', formatDateTime(viewOrder.orderDate)],
              ] as [string, string][]).map(([label, value]) => (
                <div key={label}>
                  <p className="text-xs font-medium text-gray-500">{label}</p>
                  <p className="text-sm text-gray-900 mt-0.5 capitalize">{value}</p>
                </div>
              ))}
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Tests Ordered</p>
              <div className="space-y-2">
                {viewOrder.tests?.map((t, i) => (
                  <div key={i} className="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{t.testName}</p>
                      <p className="text-xs text-gray-500">{t.category}</p>
                    </div>
                    <span className="text-xs font-mono text-gray-400">{t.testCode}</span>
                  </div>
                ))}
              </div>
            </div>
            {viewOrder.clinicalNotes && (
              <div>
                <p className="text-sm font-semibold text-gray-700 mb-1">Clinical Notes</p>
                <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3">{viewOrder.clinicalNotes}</p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
