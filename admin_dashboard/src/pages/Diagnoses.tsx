import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Search, Activity, Brain } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import api from '../lib/api';
import { formatDateTime } from '../lib/utils';
import type { Diagnosis, Patient } from '../types';

const STATUS_BADGE: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
  pending: 'warning', confirmed: 'success', revised: 'info', cancelled: 'danger',
};

export function Diagnoses() {
  const [patientSearch, setPatientSearch] = useState('');
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [viewDiag, setViewDiag] = useState<Diagnosis | null>(null);

  // Search patients first, then load their diagnoses
  const { data: patients, isLoading: patientsLoading } = useQuery({
    queryKey: ['patients-search', patientSearch],
    queryFn: async () => {
      if (!patientSearch.trim()) return [] as Patient[];
      const { data } = await api.get(`/patients?search=${encodeURIComponent(patientSearch)}&limit=10`);
      return (data.data?.patients ?? []) as Patient[];
    },
    enabled: patientSearch.trim().length > 1,
  });

  const { data: diagnoses, isLoading: diagLoading } = useQuery({
    queryKey: ['diagnoses', selectedPatient?.id],
    queryFn: async () => {
      const { data } = await api.get(`/diagnosis/patients/${selectedPatient!.id}/diagnoses`);
      return (data.data?.diagnoses ?? data.data ?? []) as Diagnosis[];
    },
    enabled: !!selectedPatient,
  });

  const diagRows = diagnoses ?? [];

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
    { key: 'gender', header: 'Gender', render: (p: Patient) => <span className="capitalize text-gray-700">{p.gender}</span> },
    { key: 'clinicId', header: 'Clinic', render: (p: Patient) => <span className="text-gray-600">{p.clinicId}</span> },
    {
      key: 'select',
      header: '',
      render: (p: Patient) => (
        <Button size="sm" variant="outline" onClick={(e) => { e.stopPropagation(); setSelectedPatient(p); }}>
          View Diagnoses
        </Button>
      ),
    },
  ];

  const diagColumns: Column[] = [
    {
      key: 'id',
      header: 'Diagnosis ID',
      render: (d: Diagnosis) => <span className="text-xs font-mono text-gray-500">{d.diagnosisId}</span>,
    },
    {
      key: 'diagnosis',
      header: 'AI Diagnosis',
      render: (d: Diagnosis) => (
        <div>
          {d.selectedDiagnosis ? (
            <p className="font-medium text-gray-900">{d.selectedDiagnosis.disease}</p>
          ) : d.aiPredictions?.[0] ? (
            <>
              <p className="text-gray-700">{d.aiPredictions[0].disease}</p>
              <p className="text-xs text-gray-400">{(d.aiPredictions[0].confidence * 100).toFixed(0)}% confidence</p>
            </>
          ) : <span className="text-gray-400">—</span>}
        </div>
      ),
    },
    {
      key: 'symptoms',
      header: 'Symptoms',
      render: (d: Diagnosis) => (
        <div className="flex flex-wrap gap-1">
          {d.symptoms?.slice(0, 2).map((s) => <Badge key={s.name} variant="default">{s.name}</Badge>)}
          {d.symptoms?.length > 2 && <Badge variant="default">+{d.symptoms.length - 2}</Badge>}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (d: Diagnosis) => <Badge variant={STATUS_BADGE[d.status] ?? 'default'}>{d.status}</Badge>,
    },
    {
      key: 'date',
      header: 'Date',
      render: (d: Diagnosis) => <span className="text-xs text-gray-500">{formatDateTime(d.diagnosisDate)}</span>,
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Diagnoses</h1>
          <p className="text-sm text-gray-500 mt-1">AI-powered diagnosis records by patient</p>
        </div>
        <Activity className="w-5 h-5 text-gray-400" />
      </div>

      {/* Step 1: search patients */}
      {!selectedPatient && (
        <Card>
          <p className="text-sm font-medium text-gray-700 mb-3">Search a patient to view their diagnoses</p>
          <Input
            placeholder="Type patient name or ID..."
            leftIcon={<Search className="w-4 h-4" />}
            value={patientSearch}
            onChange={(e) => setPatientSearch(e.target.value)}
            className="max-w-sm"
          />
          {patientSearch.trim().length > 1 && (
            <div className="mt-4">
              <Table
                columns={patientColumns}
                data={patients ?? []}
                isLoading={patientsLoading}
                emptyMessage="No patients found"
              />
            </div>
          )}
        </Card>
      )}

      {/* Step 2: show diagnoses for selected patient */}
      {selectedPatient && (
        <>
          <Card>
            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold text-gray-900">
                  {selectedPatient.firstName} {selectedPatient.lastName}
                </p>
                <p className="text-sm text-gray-500">{selectedPatient.patientId} · {selectedPatient.clinicId}</p>
              </div>
              <Button variant="outline" size="sm" onClick={() => setSelectedPatient(null)}>
                ← Change Patient
              </Button>
            </div>
          </Card>

          <Card padding={false}>
            <Table
              columns={diagColumns}
              data={diagRows}
              isLoading={diagLoading}
              emptyMessage="No diagnoses found for this patient"
              onRowClick={(d) => setViewDiag(d as unknown as Diagnosis)}
            />
          </Card>
        </>
      )}

      {/* Detail modal */}
      <Modal isOpen={!!viewDiag} onClose={() => setViewDiag(null)} title="Diagnosis Details" size="lg"
        footer={<Button variant="outline" onClick={() => setViewDiag(null)}>Close</Button>}>
        {viewDiag && (
          <div className="space-y-5">
            <div className="grid grid-cols-2 gap-3">
              {([
                ['Diagnosis ID', viewDiag.diagnosisId],
                ['Status', viewDiag.status],
                ['Patient Age', `${viewDiag.patientAge} years`],
                ['Gender', viewDiag.patientGender],
                ['Date', formatDateTime(viewDiag.diagnosisDate)],
                ['Clinic', viewDiag.clinicId],
              ] as [string, string][]).map(([label, value]) => (
                <div key={label}>
                  <p className="text-xs font-medium text-gray-500">{label}</p>
                  <p className="text-sm text-gray-900 mt-0.5 capitalize">{value}</p>
                </div>
              ))}
            </div>

            {viewDiag.vitalSigns && (
              <div>
                <p className="text-sm font-semibold text-gray-700 mb-2">Vital Signs</p>
                <div className="grid grid-cols-3 gap-2">
                  {([
                    ['Temp', viewDiag.vitalSigns.temperature ? `${viewDiag.vitalSigns.temperature}°C` : '—'],
                    ['BP', viewDiag.vitalSigns.bloodPressureSystolic ? `${viewDiag.vitalSigns.bloodPressureSystolic}/${viewDiag.vitalSigns.bloodPressureDiastolic}` : '—'],
                    ['HR', viewDiag.vitalSigns.heartRate ? `${viewDiag.vitalSigns.heartRate} bpm` : '—'],
                    ['RR', viewDiag.vitalSigns.respiratoryRate ? `${viewDiag.vitalSigns.respiratoryRate}/min` : '—'],
                    ['SpO2', viewDiag.vitalSigns.oxygenSaturation ? `${viewDiag.vitalSigns.oxygenSaturation}%` : '—'],
                    ['Weight', viewDiag.vitalSigns.weight ? `${viewDiag.vitalSigns.weight} kg` : '—'],
                  ] as [string, string][]).map(([label, value]) => (
                    <div key={label} className="bg-gray-50 rounded-lg p-2 text-center">
                      <p className="text-xs text-gray-500">{label}</p>
                      <p className="text-sm font-medium text-gray-900">{value}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {viewDiag.symptoms?.length > 0 && (
              <div>
                <p className="text-sm font-semibold text-gray-700 mb-2">Symptoms</p>
                <div className="flex flex-wrap gap-2">
                  {viewDiag.symptoms.map((s) => (
                    <div key={s.name} className="bg-blue-50 rounded-lg px-3 py-1.5">
                      <p className="text-sm font-medium text-blue-800">{s.name}</p>
                      {s.severity && <p className="text-xs text-blue-600">{s.severity}</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {viewDiag.aiPredictions?.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Brain className="w-4 h-4 text-purple-500" />
                  <p className="text-sm font-semibold text-gray-700">AI Predictions</p>
                </div>
                <div className="space-y-2">
                  {viewDiag.aiPredictions.map((p, i) => (
                    <div key={i} className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                      <div>
                        <p className="text-sm font-medium text-purple-900">{p.disease}</p>
                        {p.icd10Code && <p className="text-xs text-purple-600">ICD-10: {p.icd10Code}</p>}
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-bold text-purple-700">{(p.confidence * 100).toFixed(0)}%</p>
                        <p className="text-xs text-purple-500">confidence</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {viewDiag.notes && (
              <div>
                <p className="text-sm font-semibold text-gray-700 mb-1">Notes</p>
                <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3">{viewDiag.notes}</p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
