import { useEffect, useState, useCallback } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Save, MapPin, Building2, Clock, Navigation, Info } from 'lucide-react';
import {
  MapContainer, TileLayer, Marker, useMapEvents, useMap,
} from 'react-leaflet';
import L from 'leaflet';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import api, { getErrorMessage } from '../lib/api';
import { Clinic, MedicalSpecialty } from '../types';
import toast from 'react-hot-toast';

// Fix Leaflet default marker icons broken by bundlers
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

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

const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

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

export function Profile() {
  const qc = useQueryClient();
  const [isEditing, setIsEditing] = useState(false);
  const [gpsLoading, setGpsLoading] = useState(false);
  const [markerPos, setMarkerPos] = useState<[number, number] | null>(null);

  const { data: clinicData, isLoading } = useQuery({
    queryKey: ['clinic-profile'],
    queryFn: async () => {
      const { data } = await api.get('/clinic-manager/my');
      return data.data.clinic as Clinic;
    },
  });

  const [formData, setFormData] = useState<Partial<Clinic>>({
    specialties: [],
    openingHours: {},
  });

  // Initialize form data when clinic data is loaded
  useEffect(() => {
    if (clinicData && !isEditing) {
      setFormData({
        name: clinicData.name,
        managerName: clinicData.managerName,
        phoneNumber: clinicData.phoneNumber,
        address: clinicData.address,
        city: clinicData.city,
        district: clinicData.district,
        country: clinicData.country,
        latitude: clinicData.latitude,
        longitude: clinicData.longitude,
        specialties: clinicData.specialties || [],
        openingHours: clinicData.openingHours || {},
      });
      
      // Set marker position
      if (clinicData.latitude && clinicData.longitude) {
        setMarkerPos([Number(clinicData.latitude), Number(clinicData.longitude)]);
      }
    }
  }, [clinicData, isEditing]);

  // Sync marker position with lat/lng changes
  useEffect(() => {
    if (isEditing && formData.latitude && formData.longitude) {
      const lat = Number(formData.latitude);
      const lng = Number(formData.longitude);
      if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        setMarkerPos([lat, lng]);
      }
    }
  }, [formData.latitude, formData.longitude, isEditing]);

  const updateMutation = useMutation({
    mutationFn: async (data: Partial<Clinic>) => {
      return api.put('/clinic-manager/my/profile', data);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['clinic-profile'] });
      setIsEditing(false);
      toast.success('Profile updated successfully!');
    },
    onError: (err) => {
      toast.error(getErrorMessage(err, 'Failed to update profile'));
    },
  });

  const handleEdit = () => {
    if (clinicData) {
      setFormData({
        name: clinicData.name,
        managerName: clinicData.managerName,
        phoneNumber: clinicData.phoneNumber,
        address: clinicData.address,
        city: clinicData.city,
        district: clinicData.district,
        country: clinicData.country,
        latitude: clinicData.latitude,
        longitude: clinicData.longitude,
        specialties: clinicData.specialties || [],
        openingHours: clinicData.openingHours || {},
      });
      
      // Set marker position when entering edit mode
      if (clinicData.latitude && clinicData.longitude) {
        setMarkerPos([Number(clinicData.latitude), Number(clinicData.longitude)]);
      }
    }
    setIsEditing(true);
  };

  const handleMapClick = useCallback((lat: number, lng: number) => {
    const latStr = lat.toFixed(7);
    const lngStr = lng.toFixed(7);
    setFormData(prev => ({
      ...prev,
      latitude: parseFloat(latStr),
      longitude: parseFloat(lngStr)
    }));
    setMarkerPos([lat, lng]);
    toast.success('Location selected from map');
  }, []);

  const detectLocation = () => {
    if (!navigator.geolocation) {
      toast.error('Geolocation not supported by your browser');
      return;
    }
    setGpsLoading(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const lat = pos.coords.latitude;
        const lng = pos.coords.longitude;
        setFormData(prev => ({
          ...prev,
          latitude: parseFloat(lat.toFixed(7)),
          longitude: parseFloat(lng.toFixed(7))
        }));
        setMarkerPos([lat, lng]);
        toast.success('Location detected!');
        setGpsLoading(false);
      },
      () => {
        toast.error('Could not detect location. Click on the map or enter coordinates manually.');
        setGpsLoading(false);
      }
    );
  };

  const handleCancel = () => {
    setIsEditing(false);
    setFormData({
      specialties: [],
      openingHours: {},
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate coordinates
    if (formData.latitude !== undefined) {
      const lat = Number(formData.latitude);
      if (isNaN(lat) || lat < -90 || lat > 90) {
        toast.error('Latitude must be between -90 and 90');
        return;
      }
    }

    if (formData.longitude !== undefined) {
      const lon = Number(formData.longitude);
      if (isNaN(lon) || lon < -180 || lon > 180) {
        toast.error('Longitude must be between -180 and 180');
        return;
      }
    }

    // Validate at least one specialty
    if (!formData.specialties || formData.specialties.length === 0) {
      toast.error('Please select at least one specialty');
      return;
    }

    await updateMutation.mutateAsync(formData);
  };

  const toggleSpecialty = (specialty: string) => {
    if (!isEditing) return;
    
    setFormData(prev => ({
      ...prev,
      specialties: prev.specialties?.includes(specialty)
        ? prev.specialties.filter(s => s !== specialty)
        : [...(prev.specialties || []), specialty]
    }));
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const clinic = clinicData;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Clinic Profile</h1>
          <p className="text-sm text-gray-500 mt-1">Manage your clinic information</p>
        </div>
        {!isEditing && (
          <Button onClick={handleEdit}>Edit Profile</Button>
        )}
      </div>

      <form onSubmit={handleSubmit}>
        <Card>
          <div className="space-y-6">
            {/* Basic Information */}
            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4">Basic Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Input
                  label="Clinic Name"
                  value={isEditing ? formData.name || '' : clinic?.name || ''}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  disabled={!isEditing}
                  required
                />
                <Input
                  label="Manager Name"
                  value={isEditing ? formData.managerName || '' : clinic?.managerName || ''}
                  onChange={(e) => setFormData({ ...formData, managerName: e.target.value })}
                  disabled={!isEditing}
                />
                <Input
                  label="Email"
                  value={clinic?.email || ''}
                  disabled
                  hint="Email cannot be changed"
                />
                <Input
                  label="Phone Number"
                  value={isEditing ? formData.phoneNumber || '' : clinic?.phoneNumber || ''}
                  onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                  disabled={!isEditing}
                />
              </div>
            </div>

            {/* Location */}
            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <MapPin className="w-4 h-4 text-indigo-600" />
                Location
              </h3>
              <div className="space-y-4">
                <Input
                  label="Address"
                  value={isEditing ? formData.address || '' : clinic?.address || ''}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  disabled={!isEditing}
                  placeholder="e.g. KG 123 St, Kigali"
                />
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Input
                    label="City"
                    value={isEditing ? formData.city || '' : clinic?.city || ''}
                    onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                    disabled={!isEditing}
                    placeholder="Kigali"
                  />
                  <Input
                    label="District"
                    value={isEditing ? formData.district || '' : clinic?.district || ''}
                    onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                    disabled={!isEditing}
                    placeholder="Gasabo"
                  />
                  <Input
                    label="Country"
                    value={isEditing ? formData.country || '' : clinic?.country || ''}
                    onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                    disabled={!isEditing}
                    placeholder="Rwanda"
                  />
                </div>

                {/* Map picker - only show in edit mode */}
                {isEditing && (
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium text-gray-700 flex items-center gap-1.5">
                        <MapPin className="w-4 h-4 text-indigo-600" />
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
                      <Info className="w-4 h-4 text-blue-500 shrink-0 mt-0.5" />
                      <p className="text-xs text-blue-700">
                        Click anywhere on the map to drop a pin at your clinic's exact location,
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
                  </div>
                )}

                {/* Coordinate inputs */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Input
                    label="Latitude"
                    type="number"
                    step="any"
                    value={isEditing ? formData.latitude || '' : clinic?.latitude || ''}
                    onChange={(e) => setFormData({ ...formData, latitude: parseFloat(e.target.value) })}
                    disabled={!isEditing}
                    hint={isEditing ? "Auto-filled when you click the map" : "-90 to 90"}
                    placeholder="-1.9441"
                  />
                  <Input
                    label="Longitude"
                    type="number"
                    step="any"
                    value={isEditing ? formData.longitude || '' : clinic?.longitude || ''}
                    onChange={(e) => setFormData({ ...formData, longitude: parseFloat(e.target.value) })}
                    disabled={!isEditing}
                    hint={isEditing ? "Auto-filled when you click the map" : "-180 to 180"}
                    placeholder="30.0619"
                  />
                </div>
              </div>
            </div>

            {/* Specialties */}
            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4">Medical Specialties</h3>
              <p className="text-sm text-gray-600 mb-3">Select at least one specialty</p>
              <div className="grid grid-cols-2 gap-3">
                {SPECIALTIES.map(specialty => (
                  <label
                    key={specialty.value}
                    className={`flex items-center gap-2 p-3 border border-gray-200 rounded-lg transition-colors ${
                      isEditing ? 'cursor-pointer hover:bg-gray-50' : 'cursor-not-allowed bg-gray-50'
                    }`}
                  >
                    <input
                      type="checkbox"
                      checked={
                        isEditing
                          ? formData.specialties?.includes(specialty.value)
                          : clinic?.specialties?.includes(specialty.value)
                      }
                      onChange={() => toggleSpecialty(specialty.value)}
                      disabled={!isEditing}
                      className="w-4 h-4 text-indigo-600 rounded focus:ring-indigo-500"
                    />
                    <span className="text-sm text-gray-700">{specialty.label}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Opening Hours */}
            <div>
              <h3 className="text-sm font-semibold text-gray-900 mb-4">Opening Hours</h3>
              <div className="space-y-3">
                {DAYS.map(day => (
                  <div key={day} className="flex items-center gap-3">
                    <span className="w-24 text-sm text-gray-700 capitalize">{day}</span>
                    <Input
                      type="time"
                      placeholder="Open"
                      value={
                        isEditing
                          ? formData.openingHours?.[day]?.open || ''
                          : clinic?.openingHours?.[day]?.open || ''
                      }
                      onChange={(e) => setFormData({
                        ...formData,
                        openingHours: {
                          ...formData.openingHours,
                          [day]: {
                            ...formData.openingHours?.[day],
                            open: e.target.value
                          }
                        }
                      })}
                      disabled={!isEditing}
                      className="flex-1"
                    />
                    <span className="text-gray-400">to</span>
                    <Input
                      type="time"
                      placeholder="Close"
                      value={
                        isEditing
                          ? formData.openingHours?.[day]?.close || ''
                          : clinic?.openingHours?.[day]?.close || ''
                      }
                      onChange={(e) => setFormData({
                        ...formData,
                        openingHours: {
                          ...formData.openingHours,
                          [day]: {
                            ...formData.openingHours?.[day],
                            close: e.target.value
                          }
                        }
                      })}
                      disabled={!isEditing}
                      className="flex-1"
                    />
                  </div>
                ))}
              </div>
            </div>

            {/* Actions */}
            {isEditing && (
              <div className="flex justify-end gap-3 pt-4 border-t">
                <Button type="button" variant="outline" onClick={handleCancel}>
                  Cancel
                </Button>
                <Button
                  type="submit"
                  leftIcon={<Save className="w-4 h-4" />}
                  isLoading={updateMutation.isPending}
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
