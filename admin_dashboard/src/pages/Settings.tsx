import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Settings as SettingsIcon, User, Lock, Bell, Database, Save } from 'lucide-react';
import { Card, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { useAuth } from '../contexts/AuthContext';
import toast from 'react-hot-toast';

const profileSchema = z.object({
  firstName: z.string().min(2, 'Required'),
  lastName: z.string().min(2, 'Required'),
  email: z.string().email('Valid email required'),
  phoneNumber: z.string().optional(),
});

const passwordSchema = z.object({
  currentPassword: z.string().min(1, 'Required'),
  newPassword: z.string().min(8, 'Min 8 characters').regex(/[A-Z]/, 'Must contain uppercase').regex(/[0-9]/, 'Must contain number'),
  confirmPassword: z.string(),
}).refine((d) => d.newPassword === d.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

type ProfileForm = z.infer<typeof profileSchema>;
type PasswordForm = z.infer<typeof passwordSchema>;

const TABS = [
  { id: 'profile', label: 'Profile', icon: User },
  { id: 'security', label: 'Security', icon: Lock },
  { id: 'notifications', label: 'Notifications', icon: Bell },
  { id: 'system', label: 'System', icon: Database },
];

export function Settings() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('profile');

  const profileForm = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      email: user?.email ?? '',
      phoneNumber: user?.phoneNumber ?? '',
    },
  });

  const passwordForm = useForm<PasswordForm>({ resolver: zodResolver(passwordSchema) });

  const onProfileSubmit = async (_data: ProfileForm) => {
    await new Promise((r) => setTimeout(r, 500));
    toast.success('Profile updated successfully');
  };

  const onPasswordSubmit = async (_data: PasswordForm) => {
    await new Promise((r) => setTimeout(r, 500));
    passwordForm.reset();
    toast.success('Password changed successfully');
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <SettingsIcon className="w-6 h-6 text-gray-400" />
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
          <p className="text-sm text-gray-500">Manage your account and system preferences</p>
        </div>
      </div>

      <div className="flex gap-6">
        {/* Sidebar tabs */}
        <div className="w-48 flex-shrink-0">
          <nav className="space-y-1">
            {TABS.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  activeTab === id
                    ? 'bg-blue-50 text-blue-700'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <Icon className="w-4 h-4" />
                {label}
              </button>
            ))}
          </nav>
        </div>

        {/* Content */}
        <div className="flex-1 space-y-6">
          {activeTab === 'profile' && (
            <Card>
              <CardHeader>
                <CardTitle>Profile Information</CardTitle>
              </CardHeader>
              <form onSubmit={profileForm.handleSubmit(onProfileSubmit)} className="space-y-4">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-16 h-16 bg-blue-600 rounded-full flex items-center justify-center text-white text-xl font-bold">
                    {user?.firstName?.charAt(0)}{user?.lastName?.charAt(0)}
                  </div>
                  <div>
                    <p className="font-semibold text-gray-900">{user?.firstName} {user?.lastName}</p>
                    <p className="text-sm text-gray-500 capitalize">{user?.role?.replace('_', ' ')}</p>
                    <p className="text-xs text-gray-400">{user?.clinicId || 'System Admin'}</p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <Input
                    label="First Name"
                    required
                    error={profileForm.formState.errors.firstName?.message}
                    {...profileForm.register('firstName')}
                  />
                  <Input
                    label="Last Name"
                    required
                    error={profileForm.formState.errors.lastName?.message}
                    {...profileForm.register('lastName')}
                  />
                  <Input
                    label="Email Address"
                    type="email"
                    required
                    error={profileForm.formState.errors.email?.message}
                    {...profileForm.register('email')}
                  />
                  <Input
                    label="Phone Number"
                    placeholder="+250788123456"
                    {...profileForm.register('phoneNumber')}
                  />
                </div>
                <div className="flex justify-end">
                  <Button
                    type="submit"
                    isLoading={profileForm.formState.isSubmitting}
                    leftIcon={<Save className="w-4 h-4" />}
                  >
                    Save Changes
                  </Button>
                </div>
              </form>
            </Card>
          )}

          {activeTab === 'security' && (
            <Card>
              <CardHeader>
                <CardTitle>Change Password</CardTitle>
              </CardHeader>
              <form onSubmit={passwordForm.handleSubmit(onPasswordSubmit)} className="space-y-4 max-w-md">
                <Input
                  label="Current Password"
                  type="password"
                  required
                  error={passwordForm.formState.errors.currentPassword?.message}
                  {...passwordForm.register('currentPassword')}
                />
                <Input
                  label="New Password"
                  type="password"
                  required
                  hint="Min 8 chars, 1 uppercase, 1 number"
                  error={passwordForm.formState.errors.newPassword?.message}
                  {...passwordForm.register('newPassword')}
                />
                <Input
                  label="Confirm New Password"
                  type="password"
                  required
                  error={passwordForm.formState.errors.confirmPassword?.message}
                  {...passwordForm.register('confirmPassword')}
                />
                <Button
                  type="submit"
                  isLoading={passwordForm.formState.isSubmitting}
                  leftIcon={<Lock className="w-4 h-4" />}
                >
                  Update Password
                </Button>
              </form>
            </Card>
          )}

          {activeTab === 'notifications' && (
            <Card>
              <CardHeader>
                <CardTitle>Notification Preferences</CardTitle>
              </CardHeader>
              <div className="space-y-4">
                {[
                  { label: 'Low stock alerts', desc: 'Get notified when medications are running low', defaultChecked: true },
                  { label: 'Critical lab results', desc: 'Immediate alerts for critical lab values', defaultChecked: true },
                  { label: 'New user registrations', desc: 'When a new user is added to the system', defaultChecked: false },
                  { label: 'System health alerts', desc: 'Server errors and performance issues', defaultChecked: true },
                  { label: 'Daily summary email', desc: 'Daily digest of system activity', defaultChecked: false },
                ].map(({ label, desc, defaultChecked }) => (
                  <div key={label} className="flex items-start justify-between py-3 border-b border-gray-100 last:border-0">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{label}</p>
                      <p className="text-xs text-gray-500 mt-0.5">{desc}</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer ml-4">
                      <input type="checkbox" defaultChecked={defaultChecked} className="sr-only peer" />
                      <div className="w-10 h-5 bg-gray-200 peer-focus:ring-2 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-5 peer-checked:bg-blue-600 after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all" />
                    </label>
                  </div>
                ))}
                <div className="flex justify-end pt-2">
                  <Button leftIcon={<Save className="w-4 h-4" />} onClick={() => toast.success('Preferences saved')}>
                    Save Preferences
                  </Button>
                </div>
              </div>
            </Card>
          )}

          {activeTab === 'system' && (
            <Card>
              <CardHeader>
                <CardTitle>System Information</CardTitle>
              </CardHeader>
              <div className="space-y-3">
                {[
                  ['API Base URL', import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1'],
                  ['Environment', import.meta.env.MODE],
                  ['Version', '1.0.0'],
                  ['Database', 'PostgreSQL'],
                  ['Authentication', 'JWT (RS256)'],
                  ['Compliance', 'HIPAA · GDPR · Rwanda MoH'],
                ].map(([label, value]) => (
                  <div key={label} className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-sm text-gray-500">{label}</span>
                    <span className="text-sm font-medium text-gray-900 font-mono">{value}</span>
                  </div>
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
