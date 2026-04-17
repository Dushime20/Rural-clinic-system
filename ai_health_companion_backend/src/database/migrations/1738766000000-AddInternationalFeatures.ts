import { MigrationInterface, QueryRunner } from "typeorm";

export class AddInternationalFeatures1738766000000 implements MigrationInterface {
    name = 'AddInternationalFeatures1738766000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create appointments table
        await queryRunner.query(`
            CREATE TYPE "appointment_status_enum" AS ENUM('scheduled', 'confirmed', 'checked_in', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled')
        `);

        await queryRunner.query(`
            CREATE TYPE "appointment_type_enum" AS ENUM('consultation', 'follow_up', 'emergency', 'vaccination', 'lab_test', 'procedure', 'telemedicine')
        `);

        await queryRunner.query(`
            CREATE TABLE "appointments" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "appointmentId" character varying(100) NOT NULL,
                "patientId" uuid NOT NULL,
                "providerId" uuid NOT NULL,
                "clinicId" character varying(255) NOT NULL,
                "appointmentDate" TIMESTAMP NOT NULL,
                "durationMinutes" integer NOT NULL,
                "appointmentType" "appointment_type_enum" NOT NULL,
                "status" "appointment_status_enum" NOT NULL DEFAULT 'scheduled',
                "reason" text,
                "notes" text,
                "reminderSettings" jsonb,
                "checkedInAt" TIMESTAMP,
                "completedAt" TIMESTAMP,
                "cancelledAt" TIMESTAMP,
                "cancellationReason" text,
                "cancelledBy" uuid,
                "rescheduledFrom" uuid,
                "isTelemedicine" boolean NOT NULL DEFAULT false,
                "telemedicineLink" character varying(500),
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_appointments_appointmentId" UNIQUE ("appointmentId"),
                CONSTRAINT "PK_appointments_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_appointments_patient" FOREIGN KEY ("patientId") REFERENCES "patients"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_appointments_provider" FOREIGN KEY ("providerId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_appointments_appointmentId" ON "appointments" ("appointmentId")`);
        await queryRunner.query(`CREATE INDEX "IDX_appointments_patientId" ON "appointments" ("patientId")`);
        await queryRunner.query(`CREATE INDEX "IDX_appointments_providerId" ON "appointments" ("providerId")`);
        await queryRunner.query(`CREATE INDEX "IDX_appointments_clinicId" ON "appointments" ("clinicId")`);
        await queryRunner.query(`CREATE INDEX "IDX_appointments_appointmentDate" ON "appointments" ("appointmentDate")`);
        await queryRunner.query(`CREATE INDEX "IDX_appointments_status" ON "appointments" ("status")`);

        // Create lab_orders table
        await queryRunner.query(`
            CREATE TYPE "lab_order_status_enum" AS ENUM('pending', 'collected', 'in_progress', 'completed', 'cancelled', 'rejected')
        `);

        await queryRunner.query(`
            CREATE TYPE "lab_order_priority_enum" AS ENUM('routine', 'urgent', 'stat')
        `);

        await queryRunner.query(`
            CREATE TABLE "lab_orders" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "orderId" character varying(100) NOT NULL,
                "patientId" uuid NOT NULL,
                "orderingProviderId" uuid NOT NULL,
                "diagnosisId" uuid,
                "clinicId" character varying(255) NOT NULL,
                "tests" jsonb NOT NULL,
                "status" "lab_order_status_enum" NOT NULL DEFAULT 'pending',
                "priority" "lab_order_priority_enum" NOT NULL DEFAULT 'routine',
                "orderDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                "clinicalNotes" text,
                "specialInstructions" text,
                "collectedAt" TIMESTAMP,
                "collectedBy" uuid,
                "expectedCompletionDate" TIMESTAMP,
                "isFasting" boolean NOT NULL DEFAULT false,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_lab_orders_orderId" UNIQUE ("orderId"),
                CONSTRAINT "PK_lab_orders_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_lab_orders_patient" FOREIGN KEY ("patientId") REFERENCES "patients"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_lab_orders_provider" FOREIGN KEY ("orderingProviderId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_lab_orders_diagnosis" FOREIGN KEY ("diagnosisId") REFERENCES "diagnoses"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_orderId" ON "lab_orders" ("orderId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_patientId" ON "lab_orders" ("patientId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_orderingProviderId" ON "lab_orders" ("orderingProviderId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_diagnosisId" ON "lab_orders" ("diagnosisId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_clinicId" ON "lab_orders" ("clinicId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_status" ON "lab_orders" ("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_orders_orderDate" ON "lab_orders" ("orderDate")`);

        // Create lab_results table
        await queryRunner.query(`
            CREATE TYPE "result_status_enum" AS ENUM('preliminary', 'final', 'corrected', 'cancelled')
        `);

        await queryRunner.query(`
            CREATE TABLE "lab_results" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "resultId" character varying(100) NOT NULL,
                "labOrderId" uuid NOT NULL,
                "results" jsonb NOT NULL,
                "status" "result_status_enum" NOT NULL DEFAULT 'preliminary',
                "resultDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                "performedBy" uuid,
                "reviewedBy" uuid,
                "reviewedAt" TIMESTAMP,
                "interpretation" text,
                "technicalNotes" text,
                "hasCriticalValues" boolean NOT NULL DEFAULT false,
                "notificationSent" boolean NOT NULL DEFAULT false,
                "attachmentUrl" character varying(500),
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_lab_results_resultId" UNIQUE ("resultId"),
                CONSTRAINT "PK_lab_results_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_lab_results_order" FOREIGN KEY ("labOrderId") REFERENCES "lab_orders"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_lab_results_reviewer" FOREIGN KEY ("reviewedBy") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_lab_results_resultId" ON "lab_results" ("resultId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_results_labOrderId" ON "lab_results" ("labOrderId")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_results_reviewedBy" ON "lab_results" ("reviewedBy")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_results_status" ON "lab_results" ("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_lab_results_resultDate" ON "lab_results" ("resultDate")`);

        // Create prescriptions table
        await queryRunner.query(`
            CREATE TYPE "prescription_status_enum" AS ENUM('active', 'completed', 'cancelled', 'expired')
        `);

        await queryRunner.query(`
            CREATE TABLE "prescriptions" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "prescriptionId" character varying(100) NOT NULL,
                "patientId" uuid NOT NULL,
                "prescriberId" uuid NOT NULL,
                "diagnosisId" uuid,
                "clinicId" character varying(255) NOT NULL,
                "medications" jsonb NOT NULL,
                "status" "prescription_status_enum" NOT NULL DEFAULT 'active',
                "prescriptionDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                "expiryDate" date,
                "notes" text,
                "pharmacyInstructions" text,
                "isDispensed" boolean NOT NULL DEFAULT false,
                "dispensedAt" TIMESTAMP,
                "dispensedBy" uuid,
                "pharmacyId" character varying(255),
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_prescriptions_prescriptionId" UNIQUE ("prescriptionId"),
                CONSTRAINT "PK_prescriptions_id" PRIMARY KEY ("id"),
                CONSTRAINT "FK_prescriptions_patient" FOREIGN KEY ("patientId") REFERENCES "patients"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_prescriptions_prescriber" FOREIGN KEY ("prescriberId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
                CONSTRAINT "FK_prescriptions_diagnosis" FOREIGN KEY ("diagnosisId") REFERENCES "diagnoses"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_prescriptionId" ON "prescriptions" ("prescriptionId")`);
        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_patientId" ON "prescriptions" ("patientId")`);
        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_prescriberId" ON "prescriptions" ("prescriberId")`);
        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_diagnosisId" ON "prescriptions" ("diagnosisId")`);
        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_status" ON "prescriptions" ("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_prescriptions_prescriptionDate" ON "prescriptions" ("prescriptionDate")`);

        // Create medications table
        await queryRunner.query(`
            CREATE TYPE "medication_form_enum" AS ENUM('tablet', 'capsule', 'syrup', 'injection', 'cream', 'ointment', 'drops', 'inhaler', 'patch', 'suppository')
        `);

        await queryRunner.query(`
            CREATE TYPE "medication_category_enum" AS ENUM('antibiotic', 'analgesic', 'antihypertensive', 'antidiabetic', 'antimalarial', 'antiretroviral', 'vitamin', 'vaccine', 'other')
        `);

        await queryRunner.query(`
            CREATE TABLE "medications" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "medicationCode" character varying(100) NOT NULL,
                "genericName" character varying(255) NOT NULL,
                "brandName" character varying(255),
                "form" "medication_form_enum" NOT NULL,
                "strength" character varying(100) NOT NULL,
                "category" "medication_category_enum" NOT NULL,
                "description" text,
                "indications" text,
                "contraindications" text,
                "sideEffects" text,
                "dosageInstructions" text,
                "manufacturer" character varying(255),
                "unitPrice" decimal(10,2),
                "clinicId" character varying(255) NOT NULL,
                "stockInfo" jsonb,
                "isAvailable" boolean NOT NULL DEFAULT true,
                "requiresPrescription" boolean NOT NULL DEFAULT false,
                "alternatives" text[] DEFAULT '{}',
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "UQ_medications_medicationCode" UNIQUE ("medicationCode"),
                CONSTRAINT "PK_medications_id" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_medications_medicationCode" ON "medications" ("medicationCode")`);
        await queryRunner.query(`CREATE INDEX "IDX_medications_genericName" ON "medications" ("genericName")`);
        await queryRunner.query(`CREATE INDEX "IDX_medications_category" ON "medications" ("category")`);
        await queryRunner.query(`CREATE INDEX "IDX_medications_clinicId" ON "medications" ("clinicId")`);

        // Create notifications table
        await queryRunner.query(`
            CREATE TYPE "notification_type_enum" AS ENUM('appointment_reminder', 'appointment_confirmation', 'lab_result_ready', 'prescription_ready', 'follow_up_reminder', 'medication_reminder', 'critical_result', 'system_alert', 'message')
        `);

        await queryRunner.query(`
            CREATE TYPE "notification_channel_enum" AS ENUM('in_app', 'email', 'sms', 'push')
        `);

        await queryRunner.query(`
            CREATE TYPE "notification_status_enum" AS ENUM('pending', 'sent', 'delivered', 'read', 'failed')
        `);

        await queryRunner.query(`
            CREATE TABLE "notifications" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "userId" uuid NOT NULL,
                "type" "notification_type_enum" NOT NULL,
                "channel" "notification_channel_enum" NOT NULL,
                "status" "notification_status_enum" NOT NULL DEFAULT 'pending',
                "title" character varying(255) NOT NULL,
                "message" text NOT NULL,
                "data" jsonb,
                "actionUrl" character varying(500),
                "sentAt" TIMESTAMP,
                "readAt" TIMESTAMP,
                "expiresAt" TIMESTAMP,
                "retryCount" integer NOT NULL DEFAULT 0,
                "errorMessage" text,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_notifications_id" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_notifications_userId" ON "notifications" ("userId")`);
        await queryRunner.query(`CREATE INDEX "IDX_notifications_type" ON "notifications" ("type")`);
        await queryRunner.query(`CREATE INDEX "IDX_notifications_status" ON "notifications" ("status")`);
        await queryRunner.query(`CREATE INDEX "IDX_notifications_createdAt" ON "notifications" ("createdAt")`);

        // Create audit_logs table
        await queryRunner.query(`
            CREATE TYPE "audit_action_enum" AS ENUM('create', 'read', 'update', 'delete', 'login', 'logout', 'export', 'print')
        `);

        await queryRunner.query(`
            CREATE TYPE "audit_resource_enum" AS ENUM('user', 'patient', 'diagnosis', 'appointment', 'lab_order', 'lab_result', 'prescription', 'medication')
        `);

        await queryRunner.query(`
            CREATE TABLE "audit_logs" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "userId" uuid,
                "userEmail" character varying(255),
                "action" "audit_action_enum" NOT NULL,
                "resource" "audit_resource_enum" NOT NULL,
                "resourceId" uuid,
                "oldValue" jsonb,
                "newValue" jsonb,
                "ipAddress" character varying(45),
                "userAgent" text,
                "clinicId" character varying(255),
                "description" text,
                "success" boolean NOT NULL DEFAULT true,
                "errorMessage" text,
                "timestamp" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_audit_logs_id" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_userId" ON "audit_logs" ("userId")`);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_action" ON "audit_logs" ("action")`);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_resource" ON "audit_logs" ("resource")`);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_timestamp" ON "audit_logs" ("timestamp")`);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_ipAddress" ON "audit_logs" ("ipAddress")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop tables in reverse order
        await queryRunner.query(`DROP TABLE "audit_logs"`);
        await queryRunner.query(`DROP TYPE "audit_resource_enum"`);
        await queryRunner.query(`DROP TYPE "audit_action_enum"`);

        await queryRunner.query(`DROP TABLE "notifications"`);
        await queryRunner.query(`DROP TYPE "notification_status_enum"`);
        await queryRunner.query(`DROP TYPE "notification_channel_enum"`);
        await queryRunner.query(`DROP TYPE "notification_type_enum"`);

        await queryRunner.query(`DROP TABLE "medications"`);
        await queryRunner.query(`DROP TYPE "medication_category_enum"`);
        await queryRunner.query(`DROP TYPE "medication_form_enum"`);

        await queryRunner.query(`DROP TABLE "prescriptions"`);
        await queryRunner.query(`DROP TYPE "prescription_status_enum"`);

        await queryRunner.query(`DROP TABLE "lab_results"`);
        await queryRunner.query(`DROP TYPE "result_status_enum"`);

        await queryRunner.query(`DROP TABLE "lab_orders"`);
        await queryRunner.query(`DROP TYPE "lab_order_priority_enum"`);
        await queryRunner.query(`DROP TYPE "lab_order_status_enum"`);

        await queryRunner.query(`DROP TABLE "appointments"`);
        await queryRunner.query(`DROP TYPE "appointment_type_enum"`);
        await queryRunner.query(`DROP TYPE "appointment_status_enum"`);
    }
}
