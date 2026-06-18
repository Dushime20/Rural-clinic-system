import { useQuery } from '@tanstack/react-query';
import { Building2, Stethoscope, Calendar, AlertCircle, MapPin, Phone } from 'lucide-react';
import { Card, CardHeader, CardTitle } from '../components/ui/Card';
import { StatCard } from '../components/ui/StatCard';
import api from '../lib/api';
import { Clinic } from '../types';

export function Dashboard() {
  const { data: clinicData, isLoading } = useQuery({
    queryKey: ['clinic-profile'],
    queryFn: async () => {
      const { data } = await api.get('/clinic-manager/my');
      return data.data.clinic as Clinic;
    },
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const clinic = clinicData;
  const isProfileComplete = clinic?.specialties?.length > 0 && clinic?.address;

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">Welcome to your clinic portal</p>
      </div>

      {/* Incomplete profile notice */}
      {!isProfileComplete && (
        <Card className="border-orange-200 bg-orange-50">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-orange-600 mt-0.5 shrink-0" />
            <div>
              <h3 className="text-sm font-semibold text-orange-900">Complete Your Profile</h3>
              <p className="text-sm text-orange-700 mt-1">
                Please update your clinic information and add specialties to be visible in search results.
              </p>
            </div>
          </div>
        </Card>
      )}

      {/* Clinic info card */}
      <Card>
        <CardHeader>
          <CardTitle>Clinic Information</CardTitle>
          <Building2 className="w-4 h-4 text-gray-400" />
        </CardHeader>
        <div className="flex items-start gap-6 flex-wrap">
          {/* Clinic name and status */}
          <div className="flex items-start gap-4 flex-1 min-w-[250px]">
            <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center shrink-0">
              <Building2 className="w-6 h-6 text-blue-600" />
            </div>
            <div className="flex-1">
              <h2 className="text-lg font-bold text-gray-900">{clinic?.name || 'Clinic Name'}</h2>
              {clinic?.isActive ? (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 mt-1">
                  Active
                </span>
              ) : (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 mt-1">
                  Inactive
                </span>
              )}
            </div>
          </div>

          {/* Address */}
          {clinic?.address && (
            <div className="flex items-start gap-3 text-sm flex-1 min-w-[250px]">
              <MapPin className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
              <div>
                <p className="text-gray-700">{clinic.address}</p>
                {clinic.city && (
                  <p className="text-gray-500">
                    {clinic.city}
                    {clinic.district && `, ${clinic.district}`}
                  </p>
                )}
              </div>
            </div>
          )}

          {/* Phone */}
          {clinic?.contactPhone && (
            <div className="flex items-center gap-3 text-sm">
              <Phone className="w-4 h-4 text-gray-400 shrink-0" />
              <p className="text-gray-700">{clinic.contactPhone}</p>
            </div>
          )}
        </div>
      </Card>

      {/* Stats grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <StatCard
          title="Specialties"
          value={clinic?.specialties?.length || 0}
          icon={Stethoscope}
          color="blue"
          isLoading={isLoading}
        />
        <StatCard
          title="Days Active"
          value={
            clinic?.createdAt
              ? Math.floor(
                  (Date.now() - new Date(clinic.createdAt).getTime()) /
                    (1000 * 60 * 60 * 24)
                )
              : 0
          }
          icon={Calendar}
          color="green"
          isLoading={isLoading}
        />
        <StatCard
          title="Recommendations"
          value={0}
          icon={Building2}
          color="purple"
          isLoading={isLoading}
        />
      </div>

      {/* Quick actions */}
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <a href="/profile" className="block">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center shrink-0">
                  <Building2 className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Update Profile</h4>
                  <p className="text-sm text-gray-600 mt-1">
                    Edit your clinic information and contact details
                  </p>
                </div>
              </div>
            </a>
          </Card>
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <a href="/specialties" className="block">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center shrink-0">
                  <Stethoscope className="w-5 h-5 text-purple-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">Manage Specialties</h4>
                  <p className="text-sm text-gray-600 mt-1">
                    Update the medical specialties your clinic offers
                  </p>
                </div>
              </div>
            </a>
          </Card>
        </div>
      </div>

      {/* Specialties list */}
      {clinic?.specialties && clinic.specialties.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Your Specialties</CardTitle>
            <Stethoscope className="w-4 h-4 text-gray-400" />
          </CardHeader>
          <div className="flex flex-wrap gap-2">
            {clinic.specialties.map((specialty) => (
              <span
                key={specialty}
                className="inline-flex items-center px-3 py-1.5 rounded-lg text-sm font-medium bg-blue-50 text-blue-700 border border-blue-100"
              >
                {specialty.replace(/_/g, ' ')}
              </span>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}
