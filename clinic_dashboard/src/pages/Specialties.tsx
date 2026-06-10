import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Save } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import api, { getErrorMessage } from '../lib/api';
import { Clinic, MedicalSpecialty } from '../types';
import toast from 'react-hot-toast';

const SPECIALTIES: { value: MedicalSpecialty; label: string }[] = [
  { value: 'Cardiology', label: 'Cardiology' },
  { value: 'Endocrinology', label: 'Endocrinology' },
  { value: 'Infectious_Disease', label: 'Infectious Disease' },
  { value: 'Pulmonology', label: 'Pulmonology' },
  { value: 'Nephrology', label: 'Nephrology' },
  { value: 'Gastroenterology', label: 'Gastroenterology' },
  { value: 'Neurology', label: 'Neurology' },
  { value: 'Oncology', label: 'Oncology' },
  { value: 'Dermatology', label: 'Dermatology' },
  { value: 'Orthopedics', label: 'Orthopedics' },
  { value: 'General_Medicine', label: 'General Medicine' },
];

export function Specialties() {
  const qc = useQueryClient();
  const [selectedSpecialties, setSelectedSpecialties] = useState<string[]>([]);
  const [hasChanges, setHasChanges] = useState(false);

  const { data: clinicData, isLoading } = useQuery({
    queryKey: ['clinic-profile'],
    queryFn: async () => {
      const { data } = await api.get('/clinic-manager/my');
      return data.data.clinic as Clinic;
    },
  });

  // Initialize selected specialties when clinic data is loaded
  useEffect(() => {
    if (clinicData?.specialties) {
      setSelectedSpecialties(clinicData.specialties);
    }
  }, [clinicData]);

  const updateMutation = useMutation({
    mutationFn: async (specialties: string[]) => {
      return api.put('/clinic-manager/my/specialties', { specialties });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['clinic-profile'] });
      setHasChanges(false);
      toast.success('Specialties updated successfully!');
    },
    onError: (err) => {
      toast.error(getErrorMessage(err, 'Failed to update specialties'));
    },
  });

  const toggleSpecialty = (specialty: string) => {
    setSelectedSpecialties((prev) => {
      const newSelection = prev.includes(specialty)
        ? prev.filter((s) => s !== specialty)
        : [...prev, specialty];
      setHasChanges(true);
      return newSelection;
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (selectedSpecialties.length === 0) {
      toast.error('Please select at least one specialty');
      return;
    }

    await updateMutation.mutateAsync(selectedSpecialties);
  };

  const handleReset = () => {
    if (clinicData?.specialties) {
      setSelectedSpecialties(clinicData.specialties);
      setHasChanges(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Medical Specialties</h1>
        <p className="text-sm text-gray-500 mt-1">
          Select the medical specialties your clinic offers
        </p>
      </div>

      <form onSubmit={handleSubmit}>
        <Card>
          <div className="space-y-6">
            <div>
              <p className="text-sm text-gray-700 mb-4">
                Select at least one specialty. These will be used to match your clinic with
                patients looking for specialized care.
              </p>
              
              {selectedSpecialties.length === 0 && (
                <p className="text-sm text-red-600 mb-4">
                  ⚠️ At least one specialty is required
                </p>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {SPECIALTIES.map((specialty) => (
                  <label
                    key={specialty.value}
                    className={`flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all ${
                      selectedSpecialties.includes(specialty.value)
                        ? 'border-indigo-500 bg-indigo-50'
                        : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    <input
                      type="checkbox"
                      checked={selectedSpecialties.includes(specialty.value)}
                      onChange={() => toggleSpecialty(specialty.value)}
                      className="w-5 h-5 text-indigo-600 rounded focus:ring-indigo-500"
                    />
                    <span className="text-sm font-medium text-gray-900">
                      {specialty.label}
                    </span>
                  </label>
                ))}
              </div>
            </div>

            {/* Selected count */}
            <div className="p-4 bg-gray-50 rounded-lg">
              <p className="text-sm text-gray-700">
                <span className="font-semibold">{selectedSpecialties.length}</span>{' '}
                {selectedSpecialties.length === 1 ? 'specialty' : 'specialties'} selected
              </p>
            </div>

            {/* Actions */}
            {hasChanges && (
              <div className="flex justify-end gap-3 pt-4 border-t">
                <Button type="button" variant="outline" onClick={handleReset}>
                  Reset
                </Button>
                <Button
                  type="submit"
                  leftIcon={<Save className="w-4 h-4" />}
                  isLoading={updateMutation.isPending}
                  disabled={selectedSpecialties.length === 0}
                >
                  Save Changes
                </Button>
              </div>
            )}
          </div>
        </Card>
      </form>
    </div>
  );
}
