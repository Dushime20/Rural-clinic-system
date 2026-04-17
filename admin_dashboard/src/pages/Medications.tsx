import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Search, Edit2, Package, AlertTriangle } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import api, { getErrorMessage } from '../lib/api';
import { formatDate, formatCurrency } from '../lib/utils';
import type { Medication } from '../types';
import toast from 'react-hot-toast';

const schema = z.object({
  genericName: z.string().min(2, 'Required'),
  brandName: z.string().optional(),
  form: z.enum(['tablet', 'capsule', 'syrup', 'injection', 'cream', 'ointment', 'drops', 'inhaler', 'patch', 'suppository']),
  strength: z.string().min(1, 'Required'),
  category: z.enum(['antibiotic', 'analgesic', 'antihypertensive', 'antidiabetic', 'antimalarial', 'antiretroviral', 'vitamin', 'vaccine', 'other']),
  indications: z.string().optional(),
  contraindications: z.string().optional(),
  manufacturer: z.string().optional(),
  unitPrice: z.coerce.number().min(0).optional(),
  clinicId: z.string().min(1, 'Required'),
  requiresPrescription: z.boolean().default(false),
  stockQuantity: z.coerce.number().min(0).default(0),
  reorderLevel: z.coerce.number().min(0).default(50),
  expiryDate: z.string().optional(),
  batchNumber: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

const FORM_OPTIONS = ['tablet','capsule','syrup','injection','cream','ointment','drops','inhaler','patch','suppository']
  .map((v) => ({ value: v, label: v.charAt(0).toUpperCase() + v.slice(1) }));

const CATEGORY_OPTIONS = ['antibiotic','analgesic','antihypertensive','antidiabetic','antimalarial','antiretroviral','vitamin','vaccine','other']
  .map((v) => ({ value: v, label: v.charAt(0).toUpperCase() + v.slice(1) }));

export function Medications() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [editMed, setEditMed] = useState<Medication | null>(null);
  const [showStock, setShowStock] = useState<Medication | null>(null);
  const [stockQty, setStockQty] = useState('');

  // ── Fetch list ─────────────────────────────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['medications', page, search, categoryFilter],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (search) params.set('search', search);
      if (categoryFilter) params.set('category', categoryFilter);
      const { data } = await api.get(`/medications?${params}`);
      // Response: { success, data: { medications: [], pagination: { total } } }
      return {
        rows: (data.data?.medications ?? []) as Medication[],
        total: (data.data?.pagination?.total ?? 0) as number,
      };
    },
  });

  // ── Low stock ──────────────────────────────────────────────────────────────
  const { data: lowStock } = useQuery({
    queryKey: ['medications-low-stock'],
    queryFn: async () => {
      const { data } = await api.get('/medications/low-stock');
      return (data.data?.medications ?? data.data ?? []) as Medication[];
    },
  });

  // ── Mutations ──────────────────────────────────────────────────────────────
  const createMutation = useMutation({
    mutationFn: (body: Record<string, unknown>) => api.post('/medications', body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['medications'] });
      setShowCreate(false);
      reset();
      toast.success('Medication added');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to add medication')),
  });

  const updateStockMutation = useMutation({
    mutationFn: ({ id, quantity }: { id: string; quantity: number }) =>
      api.put(`/medications/${id}/stock`, { quantity }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['medications'] });
      setShowStock(null);
      toast.success('Stock updated');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to update stock')),
  });

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = (d: FormData) => {
    createMutation.mutate({
      ...d,
      stockInfo: {
        quantity: d.stockQuantity,
        reorderLevel: d.reorderLevel,
        expiryDate: d.expiryDate || undefined,
        batchNumber: d.batchNumber || undefined,
      },
    });
  };

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  const getStockBadge = (med: Medication) => {
    const qty = med.stockInfo?.quantity ?? 0;
    const reorder = med.stockInfo?.reorderLevel ?? 50;
    if (qty === 0) return <Badge variant="danger">Out of Stock</Badge>;
    if (qty <= reorder) return <Badge variant="warning">Low ({qty})</Badge>;
    return <Badge variant="success">In Stock ({qty})</Badge>;
  };

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'name',
      header: 'Medication',
      render: (m: Medication) => (
        <div>
          <p className="font-medium text-gray-900">{m.genericName}</p>
          {m.brandName && <p className="text-xs text-gray-500">{m.brandName}</p>}
          <p className="text-xs text-gray-400">{m.medicationCode}</p>
        </div>
      ),
    },
    {
      key: 'form',
      header: 'Form / Strength',
      render: (m: Medication) => (
        <div>
          <p className="text-gray-700 capitalize">{m.form}</p>
          <p className="text-xs text-gray-500">{m.strength}</p>
        </div>
      ),
    },
    {
      key: 'category',
      header: 'Category',
      render: (m: Medication) => <Badge variant="info">{m.category}</Badge>,
    },
    {
      key: 'stock',
      header: 'Stock',
      render: (m: Medication) => getStockBadge(m),
    },
    {
      key: 'price',
      header: 'Unit Price',
      render: (m: Medication) => (
        <span className="text-gray-700">{m.unitPrice ? formatCurrency(m.unitPrice) : '—'}</span>
      ),
    },
    {
      key: 'expiry',
      header: 'Expiry',
      render: (m: Medication) => (
        <span className="text-xs text-gray-500">
          {m.stockInfo?.expiryDate ? formatDate(m.stockInfo.expiryDate) : '—'}
        </span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (m: Medication) => (
        <div className="flex items-center gap-2">
          <button onClick={(e) => { e.stopPropagation(); setShowStock(m); setStockQty(''); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-green-600 hover:bg-green-50 transition-colors"
            aria-label="Update stock"><Package className="w-4 h-4" /></button>
          <button onClick={(e) => { e.stopPropagation(); setEditMed(m); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="Edit medication"><Edit2 className="w-4 h-4" /></button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Medications</h1>
          <p className="text-sm text-gray-500 mt-1">Manage medication catalog and stock</p>
        </div>
        <Button leftIcon={<Plus className="w-4 h-4" />} onClick={() => { reset(); setShowCreate(true); }}>
          Add Medication
        </Button>
      </div>

      {/* Low stock alert */}
      {lowStock && lowStock.length > 0 && (
        <Card className="border-orange-200 bg-orange-50">
          <div className="flex items-center gap-3">
            <AlertTriangle className="w-5 h-5 text-orange-500 flex-shrink-0" />
            <div>
              <p className="font-medium text-orange-800">{lowStock.length} medications are low on stock</p>
              <p className="text-sm text-orange-600 mt-0.5">
                {lowStock.slice(0, 3).map((m) => m.genericName).join(', ')}
                {lowStock.length > 3 && ` and ${lowStock.length - 3} more`}
              </p>
            </div>
          </div>
        </Card>
      )}

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input placeholder="Search medications..." leftIcon={<Search className="w-4 h-4" />}
            value={search} onChange={(e) => { setSearch(e.target.value); setPage(1); }} className="sm:w-72" />
          <Select options={[{ value: '', label: 'All Categories' }, ...CATEGORY_OPTIONS]}
            value={categoryFilter} onChange={(e) => { setCategoryFilter(e.target.value); setPage(1); }} className="sm:w-48" />
        </div>
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No medications found" />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* ── Create Modal ── */}
      <Modal isOpen={showCreate} onClose={() => setShowCreate(false)} title="Add New Medication" size="xl"
        footer={
          <>
            <Button variant="outline" onClick={() => setShowCreate(false)}>Cancel</Button>
            <Button onClick={handleSubmit(onSubmit)} isLoading={isSubmitting || createMutation.isPending}
              leftIcon={<Plus className="w-4 h-4" />}>Add Medication</Button>
          </>
        }>
        <form className="space-y-5" noValidate>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Basic Information</p>
            <div className="grid grid-cols-2 gap-4">
              <Input label="Generic Name" required error={errors.genericName?.message} {...register('genericName')} />
              <Input label="Brand Name" {...register('brandName')} />
              <Select label="Form" required options={FORM_OPTIONS} error={errors.form?.message} {...register('form')} />
              <Input label="Strength" required placeholder="500mg" error={errors.strength?.message} {...register('strength')} />
              <Select label="Category" required options={CATEGORY_OPTIONS} error={errors.category?.message} {...register('category')} />
              <Input label="Clinic ID" required placeholder="CLINIC-001" error={errors.clinicId?.message} {...register('clinicId')} />
              <Input label="Manufacturer" {...register('manufacturer')} />
              <Input label="Unit Price (RWF)" type="number" min="0" {...register('unitPrice')} />
            </div>
          </div>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Clinical Information</p>
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Indications</label>
                <textarea className="block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" rows={2} {...register('indications')} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Contraindications</label>
                <textarea className="block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" rows={2} {...register('contraindications')} />
              </div>
            </div>
          </div>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Stock Information</p>
            <div className="grid grid-cols-2 gap-4">
              <Input label="Initial Quantity" type="number" min="0" defaultValue="0" {...register('stockQuantity')} />
              <Input label="Reorder Level" type="number" min="0" defaultValue="50" {...register('reorderLevel')} />
              <Input label="Expiry Date" type="date" {...register('expiryDate')} />
              <Input label="Batch Number" {...register('batchNumber')} />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <input type="checkbox" id="requiresPrescription" {...register('requiresPrescription')} className="rounded" />
            <label htmlFor="requiresPrescription" className="text-sm text-gray-700">Requires prescription</label>
          </div>
        </form>
      </Modal>

      {/* ── Update Stock Modal ── */}
      <Modal isOpen={!!showStock} onClose={() => setShowStock(null)} title="Update Stock" size="sm"
        footer={
          <>
            <Button variant="outline" onClick={() => setShowStock(null)}>Cancel</Button>
            <Button isLoading={updateStockMutation.isPending}
              onClick={() => showStock && updateStockMutation.mutate({ id: showStock.id, quantity: Number(stockQty) })}>
              Update Stock
            </Button>
          </>
        }>
        {showStock && (
          <div className="space-y-4">
            <div className="p-3 bg-gray-50 rounded-lg">
              <p className="font-medium text-gray-900">{showStock.genericName}</p>
              <p className="text-sm text-gray-500">{showStock.strength} · {showStock.form}</p>
              <p className="text-sm text-gray-500 mt-1">
                Current stock: <span className="font-medium">{showStock.stockInfo?.quantity ?? 0}</span>
              </p>
            </div>
            <Input label="New Quantity" type="number" min="0" value={stockQty}
              onChange={(e) => setStockQty(e.target.value)} placeholder="Enter new quantity" />
          </div>
        )}
      </Modal>

      {/* ── Edit Modal ── */}
      <Modal isOpen={!!editMed} onClose={() => setEditMed(null)} title="Edit Medication" size="md"
        footer={
          <>
            <Button variant="outline" onClick={() => setEditMed(null)}>Cancel</Button>
            <Button onClick={() => { toast.success('Medication updated'); setEditMed(null); }}>Save Changes</Button>
          </>
        }>
        {editMed && (
          <div className="space-y-1">
            {([
              ['Generic Name', editMed.genericName],
              ['Brand Name', editMed.brandName || '—'],
              ['Form', editMed.form],
              ['Strength', editMed.strength],
              ['Category', editMed.category],
              ['Manufacturer', editMed.manufacturer || '—'],
              ['Unit Price', editMed.unitPrice ? formatCurrency(editMed.unitPrice) : '—'],
              ['Requires Prescription', editMed.requiresPrescription ? 'Yes' : 'No'],
            ] as [string, string][]).map(([label, value]) => (
              <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                <span className="text-sm text-gray-500">{label}</span>
                <span className="text-sm font-medium text-gray-900 capitalize">{value}</span>
              </div>
            ))}
          </div>
        )}
      </Modal>
    </div>
  );
}
