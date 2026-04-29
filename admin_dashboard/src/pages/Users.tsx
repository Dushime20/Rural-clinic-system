import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Plus, Search, Edit2, ToggleLeft, ToggleRight, UserPlus } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Badge } from '../components/ui/Badge';
import { Table } from '../components/ui/Table';
import type { Column } from '../components/ui/Table';
import { Pagination } from '../components/ui/Pagination';
import { Modal } from '../components/ui/Modal';
import api from '../lib/api';
import { formatDate, getInitials, ROLE_COLORS } from '../lib/utils';
import type { User } from '../types';
import toast from 'react-hot-toast';

const createSchema = z.object({
  email: z.string().email('Valid email required'),
  firstName: z.string().min(2, 'Required'),
  lastName: z.string().min(2, 'Required'),
  role: z.enum(['admin', 'health_worker', 'clinic_staff', 'supervisor', 'pharmacist']),
  clinicId: z.string().optional(),
  phoneNumber: z.string().optional(),
  sendEmail: z.boolean().default(true),
});

type CreateForm = z.infer<typeof createSchema>;

const ROLE_OPTIONS = [
  { value: 'admin', label: 'Administrator' },
  { value: 'health_worker', label: 'Health Worker' },
  { value: 'clinic_staff', label: 'Clinic Staff' },
  { value: 'supervisor', label: 'Supervisor' },
  { value: 'pharmacist', label: 'Pharmacist' },
];

export function Users() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [showCreate, setShowCreate] = useState(false);
  const [editUser, setEditUser] = useState<User | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['users', page, search, roleFilter],
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page), limit: '10' });
      if (search) params.set('search', search);
      if (roleFilter) params.set('role', roleFilter);
      try {
        const { data } = await api.get(`/users?${params}`);
        return data;
      } catch {
        return { data: { users: [], pagination: { total: 0 } } };
      }
    },
  });

  const createMutation = useMutation({
    mutationFn: (body: CreateForm) => api.post('/users', body),
    onSuccess: (response) => {
      const emailStatus = response?.data?.data?.emailSent ? ' Email sent successfully!' : ' (Email not sent)';
      toast.success('User created successfully' + emailStatus);
      
      // Close modal and reset form
      setShowCreate(false);
      reset();
      
      // Refresh users list and go to first page to see new user
      setPage(1);
      qc.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Failed to create user';
      toast.error(msg);
    },
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      api.patch(`/users/${id}`, { isActive }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['users'] });
      toast.success('User status updated');
    },
    onError: () => toast.error('Failed to update user'),
  });

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<CreateForm>({ resolver: zodResolver(createSchema) });

  const onSubmit = (data: CreateForm) => createMutation.mutate(data);

  const users: User[] = data?.data?.users ?? [];
  const total: number = data?.data?.pagination?.total ?? 0;

  const columns: Column[] = [
    {
      key: 'name',
      header: 'User',
      render: (u: User) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-xs font-semibold flex-shrink-0">
            {getInitials(u.firstName, u.lastName)}
          </div>
          <div>
            <p className="font-medium text-gray-900">{u.firstName} {u.lastName}</p>
            <p className="text-xs text-gray-500">{u.email}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'role',
      header: 'Role',
      render: (u: User) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${ROLE_COLORS[u.role]}`}>
          {u.role.replace('_', ' ')}
        </span>
      ),
    },
    {
      key: 'clinicId',
      header: 'Clinic',
      render: (u: User) => <span className="text-gray-600">{u.clinicId || '—'}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (u: User) => (
        <Badge variant={u.isActive ? 'success' : 'danger'}>
          {u.isActive ? 'Active' : 'Inactive'}
        </Badge>
      ),
    },
    {
      key: 'lastLogin',
      header: 'Last Login',
      render: (u: User) => (
        <span className="text-gray-500 text-xs">
          {u.lastLogin ? formatDate(u.lastLogin) : 'Never'}
        </span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (u: User) => (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); setEditUser(u); }}
            className="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            aria-label="Edit user"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); toggleMutation.mutate({ id: u.id, isActive: !u.isActive }); }}
            className={`p-1.5 rounded-lg transition-colors ${u.isActive ? 'text-green-500 hover:bg-green-50' : 'text-gray-400 hover:bg-gray-50'}`}
            aria-label={u.isActive ? 'Deactivate user' : 'Activate user'}
          >
            {u.isActive ? <ToggleRight className="w-4 h-4" /> : <ToggleLeft className="w-4 h-4" />}
          </button>
        </div>
      ),
    },
  ] as Column[];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
          <p className="text-sm text-gray-500 mt-1">Manage system users and their roles</p>
        </div>
        <Button leftIcon={<UserPlus className="w-4 h-4" />} onClick={() => { reset(); setShowCreate(true); }}>
          Add User
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-col sm:flex-row gap-3">
          <Input
            placeholder="Search by name or email..."
            leftIcon={<Search className="w-4 h-4" />}
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            className="sm:w-72"
          />
          <Select
            options={[{ value: '', label: 'All Roles' }, ...ROLE_OPTIONS]}
            value={roleFilter}
            onChange={(e) => { setRoleFilter(e.target.value); setPage(1); }}
            className="sm:w-48"
          />
        </div>
      </Card>

      {/* Table */}
      <Card padding={false}>
        <Table
          columns={columns}
          data={users as unknown as Record<string, unknown>[]}
          isLoading={isLoading}
          emptyMessage="No users found"
        />
        <Pagination page={page} total={total} limit={10} onPageChange={setPage} />
      </Card>

      {/* Create Modal */}
      <Modal
        isOpen={showCreate}
        onClose={() => setShowCreate(false)}
        title="Create New User"
        size="lg"
        footer={
          <>
            <Button 
              variant="outline" 
              onClick={() => setShowCreate(false)}
              disabled={createMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              onClick={handleSubmit(onSubmit)}
              isLoading={createMutation.isPending}
              disabled={createMutation.isPending}
              leftIcon={!createMutation.isPending && <Plus className="w-4 h-4" />}
            >
              {createMutation.isPending ? 'Creating User...' : 'Create User'}
            </Button>
          </>
        }
      >
        <form className="space-y-4" noValidate>
          <div className="grid grid-cols-2 gap-4">
            <Input label="First Name" required error={errors.firstName?.message} {...register('firstName')} />
            <Input label="Last Name" required error={errors.lastName?.message} {...register('lastName')} />
          </div>
          <Input label="Email Address" type="email" required error={errors.email?.message} {...register('email')} />
          
          <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg">
            <p className="text-xs text-amber-800">
              <strong>Note:</strong> A secure temporary password will be generated automatically and sent to the user's email.
            </p>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Role"
              required
              options={ROLE_OPTIONS}
              error={errors.role?.message}
              {...register('role')}
            />
            <Input label="Clinic ID" placeholder="CLINIC-001" error={errors.clinicId?.message} {...register('clinicId')} />
          </div>
          <Input label="Phone Number" placeholder="+250788123456" error={errors.phoneNumber?.message} {...register('phoneNumber')} />
          
          <div className="flex items-start gap-3 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <input
              type="checkbox"
              id="sendEmail"
              defaultChecked={true}
              className="mt-1 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              {...register('sendEmail')}
            />
            <label htmlFor="sendEmail" className="flex-1 cursor-pointer">
              <p className="text-sm font-medium text-gray-900">Send welcome email</p>
              <p className="text-xs text-gray-600 mt-0.5">
                User will receive an email with their login credentials.
                Pharmacists will receive a link to the Pharmacy Dashboard.
                Other roles will receive a link to download the mobile app.
              </p>
            </label>
          </div>
        </form>
      </Modal>

      {/* Edit Modal */}
      <Modal
        isOpen={!!editUser}
        onClose={() => setEditUser(null)}
        title="Edit User"
        size="md"
        footer={
          <>
            <Button variant="outline" onClick={() => setEditUser(null)}>Cancel</Button>
            <Button onClick={() => { toast.success('User updated'); setEditUser(null); }}>
              Save Changes
            </Button>
          </>
        }
      >
        {editUser && (
          <div className="space-y-4">
            <div className="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
              <div className="w-12 h-12 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center font-semibold">
                {getInitials(editUser.firstName, editUser.lastName)}
              </div>
              <div>
                <p className="font-semibold text-gray-900">{editUser.firstName} {editUser.lastName}</p>
                <p className="text-sm text-gray-500">{editUser.email}</p>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Role</p>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${ROLE_COLORS[editUser.role]}`}>
                  {editUser.role.replace('_', ' ')}
                </span>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Status</p>
                <Badge variant={editUser.isActive ? 'success' : 'danger'}>
                  {editUser.isActive ? 'Active' : 'Inactive'}
                </Badge>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Clinic ID</p>
                <p className="text-sm text-gray-700">{editUser.clinicId || '—'}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 mb-1">Phone</p>
                <p className="text-sm text-gray-700">{editUser.phoneNumber || '—'}</p>
              </div>
            </div>
            <p className="text-xs text-gray-400">
              Created: {formatDate(editUser.createdAt)} · Last login: {editUser.lastLogin ? formatDate(editUser.lastLogin) : 'Never'}
            </p>
          </div>
        )}
      </Modal>
    </div>
  );
}
