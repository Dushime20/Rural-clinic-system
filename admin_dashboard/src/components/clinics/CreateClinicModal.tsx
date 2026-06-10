import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Copy, Check, AlertCircle, Info } from 'lucide-react';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import api, { getErrorMessage } from '../../lib/api';
import toast from 'react-hot-toast';

interface CreateClinicModalProps {
  isOpen: boolean;
  onClose: () => void;
}

interface FormData {
  name: string;
  managerName: string;
  email: string;
  phoneNumber: string;
}

export function CreateClinicModal({ isOpen, onClose }: CreateClinicModalProps) {
  const qc = useQueryClient();
  const [copied, setCopied] = useState(false);
  const [createdData, setCreatedData] = useState<{ temporaryPassword: string; email: string } | null>(null);
  
  const [formData, setFormData] = useState<FormData>({
    name: '',
    managerName: '',
    email: '',
    phoneNumber: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const createMutation = useMutation({
    mutationFn: async (data: FormData) => {
      // Send minimal data - clinic will complete their profile
      const payload = {
        ...data,
        // Backend defaults
        latitude: 0,
        longitude: 0,
        specialties: ['General_Medicine'], // Default specialty
        sendEmail: true,
      };
      return api.post('/admin/clinics', payload);
    },
    onSuccess: (response) => {
      const { temporaryPassword, user } = response.data.data;
      setCreatedData({ temporaryPassword, email: user.email });
      qc.invalidateQueries({ queryKey: ['clinics'] });
      toast.success('Clinic created successfully!');
    },
    onError: (err) => {
      toast.error(getErrorMessage(err, 'Failed to create clinic'));
    },
  });

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) newErrors.name = 'Clinic name is required';
    if (!formData.managerName.trim()) newErrors.managerName = 'Manager name is required';
    if (!formData.email.trim()) newErrors.email = 'Email is required';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) newErrors.email = 'Invalid email format';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!validate()) return;
    await createMutation.mutateAsync(formData);
  };

  const handleClose = () => {
    setFormData({
      name: '',
      managerName: '',
      email: '',
      phoneNumber: '',
    });
    setErrors({});
    setCreatedData(null);
    setCopied(false);
    onClose();
  };

  const copyToClipboard = () => {
    if (createdData) {
      navigator.clipboard.writeText(createdData.temporaryPassword);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  // Success view
  if (createdData) {
    return (
      <Modal isOpen={isOpen} onClose={handleClose} title="Clinic Created Successfully" size="md">
        <div className="space-y-4">
          <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
            <div className="flex items-start gap-3">
              <Check className="w-5 h-5 text-green-600 mt-0.5 shrink-0" />
              <div className="flex-1">
                <p className="text-sm font-medium text-green-900">Clinic user created successfully!</p>
                <p className="text-xs text-green-700 mt-1">
                  An email with login credentials has been sent to <strong>{createdData.email}</strong>
                </p>
              </div>
            </div>
          </div>

          <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <h4 className="text-sm font-semibold text-gray-900 mb-2">Temporary Password</h4>
            <div className="flex items-center gap-2">
              <code className="flex-1 px-3 py-2 bg-white border border-gray-300 rounded text-sm font-mono">
                {createdData.temporaryPassword}
              </code>
              <Button
                variant="outline"
                size="sm"
                onClick={copyToClipboard}
                leftIcon={copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
              >
                {copied ? 'Copied!' : 'Copy'}
              </Button>
            </div>
            <p className="text-xs text-gray-600 mt-2">
              <AlertCircle className="w-3 h-3 inline mr-1" />
              Save this password - it won't be shown again. The clinic user must change it on first login.
            </p>
          </div>
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <Button onClick={handleClose}>Done</Button>
        </div>
      </Modal>
    );
  }

  // Multi-step form
  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="Create New Clinic"
      size="md"
    >
      <div className="space-y-6">
        <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg flex items-start gap-3">
          <Info className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-blue-900">Quick Setup</p>
            <p className="text-sm text-blue-700 mt-1">
              Enter basic info to create the clinic account. The clinic manager will complete their profile (location, specialties, hours) after first login.
            </p>
          </div>
        </div>

        <div className="space-y-4">
          <Input
            label="Clinic Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            error={errors.name}
            required
            placeholder="e.g. Kigali Central Clinic"
          />
          <Input
            label="Manager Name"
            value={formData.managerName}
            onChange={(e) => setFormData({ ...formData, managerName: e.target.value })}
            error={errors.managerName}
            required
            placeholder="e.g. Dr. John Doe"
          />
          <Input
            label="Email"
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            error={errors.email}
            required
            placeholder="manager@clinic.com"
          />
          <Input
            label="Phone Number (Optional)"
            value={formData.phoneNumber}
            onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
            placeholder="+250788123456"
          />
        </div>

        <div className="flex justify-end gap-3 pt-4 border-t">
          <Button variant="outline" onClick={handleClose}>
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={createMutation.isPending}
            isLoading={createMutation.isPending}
          >
            {createMutation.isPending ? 'Creating...' : 'Create Clinic'}
          </Button>
        </div>
      </div>
    </Modal>
  );
}
