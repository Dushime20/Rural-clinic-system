import { useEffect, useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { MapPin, Store, Navigation, Save, Info } from 'lucide-react';
import toast from 'react-hot-toast';
import {
  MapContainer, TileLayer, Marker, useMapEvents, useMap,
} from 'react-leaflet';
import L from 'leaflet';
import api from '../../lib/api';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { Card } from '../../components/ui/Card';

// Fix Leaflet default marker icons broken by bundlers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

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

// Default center: Kigali, Rwanda
const DEFAULT_CENTER: [number, number] = [-1.9441, 30.0619];
const DEFAULT_ZOOM = 13;

/** Syncs the map view when the marker position changes externally (GPS detect) */
function MapViewUpdater({ position }: { position: [number, number] | null }) {
  const map = useMap();
  useEffect(() => {
    if (position) {
      map.setView(position, map.getZoom() < 15 ? 15 : map.getZoom());
    }
  }, [position, map]);
  return null;
}

/** Listens for map clicks and calls onSelect with [lat, lng] */
function MapClickHandler({ onSelect }: { onSelect: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onSelect(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

export function PharmacyProfile() {
  const qc = useQueryClient();
  const [gpsLoading, setGpsLoading] = useState(false);
  const [markerPos, setMarkerPos] = useState<[number, number] | null>(null);

  const { data: pharmacy, isLoading } = useQuery({
    queryKey: ['my-pharmacy'],
    queryFn: async () => {
      const { data } = await api.get('/pharmacy-manager/my');
      return data.data.pharmacy as Pharmacy | null;
    },
  });

  const isNew = !pharmacy;

  const { register, handleSubmit, setValue, watch, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: '', phoneNumber: '', address: '',
      latitude: '', longitude: '',
      city: '', district: '', country: 'Rwanda', openingHours: '',
    },
  });

  // Watch lat/lng to keep marker in sync when user types manually
  const watchedLat = watch('latitude');
  const watchedLng = watch('longitude');

  useEffect(() => {
    const lat = parseFloat(watchedLat);
    const lng = parseFloat(watchedLng);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setMarkerPos([lat, lng]);
    }
  }, [watchedLat, watchedLng]);

  // Populate form when existing pharmacy loads
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
      setMarkerPos([Number(pharmacy.latitude), Number(pharmacy.longitude)]);
    }
  }, [pharmacy, setValue]);

  const handleMapClick = useCallback((lat: number, lng: number) => {
    const latStr = lat.toFixed(7);
    const lngStr = lng.toFixed(7);
    setValue('latitude', latStr, { shouldValidate: true });
    setValue('longitude', lngStr, { shouldValidate: true });
    setMarkerPos([lat, lng]);
    toast.success('Location selected from map');
  }, [setValue]);

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
        const lat = pos.coords.latitude.toFixed(7);
        const lng = pos.coords.longitude.toFixed(7);
        setValue('latitude', lat, { shouldValidate: true });
        setValue('longitude', lng, { shouldValidate: true });
        setMarkerPos([pos.coords.latitude, pos.coords.longitude]);
        toast.success('Location detected!');
        setGpsLoading(false);
      },
      () => {
        toast.error('Could not detect location. Click on the map or enter coordinates manually.');
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

            {/* Map picker */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-gray-700 flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-teal-600" />
                  Pin Your Location on the Map
                </p>
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

              {/* Hint */}
              <div className="flex items-start gap-2 p-2.5 bg-blue-50 border border-blue-100 rounded-lg">
                <Info className="w-4 h-4 text-blue-500 flex-shrink-0 mt-0.5" />
                <p className="text-xs text-blue-700">
                  Click anywhere on the map to drop a pin at your pharmacy's exact location,
                  or use "Detect My Location" to auto-fill from your device GPS.
                </p>
              </div>

              {/* Map */}
              <div
                className="rounded-xl overflow-hidden border border-gray-200 shadow-sm"
                style={{ height: '320px', minHeight: '320px', position: 'relative' }}
              >
                <MapContainer
                  center={markerPos ?? DEFAULT_CENTER}
                  zoom={DEFAULT_ZOOM}
                  style={{ height: '100%', width: '100%', minHeight: '320px' }}
                  scrollWheelZoom={true}
                >
                  <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  />
                  <MapClickHandler onSelect={handleMapClick} />
                  <MapViewUpdater position={markerPos} />
                  {markerPos && (
                    <Marker position={markerPos} />
                  )}
                </MapContainer>
              </div>

              {/* Coordinate inputs */}
              <div className="grid grid-cols-2 gap-4 pt-1">
                <Input
                  label="Latitude"
                  placeholder="-1.9441"
                  required
                  error={errors.latitude?.message}
                  hint="Auto-filled when you click the map"
                  {...register('latitude')}
                />
                <Input
                  label="Longitude"
                  placeholder="30.0619"
                  required
                  error={errors.longitude?.message}
                  hint="Auto-filled when you click the map"
                  {...register('longitude')}
                />
              </div>
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
