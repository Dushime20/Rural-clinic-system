import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Lock, Eye, EyeOff } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Card } from '../components/ui/Card';
import api from '../lib/api';
import toast from 'react-hot-toast';

export function ChangePassword() {
  const navigate = useNavigate();
  const { user, updateUser } = useAuth();
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPasswords, setShowPasswords] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (newPassword.length < 8) {
      toast.error('Password must be at least 8 characters long');
      return;
    }

    if (newPassword !== confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    setIsLoading(true);
    try {
      await api.post('/auth/change-password', {
        currentPassword,
        newPassword,
      });

      // Update user state to clear mustChangePassword flag
      if (user) {
        updateUser({ ...user, mustChangePassword: false });
      }

      toast.success('Password changed successfully!');
      navigate('/', { replace: true });
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Failed to change password');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 to-blue-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <div className="text-center mb-6">
          <div className="inline-flex items-center justify-center w-12 h-12 bg-indigo-100 rounded-full mb-3">
            <Lock className="w-6 h-6 text-indigo-600" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Change Password</h1>
          <p className="text-sm text-gray-600 mt-1">
            You must change your password before continuing
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Current Password"
            type={showPasswords ? 'text' : 'password'}
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
            leftIcon={<Lock className="w-4 h-4" />}
            required
          />

          <Input
            label="New Password"
            type={showPasswords ? 'text' : 'password'}
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            leftIcon={<Lock className="w-4 h-4" />}
            hint="Minimum 8 characters"
            required
          />

          <Input
            label="Confirm New Password"
            type={showPasswords ? 'text' : 'password'}
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            leftIcon={<Lock className="w-4 h-4" />}
            required
          />

          <button
            type="button"
            onClick={() => setShowPasswords(!showPasswords)}
            className="text-sm text-indigo-600 hover:text-indigo-700 flex items-center gap-2"
          >
            {showPasswords ? (
              <>
                <EyeOff className="w-4 h-4" />
                Hide passwords
              </>
            ) : (
              <>
                <Eye className="w-4 h-4" />
                Show passwords
              </>
            )}
          </button>

          <Button type="submit" className="w-full" isLoading={isLoading}>
            Change Password
          </Button>
        </form>
      </Card>
    </div>
  );
}
