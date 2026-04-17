// ─── Auth ────────────────────────────────────────────────────────────────────
export type UserRole = 'admin' | 'health_worker' | 'clinic_staff' | 'supervisor';

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  clinicId?: string;
  phoneNumber?: string;
  isActive: boolean;
  isEmailVerified: boolean;
  lastLogin?: string;
  createdAt: string;
  updatedAt: string;
}

export interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
}

// ─── Patient ─────────────────────────────────────────────────────────────────
export type Gender = 'male' | 'female' | 'other';
export type BloodType = 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-' | 'unknown';

export interface Address {
  street?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
}

export interface EmergencyContact {
  name: string;
  relationship: string;
  phoneNumber: string;
}

export interface Patient {
  id: string;
  patientId: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: Gender;
  bloodType?: BloodType;
  weight?: number;
  height?: number;
  address?: Address;
  phoneNumber?: string;
  email?: string;
  emergencyContact?: EmergencyContact;
  allergies?: string[];
  chronicConditions?: string[];
  currentMedications?: string[];
  clinicId: string;
  createdById: string;
  isActive: boolean;
  lastVisit?: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Medication ───────────────────────────────────────────────────────────────
export type MedicationForm =
  | 'tablet' | 'capsule' | 'syrup' | 'injection' | 'cream'
  | 'ointment' | 'drops' | 'inhaler' | 'patch' | 'suppository';

export type MedicationCategory =
  | 'antibiotic' | 'analgesic' | 'antihypertensive' | 'antidiabetic'
  | 'antimalarial' | 'antiretroviral' | 'vitamin' | 'vaccine' | 'other';

export interface StockInfo {
  quantity: number;
  reorderLevel: number;
  expiryDate?: string;
  batchNumber?: string;
}

export interface Medication {
  id: string;
  medicationCode: string;
  genericName: string;
  brandName?: string;
  form: MedicationForm;
  strength: string;
  category: MedicationCategory;
  description?: string;
  indications?: string;
  contraindications?: string;
  sideEffects?: string;
  dosageInstructions?: string;
  manufacturer?: string;
  unitPrice?: number;
  clinicId: string;
  stockInfo?: StockInfo;
  isAvailable: boolean;
  requiresPrescription: boolean;
  alternatives?: string[];
  createdAt: string;
  updatedAt: string;
}

// ─── Appointment ──────────────────────────────────────────────────────────────
export type AppointmentStatus =
  | 'scheduled' | 'confirmed' | 'checked_in' | 'in_progress'
  | 'completed' | 'cancelled' | 'no_show' | 'rescheduled';

export type AppointmentType =
  | 'consultation' | 'follow_up' | 'emergency' | 'vaccination'
  | 'lab_test' | 'procedure' | 'telemedicine';

export interface Appointment {
  id: string;
  appointmentId: string;
  patientId: string;
  patient?: Patient;
  providerId: string;
  provider?: User;
  clinicId: string;
  appointmentDate: string;
  durationMinutes: number;
  appointmentType: AppointmentType;
  status: AppointmentStatus;
  reason?: string;
  notes?: string;
  isTelemedicine: boolean;
  createdAt: string;
  updatedAt: string;
}

// ─── Diagnosis ────────────────────────────────────────────────────────────────
export interface Symptom {
  name: string;
  category: string;
  severity?: 'mild' | 'moderate' | 'severe';
  duration?: string;
}

export interface VitalSigns {
  temperature?: number;
  bloodPressureSystolic?: number;
  bloodPressureDiastolic?: number;
  heartRate?: number;
  respiratoryRate?: number;
  oxygenSaturation?: number;
  weight?: number;
  height?: number;
}

export interface AIPrediction {
  disease: string;
  confidence: number;
  icd10Code?: string;
  recommendations?: string[];
}

export interface Diagnosis {
  id: string;
  diagnosisId: string;
  patientId: string;
  patient?: Patient;
  performedById: string;
  performedBy?: User;
  clinicId: string;
  symptoms: Symptom[];
  vitalSigns: VitalSigns;
  patientAge: number;
  patientGender: string;
  aiPredictions: AIPrediction[];
  selectedDiagnosis?: { disease: string; confidence: number; icd10Code?: string };
  notes?: string;
  followUpRequired: boolean;
  followUpDate?: string;
  referralRequired: boolean;
  status: 'pending' | 'confirmed' | 'revised' | 'cancelled';
  diagnosisDate: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Prescription ─────────────────────────────────────────────────────────────
export interface PrescriptionItem {
  medicationId: string;
  medicationName: string;
  dosage: string;
  frequency: string;
  duration: string;
  quantity: number;
  instructions: string;
  refillsAllowed: number;
  refillsRemaining: number;
}

export interface Prescription {
  id: string;
  prescriptionId: string;
  patientId: string;
  patient?: Patient;
  prescriberId: string;
  prescriber?: User;
  diagnosisId?: string;
  clinicId: string;
  medications: PrescriptionItem[];
  status: 'active' | 'completed' | 'cancelled' | 'expired';
  prescriptionDate: string;
  expiryDate?: string;
  notes?: string;
  isDispensed: boolean;
  dispensedAt?: string;
  dispensedBy?: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Lab ──────────────────────────────────────────────────────────────────────
export interface LabOrder {
  id: string;
  orderId: string;
  patientId: string;
  patient?: Patient;
  orderingProviderId: string;
  clinicId: string;
  tests: { testCode: string; testName: string; category: string }[];
  status: 'pending' | 'collected' | 'in_progress' | 'completed' | 'cancelled' | 'rejected';
  priority: 'routine' | 'urgent' | 'stat';
  orderDate: string;
  clinicalNotes?: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Audit Log ────────────────────────────────────────────────────────────────
export interface AuditLog {
  id: string;
  userId?: string;
  userEmail?: string;
  action: 'create' | 'read' | 'update' | 'delete' | 'login' | 'logout' | 'export' | 'print';
  resource: string;
  resourceId?: string;
  ipAddress?: string;
  clinicId?: string;
  description?: string;
  success: boolean;
  errorMessage?: string;
  timestamp: string;
}

// ─── Reports ──────────────────────────────────────────────────────────────────
export interface DashboardStats {
  totalUsers: number;
  totalPatients: number;
  totalDiagnoses: number;
  totalAppointments: number;
  totalMedications: number;
  lowStockCount: number;
  pendingPrescriptions: number;
  criticalLabResults: number;
  activeUsers: number;
  todayAppointments: number;
}

// ─── API Response ─────────────────────────────────────────────────────────────
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data: T;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  total: number;
  page: number;
  limit: number;
}
