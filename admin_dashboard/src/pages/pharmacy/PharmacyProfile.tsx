import { useEffect, useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { MapPin, Store, Navigation, Save } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../lib/api';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { Card } from '../../components/ui/Card';

interface Pharmacy {
  id: string; managerId: string; name: string; phoneNumber?: string; address?: string;
  latitude: number; longitude: number; city?: string; district?: string;
  country?: string; openingHours?: string; isActive: boolean; createdAt: string;
}

const schema = z.object({
  name: z.string().min(2, 'Pharmacy name is required'),
  phoneNumber: z.string().optional(),
  address: z.string().optional(),
  latitude: z.string().refine(
    (v) => !isNaN(parseFloat(v)) && parseFloat(v) >= -90 && parseFloat(v) <= 90,
    'Enter a valid latitude (e.g. -1.9441)'
  ),
  longitude: z.string().refine(
    (v) => !isNaN(parseFloat(v)) && parseFloat(v) >= -180 && parseFloat(v) <= 180,
    'Enter a valid longitude (e.g. 30.0619)'
  ),
  city: z.string().optional(),
  district: z.string().optional(),
  country: z.string().optional(),
  openingHours: z.string().optional(),
});
type FormData = z.infer<typeof schema>;

export function PharmacyProfile() {
  const qc = useQueryClient();
  const [gpsLoading, setGpsLoading] = useState(false);

  const { data: pharmacy, isLoading } = useQuery({
    queryKey: ['my-pharmacy'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/my');
      return data.data.pharmacy as Pharmacy | null;
    },
  });

  const isNew = !pharmacy;

  const { register, handleSubmit, setValue, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: '', phoneNumber: '', address: '',
      latitude: '', longitude: '',
      city: '', district: '', country: 'Rwanda', openingHours: '',
    },
  });

  useEffect(() => {
    if (pharmacy) {
      setValue('name', pharmacy.name);
      setValue('phoneNumber', pharmacy.phoneNumber ?? '');
      setValue('address', pharmacy.address ?? '');
      setValue('latitude', String(pharmacy.latitude));
      setValue('longitude', String(pharmacy.longitude));
      setValue('city', pharmacy.city ?? '');
      setValue('district', pharmacy.district ?? '');
      setValue('country', pharmacy.country ?? 'Rwanda');
      setValue('openingHours', pharmacy.openingHours ?? '');
    }
  }, [pharmacy, setValue]);

  const mutation = useMutation({
    mutationFn: (body: FormData) =>
      isNew
        ? api.post('/pharmacy-manager/my', body)
        : api.put('/pharmacy-manager/my', body),
    onSuccess: () => {
      toast.success(isNew ? 'Pharmacy registered!' : 'Pharmacy updated!');
      qc.invalidateQueries({ queryKey: ['my-pharmacy'] });
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message ?? 'Failed to save';
      toast.error(msg);
    },
  });

  const detectLocation = () => {
    if (!navigator.geolocation) {
      toast.error('Geolocation not supported by your browser');
      return;
    }
    setGpsLoading(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setValue('latitude', pos.coords.latitude.toFixed(7));
        setValue('longitude', pos.coords.longitude.toFixed(7));
        toast.success('Location detected!');
        setGpsLoading(false);
      },
      () => {
        toast.error('Could not detect location. Enter coordinates manually.');
        setGpsLoading(false);
      }
    );
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-teal-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">
          {isNew ? 'Register Your Pharmacy' : 'Pharmacy Profile'}
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          {isNew
            ? 'Set up your pharmacy so health workers can find you on the map'
            : 'Update your pharmacy information and GPS location'}
        </p>
      </div>

      {isNew && (
        <div className="p-4 bg-teal-50 border border-teal-200 rounded-xl flex items-start gap-3">
          <Store className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-teal-900">First-time setup</p>
            <p className="text-sm text-teal-700 mt-0.5">
              Once registered, your pharmacy appears on the map and health workers will see
              your medicines and prices in AI diagnosis results.
            </p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit((d) => mutation.mutate(d))} noValidate className="space-y-6">
        {/* Basic Info */}
        <Card>
          <h2 className="text-base font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Store className="w-4 h-4 text-teal-600" /> Basic Information
          </h2>
          <div className="space-y-4">
            <Input
              label="Pharmacy Name"
              placeholder="e.g. Kigali Central Pharmacy"
              required
              error={errors.name?.message}
              {...register('name')}
            />
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Phone Number"
                placeholder="+250788123456"
                error={errors.phoneNumber?.message}
                {...register('phoneNumber')}
              />
              <Input
                label="Opening Hours"
                placeholder="Mon–Sat 8am–8pm"
                error={errors.openingHours?.message}
                {...register('openingHours')}
              />
            </div>
            <Input
              label="Street Address"
              placeholder="e.g. KG 123 St, Kigali"
              error={errors.address?.message}
              {...register('address')}
            />
          </div>
        </Card>

        {/* Location */}
        <Card>
          <h2 className="text-base font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <MapPin className="w-4 h-4 text-teal-600" /> Location
          </h2>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <Input label="City" placeholder="Kigali" error={errors.city?.message} {...register('city')} />
              <Input label="District" placeholder="Gasabo" error={errors.district?.message} {...register('district')} />
            </div>
            <Input label="Country" placeholder="Rwanda" error={errors.country?.message} {...register('country')} />

            {/* GPS */}
            <div className="p-4 bg-gray-50 rounded-xl border border-gray-200">
              <div className="flex items-center justify-between mb-3">
                <p className="text-sm font-medium text-gray-700">GPS Coordinates</p>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={detectLocation}
                  isLoading={gpsLoading}
                  leftIcon={<Navigation className="w-4 h-4" />}
                >
                  Detect My Location
                </Button>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <Input
                  label="Latitude"
                  placeholder="-1.9441"
                  required
                  error={errors.latitude?.message}
                  hint="e.g. -1.9441 for Kigali"
                  {...register('latitude')}
                />
                <Input
                  label="Longitude"
                  placeholder="30.0619"
                  required
                  error={errors.longitude?.message}
                  hint="e.g. 30.0619 for Kigali"
                  {...register('longitude')}
                />
              </div>
              <p className="text-xs text-gray-500 mt-2">
                Used to show your pharmacy on the map and calculate distance for health workers.
              </p>
            </div>
          </div>
        </Card>

        <Button
          type="submit"
          size="lg"
          isLoading={mutation.isPending}
          leftIcon={<Save className="w-4 h-4" />}
        >
          {isNew ? 'Register Pharmacy' : 'Save Changes'}
        </Button>
      </form>
    </div>
  );
}
