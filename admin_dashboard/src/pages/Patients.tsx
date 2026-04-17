import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Search, Trash2, Eye, UserPlus } from 'lucide-react';
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
import { formatDate } from '../lib/utils';
import type { Patient } from '../types';
import toast from 'react-hot-toast';

const schema = z.object({
  firstName: z.string().min(2, 'Required'),
  lastName: z.string().min(2, 'Required'),
  dateOfBirth: z.string().min(1, 'Required'),
  gender: z.enum(['male', 'female', 'other']),
  bloodType: z.string().optional(),
  phoneNumber: z.string().optional(),
  email: z.string().email().optional().or(z.literal('')),
  clinicId: z.string().min(1, 'Required'),
  addressCity: z.string().optional(),
  addressCountry: z.string().optional(),
  emergencyName: z.string().optional(),
  emergencyRelationship: z.string().optional(),
  emergencyPhone: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'unknown'].map(
  (v) => ({ value: v, label: v })
);

export function Patients() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [viewPatient, setViewPatient] = useState<Patient | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // ── Fetch ──────────────────────────────────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['patients', page, search],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (search) params.set('search', search);
      const { data } = await api.get(`/patients?${params}`);
      // Response: { success, data: { patients: [], pagination: { total } } }
      return {
        rows: (data.data?.patients ?? []) as Patient[],
        total: (data.data?.pagination?.total ?? 0) as number,
      };
    },
  });

  // ── Mutations ──────────────────────────────────────────────────────────────
  const createMutation = useMutation({
    mutationFn: (body: Record<string, unknown>) => api.post('/patients', body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients'] });
      setShowCreate(false);
      reset();
      toast.success('Patient registered successfully');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to register patient')),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => api.delete(`/patients/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients'] });
      setDeleteId(null);
      toast.success('Patient deleted');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to delete patient')),
  });

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = (d: FormData) => {
    createMutation.mutate({
      firstName: d.firstName,
      lastName: d.lastName,
      dateOfBirth: d.dateOfBirth,
      gender: d.gender,
      bloodType: d.bloodType || undefined,
      phoneNumber: d.phoneNumber || undefined,
      email: d.email || undefined,
      clinicId: d.clinicId,
      address: { city: d.addressCity, country: d.addressCountry || 'Rwanda' },
      emergencyContact: d.emergencyName
        ? { name: d.emergencyName, relationship: d.emergencyRelationship, phoneNumber: d.emergencyPhone }
        : undefined,
    });
  };

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'name',
      header: 'Patient',
      render: (p: Patient) => (
        <div>
          <p className="font-medium text-gray-900">{p.firstName} {p.lastName}</p>
          <p className="text-xs text-gray-500">{p.patientId}</p>
        </div>
      ),
    },
    {
      key: 'gender',
      header: 'Gender / DOB',
      render: (p: Patient) => (
        <div>
          <p className="text-gray-700 capitalize">{p.gender}</p>
          <p className="text-xs text-gray-500">{formatDate(p.dateOfBirth)}</p>
        </div>
      ),
    },
    {
      key: 'contact',
      header: 'Contact',
      render: (p: Patient) => (
        <div>
          <p className="text-gray-700">{p.phoneNumber || '—'}</p>
          <p className="text-xs text-gray-500">{p.email || ''}</p>
        </div>
      ),
    },
    {
      key: 'clinicId',
      header: 'Clinic',
      render: (p: Patient) => <span className="text-gray-600">{p.clinicId}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (p: Patient) => (
        <Badge variant={p.isActive ? 'success' : 'danger'}>
          {p.isActive ? 'Active' : 'Inactive'}
        </Badge>
      ),
    },
    {
      key: 'lastVisit',
      header: 'Last Visit',
      render: (p: Patient) => (
        <span className="text-xs text-gray-500">{p.lastVisit ? formatDate(p.lastVisit) : 'Never'}</span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (p: Patient) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); setViewPatient(p); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="View patient"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); setDeleteId(p.id); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
            aria-label="Delete patient"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Patients</h1>
          <p className="text-sm text-gray-500 mt-1">Manage patient records</p>
        </div>
        <Button leftIcon={<UserPlus className="w-4 h-4" />} onClick={() => { reset(); setShowCreate(true); }}>
          Register Patient
        </Button>
      </div>

      <Card>
        <Input
          placeholder="Search by name, ID, or phone..."
          leftIcon={<Search className="w-4 h-4" />}
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          className="max-w-sm"
        />
      </Card>

      <Card padding={false}>
        <Table columns={columns} data={rows} isLoading={isLoading} emptyMessage="No patients found"
          onRowClick={(p) => setViewPatient(p as unknown as Patient)} />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* ── Create Modal ── */}
      <Modal isOpen={showCreate} onClose={() => setShowCreate(false)} title="Register New Patient" size="xl"
        footer={
          <>
            <Button variant="outline" onClick={() => setShowCreate(false)}>Cancel</Button>
            <Button onClick={handleSubmit(onSubmit)} isLoading={isSubmitting || createMutation.isPending}
              leftIcon={<Plus className="w-4 h-4" />}>Register Patient</Button>
          </>
        }>
        <form className="space-y-5" noValidate>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Personal Information</p>
            <div className="grid grid-cols-2 gap-4">
              <Input label="First Name" required error={errors.firstName?.message} {...register('firstName')} />
              <Input label="Last Name" required error={errors.lastName?.message} {...register('lastName')} />
              <Input label="Date of Birth" type="date" required error={errors.dateOfBirth?.message} {...register('dateOfBirth')} />
              <Select label="Gender" required
                options={[{ value: 'male', label: 'Male' }, { value: 'female', label: 'Female' }, { value: 'other', label: 'Other' }]}
                error={errors.gender?.message} {...register('gender')} />
              <Select label="Blood Type" options={BLOOD_TYPES} placeholder="Select blood type" {...register('bloodType')} />
              <Input label="Clinic ID" required placeholder="CLINIC-001" error={errors.clinicId?.message} {...register('clinicId')} />
            </div>
          </div>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Contact Information</p>
            <div className="grid grid-cols-2 gap-4">
              <Input label="Phone Number" placeholder="+250788123456" {...register('phoneNumber')} />
              <Input label="Email" type="email" {...register('email')} />
              <Input label="City" {...register('addressCity')} />
              <Input label="Country" defaultValue="Rwanda" {...register('addressCountry')} />
            </div>
          </div>
          <div>
            <p className="text-sm font-semibold text-gray-700 mb-3">Emergency Contact</p>
            <div className="grid grid-cols-3 gap-4">
              <Input label="Name" {...register('emergencyName')} />
              <Input label="Relationship" placeholder="Spouse, Parent..." {...register('emergencyRelationship')} />
              <Input label="Phone" {...register('emergencyPhone')} />
            </div>
          </div>
        </form>
      </Modal>

      {/* ── View Modal ── */}
      <Modal isOpen={!!viewPatient} onClose={() => setViewPatient(null)} title="Patient Details" size="lg"
        footer={<Button variant="outline" onClick={() => setViewPatient(null)}>Close</Button>}>
        {viewPatient && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              {([
                ['Patient ID', viewPatient.patientId],
                ['Full Name', `${viewPatient.firstName} ${viewPatient.lastName}`],
                ['Date of Birth', formatDate(viewPatient.dateOfBirth)],
                ['Gender', viewPatient.gender],
                ['Blood Type', viewPatient.bloodType || '—'],
                ['Phone', viewPatient.phoneNumber || '—'],
                ['Email', viewPatient.email || '—'],
                ['Clinic', viewPatient.clinicId],
                ['Last Visit', viewPatient.lastVisit ? formatDate(viewPatient.lastVisit) : 'Never'],
                ['Status', viewPatient.isActive ? 'Active' : 'Inactive'],
              ] as [string, string][]).map(([label, value]) => (
                <div key={label}>
                  <p className="text-xs font-medium text-gray-500">{label}</p>
                  <p className="text-sm text-gray-900 mt-0.5 capitalize">{value}</p>
                </div>
              ))}
            </div>
            {viewPatient.allergies && viewPatient.allergies.length > 0 && (
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Allergies</p>
                <div className="flex flex-wrap gap-1">
                  {viewPatient.allergies.map((a) => <Badge key={a} variant="danger">{a}</Badge>)}
                </div>
              </div>
            )}
            {viewPatient.chronicConditions && viewPatient.chronicConditions.length > 0 && (
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Chronic Conditions</p>
                <div className="flex flex-wrap gap-1">
                  {viewPatient.chronicConditions.map((c) => <Badge key={c} variant="warning">{c}</Badge>)}
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* ── Delete Confirm ── */}
      <Modal isOpen={!!deleteId} onClose={() => setDeleteId(null)} title="Delete Patient" size="sm"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteId(null)}>Cancel</Button>
            <Button variant="danger" isLoading={deleteMutation.isPending}
              leftIcon={<Trash2 className="w-4 h-4" />}
              onClick={() => deleteId && deleteMutation.mutate(deleteId)}>Delete</Button>
          </>
        }>
        <p className="text-gray-600">
          Are you sure you want to permanently delete this patient record? This action cannot be undone.
        </p>
      </Modal>
    </div>
  );
}
