import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Plus, Search, Edit2, Trash2, ToggleLeft, ToggleRight,
  Pill, AlertTriangle, Package,
} from 'lucide-react';
import toast from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { Select } from '../../components/ui/Select';
import { Modal } from '../../components/ui/Modal';
import { Badge } from '../../components/ui/Badge';
import { Card } from '../../components/ui/Card';
import { Pagination } from '../../components/ui/Pagination';
import api from '../../lib/api';
import { formatCurrency } from '../../lib/utils';

interface Medicine {
  id: string; pharmacyId: string; medicationName: string; genericName?: string;
  brandName?: string; strength?: string; form?: string; category?: string;
  price: number; currency: string; stockQuantity: number; isAvailable: boolean;
  notes?: string; createdAt: string; updatedAt: string;
}

const FORM_OPTIONS = [
  { value: '', label: 'Select form' },
  { value: 'tablet', label: 'Tablet' }, { value: 'capsule', label: 'Capsule' },
  { value: 'syrup', label: 'Syrup' }, { value: 'injection', label: 'Injection' },
  { value: 'cream', label: 'Cream' }, { value: 'ointment', label: 'Ointment' },
  { value: 'drops', label: 'Drops' }, { value: 'inhaler', label: 'Inhaler' },
  { value: 'patch', label: 'Patch' }, { value: 'suppository', label: 'Suppository' },
  { value: 'other', label: 'Other' },
];

const CATEGORY_OPTIONS = [
  { value: '', label: 'Select category' },
  { value: 'antibiotic', label: 'Antibiotic' },
  { value: 'analgesic', label: 'Analgesic / Pain Relief' },
  { value: 'antihypertensive', label: 'Antihypertensive' },
  { value: 'antidiabetic', label: 'Antidiabetic' },
  { value: 'antimalarial', label: 'Antimalarial' },
  { value: 'antiretroviral', label: 'Antiretroviral' },
  { value: 'vitamin', label: 'Vitamin / Supplement' },
  { value: 'vaccine', label: 'Vaccine' },
  { value: 'other', label: 'Other' },
];

const schema = z.object({
  medicationName: z.string().min(2, 'Medicine name is required'),
  genericName: z.string().optional(),
  brandName: z.string().optional(),
  strength: z.string().optional(),
  form: z.string().optional(),
  category: z.string().optional(),
  price: z.string().refine((v) => !isNaN(parseFloat(v)) && parseFloat(v) >= 0, 'Valid price required'),
  currency: z.string().default('RWF'),
  stockQuantity: z.string().refine((v) => !isNaN(parseInt(v)) && parseInt(v) >= 0, 'Valid quantity required'),
  isAvailable: z.boolean().default(true),
  notes: z.string().optional(),
});
type MedicineFormData = z.infer<typeof schema>;

export function PharmacyMedicines() {
  const qc = useQueryClient();
  const navigate = useNavigate();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState<Medicine | null>(null);
  const [deleteItem, setDeleteItem] = useState<Medicine | null>(null);

  const { data: pharmacy } = useQuery({
    queryKey: ['my-pharmacy'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/my');
      return data.data.pharmacy;
    },
  });

  const { data, isLoading } = useQuery({
    queryKey: ['my-medicines', page, search],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '15' });
      if (search) params.set('search', search);
      const { data } = await api.get(`/pharmacy-manager/my/medicines?${params}`);
      return data.data as { medicines: Medicine[]; pagination: { total: number; totalPages: number } };
    },
    enabled: !!pharmacy,
  });

  const { register, handleSubmit, reset, setValue, formState: { errors } } = useForm<MedicineFormData>({
    resolver: zodResolver(schema),
    defaultValues: { currency: 'RWF', stockQuantity: '0', isAvailable: true },
  });

  const addMutation = useMutation({
    mutationFn: (body: MedicineFormData) => api.post('/pharmacy-manager/my/medicines', body),
    onSuccess: () => {
      toast.success('Medicine added');
      setShowAdd(false);
      reset();
      qc.invalidateQueries({ queryKey: ['my-medicines'] });
      qc.invalidateQueries({ queryKey: ['my-medicines-summary'] });
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message ?? 'Failed to add';
      toast.error(msg);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, body }: { id: string; body: MedicineFormData }) =>
      api.put(`/pharmacy-manager/my/medicines/${id}`, body),
    onSuccess: () => {
      toast.success('Medicine updated');
      setEditItem(null);
      reset();
      qc.invalidateQueries({ queryKey: ['my-medicines'] });
      qc.invalidateQueries({ queryKey: ['my-medicines-summary'] });
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message ?? 'Failed to update';
      toast.error(msg);
    },
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, isAvailable }: { id: string; isAvailable: boolean }) =>
      api.put(`/pharmacy-manager/my/medicines/${id}`, { isAvailable }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['my-medicines'] }),
    onError: () => toast.error('Failed to update availability'),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => api.delete(`/pharmacy-manager/my/medicines/${id}`),
    onSuccess: () => {
      toast.success('Medicine removed');
      setDeleteItem(null);
      qc.invalidateQueries({ queryKey: ['my-medicines'] });
      qc.invalidateQueries({ queryKey: ['my-medicines-summary'] });
    },
    onError: () => toast.error('Failed to remove medicine'),
  });

  const openEdit = (m: Medicine) => {
    setEditItem(m);
    setValue('medicationName', m.medicationName);
    setValue('genericName', m.genericName ?? '');
    setValue('brandName', m.brandName ?? '');
    setValue('strength', m.strength ?? '');
    setValue('form', m.form ?? '');
    setValue('category', m.category ?? '');
    setValue('price', String(m.price));
    setValue('currency', m.currency);
    setValue('stockQuantity', String(m.stockQuantity));
    setValue('isAvailable', m.isAvailable);
    setValue('notes', m.notes ?? '');
  };

  const onSubmit = (formData: MedicineFormData) => {
    if (editItem) updateMutation.mutate({ id: editItem.id, body: formData });
    else addMutation.mutate(formData);
  };

  const medicines = data?.medicines ?? [];
  const total = data?.pagination.total ?? 0;

  if (!pharmacy) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] text-center">
        <Package className="w-16 h-16 text-gray-300 mb-4" />
        <h2 className="text-xl font-bold text-gray-900 mb-2">Register Your Pharmacy First</h2>
        <p className="text-gray-500 mb-6">Set up your pharmacy profile before managing medicines.</p>
        <Button onClick={() => navigate('/pharmacy-portal/profile')}>Register Pharmacy</Button>
      </div>
    );
  }

  const FormFields = () => (
    <div className="space-y-4">
      <Input
        label="Medicine Name"
        placeholder="e.g. Amoxicillin"
        required
        error={errors.medicationName?.message}
        {...register('medicationName')}
      />
      <div className="grid grid-cols-2 gap-4">
        <Input label="Generic Name" placeholder="e.g. Amoxicillin" error={errors.genericName?.message} {...register('genericName')} />
        <Input label="Brand Name" placeholder="e.g. Amoxil" error={errors.brandName?.message} {...register('brandName')} />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <Input label="Strength" placeholder="e.g. 500mg" error={errors.strength?.message} {...register('strength')} />
        <Select label="Form" options={FORM_OPTIONS} error={errors.form?.message} {...register('form')} />
      </div>
      <Select label="Category" options={CATEGORY_OPTIONS} error={errors.category?.message} {...register('category')} />
      <div className="grid grid-cols-3 gap-4">
        <div className="col-span-2">
          <Input
            label="Price"
            type="number"
            min="0"
            step="0.01"
            placeholder="0.00"
            required
            error={errors.price?.message}
            {...register('price')}
          />
        </div>
        <Select
          label="Currency"
          options={[{ value: 'RWF', label: 'RWF' }, { value: 'USD', label: 'USD' }, { value: 'EUR', label: 'EUR' }]}
          {...register('currency')}
        />
      </div>
      <Input
        label="Stock Quantity"
        type="number"
        min="0"
        placeholder="0"
        required
        error={errors.stockQuantity?.message}
        hint="Number of units currently in stock"
        {...register('stockQuantity')}
      />
      <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
        <input
          type="checkbox"
          id="isAvailable"
          className="w-4 h-4 text-teal-600 border-gray-300 rounded focus:ring-teal-500"
          {...register('isAvailable')}
        />
        <label htmlFor="isAvailable" className="text-sm font-medium text-gray-700 cursor-pointer">
          Available for purchase
        </label>
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Notes (optional)</label>
        <textarea
          className="block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
          rows={2}
          placeholder="Any additional notes..."
          {...register('notes')}
        />
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Medicines &amp; Prices</h1>
          <p className="text-sm text-gray-500 mt-1">{total} medicine{total !== 1 ? 's' : ''} in your pharmacy</p>
        </div>
        <Button leftIcon={<Plus className="w-4 h-4" />} onClick={() => { reset(); setShowAdd(true); }}>
          Add Medicine
        </Button>
      </div>

      {/* Search */}
      <Card>
        <Input
          placeholder="Search by name, generic name, or brand..."
          leftIcon={<Search className="w-4 h-4" />}
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          className="max-w-sm"
        />
      </Card>

      {/* Table */}
      <Card padding={false}>
        {isLoading ? (
          <div className="flex items-center justify-center h-48">
            <div className="w-8 h-8 border-4 border-teal-600 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : medicines.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <Pill className="w-12 h-12 text-gray-300 mb-3" />
            <p className="text-gray-500 font-medium">
              {search ? 'No medicines match your search' : 'No medicines added yet'}
            </p>
            {!search && (
              <Button size="sm" className="mt-4" onClick={() => { reset(); setShowAdd(true); }}>
                Add Your First Medicine
              </Button>
            )}
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100 bg-gray-50">
                    {['Medicine', 'Form / Strength', 'Category', 'Price', 'Stock', 'Status', 'Actions'].map((h) => (
                      <th
                        key={h}
                        className={`px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wide ${
                          h === 'Price' || h === 'Actions' ? 'text-right' : h === 'Stock' || h === 'Status' ? 'text-center' : 'text-left'
                        } ${h === 'Medicine' ? 'pl-6' : ''} ${h === 'Actions' ? 'pr-6' : ''}`}
                      >
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {medicines.map((m) => (
                    <tr key={m.id} className="hover:bg-gray-50 transition-colors">
                      <td className="pl-6 pr-4 py-4">
                        <p className="font-medium text-gray-900">{m.medicationName}</p>
                        {m.genericName && <p className="text-xs text-gray-500">{m.genericName}</p>}
                        {m.brandName && <p className="text-xs text-gray-400 italic">{m.brandName}</p>}
                      </td>
                      <td className="px-4 py-4 text-gray-600">
                        {[m.strength, m.form].filter(Boolean).join(' · ') || '—'}
                      </td>
                      <td className="px-4 py-4">
                        {m.category ? (
                          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-teal-50 text-teal-700 capitalize">
                            {m.category}
                          </span>
                        ) : '—'}
                      </td>
                      <td className="px-4 py-4 text-right font-semibold text-teal-700">
                        {formatCurrency(m.price, m.currency)}
                      </td>
                      <td className="px-4 py-4 text-center">
                        <span className={`font-medium ${
                          m.stockQuantity === 0 ? 'text-red-600'
                          : m.stockQuantity < 10 ? 'text-amber-600'
                          : 'text-gray-700'
                        }`}>
                          {m.stockQuantity}
                        </span>
                        {m.stockQuantity > 0 && m.stockQuantity < 10 && (
                          <AlertTriangle className="w-3 h-3 text-amber-500 inline ml-1" />
                        )}
                      </td>
                      <td className="px-4 py-4 text-center">
                        <Badge variant={m.isAvailable && m.stockQuantity > 0 ? 'success' : 'danger'}>
                          {m.isAvailable && m.stockQuantity > 0 ? 'Available' : 'Unavailable'}
                        </Badge>
                      </td>
                      <td className="pl-4 pr-6 py-4">
                        <div className="flex items-center justify-end gap-1">
                          <button
                            onClick={() => openEdit(m)}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-teal-600 hover:bg-teal-50 transition-colors"
                            title="Edit"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => toggleMutation.mutate({ id: m.id, isAvailable: !m.isAvailable })}
                            className={`p-1.5 rounded-lg transition-colors ${
                              m.isAvailable ? 'text-green-500 hover:bg-green-50' : 'text-gray-400 hover:bg-gray-50'
                            }`}
                            title={m.isAvailable ? 'Mark unavailable' : 'Mark available'}
                          >
                            {m.isAvailable ? <ToggleRight className="w-4 h-4" /> : <ToggleLeft className="w-4 h-4" />}
                          </button>
                          <button
                            onClick={() => setDeleteItem(m)}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                            title="Remove"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <Pagination page={page} total={total} limit={15} onPageChange={setPage} />
          </>
        )}
      </Card>

      {/* Add / Edit Modal */}
      <Modal
        isOpen={showAdd || !!editItem}
        onClose={() => { setShowAdd(false); setEditItem(null); reset(); }}
        title={editItem ? 'Edit Medicine' : 'Add Medicine'}
        size="lg"
        footer={
          <>
            <Button variant="outline" onClick={() => { setShowAdd(false); setEditItem(null); reset(); }}>
              Cancel
            </Button>
            <Button
              onClick={handleSubmit(onSubmit)}
              isLoading={addMutation.isPending || updateMutation.isPending}
              leftIcon={<Plus className="w-4 h-4" />}
            >
              {editItem ? 'Save Changes' : 'Add Medicine'}
            </Button>
          </>
        }
      >
        <FormFields />
      </Modal>

      {/* Delete Confirm */}
      <Modal
        isOpen={!!deleteItem}
        onClose={() => setDeleteItem(null)}
        title="Remove Medicine"
        size="sm"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteItem(null)}>Cancel</Button>
            <Button
              variant="danger"
              isLoading={deleteMutation.isPending}
              onClick={() => deleteItem && deleteMutation.mutate(deleteItem.id)}
            >
              Remove
            </Button>
          </>
        }
      >
        <p className="text-sm text-gray-600">
          Are you sure you want to remove <strong>{deleteItem?.medicationName}</strong> from your pharmacy?
        </p>
      </Modal>
    </div>
  );
}
