import { useQuery } from '@tanstack/react-query';
import { Pill, CheckCircle, XCircle, Store, MapPin, Package, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { StatCard } from '../../components/ui/StatCard';
import api from '../../lib/api';
import { formatCurrency, formatDate } from '../../lib/utils';

interface Pharmacy {
  id: string; name: string; address?: string; latitude: number; longitude: number;
  city?: string; district?: string; phoneNumber?: string; openingHours?: string;
  isActive: boolean; createdAt: string;
}
interface Medicine {
  id: string; medicationName: string; genericName?: string; brandName?: string;
  strength?: string; form?: string; category?: string;
  price: number; currency: string; stockQuantity: number; isAvailable: boolean;
}

export function PharmacyDashboard() {
  const navigate = useNavigate();

  const { data: pharmacy, isLoading: pharmacyLoading } = useQuery({
    queryKey: ['my-pharmacy'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/my');
      return data.data.pharmacy as Pharmacy | null;
    },
  });

  const { data: medicinesData } = useQuery({
    queryKey: ['my-medicines-summary'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/my/medicines?limit=6');
      return data.data as { medicines: Medicine[]; pagination: { total: number } };
    },
    enabled: !!pharmacy,
  });

  if (pharmacyLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-teal-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!pharmacy) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] text-center">
        <div className="w-20 h-20 bg-teal-100 rounded-full flex items-center justify-center mb-6">
          <Store className="w-10 h-10 text-teal-600" />
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Welcome to Your Pharmacy Portal</h2>
        <p className="text-gray-500 mb-8 max-w-md">
          You haven't set up your pharmacy yet. Register your pharmacy to start managing medicines
          and appear on the map for health workers.
        </p>
        <Button
          size="lg"
          onClick={() => navigate('/pharmacy-portal/profile')}
          leftIcon={<Store className="w-5 h-5" />}
        >
          Register My Pharmacy
        </Button>
      </div>
    );
  }

  const medicines = medicinesData?.medicines ?? [];
  const total = medicinesData?.pagination.total ?? 0;
  const available = medicines.filter((m) => m.isAvailable && m.stockQuantity > 0).length;
  const lowStock = medicines.filter((m) => m.stockQuantity > 0 && m.stockQuantity < 10).length;
  const outOfStock = medicines.filter((m) => m.stockQuantity === 0 || !m.isAvailable).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{pharmacy.name}</h1>
          <div className="flex items-center gap-2 mt-1 text-sm text-gray-500">
            <MapPin className="w-4 h-4 flex-shrink-0" />
            <span>{[pharmacy.address, pharmacy.city, pharmacy.district].filter(Boolean).join(', ') || 'No address set'}</span>
          </div>
        </div>
        <Badge variant={pharmacy.isActive ? 'success' : 'danger'}>
          {pharmacy.isActive ? 'Active' : 'Inactive'}
        </Badge>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Medicines"
          value={total}
          icon={<Pill className="w-5 h-5" />}
          color="blue"
        />
        <StatCard
          title="Available"
          value={available}
          icon={<CheckCircle className="w-5 h-5" />}
          color="green"
        />
        <StatCard
          title="Low Stock"
          value={lowStock}
          icon={<AlertTriangle className="w-5 h-5" />}
          color="yellow"
        />
        <StatCard
          title="Out of Stock"
          value={outOfStock}
          icon={<XCircle className="w-5 h-5" />}
          color="red"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent medicines */}
        <div className="lg:col-span-2">
          <Card padding={false}>
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
              <h2 className="text-base font-semibold text-gray-900">Recent Medicines</h2>
              <Button variant="outline" size="sm" onClick={() => navigate('/pharmacy-portal/medicines')}>
                View All
              </Button>
            </div>
            {medicines.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <Package className="w-10 h-10 text-gray-300 mb-3" />
                <p className="text-gray-500 text-sm">No medicines added yet</p>
                <Button size="sm" className="mt-3" onClick={() => navigate('/pharmacy-portal/medicines')}>
                  Add Medicines
                </Button>
              </div>
            ) : (
              <div className="divide-y divide-gray-50">
                {medicines.map((m) => (
                  <div key={m.id} className="px-6 py-3 flex items-center justify-between hover:bg-gray-50">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{m.medicationName}</p>
                      <p className="text-xs text-gray-500">
                        {[m.strength, m.form].filter(Boolean).join(' · ')}
                        {m.genericName ? ` · ${m.genericName}` : ''}
                      </p>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="text-sm font-semibold text-teal-700">
                        {formatCurrency(m.price, m.currency)}
                      </span>
                      <Badge variant={m.isAvailable && m.stockQuantity > 0 ? 'success' : m.stockQuantity < 10 && m.stockQuantity > 0 ? 'warning' : 'danger'}>
                        {m.isAvailable && m.stockQuantity > 0 ? `${m.stockQuantity} in stock` : 'Out of stock'}
                      </Badge>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </div>

        {/* Pharmacy info */}
        <div>
          <Card>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-base font-semibold text-gray-900">Pharmacy Info</h2>
              <Button variant="outline" size="sm" onClick={() => navigate('/pharmacy-portal/profile')}>
                Edit
              </Button>
            </div>
            <div className="space-y-3 text-sm">
              {[
                { label: 'Phone', value: pharmacy.phoneNumber || '—' },
                { label: 'Hours', value: pharmacy.openingHours || '—' },
                { label: 'City', value: pharmacy.city || '—' },
                { label: 'District', value: pharmacy.district || '—' },
                { label: 'GPS', value: `${Number(pharmacy.latitude).toFixed(4)}, ${Number(pharmacy.longitude).toFixed(4)}` },
                { label: 'Since', value: formatDate(pharmacy.createdAt) },
              ].map(({ label, value }) => (
                <div key={label} className="flex justify-between">
                  <span className="text-gray-500">{label}</span>
                  <span className="text-gray-800 font-medium text-right max-w-[60%] truncate">{value}</span>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
