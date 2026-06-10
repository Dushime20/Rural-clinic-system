import { useQuery } from '@tanstack/react-query';
import { Building2, Stethoscope, Calendar, AlertCircle } from 'lucide-react';
import { Card } from '../components/ui/Card';
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
        <div className="w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const clinic = clinicData;
  const isProfileComplete = clinic?.specialties?.length > 0 && clinic?.address;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">Welcome to your clinic portal</p>
      </div>

      {/* Incomplete profile notice */}
      {!isProfileComplete && (
        <Card className="border-orange-200 bg-orange-50">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-orange-600 mt-0.5 flex-shrink-0" />
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
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 bg-indigo-100 rounded-xl flex items-center justify-center flex-shrink-0">
              <Building2 className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-gray-900">{clinic?.name || 'Clinic Name'}</h2>
              {clinic?.address && (
                <p className="text-sm text-gray-600 mt-1">{clinic.address}</p>
              )}
              {clinic?.city && (
                <p className="text-sm text-gray-500">
                  {clinic.city}
                  {clinic.district && `, ${clinic.district}`}
                </p>
              )}
              <div className="mt-2">
                {clinic?.isActive ? (
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    Active
                  </span>
                ) : (
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    Inactive
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>
      </Card>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Stethoscope className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Specialties</p>
              <p className="text-2xl font-bold text-gray-900">
                {clinic?.specialties?.length || 0}
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <Calendar className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Days Since Registration</p>
              <p className="text-2xl font-bold text-gray-900">
                {clinic?.createdAt
                  ? Math.floor(
                      (Date.now() - new Date(clinic.createdAt).getTime()) /
                        (1000 * 60 * 60 * 24)
                    )
                  : 0}
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
              <Building2 className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Recommendations</p>
              <p className="text-2xl font-bold text-gray-900">0</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Quick actions */}
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <a href="/profile" className="block">
              <h4 className="font-semibold text-gray-900">Update Profile</h4>
              <p className="text-sm text-gray-600 mt-1">
                Edit your clinic information and contact details
              </p>
            </a>
          </Card>
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <a href="/specialties" className="block">
              <h4 className="font-semibold text-gray-900">Manage Specialties</h4>
              <p className="text-sm text-gray-600 mt-1">
                Update the medical specialties your clinic offers
              </p>
            </a>
          </Card>
        </div>
      </div>

      {/* Specialties list */}
      {clinic?.specialties && clinic.specialties.length > 0 && (
        <Card>
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Your Specialties</h3>
          <div className="flex flex-wrap gap-2">
            {clinic.specialties.map((specialty) => (
              <span
                key={specialty}
                className="inline-flex items-center px-3 py-1.5 rounded-lg text-sm font-medium bg-indigo-50 text-indigo-700"
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
