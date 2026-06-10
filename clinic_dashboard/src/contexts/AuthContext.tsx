import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User } from '../types';
import api from '../lib/api';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  mustChangePassword: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (user: User) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in
    const storedUser = localStorage.getItem('clinic_user');
    const token = localStorage.getItem('clinic_token');

    if (storedUser && token) {
      try {
        setUser(JSON.parse(storedUser));
      } catch (error) {
        console.error('Failed to parse stored user:', error);
        localStorage.removeItem('clinic_user');
        localStorage.removeItem('clinic_token');
        localStorage.removeItem('clinic_refresh_token');
      }
    }

    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const { data } = await api.post('/auth/login', { email, password });
    
    const { user: userData, accessToken, refreshToken } = data.data;

    // Verify user is a clinic user
    if (userData.role !== 'clinic') {
      throw new Error('Invalid user role. This portal is for clinic users only.');
    }

    setUser(userData);
    localStorage.setItem('clinic_user', JSON.stringify(userData));
    localStorage.setItem('clinic_token', accessToken);
    localStorage.setItem('clinic_refresh_token', refreshToken);
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('clinic_user');
    localStorage.removeItem('clinic_token');
    localStorage.removeItem('clinic_refresh_token');
  };

  const updateUser = (updatedUser: User) => {
    setUser(updatedUser);
    localStorage.setItem('clinic_user', JSON.stringify(updatedUser));
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    mustChangePassword: user?.mustChangePassword ?? false,
    login,
    logout,
    updateUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
