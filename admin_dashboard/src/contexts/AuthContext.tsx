import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { useMutation } from '@tanstack/react-query';
import type { User } from '../types';
import api, { getErrorMessage } from '../lib/api';

// ─── Types ────────────────────────────────────────────────────────────────────
interface LoginPayload {
  email: string;
  password: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (payload: LoginPayload) => Promise<void>;
  logout: () => Promise<void>;
  loginError: string | null;
  isLoginPending: boolean;
  refreshUser: () => Promise<void>;
}

// ─── API calls ────────────────────────────────────────────────────────────────
async function loginRequest(payload: LoginPayload) {
  const { data } = await api.post<{
    success: boolean;
    data: {
      user: User;
      accessToken: string;
      refreshToken: string;
    };
  }>('/auth/login', payload);
  return data.data;
}

async function logoutRequest() {
  await api.post('/auth/logout');
}

// ─── Context ──────────────────────────────────────────────────────────────────
const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session from localStorage on mount
  useEffect(() => {
    const token = localStorage.getItem('accessToken');
    const stored = localStorage.getItem('user');
    if (token && stored) {
      try {
        setUser(JSON.parse(stored));
      } catch {
        localStorage.clear();
      }
    }
    setIsLoading(false);
  }, []);

  // ─── Login mutation ─────────────────────────────────────────────────────────
  const loginMutation = useMutation({
    mutationFn: loginRequest,
    onSuccess: (result) => {
      const { user: u, accessToken, refreshToken } = result;
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      localStorage.setItem('user', JSON.stringify(u));
      setUser(u);
    },
  });

  const login = useCallback(
    async (payload: LoginPayload) => {
      const result = await loginMutation.mutateAsync(payload);
      // Allow admin and pharmacist roles
      if (result.user.role !== 'admin' && result.user.role !== 'pharmacist') {
        localStorage.clear();
        setUser(null);
        throw new Error('Access denied. This portal is for administrators and pharmacists only.');
      }
    },
    [loginMutation],
  );

  // ─── Logout mutation ────────────────────────────────────────────────────────
  const logoutMutation = useMutation({
    mutationFn: logoutRequest,
    onSettled: () => {
      localStorage.clear();
      setUser(null);
    },
  });

  const logout = useCallback(async () => {
    await logoutMutation.mutateAsync();
  }, [logoutMutation]);

  const refreshUser = useCallback(async () => {
    try {
      const { data } = await api.get('/users/me');
      const u = data.data.user as User;
      setUser(u);
      localStorage.setItem('user', JSON.stringify(u));
    } catch { /* ignore */ }
  }, []);

  // Derive a clean error string from the login mutation state
  const loginError = loginMutation.error
    ? getErrorMessage(loginMutation.error, 'Login failed. Please try again.')
    : null;

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        login,
        logout,
        loginError,
        isLoginPending: loginMutation.isPending,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
