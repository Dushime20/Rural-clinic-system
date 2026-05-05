import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, MapPin, Phone, Clock, CheckCircle, XCircle, Eye } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import { Button } from '../components/ui/Button';
import api, { getErrorMessage } from '../lib/api';
import toast from 'react-hot-toast';

interface Pharmacy {
  id: string;
  name: string;
  managerName?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude: number;
  longitude: number;
  isActive: boolean;
  openingHours?: string;
  createdAt: string;
  medicines?: any[];
}

export function Pharmacies() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [selectedPharmacy, setSelectedPharmacy] = useState<Pharmacy | null>(null);
  const [showDetails, setShowDetails] = useState(false);

  // ── Fetch pharmacies ───────────────────────────────────────────────────────
  const { data, isLoading } = useQuery({
    queryKey: ['pharmacies', page, search],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/map');
      let pharmacies = (data.data?.pharmacies ?? []) as Pharmacy[];
      
      // Client-side search
      if (search) {
        const searchLower = search.toLowerCase();
        pharmacies = pharmacies.filter(p => 
          p.name?.toLowerCase().includes(searchLower) ||
          p.city?.toLowerCase().includes(searchLower) ||
          p.district?.toLowerCase().includes(searchLower) ||
          p.managerName?.toLowerCase().includes(searchLower)
        );
      }
      
      // Client-side pagination
      const total = pharmacies.length;
      const start = (page - 1) * 10;
      const paginatedPharmacies = pharmacies.slice(start, start + 10);
      
      return {
        rows: paginatedPharmacies,
        total,
      };
    },
  });

  // ── Toggle active status ───────────────────────────────────────────────────
  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }: { id: string; isActive: boolean }) => {
      // Note: This endpoint may need to be created in the backend
      return api.put(`/pharmacy-manager/admin/${id}/status`, { isActive });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['pharmacies'] });
      toast.success('Pharmacy status updated');
    },
    onError: (err) => toast.error(getErrorMessage(err, 'Failed to update pharmacy status')),
  });

  const rows = data?.rows ?? [];
  const total = data?.total ?? 0;

  // ── View details ───────────────────────────────────────────────────────────
  const handleViewDetails = async (pharmacy: Pharmacy) => {
    try {
      // Fetch full pharmacy details with medicines
      const { data } = await api.get(`/pharmacy-manager/admin/pharmacies/${pharmacy.id}`);
      setSelectedPharmacy(data.data?.pharmacy ?? pharmacy);
      setShowDetails(true);
    } catch (err) {
      // If endpoint doesn't exist, just show basic info
      setSelectedPharmacy(pharmacy);
      setShowDetails(true);
    }
  };

  // ── Columns ────────────────────────────────────────────────────────────────
  const columns: Column[] = [
    {
      key: 'name',
      header: 'Pharmacy',
      render: (p: Pharmacy) => (
        <div>
          <p className="font-medium text-gray-900">{p.name}</p>
          {p.managerName && <p className="text-xs text-gray-500">Manager: {p.managerName}</p>}
        </div>
      ),
    },
    {
      key: 'location',
      header: 'Location',
      render: (p: Pharmacy) => (
        <div className="flex items-start gap-2">
          <MapPin className="w-4 h-4 text-gray-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-sm text-gray-700">{p.city || '—'}</p>
            <p className="text-xs text-gray-500">{p.district || ''}</p>
            {p.address && <p className="text-xs text-gray-400 mt-0.5">{p.address}</p>}
          </div>
        </div>
      ),
    },
    {
      key: 'contact',
      header: 'Contact',
      render: (p: Pharmacy) => (
        <div className="space-y-1">
          {p.phoneNumber && (
            <div className="flex items-center gap-2 text-sm text-gray-700">
              <Phone className="w-3.5 h-3.5 text-gray-400" />
              <span>{p.phoneNumber}</span>
            </div>
          )}
          {p.openingHours && (
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <Clock className="w-3.5 h-3.5 text-gray-400" />
              <span>{p.openingHours}</span>
            </div>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (p: Pharmacy) => (
        p.isActive ? 
          <Badge variant="success">Active</Badge> : 
          <Badge variant="danger">Inactive</Badge>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (p: Pharmacy) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); handleViewDetails(p); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="View details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              if (confirm(`${p.isActive ? 'Deactivate' : 'Activate'} ${p.name}?`)) {
                toggleActiveMutation.mutate({ id: p.id, isActive: !p.isActive });
              }
            }}
            className={`p-1.5 rounded-lg transition-colors ${
              p.isActive
                ? 'text-gray-400 hover:text-red-600 hover:bg-red-50'
                : 'text-gray-400 hover:text-green-600 hover:bg-green-50'
            }`}
            aria-label={p.isActive ? 'Deactivate' : 'Activate'}
          >
            {p.isActive ? <XCircle className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Pharmacies</h1>
          <p className="text-sm text-gray-500 mt-1">Manage registered pharmacies and their status</p>
        </div>
      </div>

      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input
            placeholder="Search pharmacies..."
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
          emptyMessage="No pharmacies found"
        />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* ── Details Modal ── */}
      <Modal
        isOpen={showDetails}
        onClose={() => setShowDetails(false)}
        title="Pharmacy Details"
        size="lg"
        footer={
          <Button variant="outline" onClick={() => setShowDetails(false)}>
            Close
          </Button>
        }
      >
        {selectedPharmacy && (
          <div className="space-y-6">
            {/* Basic Info */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Basic Information</h3>
              <div className="space-y-2">
                {([
                  ['Pharmacy Name', selectedPharmacy.name],
                  ['Manager', selectedPharmacy.managerName || '—'],
                  ['Phone Number', selectedPharmacy.phoneNumber || '—'],
                  ['Opening Hours', selectedPharmacy.openingHours || '—'],
                  ['Status', selectedPharmacy.isActive ? 'Active' : 'Inactive'],
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
                  ['Address', selectedPharmacy.address || '—'],
                  ['City', selectedPharmacy.city || '—'],
                  ['District', selectedPharmacy.district || '—'],
                  ['Country', selectedPharmacy.country || '—'],
                  ['Coordinates', `${selectedPharmacy.latitude}, ${selectedPharmacy.longitude}`],
                ] as [string, string][]).map(([label, value]) => (
                  <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-sm text-gray-500">{label}</span>
                    <span className="text-sm font-medium text-gray-900">{value}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Medicines Count */}
            {selectedPharmacy.medicines && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Inventory</h3>
                <div className="p-4 bg-blue-50 rounded-lg">
                  <p className="text-sm text-gray-700">
                    <span className="font-semibold text-blue-700">{selectedPharmacy.medicines.length}</span>
                    {' '}medicines registered
                  </p>
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
