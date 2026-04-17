import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, ClipboardList, XCircle, Eye } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import api, { getErrorMessage } from '../lib/api';
import { formatDate, formatDateTime } from '../lib/utils';
import type { Prescription, Patient } from '../types';
import toast from 'react-hot-toast';

const STATUS_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  active: 'success', completed: 'info', cancelled: 'danger', expired: 'warning',
};

export function Prescriptions() {
  const qc = useQueryClient();
  const [patientSearch, setPatientSearch] = useState('');
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [viewPres, setViewPres] = useState<Prescription | null>(null);
  const [cancelId, setCancelId] = useState<string | null>(null);

  const { data: patients, isLoading: patientsLoading } = useQuery({
    queryKey: ['patients-search-rx', patientSearch],
    queryFn: async () => {
      if (!patientSearch.trim()) return [] as Patient[];
      const { data } = await api.get(`/patients?search=${encodeURIComponent(patientSearch)}&limit=10`);
      return (data.data?.patients ?? []) as Patient[];
    },
    enabled: patientSearch.trim().length > 1,
  });

  const { data: prescriptions, isLoading: rxLoading } = useQuery({
    queryKey: ['prescriptions', selectedPatient?.id],
    queryFn: async () => {
      const { data } = await api.get(`/prescriptions/patient/${selectedPatient!.id}`);
      return (data.data?.prescriptions ?? data.data ?? []) as Prescription[];
    },
    enabled: !!selectedPatient,
  });

  const cancelMutation = useMutation({
    mutationFn: (id: string) => api.delete(`/prescriptions/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['prescriptions'] });
      setCancelId(null);
      toast.success('Prescription cancelled');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to cancel prescription')),
  });

  const rows = prescriptions ?? [];

  const patientColumns: Column[] = [
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
    { key: 'clinicId', header: 'Clinic', render: (p: Patient) => <span className="text-gray-600">{p.clinicId}</span> },
    {
      key: 'select',
      header: '',
      render: (p: Patient) => (
        <Button size="sm" variant="outline" onClick={(e) => { e.stopPropagation(); setSelectedPatient(p); }}>
          View Prescriptions
        </Button>
      ),
    },
  ];

  const rxColumns: Column[] = [
    {
      key: 'id',
      header: 'Prescription ID',
      render: (p: Prescription) => <span className="text-xs font-mono text-gray-500">{p.prescriptionId}</span>,
    },
    {
      key: 'medications',
      header: 'Medications',
      render: (p: Prescription) => (
        <div>
          <p className="text-gray-700">{p.medications?.[0]?.medicationName || '—'}</p>
          {p.medications?.length > 1 && <p className="text-xs text-gray-400">+{p.medications.length - 1} more</p>}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (p: Prescription) => <Badge variant={STATUS_BADGE[p.status] ?? 'default'}>{p.status}</Badge>,
    },
    {
      key: 'dispensed',
      header: 'Dispensed',
      render: (p: Prescription) => (
        <Badge variant={p.isDispensed ? 'success' : 'warning'}>{p.isDispensed ? 'Yes' : 'Pending'}</Badge>
      ),
    },
    {
      key: 'date',
      header: 'Date',
      render: (p: Prescription) => <span className="text-xs text-gray-500">{formatDate(p.prescriptionDate)}</span>,
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (p: Prescription) => (
        <div className="flex items-center gap-2">
          <button onClick={(e) => { e.stopPropagation(); setViewPres(p); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="View"><Eye className="w-4 h-4" /></button>
          {p.status === 'active' && (
            <button onClick={(e) => { e.stopPropagation(); setCancelId(p.id); }}
              className="p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
              aria-label="Cancel"><XCircle className="w-4 h-4" /></button>
          )}
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Prescriptions</h1>
          <p className="text-sm text-gray-500 mt-1">Manage and review prescriptions by patient</p>
        </div>
        <ClipboardList className="w-5 h-5 text-gray-400" />
      </div>

      {!selectedPatient && (
        <Card>
          <p className="text-sm font-medium text-gray-700 mb-3">Search a patient to view their prescriptions</p>
          <Input placeholder="Type patient name or ID..." leftIcon={<Search className="w-4 h-4" />}
            value={patientSearch} onChange={(e) => setPatientSearch(e.target.value)} className="max-w-sm" />
          {patientSearch.trim().length > 1 && (
            <div className="mt-4">
              <Table columns={patientColumns} data={patients ?? []} isLoading={patientsLoading} emptyMessage="No patients found" />
            </div>
          )}
        </Card>
      )}

      {selectedPatient && (
        <>
          <Card>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold text-gray-900">{selectedPatient.firstName} {selectedPatient.lastName}</p>
                <p className="text-sm text-gray-500">{selectedPatient.patientId}</p>
              </div>
              <Button variant="outline" size="sm" onClick={() => setSelectedPatient(null)}>← Change Patient</Button>
            </div>
          </Card>
          <Card padding={false}>
            <Table columns={rxColumns} data={rows} isLoading={rxLoading}
              emptyMessage="No prescriptions found for this patient"
              onRowClick={(p) => setViewPres(p as unknown as Prescription)} />
          </Card>
        </>
      )}

      {/* View Modal */}
      <Modal isOpen={!!viewPres} onClose={() => setViewPres(null)} title="Prescription Details" size="lg"
        footer={<Button variant="outline" onClick={() => setViewPres(null)}>Close</Button>}>
        {viewPres && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              {([
                ['Prescription ID', viewPres.prescriptionId],
                ['Status', viewPres.status],
                ['Date', formatDate(viewPres.prescriptionDate)],
                ['Expiry', viewPres.expiryDate ? formatDate(viewPres.expiryDate) : '—'],
                ['Dispensed', viewPres.isDispensed ? `Yes (${viewPres.dispensedAt ? formatDateTime(viewPres.dispensedAt) : ''})` : 'No'],
                ['Clinic', viewPres.clinicId],
              ] as [string, string][]).map(([label, value]) => (
                <div key={label}>
                  <p className="text-xs font-medium text-gray-500">{label}</p>
                  <p className="text-sm text-gray-900 mt-0.5 capitalize">{value}</p>
                </div>
              ))}
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-700 mb-2">Medications</p>
              <div className="space-y-2">
                {viewPres.medications?.map((m, i) => (
                  <div key={i} className="p-3 bg-gray-50 rounded-lg">
                    <p className="font-medium text-gray-900">{m.medicationName}</p>
                    <div className="grid grid-cols-3 gap-2 mt-1 text-xs text-gray-500">
                      <span>Dosage: {m.dosage}</span>
                      <span>Frequency: {m.frequency}</span>
                      <span>Duration: {m.duration}</span>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">Instructions: {m.instructions}</p>
                  </div>
                ))}
              </div>
            </div>
            {viewPres.notes && (
              <div>
                <p className="text-sm font-semibold text-gray-700 mb-1">Notes</p>
                <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3">{viewPres.notes}</p>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Cancel Confirm */}
      <Modal isOpen={!!cancelId} onClose={() => setCancelId(null)} title="Cancel Prescription" size="sm"
        footer={
          <>
            <Button variant="outline" onClick={() => setCancelId(null)}>Keep</Button>
            <Button variant="danger" isLoading={cancelMutation.isPending}
              onClick={() => cancelId && cancelMutation.mutate(cancelId)}>Cancel Prescription</Button>
          </>
        }>
        <p className="text-gray-600">Are you sure you want to cancel this prescription?</p>
      </Modal>
    </div>
  );
}
