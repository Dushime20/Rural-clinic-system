import { useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Search, AlertTriangle } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import api from '../lib/api';
import { capitalize } from '../lib/utils';

const CATEGORY_OPTIONS = ['antibiotic','analgesic','antihypertensive','antidiabetic','antimalarial','antiretroviral','vitamin','vaccine','other']
  .map((v) => ({ value: v, label: capitalize(v) }));

export function Medications() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');

  // ── Fetch list ─────────────────────────────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['pharmacy-medicines', page, search, categoryFilter],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (search) params.set('search', search);
      if (categoryFilter) params.set('category', categoryFilter);
      const { data } = await api.get(`/pharmacy-manager/admin/medicines?${params}`);
      // Response: { success, data: { medicines: [], pagination: { total } } }
      return {
        rows: (data.data?.medicines ?? []) as any[],
        total: (data.data?.pagination?.total ?? 0) as number,
      };
    },
  });

  // ── Low stock ──────────────────────────────────────────────────────────────
  const { data: lowStock } = useQuery({
    queryKey: ['pharmacy-medicines-low-stock'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/admin/medicines?isAvailable=true&limit=100');
      const medicines = data.data?.medicines ?? [];
      return medicines.filter((m: any) => m.stockQuantity <= 10);
    },
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'name',
      header: 'Medication',
      render: (m: any) => (
        <div>
          <p className="font-medium text-gray-900">{m.medicationName}</p>
          {m.brandName && <p className="text-xs text-gray-500">{m.brandName}</p>}
          {m.genericName && <p className="text-xs text-gray-400">{m.genericName}</p>}
        </div>
      ),
    },
    {
      key: 'pharmacy',
      header: 'Pharmacy',
      render: (m: any) => (
        <div>
          <p className="text-sm text-gray-700">{m.pharmacy?.name || '—'}</p>
          <p className="text-xs text-gray-500">{m.pharmacy?.city || ''}</p>
        </div>
      ),
    },
    {
      key: 'form',
      header: 'Form / Strength',
      render: (m: any) => (
        <div>
          <p className="text-gray-700 capitalize">{m.form || '—'}</p>
          <p className="text-xs text-gray-500">{m.strength || '—'}</p>
        </div>
      ),
    },
    {
      key: 'category',
      header: 'Category',
      render: (m: any) => m.category ? <Badge variant="info">{m.category}</Badge> : <span className="text-gray-400">—</span>,
    },
    {
      key: 'stock',
      header: 'Stock',
      render: (m: any) => {
        const qty = m.stockQuantity ?? 0;
        if (qty === 0) return <Badge variant="danger">Out of Stock</Badge>;
        if (qty <= 10) return <Badge variant="warning">Low ({qty})</Badge>;
        return <Badge variant="success">In Stock ({qty})</Badge>;
      },
    },
    {
      key: 'price',
      header: 'Price',
      render: (m: any) => (
        <span className="text-gray-700">{m.price ? `${m.price} ${m.currency || 'RWF'}` : '—'}</span>
      ),
    },
    {
      key: 'availability',
      header: 'Status',
      render: (m: any) => (
        m.isAvailable ? 
          <Badge variant="success">Available</Badge> : 
          <Badge variant="danger">Unavailable</Badge>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Pharmacy Medicines</h1>
          <p className="text-sm text-gray-500 mt-1">View all medicines available in registered pharmacies</p>
        </div>
      </div>

      {/* Low stock alert */}
      {lowStock && lowStock.length > 0 && (
        <Card className="border-orange-200 bg-orange-50">
          <div className="flex items-center gap-3">
            <AlertTriangle className="w-5 h-5 text-orange-500 flex-shrink-0" />
            <div>
              <p className="font-medium text-orange-800">{lowStock.length} medicines are low on stock</p>
              <p className="text-sm text-orange-600 mt-0.5">
                {lowStock.slice(0, 3).map((m: any) => m.medicationName).join(', ')}
                {lowStock.length > 3 && ` and ${lowStock.length - 3} more`}
              </p>
            </div>
          </div>
        </Card>
      )}

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input placeholder="Search medicines..." leftIcon={<Search className="w-4 h-4" />}
            value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} className="sm:w-72" />
          <Select options={[{ value: '', label: 'All Categories' }, ...CATEGORY_OPTIONS]}
            value={categoryFilter} onChange={(e) => { setCategoryFilter(e.target.value); setPage(1); }} className="sm:w-48" />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No medicines found in any pharmacy" />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>
    </div>
  );
}
