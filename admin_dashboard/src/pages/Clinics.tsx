import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, MapPin, Phone, Plus, Eye, CheckCircle, XCircle } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import { CreateClinicModal } from '../components/clinics/CreateClinicModal';
import api, { getErrorMessage } from '../lib/api';
import toast from 'react-hot-toast';

interface Clinic {
  id: string;
  name: string;
  managerName?: string;
  email?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude: number;
  longitude: number;
  isActive: boolean;
  specialties: string[];
  openingHours?: any;
  createdAt: string;
  updatedAt?: string;
}

export function Clinics() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [selectedClinic, setSelectedClinic] = useState<Clinic | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);

  // ── Fetch clinics ──────────────────────────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['clinics', page, search],
    queryFn: async () => {
      const params = new URLSearchParams({
        page: page.toString(),
        limit: '10',
      });
      if (search) params.append('search', search);
      
      const { data } = await api.get(`/admin/clinics?${params}`);
      return {
        rows: data.data?.clinics ?? [],
        total: data.data?.pagination?.total ?? 0,
      };
    },
  });

  // ── Toggle active status ───────────────────────────────────────────────────
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }: { id: string; isActive: boolean }) => {
      return api.put(`/admin/clinics/${id}/status`, { isActive });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['clinics'] });
      toast.success('Clinic status updated');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to update clinic status')),
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  // ── View details ───────────────────────────────────────────────────────────
  const handleViewDetails = async (clinic: Clinic) => {
    try {
      const { data } = await api.get(`/admin/clinics/${clinic.id}`);
      setSelectedClinic(data.data?.clinic ?? clinic);
      setShowDetails(true);
    } catch (err) {
      setSelectedClinic(clinic);
      setShowDetails(true);
    }
  };

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'name',
      header: 'Clinic',
      render: (c: Clinic) => (
        <div>
          <p className="font-medium text-gray-900">{c.name}</p>
          {c.managerName && <p className="text-xs text-gray-500">Manager: {c.managerName}</p>}
          {c.email && <p className="text-xs text-gray-400">{c.email}</p>}
        </div>
      ),
    },
    {
      key: 'location',
      header: 'Location',
      render: (c: Clinic) => (
        <div className="flex items-start gap-2">
          <MapPin className="w-4 h-4 text-gray-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-sm text-gray-700">{c.city || '—'}</p>
            <p className="text-xs text-gray-500">{c.district || ''}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'contact',
      header: 'Contact',
      render: (c: Clinic) => (
        <div className="space-y-1">
          {c.phoneNumber && (
            <div className="flex items-center gap-2 text-sm text-gray-700">
              <Phone className="w-3.5 h-3.5 text-gray-400" />
              <span>{c.phoneNumber}</span>
            </div>
          )}
        </div>
      ),
    },
    {
      key: 'specialties',
      header: 'Specialties',
      render: (c: Clinic) => (
        <div className="flex flex-wrap gap-1">
          {c.specialties?.slice(0, 2).map((spec) => (
            <Badge key={spec} variant="info" className="text-xs">
              {spec.replace(/_/g, ' ')}
            </Badge>
          ))}
          {c.specialties?.length > 2 && (
            <Badge variant="neutral" className="text-xs">
              +{c.specialties.length - 2}
            </Badge>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (c: Clinic) => (
        c.isActive ? 
          <Badge variant="success">Active</Badge> : 
          <Badge variant="danger">Inactive</Badge>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (c: Clinic) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); handleViewDetails(c); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="View details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              if (confirm(`${c.isActive ? 'Deactivate' : 'Activate'} ${c.name}?`)) {
                toggleActiveMutation.mutate({ id: c.id, isActive: !c.isActive });
              }
            }}
            className={`p-1.5 rounded-lg transition-colors ${
              c.isActive
                ? 'text-gray-400 hover:text-red-600 hover:bg-red-50'
                : 'text-gray-400 hover:text-green-600 hover:bg-green-50'
            }`}
            aria-label={c.isActive ? 'Deactivate' : 'Activate'}
          >
            {c.isActive ? <XCircle className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Clinics</h1>
          <p className="text-sm text-gray-500 mt-1">Manage specialized clinics and their profiles</p>
        </div>
        <Button
          onClick={() => setShowCreateModal(true)}
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Create Clinic
        </Button>
      </div>

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input
            placeholder="Search clinics..."
            leftIcon={<Search className="w-4 h-4" />}
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="sm:w-72"
          />
        </div>
      </Card>

      <Card padding={false}>
        <Table
          columns={columns}
          data={rows}
          isLoading={isLoading}
          emptyMessage="No clinics found"
        />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* ── Details Modal ── */}
      <Modal
        isOpen={showDetails}
        onClose={() => setShowDetails(false)}
        title="Clinic Details"
        size="lg"
        footer={
          <Button variant="outline" onClick={() => setShowDetails(false)}>
            Close
          </Button>
        }
      >
        {selectedClinic && (
          <div className="space-y-6">
            {/* Basic Info */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Basic Information</h3>
              <div className="space-y-2">
                {([
                  ['Clinic Name', selectedClinic.name],
                  ['Manager', selectedClinic.managerName || '—'],
                  ['Email', selectedClinic.email || '—'],
                  ['Phone Number', selectedClinic.phoneNumber || '—'],
                  ['Status', selectedClinic.isActive ? 'Active' : 'Inactive'],
                ] as [string, string][]).map(([label, value]) => (
                  <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-sm text-gray-500">{label}</span>
                    <span className="text-sm font-medium text-gray-900">{value}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Location */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Location</h3>
              <div className="space-y-2">
                {([
                  ['Address', selectedClinic.address || '—'],
                  ['City', selectedClinic.city || '—'],
                  ['District', selectedClinic.district || '—'],
                  ['Country', selectedClinic.country || '—'],
                  ['Coordinates', `${selectedClinic.latitude}, ${selectedClinic.longitude}`],
                ] as [string, string][]).map(([label, value]) => (
                  <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-sm text-gray-500">{label}</span>
                    <span className="text-sm font-medium text-gray-900">{value}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Specialties */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Specialties</h3>
              <div className="flex flex-wrap gap-2">
                {selectedClinic.specialties?.map((spec) => (
                  <Badge key={spec} variant="info">
                    {spec.replace(/_/g, ' ')}
                  </Badge>
                ))}
              </div>
            </div>

            {/* Opening Hours */}
            {selectedClinic.openingHours && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Opening Hours</h3>
                <div className="p-4 bg-gray-50 rounded-lg">
                  <p className="text-sm text-gray-700">
                    {JSON.stringify(selectedClinic.openingHours)}
                  </p>
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* ── Create Modal ── */}
      <CreateClinicModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
      />
    </div>
  );
}
