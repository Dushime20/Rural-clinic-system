import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { Lock, ShieldCheck } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../lib/api';
import { useAuth } from '../../contexts/AuthContext';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';

const schema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string().min(1, 'Please confirm your password'),
}).refine((d) => d.newPassword === d.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});
type FormData = z.infer<typeof schema>;

export function ChangePassword() {
  const { refreshUser } = useAuth();
  const navigate = useNavigate();

  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const mutation = useMutation({
    mutationFn: (data: FormData) =>
      api.post('/users/me/change-password', {
        currentPassword: data.currentPassword,
        newPassword: data.newPassword,
      }),
    onSuccess: async () => {
      toast.success('Password changed successfully!');
      await refreshUser();
      navigate('/pharmacy-portal', { replace: true });
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message ?? 'Failed to change password';
      toast.error(msg);
    },
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-50 to-emerald-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 bg-teal-600 rounded-xl mb-4">
            <ShieldCheck className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Set Your Password</h1>
          <p className="text-gray-500 mt-1 text-sm">You must change your temporary password to continue</p>
        </div>

        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
          <div className="mb-6 p-4 bg-amber-50 border border-amber-200 rounded-lg">
            <p className="text-sm text-amber-800">
              <strong>Security notice:</strong> Your account was created with a temporary password.
              Please set a new secure password to access the pharmacy portal.
            </p>
          </div>

          <form onSubmit={handleSubmit((d) => mutation.mutate(d))} noValidate className="space-y-4">
            <Input
              label="Current (temporary) password"
              type="password"
              leftIcon={<Lock className="w-4 h-4" />}
              error={errors.currentPassword?.message}
              required
              {...register('currentPassword')}
            />
            <Input
              label="New password"
              type="password"
              leftIcon={<Lock className="w-4 h-4" />}
              error={errors.newPassword?.message}
              hint="At least 8 characters"
              required
              {...register('newPassword')}
            />
            <Input
              label="Confirm new password"
              type="password"
              leftIcon={<Lock className="w-4 h-4" />}
              error={errors.confirmPassword?.message}
              required
              {...register('confirmPassword')}
            />
            <Button type="submit" className="w-full" size="lg" isLoading={mutation.isPending}>
              Set New Password &amp; Continue
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
