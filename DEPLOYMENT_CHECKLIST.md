# Clinic Specialized Recommendations - Deployment Checklist

## Pre-Deployment

### Code Review
- [ ] All code changes reviewed and approved
- [ ] No console.log or debug statements in production code
- [ ] Error handling comprehensive and tested
- [ ] Security vulnerabilities scanned and addressed
- [ ] Code style and linting checks passed

### Testing
- [ ] Backend services tested (manual or automated)
- [ ] Admin dashboard tested in browsers (Chrome, Firefox, Safari)
- [ ] Clinic dashboard tested in browsers
- [ ] Flutter app tested on iOS devices
- [ ] Flutter app tested on Android devices
- [ ] End-to-end flows verified (admin creates clinic, clinic logs in, patient receives recommendations)

### Documentation
- [ ] API documentation reviewed and updated
- [ ] User guides created (admin and clinic)
- [ ] README files updated
- [ ] Deployment procedures documented
- [ ] Rollback procedures documented

---

## Environment Setup

### Environment Variables

#### Backend (`.env`)
```bash
# Database
DATABASE_HOST=your-db-host
DATABASE_PORT=5432
DATABASE_NAME=health_companion
DATABASE_USER=your-db-user
DATABASE_PASSWORD=your-db-password

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d

# Email Service (for clinic credentials)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@healthcompanion.com
SMTP_PASSWORD=your-smtp-password
SMTP_FROM_NAME=AI Health Companion
SMTP_FROM_EMAIL=noreply@healthcompanion.com

# Clinic Dashboard URL (for emails)
CLINIC_DASHBOARD_URL=https://clinic.healthcompanion.com

# Optional: Analytics
ANALYTICS_ENABLED=true

# Optional: Logging
LOG_LEVEL=info
```

#### Admin Dashboard (`.env`)
```bash
VITE_API_BASE_URL=https://api.healthcompanion.com
```

#### Clinic Dashboard (`.env`)
```bash
VITE_API_BASE_URL=https://api.healthcompanion.com
```

#### Flutter App (`android/local.properties` and iOS config)
```properties
# Backend API URL
API_BASE_URL=https://api.healthcompanion.com
```

### Configuration Checklist
- [ ] All environment variables configured
- [ ] JWT secret is strong and unique
- [ ] SMTP credentials verified and working
- [ ] Database credentials correct
- [ ] API URLs point to production endpoints
- [ ] SSL certificates installed and valid

---

## Database Deployment

### 1. Backup Current Database
```bash
# Create backup before any changes
pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > backup_$(date +%Y%m%d_%H%M%S).sql
```
- [ ] Backup created and verified
- [ ] Backup stored in secure location

### 2. Run Migrations

```bash
cd ai_health_companion_backend
npm run migration:run
```

**Migrations to Apply**:
- [ ] Create `clinics` table
- [ ] Create `clinic_specialties` table
- [ ] Create `disease_specialty_mappings` table
- [ ] Extend `analytics_events` table
- [ ] Add `clinic` to UserRole enum
- [ ] Add indexes for geospatial queries

### 3. Verify Migrations
```bash
# Check tables were created
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "\dt"

# Verify clinic role was added
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT enum_range(NULL::user_role);"
```
- [ ] All tables created successfully
- [ ] Clinic role exists in enum
- [ ] Indexes created properly

### 4. Run Seed Data

```bash
npm run seed:disease-mappings
```

**Seed Data Includes**:
- 15 disease-specialty mappings (Diabetes → Endocrinology, Asthma → Pulmonology, etc.)

- [ ] Seed data inserted successfully
- [ ] Verify with: `SELECT COUNT(*) FROM disease_specialty_mappings;` (should be 15)

### 5. Rollback Plan
```bash
# If issues occur, rollback migrations
npm run migration:revert
```
- [ ] Rollback procedure documented
- [ ] Tested in staging environment

---

## Backend Deployment

### 1. Build Backend
```bash
cd ai_health_companion_backend
npm install --production
npm run build
```
- [ ] Build completed without errors
- [ ] TypeScript compilation successful
- [ ] All dependencies installed

### 2. Deploy Backend Services
```bash
# Copy files to production server
rsync -avz dist/ user@server:/path/to/backend/

# Install dependencies on server
ssh user@server "cd /path/to/backend && npm install --production"
```
- [ ] Files transferred successfully
- [ ] Dependencies installed on server
- [ ] Environment variables configured

### 3. Start/Restart Services
```bash
# Using PM2 or similar
pm2 restart health-companion-backend
# Or
systemctl restart health-companion-backend
```
- [ ] Backend service started
- [ ] Health check endpoint responding: `GET /api/health`
- [ ] Logs show no errors

### 4. Verify New Endpoints

Test each new endpoint:
- [ ] `POST /api/admin/clinics` (create clinic)
- [ ] `GET /api/admin/clinics` (list clinics)
- [ ] `GET /api/admin/clinics/:id` (get clinic)
- [ ] `PUT /api/admin/clinics/:id/status` (update status)
- [ ] `GET /api/clinic-manager/my` (get profile)
- [ ] `PUT /api/clinic-manager/my/profile` (update profile)
- [ ] `PUT /api/clinic-manager/my/specialties` (update specialties)
- [ ] `POST /api/clinics/search` (search clinics)
- [ ] `POST /api/diagnosis` (verify includes clinics in response)
- [ ] `GET /api/admin/analytics/clinic-recommendations` (analytics)

### 5. Monitor Logs
```bash
# Watch logs for errors
tail -f /var/log/health-companion-backend.log
# Or with PM2
pm2 logs health-companion-backend
```
- [ ] No error messages in logs
- [ ] Database connections successful
- [ ] Email service initialized

---

## Admin Dashboard Deployment

### 1. Build Admin Dashboard
```bash
cd admin_dashboard
npm install
npm run build
```
- [ ] Build completed successfully
- [ ] Output in `dist/` directory
- [ ] No build warnings or errors

### 2. Deploy Static Files
```bash
# Upload to hosting (e.g., Netlify, Vercel, S3)
# Example with S3:
aws s3 sync dist/ s3://your-admin-dashboard-bucket/ --delete
```
- [ ] Files uploaded successfully
- [ ] CDN cache cleared (if applicable)
- [ ] HTTPS configured

### 3. Verify Admin Dashboard
- [ ] Navigate to admin dashboard URL
- [ ] Login as admin user
- [ ] "Clinics" menu item visible in sidebar
- [ ] Can create a test clinic
- [ ] Can view clinic details
- [ ] Can update clinic status
- [ ] Credentials email sent successfully

---

## Clinic Dashboard Deployment

### 1. Build Clinic Dashboard
```bash
cd clinic_dashboard
npm install
npm run build
```
- [ ] Build completed successfully
- [ ] Output in `dist/` directory
- [ ] Blue/indigo theme applied

### 2. Deploy Static Files
```bash
# Upload to hosting
aws s3 sync dist/ s3://your-clinic-dashboard-bucket/ --delete
```
- [ ] Files uploaded successfully
- [ ] Domain configured: clinic.healthcompanion.com
- [ ] HTTPS configured

### 3. Verify Clinic Dashboard
- [ ] Navigate to clinic dashboard URL
- [ ] Login with test clinic credentials
- [ ] Forced to change password on first login
- [ ] Dashboard loads with correct theme
- [ ] Can edit profile
- [ ] Can manage specialties
- [ ] Profile saves successfully

---

## Flutter App Deployment

### 1. Update API Configuration
```dart
// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://api.healthcompanion.com';
}
```
- [ ] API URL updated to production
- [ ] Configuration verified in code

### 2. Build Android App
```bash
cd ai_health_companion
flutter build apk --release
# Or for Google Play:
flutter build appbundle --release
```
- [ ] APK/AAB built successfully
- [ ] Signed with release keystore
- [ ] Version number incremented

### 3. Build iOS App
```bash
flutter build ios --release
# Then use Xcode to archive and upload
```
- [ ] iOS build successful
- [ ] Signed with distribution certificate
- [ ] Version number incremented

### 4. Deploy to App Stores

**Google Play Store**:
- [ ] Upload AAB to Google Play Console
- [ ] Update release notes mentioning clinic features
- [ ] Submit for review

**Apple App Store**:
- [ ] Upload IPA via Xcode or Transporter
- [ ] Update release notes
- [ ] Submit for review

### 5. Verify Flutter App
- [ ] Install app on test devices
- [ ] Complete diagnosis flow
- [ ] Verify clinic recommendations appear
- [ ] Test with recurring disease pattern
- [ ] Test with no pharmacy scenario
- [ ] Verify error handling (disable internet)
- [ ] Test location permissions
- [ ] Verify specialty filtering works

---

## Email Service Configuration

### 1. Configure SMTP
- [ ] SMTP credentials verified
- [ ] Test email sent successfully
- [ ] SPF records configured for domain
- [ ] DKIM configured for authentication
- [ ] DMARC policy set

### 2. Test Email Templates
```bash
# Send test clinic credentials email
curl -X POST http://localhost:3000/api/test/send-clinic-email \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123"}'
```
- [ ] Clinic credentials email received
- [ ] Email formatting correct (HTML renders properly)
- [ ] Links work (clinic dashboard URL)
- [ ] Email not marked as spam

### 3. Email Deliverability
- [ ] Test with Gmail, Outlook, Yahoo accounts
- [ ] Check spam folders
- [ ] Verify sender reputation
- [ ] Monitor bounce rates

---

## Monitoring & Analytics

### 1. Setup Application Monitoring
- [ ] Error tracking configured (Sentry, Rollbar, etc.)
- [ ] Performance monitoring enabled
- [ ] Log aggregation setup (ELK, Datadog, etc.)
- [ ] Uptime monitoring configured

### 2. Database Monitoring
- [ ] Query performance monitoring enabled
- [ ] Slow query logging configured
- [ ] Database connection pool monitored
- [ ] Disk space alerts configured

### 3. Setup Alerts
- [ ] Email alert for backend errors
- [ ] Slack/Discord webhook for critical errors
- [ ] Alert for high API response times (>2s for clinic search)
- [ ] Alert for email delivery failures
- [ ] Alert for high error rates

### 4. Analytics Dashboard
- [ ] Google Analytics or similar configured
- [ ] Track clinic search events
- [ ] Track clinic recommendation views
- [ ] Monitor user engagement with clinic features

---

## Security

### 1. SSL/TLS Certificates
- [ ] SSL certificates installed for all domains
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Certificates set to auto-renew
- [ ] Certificate expiration monitoring setup

### 2. API Security
- [ ] Rate limiting enabled (recommended but not yet implemented)
- [ ] CORS configured properly
- [ ] JWT secrets rotated
- [ ] SQL injection protection verified (TypeORM handles this)
- [ ] Input validation on all endpoints

### 3. Authentication
- [ ] Password hashing working (bcrypt)
- [ ] JWT expiration configured (7 days default)
- [ ] Token refresh mechanism working
- [ ] Logout invalidates tokens

### 4. Authorization
- [ ] Admin endpoints require admin role
- [ ] Clinic endpoints require clinic role
- [ ] Cross-user access prevented
- [ ] Test unauthorized access attempts (should fail)

---

## Post-Deployment Verification

### 1. Smoke Tests

**Backend**:
- [ ] Health check endpoint returns 200
- [ ] Database connection successful
- [ ] Can create new clinic via admin API
- [ ] Can perform clinic search
- [ ] Diagnosis endpoint includes clinic recommendations

**Admin Dashboard**:
- [ ] Login works
- [ ] Clinics page loads
- [ ] Can create clinic
- [ ] Email sent successfully

**Clinic Dashboard**:
- [ ] Login works with new clinic credentials
- [ ] Password change forced
- [ ] Profile editable
- [ ] Specialties manageable

**Flutter App**:
- [ ] Diagnosis flow works
- [ ] Clinic recommendations appear
- [ ] Location permissions handled
- [ ] Error states work properly

### 2. Integration Tests
- [ ] Admin creates clinic → Email received
- [ ] Clinic logs in → Forced password change
- [ ] Patient completes diagnosis → Receives clinic recommendations
- [ ] Patient with recurring disease → Sees pattern notice
- [ ] No pharmacy scenario → Shows clinics as fallback

### 3. Performance Tests
- [ ] Clinic search completes in <5 seconds
- [ ] Diagnosis endpoint response time acceptable (<3s)
- [ ] Admin dashboard loads in <2s
- [ ] Clinic dashboard loads in <2s
- [ ] Flutter app responsive

### 4. Load Tests (Optional but Recommended)
```bash
# Use k6, Artillery, or similar
k6 run load-test-clinics.js
```
- [ ] Backend handles 100 concurrent clinic searches
- [ ] Database connections managed properly
- [ ] No memory leaks detected
- [ ] Error rate <1% under load

---

## Rollback Procedure

### If Critical Issues Occur

### 1. Backend Rollback
```bash
# Revert to previous version
git checkout <previous-commit>
npm run build
pm2 restart health-companion-backend

# Revert database migrations
npm run migration:revert
```
- [ ] Previous backend version deployed
- [ ] Migrations reverted
- [ ] Database restored from backup if needed

### 2. Frontend Rollback
```bash
# Revert admin/clinic dashboards
aws s3 sync s3://backup-bucket/ s3://live-bucket/ --delete
```
- [ ] Previous frontend version live
- [ ] CDN cache cleared

### 3. Communication
- [ ] Users notified of rollback
- [ ] Incident report created
- [ ] Post-mortem scheduled

---

## Post-Deployment Tasks

### Day 1
- [ ] Monitor error logs continuously
- [ ] Check email delivery rates
- [ ] Verify clinic recommendations appearing
- [ ] Respond to any user reports
- [ ] Check database performance

### Week 1
- [ ] Analyze clinic recommendation usage
- [ ] Review error rates and trends
- [ ] Collect user feedback
- [ ] Monitor system performance metrics
- [ ] Check for any security issues

### Month 1
- [ ] Generate analytics report on clinic feature usage
- [ ] Evaluate if additional disease mappings needed
- [ ] Review and update documentation based on feedback
- [ ] Plan improvements and optimizations
- [ ] Celebrate successful deployment! 🎉

---

## Success Criteria

The deployment is considered successful when:
- ✅ All services are running without errors
- ✅ Admin can create clinic users
- ✅ Clinic users can log in and manage profiles
- ✅ Patients receive clinic recommendations
- ✅ Emails are being delivered
- ✅ No critical bugs reported
- ✅ Performance meets expectations (<5s clinic search)
- ✅ Error rate <1%
- ✅ Positive user feedback

---

## Support Contacts

### Technical Team
- **Backend Lead**: backend-lead@healthcompanion.com
- **Frontend Lead**: frontend-lead@healthcompanion.com
- **Mobile Lead**: mobile-lead@healthcompanion.com
- **DevOps**: devops@healthcompanion.com

### Emergency Contact
- **On-Call Engineer**: +1 (555) 999-8888
- **Slack Channel**: #health-companion-alerts

---

## Additional Resources

- [API Documentation](CLINIC_API_DOCUMENTATION.md)
- [Admin Guide](ADMIN_CLINIC_MANAGEMENT_GUIDE.md)
- [Clinic User Guide](CLINIC_USER_GUIDE.md)
- [Feature Status](CLINIC_FEATURE_FINAL_STATUS.md)

---

**Document Version**: 1.0  
**Last Updated**: January 2024  
**Prepared By**: Development Team
