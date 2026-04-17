import { Patient } from '../models/Patient';
import { Diagnosis } from '../models/Diagnosis';
import { LabOrder } from '../models/LabOrder';
import { LabResult } from '../models/LabResult';
import { Prescription } from '../models/Prescription';
import { Appointment } from '../models/Appointment';

/**
 * FHIR R4 Service
 * Converts internal models to FHIR R4 resources and vice versa
 * Implements HL7 FHIR standard for healthcare interoperability
 */

export interface FHIRResource {
    resourceType: string;
    id?: string;
    meta?: {
        versionId?: string;
        lastUpdated?: string;
        profile?: string[];
    };
}

export interface FHIRPatient extends FHIRResource {
    resourceType: 'Patient';
    identifier?: Array<{
        system: string;
        value: string;
    }>;
    name?: Array<{
        use: string;
        family: string;
        given: string[];
    }>;
    telecom?: Array<{
        system: string;
        value: string;
        use?: string;
    }>;
    gender?: 'male' | 'female' | 'other' | 'unknown';
    birthDate?: string;
    address?: Array<{
        use?: string;
        line?: string[];
        city?: string;
        state?: string;
        postalCode?: string;
        country?: string;
    }>;
    contact?: Array<{
        relationship?: Array<{
            coding: Array<{
                system: string;
                code: string;
            }>;
        }>;
        name?: {
            family: string;
            given: string[];
        };
        telecom?: Array<{
            system: string;
            value: string;
        }>;
    }>;
}

export interface FHIRObservation extends FHIRResource {
    resourceType: 'Observation';
    status: 'registered' | 'preliminary' | 'final' | 'amended' | 'corrected' | 'cancelled';
    category?: Array<{
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
    }>;
    code: {
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
        text?: string;
    };
    subject: {
        reference: string;
    };
    effectiveDateTime?: string;
    valueQuantity?: {
        value: number;
        unit: string;
        system: string;
        code: string;
    };
    valueString?: string;
    interpretation?: Array<{
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
    }>;
}

export interface FHIRCondition extends FHIRResource {
    resourceType: 'Condition';
    clinicalStatus?: {
        coding: Array<{
            system: string;
            code: string;
        }>;
    };
    verificationStatus?: {
        coding: Array<{
            system: string;
            code: string;
        }>;
    };
    category?: Array<{
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
    }>;
    code: {
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
        text?: string;
    };
    subject: {
        reference: string;
    };
    onsetDateTime?: string;
    recordedDate?: string;
}

export interface FHIRMedicationRequest extends FHIRResource {
    resourceType: 'MedicationRequest';
    status: 'active' | 'on-hold' | 'cancelled' | 'completed' | 'entered-in-error' | 'stopped' | 'draft' | 'unknown';
    intent: 'proposal' | 'plan' | 'order' | 'original-order' | 'reflex-order' | 'filler-order' | 'instance-order' | 'option';
    medicationCodeableConcept?: {
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
        text?: string;
    };
    subject: {
        reference: string;
    };
    authoredOn?: string;
    requester?: {
        reference: string;
    };
    dosageInstruction?: Array<{
        text?: string;
        timing?: {
            repeat?: {
                frequency?: number;
                period?: number;
                periodUnit?: string;
            };
        };
        doseAndRate?: Array<{
            doseQuantity?: {
                value: number;
                unit: string;
            };
        }>;
    }>;
}

export interface FHIRAppointment extends FHIRResource {
    resourceType: 'Appointment';
    status: 'proposed' | 'pending' | 'booked' | 'arrived' | 'fulfilled' | 'cancelled' | 'noshow' | 'entered-in-error' | 'checked-in' | 'waitlist';
    appointmentType?: {
        coding: Array<{
            system: string;
            code: string;
            display: string;
        }>;
    };
    description?: string;
    start?: string;
    end?: string;
    minutesDuration?: number;
    participant: Array<{
        actor?: {
            reference: string;
        };
        required?: 'required' | 'optional' | 'information-only';
        status: 'accepted' | 'declined' | 'tentative' | 'needs-action';
    }>;
}

export class FHIRService {
    /**
     * Convert internal Patient model to FHIR Patient resource
     */
    patientToFHIR(patient: Patient): FHIRPatient {
        const fhirPatient: FHIRPatient = {
            resourceType: 'Patient',
            id: patient.id,
            meta: {
                lastUpdated: patient.updatedAt.toISOString(),
                profile: ['http://hl7.org/fhir/StructureDefinition/Patient']
            },
            identifier: [
                {
                    system: 'http://ruralclinic.health/patient-id',
                    value: patient.patientId
                }
            ],
            name: [
                {
                    use: 'official',
                    family: patient.lastName,
                    given: [patient.firstName]
                }
            ],
            gender: patient.gender as 'male' | 'female' | 'other',
            birthDate: patient.dateOfBirth.toISOString().split('T')[0]
        };

        // Add telecom if available
        if (patient.phoneNumber || patient.email) {
            fhirPatient.telecom = [];
            if (patient.phoneNumber) {
                fhirPatient.telecom.push({
                    system: 'phone',
                    value: patient.phoneNumber,
                    use: 'mobile'
                });
            }
            if (patient.email) {
                fhirPatient.telecom.push({
                    system: 'email',
                    value: patient.email
                });
            }
        }

        // Add address if available
        if (patient.address) {
            fhirPatient.address = [
                {
                    use: 'home',
                    line: patient.address.street ? [patient.address.street] : undefined,
                    city: patient.address.city,
                    state: patient.address.state,
                    postalCode: patient.address.postalCode,
                    country: patient.address.country
                }
            ];
        }

        // Add emergency contact if available
        if (patient.emergencyContact) {
            fhirPatient.contact = [
                {
                    relationship: [
                        {
                            coding: [
                                {
                                    system: 'http://terminology.hl7.org/CodeSystem/v2-0131',
                                    code: 'C'
                                }
                            ]
                        }
                    ],
                    name: {
                        family: patient.emergencyContact.name.split(' ').pop() || '',
                        given: patient.emergencyContact.name.split(' ').slice(0, -1)
                    },
                    telecom: [
                        {
                            system: 'phone',
                            value: patient.emergencyContact.phoneNumber
                        }
                    ]
                }
            ];
        }

        return fhirPatient;
    }

    /**
     * Convert FHIR Patient resource to internal Patient model data
     */
    fhirToPatient(fhirPatient: FHIRPatient): Partial<Patient> {
        const patientData: Partial<Patient> = {};

        if (fhirPatient.identifier && fhirPatient.identifier.length > 0) {
            patientData.patientId = fhirPatient.identifier[0].value;
        }

        if (fhirPatient.name && fhirPatient.name.length > 0) {
            const name = fhirPatient.name[0];
            patientData.firstName = name.given?.[0] || '';
            patientData.lastName = name.family || '';
        }

        if (fhirPatient.gender) {
            patientData.gender = fhirPatient.gender as any;
        }

        if (fhirPatient.birthDate) {
            patientData.dateOfBirth = new Date(fhirPatient.birthDate);
        }

        if (fhirPatient.telecom) {
            const phone = fhirPatient.telecom.find(t => t.system === 'phone');
            const email = fhirPatient.telecom.find(t => t.system === 'email');
            if (phone) patientData.phoneNumber = phone.value;
            if (email) patientData.email = email.value;
        }

        if (fhirPatient.address && fhirPatient.address.length > 0) {
            const addr = fhirPatient.address[0];
            patientData.address = {
                street: addr.line?.[0],
                city: addr.city,
                state: addr.state,
                postalCode: addr.postalCode,
                country: addr.country
            };
        }

        return patientData;
    }

    /**
     * Convert vital signs to FHIR Observation resources
     */
    vitalSignsToFHIRObservations(vitalSigns: any, patientId: string): FHIRObservation[] {
        const observations: FHIRObservation[] = [];

        if (vitalSigns.temperature) {
            observations.push({
                resourceType: 'Observation',
                status: 'final',
                category: [
                    {
                        coding: [
                            {
                                system: 'http://terminology.hl7.org/CodeSystem/observation-category',
                                code: 'vital-signs',
                                display: 'Vital Signs'
                            }
                        ]
                    }
                ],
                code: {
                    coding: [
                        {
                            system: 'http://loinc.org',
                            code: '8310-5',
                            display: 'Body temperature'
                        }
                    ]
                },
                subject: {
                    reference: `Patient/${patientId}`
                },
                effectiveDateTime: new Date().toISOString(),
                valueQuantity: {
                    value: vitalSigns.temperature,
                    unit: 'Cel',
                    system: 'http://unitsofmeasure.org',
                    code: 'Cel'
                }
            });
        }

        if (vitalSigns.bloodPressureSystolic && vitalSigns.bloodPressureDiastolic) {
            observations.push({
                resourceType: 'Observation',
                status: 'final',
                category: [
                    {
                        coding: [
                            {
                                system: 'http://terminology.hl7.org/CodeSystem/observation-category',
                                code: 'vital-signs',
                                display: 'Vital Signs'
                            }
                        ]
                    }
                ],
                code: {
                    coding: [
                        {
                            system: 'http://loinc.org',
                            code: '85354-9',
                            display: 'Blood pressure panel'
                        }
                    ]
                },
                subject: {
                    reference: `Patient/${patientId}`
                },
                effectiveDateTime: new Date().toISOString(),
                valueString: `${vitalSigns.bloodPressureSystolic}/${vitalSigns.bloodPressureDiastolic} mmHg`
            });
        }

        if (vitalSigns.heartRate) {
            observations.push({
                resourceType: 'Observation',
                status: 'final',
                category: [
                    {
                        coding: [
                            {
                                system: 'http://terminology.hl7.org/CodeSystem/observation-category',
                                code: 'vital-signs',
                                display: 'Vital Signs'
                            }
                        ]
                    }
                ],
                code: {
                    coding: [
                        {
                            system: 'http://loinc.org',
                            code: '8867-4',
                            display: 'Heart rate'
                        }
                    ]
                },
                subject: {
                    reference: `Patient/${patientId}`
                },
                effectiveDateTime: new Date().toISOString(),
                valueQuantity: {
                    value: vitalSigns.heartRate,
                    unit: 'beats/minute',
                    system: 'http://unitsofmeasure.org',
                    code: '/min'
                }
            });
        }

        return observations;
    }

    /**
     * Convert diagnosis to FHIR Condition resource
     */
    diagnosisToFHIRCondition(diagnosis: Diagnosis): FHIRCondition {
        const selectedDiagnosis = diagnosis.selectedDiagnosis || diagnosis.aiPredictions[0];

        return {
            resourceType: 'Condition',
            id: diagnosis.id,
            meta: {
                lastUpdated: diagnosis.updatedAt.toISOString()
            },
            clinicalStatus: {
                coding: [
                    {
                        system: 'http://terminology.hl7.org/CodeSystem/condition-clinical',
                        code: diagnosis.status === 'confirmed' ? 'active' : 'provisional'
                    }
                ]
            },
            verificationStatus: {
                coding: [
                    {
                        system: 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
                        code: diagnosis.status === 'confirmed' ? 'confirmed' : 'provisional'
                    }
                ]
            },
            category: [
                {
                    coding: [
                        {
                            system: 'http://terminology.hl7.org/CodeSystem/condition-category',
                            code: 'encounter-diagnosis',
                            display: 'Encounter Diagnosis'
                        }
                    ]
                }
            ],
            code: {
                coding: [
                    {
                        system: 'http://hl7.org/fhir/sid/icd-10',
                        code: selectedDiagnosis?.icd10Code || 'R69',
                        display: selectedDiagnosis?.disease || 'Unknown diagnosis'
                    }
                ],
                text: selectedDiagnosis?.disease
            },
            subject: {
                reference: `Patient/${diagnosis.patientId}`
            },
            onsetDateTime: diagnosis.diagnosisDate.toISOString(),
            recordedDate: diagnosis.createdAt.toISOString()
        };
    }

    /**
     * Convert prescription to FHIR MedicationRequest resource
     */
    prescriptionToFHIRMedicationRequest(prescription: Prescription): FHIRMedicationRequest[] {
        return prescription.medications.map(med => ({
            resourceType: 'MedicationRequest',
            id: `${prescription.id}-${med.medicationId}`,
            meta: {
                lastUpdated: prescription.updatedAt.toISOString()
            },
            status: prescription.status as any,
            intent: 'order',
            medicationCodeableConcept: {
                coding: [
                    {
                        system: 'http://ruralclinic.health/medication',
                        code: med.medicationId,
                        display: med.medicationName
                    }
                ],
                text: med.medicationName
            },
            subject: {
                reference: `Patient/${prescription.patientId}`
            },
            authoredOn: prescription.prescriptionDate.toISOString(),
            requester: {
                reference: `Practitioner/${prescription.prescriberId}`
            },
            dosageInstruction: [
                {
                    text: `${med.dosage} ${med.frequency} for ${med.duration}. ${med.instructions}`,
                    timing: {
                        repeat: {
                            frequency: parseInt(med.frequency) || 1,
                            period: 1,
                            periodUnit: 'd'
                        }
                    },
                    doseAndRate: [
                        {
                            doseQuantity: {
                                value: parseFloat(med.dosage) || 1,
                                unit: 'tablet'
                            }
                        }
                    ]
                }
            ]
        }));
    }

    /**
     * Convert appointment to FHIR Appointment resource
     */
    appointmentToFHIRAppointment(appointment: Appointment): FHIRAppointment {
        const statusMap: Record<string, any> = {
            'scheduled': 'booked',
            'confirmed': 'booked',
            'checked_in': 'arrived',
            'in_progress': 'fulfilled',
            'completed': 'fulfilled',
            'cancelled': 'cancelled',
            'no_show': 'noshow'
        };

        const endDate = new Date(appointment.appointmentDate);
        endDate.setMinutes(endDate.getMinutes() + appointment.durationMinutes);

        return {
            resourceType: 'Appointment',
            id: appointment.id,
            meta: {
                lastUpdated: appointment.updatedAt.toISOString()
            },
            status: statusMap[appointment.status] || 'booked',
            appointmentType: {
                coding: [
                    {
                        system: 'http://terminology.hl7.org/CodeSystem/v2-0276',
                        code: appointment.appointmentType.toUpperCase(),
                        display: appointment.appointmentType
                    }
                ]
            },
            description: appointment.reason,
            start: appointment.appointmentDate.toISOString(),
            end: endDate.toISOString(),
            minutesDuration: appointment.durationMinutes,
            participant: [
                {
                    actor: {
                        reference: `Patient/${appointment.patientId}`
                    },
                    required: 'required',
                    status: 'accepted'
                },
                {
                    actor: {
                        reference: `Practitioner/${appointment.providerId}`
                    },
                    required: 'required',
                    status: 'accepted'
                }
            ]
        };
    }
}

export const fhirService = new FHIRService();
