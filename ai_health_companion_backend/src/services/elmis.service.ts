import axios from 'axios';
import { config } from '../config';
import { logger } from '../utils/logger';

/**
 * e-LMIS (Electronic Logistics Management Information System) Service
 * Integrates with Rwanda's national pharmacy system for medication availability
 * 
 * This service prevents "pharmacy hopping" by checking medication stock
 * before patients travel to health facilities
 */

export interface MedicationAvailability {
    medicationId: string;
    medicationName: string;
    genericName: string;
    brandName?: string;
    isAvailable: boolean;
    quantityAvailable: number;
    unit: string;
    expiryDate?: Date;
    facilityId: string;
    facilityName: string;
    distance?: number;
    lastUpdated: Date;
}

export interface PharmacyLocation {
    facilityId: string;
    facilityName: string;
    facilityType: 'health_center' | 'district_hospital' | 'pharmacy' | 'clinic';
    address: {
        district: string;
        sector: string;
        cell: string;
        village?: string;
    };
    coordinates?: {
        latitude: number;
        longitude: number;
    };
    contactPhone?: string;
    operatingHours?: string;
    distance?: number;
}

export interface MedicationSearchResult {
    medicationId: string;
    medicationName: string;
    genericName: string;
    brandNames: string[];
    category: string;
    description?: string;
    alternatives?: string[];
}

export interface StockReservation {
    reservationId: string;
    medicationId: string;
    facilityId: string;
    quantity: number;
    reservedFor: string; // patient ID
    expiresAt: Date;
    status: 'active' | 'expired' | 'fulfilled' | 'cancelled';
}

export class ELMISService {
    private baseUrl: string;
    private apiKey: string;
    private mockMode: boolean;

    constructor() {
        // In production, these would come from environment variables
        this.baseUrl = process.env.ELMIS_BASE_URL || 'https://elmis.moh.gov.rw/api/v1';
        this.apiKey = process.env.ELMIS_API_KEY || 'mock-api-key';
        this.mockMode = process.env.ELMIS_MOCK_MODE === 'true' || !process.env.ELMIS_API_KEY;

        if (this.mockMode) {
            logger.info('e-LMIS service running in MOCK mode');
        }
    }

    /**
     * Check medication availability at specific facility or nearby facilities
     */
    async checkAvailability(
        medicationName: string,
        facilityId?: string,
        maxDistance?: number
    ): Promise<MedicationAvailability[]> {
        if (this.mockMode) {
            return this.mockCheckAvailability(medicationName, facilityId);
        }

        try {
            const response = await axios.get(`${this.baseUrl}/medications/availability`, {
                params: {
                    medication: medicationName,
                    facility: facilityId,
                    maxDistance: maxDistance || 50 // km
                },
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });

            return response.data.data;
        } catch (error) {
            logger.error('e-LMIS availability check failed:', error);
            throw new Error('Failed to check medication availability');
        }
    }

    /**
     * Search for medications by name or category
     */
    async searchMedications(query: string): Promise<MedicationSearchResult[]> {
        if (this.mockMode) {
            return this.mockSearchMedications(query);
        }

        try {
            const response = await axios.get(`${this.baseUrl}/medications/search`, {
                params: { q: query },
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });

            return response.data.data;
        } catch (error) {
            logger.error('e-LMIS medication search failed:', error);
            throw new Error('Failed to search medications');
        }
    }

    /**
     * Get alternative medications (generics, similar drugs)
     */
    async getAlternatives(medicationId: string): Promise<MedicationSearchResult[]> {
        if (this.mockMode) {
            return this.mockGetAlternatives(medicationId);
        }

        try {
            const response = await axios.get(`${this.baseUrl}/medications/${medicationId}/alternatives`, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });

            return response.data.data;
        } catch (error) {
            logger.error('e-LMIS alternatives fetch failed:', error);
            throw new Error('Failed to get medication alternatives');
        }
    }

    /**
     * Find nearby pharmacies/facilities
     */
    async findNearbyFacilities(
        latitude: number,
        longitude: number,
        radius: number = 50
    ): Promise<PharmacyLocation[]> {
        if (this.mockMode) {
            return this.mockFindNearbyFacilities();
        }

        try {
            const response = await axios.get(`${this.baseUrl}/facilities/nearby`, {
                params: {
                    lat: latitude,
                    lon: longitude,
                    radius
                },
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });

            return response.data.data;
        } catch (error) {
            logger.error('e-LMIS facility search failed:', error);
            throw new Error('Failed to find nearby facilities');
        }
    }

    /**
     * Reserve medication stock (optional feature)
     */
    async reserveStock(
        medicationId: string,
        facilityId: string,
        quantity: number,
        patientId: string
    ): Promise<StockReservation> {
        if (this.mockMode) {
            return this.mockReserveStock(medicationId, facilityId, quantity, patientId);
        }

        try {
            const response = await axios.post(
                `${this.baseUrl}/stock/reserve`,
                {
                    medicationId,
                    facilityId,
                    quantity,
                    patientId
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json'
                    },
                    timeout: 10000
                }
            );

            return response.data.data;
        } catch (error) {
            logger.error('e-LMIS stock reservation failed:', error);
            throw new Error('Failed to reserve medication stock');
        }
    }

    // ==================== MOCK IMPLEMENTATIONS ====================

    private mockCheckAvailability(
        medicationName: string,
        facilityId?: string
    ): MedicationAvailability[] {
        const mockData: MedicationAvailability[] = [
            {
                medicationId: 'MED-001',
                medicationName: 'Amoxicillin 500mg',
                genericName: 'Amoxicillin',
                brandName: 'Amoxil',
                isAvailable: true,
                quantityAvailable: 150,
                unit: 'tablets',
                expiryDate: new Date('2026-12-31'),
                facilityId: 'FAC-001',
                facilityName: 'Kigali Health Center',
                distance: 2.5,
                lastUpdated: new Date()
            },
            {
                medicationId: 'MED-001',
                medicationName: 'Amoxicillin 500mg',
                genericName: 'Amoxicillin',
                isAvailable: true,
                quantityAvailable: 80,
                unit: 'tablets',
                expiryDate: new Date('2026-10-15'),
                facilityId: 'FAC-002',
                facilityName: 'Nyarugenge District Hospital',
                distance: 5.8,
                lastUpdated: new Date()
            },
            {
                medicationId: 'MED-001',
                medicationName: 'Amoxicillin 500mg',
                genericName: 'Amoxicillin',
                isAvailable: false,
                quantityAvailable: 0,
                unit: 'tablets',
                facilityId: 'FAC-003',
                facilityName: 'Remera Clinic',
                distance: 8.2,
                lastUpdated: new Date()
            }
        ];

        if (facilityId) {
            return mockData.filter(m => m.facilityId === facilityId);
        }

        return mockData;
    }

    private mockSearchMedications(query: string): MedicationSearchResult[] {
        const mockMedications: MedicationSearchResult[] = [
            {
                medicationId: 'MED-001',
                medicationName: 'Amoxicillin 500mg',
                genericName: 'Amoxicillin',
                brandNames: ['Amoxil', 'Trimox'],
                category: 'Antibiotic',
                description: 'Penicillin antibiotic used to treat bacterial infections',
                alternatives: ['MED-002', 'MED-003']
            },
            {
                medicationId: 'MED-002',
                medicationName: 'Paracetamol 500mg',
                genericName: 'Paracetamol',
                brandNames: ['Panadol', 'Tylenol'],
                category: 'Analgesic',
                description: 'Pain reliever and fever reducer',
                alternatives: ['MED-004']
            },
            {
                medicationId: 'MED-003',
                medicationName: 'Artemether-Lumefantrine',
                genericName: 'Artemether-Lumefantrine',
                brandNames: ['Coartem'],
                category: 'Antimalarial',
                description: 'Treatment for uncomplicated malaria',
                alternatives: []
            }
        ];

        return mockMedications.filter(m =>
            m.medicationName.toLowerCase().includes(query.toLowerCase()) ||
            m.genericName.toLowerCase().includes(query.toLowerCase())
        );
    }

    private mockGetAlternatives(medicationId: string): MedicationSearchResult[] {
        return [
            {
                medicationId: 'MED-ALT-001',
                medicationName: 'Ampicillin 500mg',
                genericName: 'Ampicillin',
                brandNames: ['Principen'],
                category: 'Antibiotic',
                description: 'Alternative penicillin antibiotic'
            }
        ];
    }

    private mockFindNearbyFacilities(): PharmacyLocation[] {
        return [
            {
                facilityId: 'FAC-001',
                facilityName: 'Kigali Health Center',
                facilityType: 'health_center',
                address: {
                    district: 'Gasabo',
                    sector: 'Remera',
                    cell: 'Rukiri'
                },
                coordinates: {
                    latitude: -1.9536,
                    longitude: 30.0606
                },
                contactPhone: '+250788123456',
                operatingHours: '24/7',
                distance: 2.5
            },
            {
                facilityId: 'FAC-002',
                facilityName: 'Nyarugenge District Hospital',
                facilityType: 'district_hospital',
                address: {
                    district: 'Nyarugenge',
                    sector: 'Nyarugenge',
                    cell: 'Rwampara'
                },
                coordinates: {
                    latitude: -1.9705,
                    longitude: 30.0588
                },
                contactPhone: '+250788234567',
                operatingHours: '24/7',
                distance: 5.8
            }
        ];
    }

    private mockReserveStock(
        medicationId: string,
        facilityId: string,
        quantity: number,
        patientId: string
    ): StockReservation {
        const expiresAt = new Date();
        expiresAt.setHours(expiresAt.getHours() + 24); // 24-hour reservation

        return {
            reservationId: `RES-${Date.now()}`,
            medicationId,
            facilityId,
            quantity,
            reservedFor: patientId,
            expiresAt,
            status: 'active'
        };
    }
}

export const elmisService = new ELMISService();
