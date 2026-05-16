import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Search, FileText, User, Calendar, Pill, AlertCircle } from 'lucide-react';
import { Card } from '../../components/ui/Card';
import { Input } from '../../components/ui/Input';
import { Badge } from '../../components/ui/Badge';
import { Table } from '../../components/ui/Table';
import type { Column } from '../../components/ui/Table';
import { Pagination } from '../../components/ui/Pagination';
import { Modal } from '../../components/ui/Modal';
import { Button } from '../../components/ui/Button';
import api from '../../lib/api';
import { formatDate } from '../../lib/utils';

interface Diagnosis {
  id: string;
  diagnosisId: string;
  patientId: string;
  patient?: {
    firstName: string;
    lastName: string;
    phoneNumber?: string;
    dateOfBirth?: string;
  };
  performedBy?: {
    firstName: string;
    lastName: string;
  };
  symptoms: Array<{ name: string; severity?: string }>;
  vitalSigns: {
    temperature?: number;
    bloodPressureSystolic?: number;
    bloodPressureDiastolic?: number;
    heartRate?: number;
  };
  aiPredictions?: Array<{
    disease: string;
    confidence: number;
    icd10Code?: string;
    description?: string;
    recommendations?: string[];
    precautions?: string[];
    medications?: string[];
    diet?: string[];
    workout?: string[];
  }>;
  selectedDiagnosis?: {
    disease: string;
    confidence: number;
    icd10Code?: string;
  };
  prescriptions?: Array<{
    medication: string;
    dosage: string;
    frequency: string;
    duration: string;
  }>;
  notes?: string;
  diagnosisDate: string;
}

export function PharmacyPrescriptions() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [selectedDiagnosis, setSelectedDiagnosis] = useState<Diagnosis | null>(null);
  const [showDetails, setShowDetails] = useState(false);

  // ── Fetch diagnoses with prescriptions ────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['pharmacy-diagnoses', page, search],
    queryFn: async () => {
      // Fetch all diagnoses that have prescriptions
      const params = new URLSearchParams({ 
        page: String(page), 
        limit: '10',
      });
      if (search) params.set('search', search);
      
      const { data } = await api.get(`/diagnosis/prescriptions?${params}`);
      
      return {
        rows: (data.data?.diagnoses ?? []) as Diagnosis[],
        total: (data.data?.pagination?.total ?? 0) as number,
      };
    },
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  // ── View diagnosis details ─────────────────────────────────────────────────
  const handleViewDetails = async (diagnosis: Diagnosis) => {
    try {
      // Fetch full diagnosis details
      const { data } = await api.get(`/diagnosis/${diagnosis.id}`);
      setSelectedDiagnosis(data.data?.diagnosis ?? diagnosis);
      setShowDetails(true);
    } catch (err) {
      setSelectedDiagnosis(diagnosis);
      setShowDetails(true);
    }
  };

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'patient',
      header: 'Patient',
      render: (d: Diagnosis) => (
        <div className="flex items-start gap-2">
          <div className="w-8 h-8 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center flex-shrink-0">
            <User className="w-4 h-4" />
          </div>
          <div>
            <p className="font-medium text-gray-900">
              {d.patient?.firstName} {d.patient?.lastName}
            </p>
            {d.patient?.phoneNumber && (
              <p className="text-xs text-gray-500">{d.patient.phoneNumber}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'diagnosis',
      header: 'Diagnosis',
      render: (d: Diagnosis) => (
        <div>
          <p className="font-medium text-gray-900">
            {d.selectedDiagnosis?.disease || 'Pending'}
          </p>
          {d.selectedDiagnosis?.icd10Code && (
            <p className="text-xs text-gray-500">ICD-10: {d.selectedDiagnosis.icd10Code}</p>
          )}
          {d.selectedDiagnosis?.confidence && (
            <p className="text-xs text-gray-400">
              Confidence: {(d.selectedDiagnosis.confidence * 100).toFixed(0)}%
            </p>
          )}
        </div>
      ),
    },
    {
      key: 'prescriptions',
      header: 'Prescriptions',
      render: (d: Diagnosis) => (
        <div className="flex items-center gap-2">
          <Pill className="w-4 h-4 text-teal-500" />
          <span className="text-sm text-gray-700">
            {d.prescriptions?.length || 0} medication(s)
          </span>
        </div>
      ),
    },
    {
      key: 'date',
      header: 'Date',
      render: (d: Diagnosis) => (
        <div className="flex items-center gap-2 text-sm text-gray-600">
          <Calendar className="w-4 h-4 text-gray-400" />
          <span>{formatDate(d.diagnosisDate)}</span>
        </div>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (d: Diagnosis) => (
        <Button
          size="sm"
          variant="outline"
          onClick={(e) => {
            e.stopPropagation();
            handleViewDetails(d);
          }}
        >
          View Details
        </Button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Patient Prescriptions</h1>
          <p className="text-sm text-gray-500 mt-1">
            View patient diagnoses and prescribed medications
          </p>
        </div>
      </div>

      {/* Info Card */}
      <Card className="border-teal-200 bg-teal-50">
        <div className="flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-teal-900">
              Prescription Information
            </p>
            <p className="text-sm text-teal-700 mt-1">
              This page shows patient diagnoses with prescribed medications. Use this to check
              medicine availability and prepare orders for patients.
            </p>
          </div>
        </div>
      </Card>

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input
            placeholder="Search by patient name or phone number..."
            leftIcon={<Search className="w-4 h-4" />}
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="sm:w-96"
          />
        </div>
      </Card>

      <Card padding={false}>
        <Table
          columns={columns}
          data={rows}
          isLoading={isLoading}
          emptyMessage="No prescriptions found"
        />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* ── Details Modal ── */}
      <Modal
        isOpen={showDetails}
        onClose={() => setShowDetails(false)}
        title="Diagnosis & Prescription Details"
        size="xl"
        footer={
          <Button variant="outline" onClick={() => setShowDetails(false)}>
            Close
          </Button>
        }
      >
        {selectedDiagnosis && (
          <div className="space-y-6">
            {/* Patient Info */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
                <User className="w-4 h-4" />
                Patient Information
              </h3>
              <div className="p-4 bg-gray-50 rounded-lg space-y-2">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Name</span>
                  <span className="text-sm font-medium text-gray-900">
                    {selectedDiagnosis.patient?.firstName} {selectedDiagnosis.patient?.lastName}
                  </span>
                </div>
                {selectedDiagnosis.patient?.phoneNumber && (
                  <div className="flex justify-between">
                    <span className="text-sm text-gray-600">Phone</span>
                    <span className="text-sm font-medium text-gray-900">
                      {selectedDiagnosis.patient.phoneNumber}
                    </span>
                  </div>
                )}
                {selectedDiagnosis.patient?.dateOfBirth && (
                  <div className="flex justify-between">
                    <span className="text-sm text-gray-600">Date of Birth</span>
                    <span className="text-sm font-medium text-gray-900">
                      {formatDate(selectedDiagnosis.patient.dateOfBirth)}
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Diagnosis */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
                <FileText className="w-4 h-4" />
                Diagnosis Information
              </h3>
              <div className="p-4 bg-blue-50 rounded-lg space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Disease</span>
                  <span className="text-sm font-medium text-gray-900">
                    {selectedDiagnosis.selectedDiagnosis?.disease || 
                     selectedDiagnosis.aiPredictions?.[0]?.disease || 
                     'Pending'}
                  </span>
                </div>
                {(selectedDiagnosis.selectedDiagnosis?.icd10Code || 
                  selectedDiagnosis.aiPredictions?.[0]?.icd10Code) && (
                  <div className="flex justify-between">
                    <span className="text-sm text-gray-600">ICD-10 Code</span>
                    <span className="text-sm font-medium text-gray-900">
                      {selectedDiagnosis.selectedDiagnosis?.icd10Code || 
                       selectedDiagnosis.aiPredictions?.[0]?.icd10Code}
                    </span>
                  </div>
                )}
                {(selectedDiagnosis.selectedDiagnosis?.confidence || 
                  selectedDiagnosis.aiPredictions?.[0]?.confidence) && (
                  <div className="flex justify-between">
                    <span className="text-sm text-gray-600">Confidence</span>
                    <span className="text-sm font-medium text-gray-900">
                      {((selectedDiagnosis.selectedDiagnosis?.confidence || 
                         selectedDiagnosis.aiPredictions?.[0]?.confidence || 0) * 100).toFixed(1)}%
                    </span>
                  </div>
                )}
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Date</span>
                  <span className="text-sm font-medium text-gray-900">
                    {formatDate(selectedDiagnosis.diagnosisDate)}
                  </span>
                </div>
              </div>
            </div>

            {/* Disease Description */}
            {selectedDiagnosis.aiPredictions?.[0]?.description && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">
                  About {selectedDiagnosis.selectedDiagnosis?.disease || 
                         selectedDiagnosis.aiPredictions[0].disease}
                </h3>
                <div className="p-4 bg-blue-50 rounded-lg border border-blue-100">
                  <p className="text-sm text-gray-700 leading-relaxed">
                    {selectedDiagnosis.aiPredictions[0].description}
                  </p>
                </div>
              </div>
            )}

            {/* Symptoms */}
            {selectedDiagnosis.symptoms && selectedDiagnosis.symptoms.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Symptoms</h3>
                <div className="flex flex-wrap gap-2">
                  {selectedDiagnosis.symptoms.map((symptom, idx) => (
                    <Badge key={idx} variant="info">
                      {symptom.name}
                      {symptom.severity && ` (${symptom.severity})`}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            {/* Vital Signs */}
            {selectedDiagnosis.vitalSigns && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Vital Signs</h3>
                <div className="grid grid-cols-2 gap-3">
                  {selectedDiagnosis.vitalSigns.temperature && (
                    <div className="p-3 bg-gray-50 rounded-lg">
                      <p className="text-xs text-gray-500">Temperature</p>
                      <p className="text-sm font-medium text-gray-900">
                        {selectedDiagnosis.vitalSigns.temperature}°C
                      </p>
                    </div>
                  )}
                  {selectedDiagnosis.vitalSigns.bloodPressureSystolic && (
                    <div className="p-3 bg-gray-50 rounded-lg">
                      <p className="text-xs text-gray-500">Blood Pressure</p>
                      <p className="text-sm font-medium text-gray-900">
                        {selectedDiagnosis.vitalSigns.bloodPressureSystolic}/
                        {selectedDiagnosis.vitalSigns.bloodPressureDiastolic}
                      </p>
                    </div>
                  )}
                  {selectedDiagnosis.vitalSigns.heartRate && (
                    <div className="p-3 bg-gray-50 rounded-lg">
                      <p className="text-xs text-gray-500">Heart Rate</p>
                      <p className="text-sm font-medium text-gray-900">
                        {selectedDiagnosis.vitalSigns.heartRate} bpm
                      </p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Prescriptions */}
            {selectedDiagnosis.prescriptions && selectedDiagnosis.prescriptions.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
                  <Pill className="w-4 h-4" />
                  Prescribed Medications
                </h3>
                <div className="space-y-3">
                  {selectedDiagnosis.prescriptions.map((rx, idx) => (
                    <div key={idx} className="p-4 border border-teal-200 bg-teal-50 rounded-lg">
                      <div className="flex items-start justify-between mb-2">
                        <p className="font-medium text-gray-900">{rx.medication}</p>
                        <Badge variant="success">Prescribed</Badge>
                      </div>
                      <div className="grid grid-cols-3 gap-3 text-sm">
                        <div>
                          <p className="text-gray-500">Dosage</p>
                          <p className="font-medium text-gray-900">{rx.dosage}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Frequency</p>
                          <p className="font-medium text-gray-900">{rx.frequency}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Duration</p>
                          <p className="font-medium text-gray-900">{rx.duration}</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Notes */}
            {selectedDiagnosis.notes && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Clinical Notes</h3>
                <div className="p-4 bg-gray-50 rounded-lg">
                  <p className="text-sm text-gray-700">{selectedDiagnosis.notes}</p>
                </div>
              </div>
            )}

            {/* Performed By */}
            {selectedDiagnosis.performedBy && (
              <div className="pt-4 border-t border-gray-200">
                <p className="text-xs text-gray-500">
                  Diagnosed by:{' '}
                  <span className="font-medium text-gray-700">
                    {selectedDiagnosis.performedBy.firstName} {selectedDiagnosis.performedBy.lastName}
                  </span>
                </p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
