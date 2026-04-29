/**
 * Email Service
 * Handles sending emails for user credentials, notifications, etc.
 */

import nodemailer, { Transporter } from 'nodemailer';
import { logger } from '../utils/logger';

interface EmailOptions {
    to: string;
    subject: string;
    html: string;
    text?: string;
}

interface UserCredentials {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: string;
}

class EmailService {
    private transporter: Transporter | null = null;
    private isConfigured: boolean = false;

    constructor() {
        this.initialize();
    }

    private initialize() {
        try {
            const smtpHost = process.env.SMTP_HOST;
            const smtpPort = parseInt(process.env.SMTP_PORT || '587');
            const smtpUser = process.env.SMTP_USER;
            const smtpPassword = process.env.SMTP_PASSWORD;
            const smtpSecure = process.env.SMTP_SECURE === 'true';

            if (!smtpHost || !smtpUser || !smtpPassword) {
                logger.warn('Email service not configured. Set SMTP_* environment variables.');
                this.isConfigured = false;
                return;
            }

            this.transporter = nodemailer.createTransport({
                host: smtpHost,
                port: smtpPort,
                secure: smtpSecure,
                auth: {
                    user: smtpUser,
                    pass: smtpPassword,
                },
            });

            this.isConfigured = true;
            logger.info('Email service initialized successfully');
        } catch (error) {
            logger.error('Failed to initialize email service:', error);
            this.isConfigured = false;
        }
    }

    /**
     * Send email
     */
    private async sendEmail(options: EmailOptions): Promise<boolean> {
        if (!this.isConfigured || !this.transporter) {
            logger.warn('Email service not configured. Email not sent.');
            return false;
        }

        try {
            const mailOptions = {
                from: `"${process.env.SMTP_FROM_NAME || 'AI Health Companion'}" <${process.env.SMTP_USER}>`,
                to: options.to,
                subject: options.subject,
                html: options.html,
                text: options.text || this.stripHtml(options.html),
            };

            const info = await this.transporter.sendMail(mailOptions);
            logger.info(`Email sent to ${options.to}: ${info.messageId}`);
            return true;
        } catch (error) {
            logger.error(`Failed to send email to ${options.to}:`, error);
            return false;
        }
    }

    /**
     * Send welcome email with credentials to new user
     */
    async sendWelcomeEmail(credentials: UserCredentials): Promise<boolean> {
        const subject = 'Welcome to AI Health Companion - Your Account Credentials';
        
        const html = this.generateWelcomeEmailTemplate(credentials);

        return this.sendEmail({
            to: credentials.email,
            subject,
            html,
        });
    }

    /**
     * Send password reset email
     */
    async sendPasswordResetEmail(email: string, resetToken: string, firstName: string): Promise<boolean> {
        const subject = 'Password Reset Request - AI Health Companion';
        
        // Build reset URL (frontend will handle the token)
        const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:5173'}/reset-password?token=${resetToken}`;
        
        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                    .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
                    .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
                    .code-box { background: #f8f9fa; border: 2px dashed #667eea; padding: 20px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 3px; margin: 20px 0; color: #667eea; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🔐 Password Reset Request</h1>
                    </div>
                    <div class="content">
                        <p>Hello ${firstName},</p>
                        
                        <p>We received a request to reset your password for your AI Health Companion account.</p>
                        
                        <p><strong>Option 1: Click the button below to reset your password:</strong></p>
                        
                        <div style="text-align: center;">
                            <a href="${resetUrl}" class="button">Reset Password</a>
                        </div>
                        
                        <p><strong>Option 2: Use this reset code in the mobile app:</strong></p>
                        <div class="code-box">${resetToken.substring(0, 8).toUpperCase()}</div>
                        
                        <p style="font-size: 12px; color: #666;">Or copy the full link:</p>
                        <p style="word-break: break-all; color: #667eea; font-size: 12px;">${resetUrl}</p>
                        
                        <div class="warning">
                            <strong>⚠️ Security Notice:</strong>
                            <ul>
                                <li>This link will expire in 1 hour</li>
                                <li>If you didn't request this, please ignore this email</li>
                                <li>Never share this link or code with anyone</li>
                            </ul>
                        </div>
                        
                        <p>If you have any questions, please contact your system administrator.</p>
                        
                        <p>Best regards,<br>AI Health Companion Team</p>
                    </div>
                    <div class="footer">
                        <p>This is an automated email. Please do not reply.</p>
                        <p>&copy; 2026 AI Health Companion. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return this.sendEmail({
            to: email,
            subject,
            html,
        });
    }

    /**
     * Send account activation email
     */
    async sendActivationEmail(email: string, firstName: string, activationUrl: string): Promise<boolean> {
        const subject = 'Activate Your AI Health Companion Account';
        
        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                    .button { display: inline-block; padding: 12px 30px; background: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>✅ Activate Your Account</h1>
                    </div>
                    <div class="content">
                        <p>Hello ${firstName},</p>
                        
                        <p>Thank you for joining AI Health Companion! Please activate your account by clicking the button below:</p>
                        
                        <div style="text-align: center;">
                            <a href="${activationUrl}" class="button">Activate Account</a>
                        </div>
                        
                        <p>This link will expire in 24 hours.</p>
                        
                        <p>Best regards,<br>AI Health Companion Team</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return this.sendEmail({
            to: email,
            subject,
            html,
        });
    }

    /**
     * Generate welcome email template with credentials
     */
    private generateWelcomeEmailTemplate(credentials: UserCredentials): string {
        const appDownloadUrl = process.env.APP_DOWNLOAD_URL || 'https://play.google.com/store';
        const pharmacyDashboardUrl = process.env.PHARMACY_DASHBOARD_URL || 'http://localhost:5174';
        const supportEmail = process.env.SUPPORT_EMAIL || 'support@clinic.rw';
        const isPharmacist = credentials.role === 'pharmacist';

        return `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        line-height: 1.6;
                        color: #333;
                        margin: 0;
                        padding: 0;
                        background-color: #f4f4f4;
                    }
                    .container {
                        max-width: 600px;
                        margin: 20px auto;
                        background: white;
                        border-radius: 10px;
                        overflow: hidden;
                        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                    }
                    .header {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        padding: 40px 20px;
                        text-align: center;
                    }
                    .header h1 {
                        margin: 0;
                        font-size: 28px;
                    }
                    .header p {
                        margin: 10px 0 0 0;
                        opacity: 0.9;
                    }
                    .content {
                        padding: 40px 30px;
                    }
                    .greeting {
                        font-size: 18px;
                        color: #667eea;
                        margin-bottom: 20px;
                    }
                    .credentials-box {
                        background: #f8f9fa;
                        border-left: 4px solid #667eea;
                        padding: 20px;
                        margin: 25px 0;
                        border-radius: 5px;
                    }
                    .credentials-box h3 {
                        margin-top: 0;
                        color: #667eea;
                    }
                    .credential-item {
                        margin: 15px 0;
                        padding: 10px;
                        background: white;
                        border-radius: 5px;
                    }
                    .credential-label {
                        font-weight: bold;
                        color: #666;
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                    }
                    .credential-value {
                        font-size: 16px;
                        color: #333;
                        margin-top: 5px;
                        font-family: 'Courier New', monospace;
                        word-break: break-all;
                    }
                    .button {
                        display: inline-block;
                        padding: 15px 40px;
                        background: #667eea;
                        color: white;
                        text-decoration: none;
                        border-radius: 5px;
                        margin: 20px 0;
                        font-weight: bold;
                        text-align: center;
                    }
                    .button:hover {
                        background: #5568d3;
                    }
                    .steps {
                        background: #e8f4f8;
                        padding: 20px;
                        border-radius: 5px;
                        margin: 25px 0;
                    }
                    .steps h3 {
                        margin-top: 0;
                        color: #0066cc;
                    }
                    .step {
                        margin: 15px 0;
                        padding-left: 30px;
                        position: relative;
                    }
                    .step:before {
                        content: "✓";
                        position: absolute;
                        left: 0;
                        background: #28a745;
                        color: white;
                        width: 20px;
                        height: 20px;
                        border-radius: 50%;
                        text-align: center;
                        line-height: 20px;
                        font-size: 12px;
                    }
                    .warning {
                        background: #fff3cd;
                        border-left: 4px solid #ffc107;
                        padding: 15px;
                        margin: 20px 0;
                        border-radius: 5px;
                    }
                    .warning strong {
                        color: #856404;
                    }
                    .features {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 15px;
                        margin: 25px 0;
                    }
                    .feature {
                        padding: 15px;
                        background: #f8f9fa;
                        border-radius: 5px;
                        text-align: center;
                    }
                    .feature-icon {
                        font-size: 30px;
                        margin-bottom: 10px;
                    }
                    .footer {
                        background: #f8f9fa;
                        padding: 30px;
                        text-align: center;
                        color: #666;
                        font-size: 14px;
                    }
                    .footer a {
                        color: #667eea;
                        text-decoration: none;
                    }
                    @media only screen and (max-width: 600px) {
                        .features {
                            grid-template-columns: 1fr;
                        }
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <!-- Header -->
                    <div class="header">
                        <h1>🏥 Welcome to AI Health Companion</h1>
                        <p>Your account has been created successfully</p>
                    </div>

                    <!-- Content -->
                    <div class="content">
                        <p class="greeting">Hello ${credentials.firstName} ${credentials.lastName}! 👋</p>
                        
                        <p>Welcome to AI Health Companion! An administrator has created an account for you. You can now access the mobile application to provide quality healthcare services.</p>

                        <!-- Credentials Box -->
                        <div class="credentials-box">
                            <h3>🔐 Your Login Credentials</h3>
                            <p style="margin-bottom: 15px;">Use these credentials to log in to the mobile app:</p>
                            
                            <div class="credential-item">
                                <div class="credential-label">Email Address</div>
                                <div class="credential-value">${credentials.email}</div>
                            </div>
                            
                            <div class="credential-item">
                                <div class="credential-label">Temporary Password</div>
                                <div class="credential-value">${credentials.password}</div>
                            </div>
                            
                            <div class="credential-item">
                                <div class="credential-label">Role</div>
                                <div class="credential-value">${this.formatRole(credentials.role)}</div>
                            </div>
                        </div>

                        <!-- Warning -->
                        <div class="warning">
                            <strong>⚠️ Important Security Notice:</strong>
                            <ul style="margin: 10px 0;">
                                <li>This is a temporary password</li>
                                <li>You will be required to change it on first login</li>
                                <li>Never share your password with anyone</li>
                                <li>Keep this email secure or delete it after changing your password</li>
                            </ul>
                        </div>

                        <!-- Getting Started Steps -->
                        <div class="steps">
                            <h3>${isPharmacist ? '💊 Getting Started' : '📱 Getting Started'}</h3>
                            ${isPharmacist ? `
                            <div class="step">Visit the Pharmacy Dashboard: <a href="${pharmacyDashboardUrl}" style="color:#667eea;">${pharmacyDashboardUrl}</a></div>
                            <div class="step">Log in with your email and temporary password</div>
                            <div class="step">Create a new secure password when prompted</div>
                            <div class="step">Register your pharmacy (name, address, GPS location)</div>
                            <div class="step">Add your available medicines with prices and stock</div>
                            <div class="step">Keep your inventory updated so patients can find you!</div>
                            ` : `
                            <div class="step">Download the AI Health Companion mobile app from the app store</div>
                            <div class="step">Open the app and tap "Login"</div>
                            <div class="step">Enter your email and temporary password</div>
                            <div class="step">Create a new secure password when prompted</div>
                            <div class="step">Complete your profile setup</div>
                            <div class="step">Start providing healthcare services!</div>
                            `}
                        </div>

                        <!-- Action Button -->
                        <div style="text-align: center;">
                            ${isPharmacist
                                ? `<a href="${pharmacyDashboardUrl}" class="button">💊 Open Pharmacy Dashboard</a>`
                                : `<a href="${appDownloadUrl}" class="button">📲 Download Mobile App</a>`
                            }
                        </div>

                        <!-- Features -->
                        <div class="features">
                            <div class="feature">
                                <div class="feature-icon">🤖</div>
                                <strong>AI Diagnosis</strong>
                                <p style="font-size: 13px; margin: 5px 0 0 0;">Get AI-powered disease predictions</p>
                            </div>
                            <div class="feature">
                                <div class="feature-icon">📴</div>
                                <strong>Offline Mode</strong>
                                <p style="font-size: 13px; margin: 5px 0 0 0;">Works without internet</p>
                            </div>
                            <div class="feature">
                                <div class="feature-icon">👥</div>
                                <strong>Patient Records</strong>
                                <p style="font-size: 13px; margin: 5px 0 0 0;">Manage patient information</p>
                            </div>
                            <div class="feature">
                                <div class="feature-icon">📊</div>
                                <strong>Reports</strong>
                                <p style="font-size: 13px; margin: 5px 0 0 0;">Generate health reports</p>
                            </div>
                        </div>

                        <!-- Support -->
                        <div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin-top: 30px;">
                            <h4 style="margin-top: 0;">Need Help?</h4>
                            <p style="margin-bottom: 10px;">If you have any questions or need assistance:</p>
                            <ul style="margin: 10px 0;">
                                <li>📧 Email: <a href="mailto:${supportEmail}" style="color: #667eea;">${supportEmail}</a></li>
                                <li>📱 Contact your system administrator</li>
                                <li>📖 Check the in-app help section</li>
                            </ul>
                        </div>

                        <p style="margin-top: 30px;">We're excited to have you on board!</p>
                        
                        <p>Best regards,<br>
                        <strong>AI Health Companion Team</strong></p>
                    </div>

                    <!-- Footer -->
                    <div class="footer">
                        <p><strong>AI Health Companion</strong></p>
                        <p>Empowering Rural Healthcare with AI Technology</p>
                        <p style="margin-top: 20px;">
                            This is an automated email. Please do not reply.<br>
                            If you received this email by mistake, please contact <a href="mailto:${supportEmail}">${supportEmail}</a>
                        </p>
                        <p style="margin-top: 20px; font-size: 12px; color: #999;">
                            &copy; 2026 AI Health Companion. All rights reserved.
                        </p>
                    </div>
                </div>
            </body>
            </html>
        `;
    }

    /**
     * Format role for display
     */
    private formatRole(role: string): string {
        const roleMap: Record<string, string> = {
            'ADMIN': 'Administrator',
            'DOCTOR': 'Doctor',
            'NURSE': 'Nurse',
            'CHW': 'Community Health Worker',
            'PHARMACIST': 'Pharmacist',
            'LAB_TECHNICIAN': 'Laboratory Technician',
            'admin': 'Administrator',
            'health_worker': 'Health Worker',
            'clinic_staff': 'Clinic Staff',
            'supervisor': 'Supervisor',
            'pharmacist': 'Pharmacist',
        };
        return roleMap[role] || role;
    }

    /**
     * Strip HTML tags for plain text version
     */
    private stripHtml(html: string): string {
        return html
            .replace(/<style[^>]*>.*<\/style>/gm, '')
            .replace(/<[^>]+>/gm, '')
            .replace(/\s+/g, ' ')
            .trim();
    }

    /**
     * Send pharmacy welcome email with credentials
     */
    async sendPharmacyWelcomeEmail(data: {
        email: string;
        password: string;
        pharmacyName: string;
        managerName: string;
        dashboardUrl: string;
    }): Promise<boolean> {
        const subject = `Welcome to AI Health Companion - Pharmacy Dashboard Credentials`;
        const supportEmail = process.env.SUPPORT_EMAIL || 'support@clinic.rw';

        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }
                    .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 40px 20px; text-align: center; }
                    .header h1 { margin: 0; font-size: 26px; }
                    .header p { margin: 10px 0 0 0; opacity: 0.9; }
                    .content { padding: 40px 30px; }
                    .credentials-box { background: #f0fdf4; border-left: 4px solid #10b981; padding: 20px; margin: 25px 0; border-radius: 5px; }
                    .credentials-box h3 { margin-top: 0; color: #059669; }
                    .credential-item { margin: 15px 0; padding: 10px; background: white; border-radius: 5px; border: 1px solid #d1fae5; }
                    .credential-label { font-weight: bold; color: #666; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
                    .credential-value { font-size: 16px; color: #333; margin-top: 5px; font-family: 'Courier New', monospace; word-break: break-all; }
                    .button { display: inline-block; padding: 15px 40px; background: #10b981; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
                    .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px; }
                    .steps { background: #ecfdf5; padding: 20px; border-radius: 5px; margin: 25px 0; }
                    .steps h3 { margin-top: 0; color: #059669; }
                    .footer { background: #f8f9fa; padding: 30px; text-align: center; color: #666; font-size: 14px; }
                    .footer a { color: #10b981; text-decoration: none; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>💊 Pharmacy Dashboard Access</h1>
                        <p>Your pharmacy has been registered on AI Health Companion</p>
                    </div>
                    <div class="content">
                        <p>Hello <strong>${data.managerName}</strong>,</p>
                        <p>Your pharmacy <strong>${data.pharmacyName}</strong> has been successfully registered on the AI Health Companion platform. You can now manage your medicine inventory and pricing through the pharmacy dashboard.</p>

                        <div class="credentials-box">
                            <h3>🔐 Your Login Credentials</h3>
                            <div class="credential-item">
                                <div class="credential-label">Dashboard URL</div>
                                <div class="credential-value">${data.dashboardUrl}</div>
                            </div>
                            <div class="credential-item">
                                <div class="credential-label">Email Address</div>
                                <div class="credential-value">${data.email}</div>
                            </div>
                            <div class="credential-item">
                                <div class="credential-label">Temporary Password</div>
                                <div class="credential-value">${data.password}</div>
                            </div>
                        </div>

                        <div class="warning">
                            <strong>⚠️ Security Notice:</strong>
                            <ul style="margin: 10px 0;">
                                <li>This is a temporary password — change it on first login</li>
                                <li>Never share your credentials with anyone</li>
                                <li>Delete this email after saving your credentials securely</li>
                            </ul>
                        </div>

                        <div class="steps">
                            <h3>📋 Getting Started</h3>
                            <ol>
                                <li>Visit the dashboard URL above</li>
                                <li>Log in with your email and temporary password</li>
                                <li>Change your password when prompted</li>
                                <li>Add your available medicines and prices</li>
                                <li>Keep your inventory updated so patients can find you</li>
                            </ol>
                        </div>

                        <div style="text-align: center;">
                            <a href="${data.dashboardUrl}" class="button">🚀 Open Pharmacy Dashboard</a>
                        </div>

                        <p>Your pharmacy will appear on the map and health workers will be able to see your available medicines and prices when making diagnoses.</p>

                        <p>For support, contact: <a href="mailto:${supportEmail}" style="color: #10b981;">${supportEmail}</a></p>

                        <p>Best regards,<br><strong>AI Health Companion Team</strong></p>
                    </div>
                    <div class="footer">
                        <p><strong>AI Health Companion</strong> — Empowering Rural Healthcare</p>
                        <p style="font-size: 12px; color: #999;">&copy; 2026 AI Health Companion. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        return this.sendEmail({ to: data.email, subject, html });
    }

    /**
     * Test email configuration
     */
    async testConnection(): Promise<boolean> {
        if (!this.isConfigured || !this.transporter) {
            logger.error('Email service not configured');
            return false;
        }

        try {
            await this.transporter.verify();
            logger.info('Email service connection verified');
            return true;
        } catch (error) {
            logger.error('Email service connection failed:', error);
            return false;
        }
    }
}

// Export singleton instance
export const emailService = new EmailService();
