export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'clinic';
  mustChangePassword: boolean;
}

export interface Clinic {
  id: string;
  name: string;
  managerName?: string;
  email?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude: number;
  longitude: number;
  isActive: boolean;
  openingHours?: Record<string, { open: string; close: string }>;
  specialties: string[];
  createdAt: string;
  updatedAt?: string;
}

export type MedicalSpecialty =
  | 'Cardiology'
  | 'Endocrinology'
  | 'Infectious_Disease'
  | 'Pulmonology'
  | 'Nephrology'
  | 'Gastroenterology'
  | 'Neurology'
  | 'Oncology'
  | 'Dermatology'
  | 'Orthopedics'
  | 'General_Medicine';
