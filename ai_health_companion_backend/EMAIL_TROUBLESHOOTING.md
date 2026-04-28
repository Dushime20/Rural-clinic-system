# Email Troubleshooting Guide

## 🔍 Issue: User Not Receiving Email

Your email service is configured and initialized successfully, but users aren't receiving emails after registration.

---

## ✅ Current Configuration

Based on your `.env` file:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=irahwizz@gmail.com
SMTP_PASSWORD=rlze lzlt kyrz bcex
SMTP_FROM_NAME=AI Health Companion
```

---

## 🔧 Common Issues & Solutions

### 1. Gmail App Password Issue

**Problem**: Gmail may be blocking the app password or it might be expired.

**Solution**:
1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Enable 2-Step Verification (if not already enabled)
3. Go to [App Passwords](https://myaccount.google.com/apppasswords)
4. Generate a new app password for "Mail"
5. Update your `.env` file with the new password (remove spaces)

```env
SMTP_PASSWORD=your-new-app-password-without-spaces
```

### 2. Less Secure App Access

**Problem**: Gmail might be blocking "less secure apps"

**Solution**:
- Use App Passwords (recommended) instead of your regular password
- Or enable "Less secure app access" (not recommended)

### 3. Email Sending Not Triggered

**Problem**: The `sendEmail` parameter might be set to `false`

**Solution**: When creating a user via API, ensure `sendEmail` is `true` or omitted:

```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "DOCTOR",
    "sendEmail": true
  }'
```

### 4. SMTP Connection Blocked

**Problem**: Firewall or antivirus blocking SMTP port 587

**Solution**:
- Check Windows Firewall settings
- Temporarily disable antivirus to test
- Try alternative port 465 with SSL:

```env
SMTP_PORT=465
SMTP_SECURE=true
```

### 5. Email in Spam Folder

**Problem**: Emails are being sent but landing in spam

**Solution**:
- Check the recipient's spam/junk folder
- Add `irahwizz@gmail.com` to contacts
- Mark the email as "Not Spam"

---

## 🧪 Testing Email Service

### Test 1: Check Email Service Status

Run this test script to verify email configuration:

```bash
cd ai_health_companion_backend
npm run test:email
```

### Test 2: Manual Email Test via API

Create a test endpoint or use the existing user creation:

```bash
# Login as admin first
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'

# Copy the access token from response, then create a test user
curl -X POST http://localhost:5000/api/v1/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "firstName": "Test",
    "lastName": "User",
    "role": "DOCTOR",
    "sendEmail": true
  }'
```

### Test 3: Check Logs for Email Errors

```bash
# Check error logs
Get-Content ai_health_companion_backend/logs/error.log -Tail 50

# Check combined logs for email
Get-Content ai_health_companion_backend/logs/combined.log -Tail 100 | Select-String "email"
```

---

## 📊 Debugging Steps

### Step 1: Verify SMTP Credentials

Test your Gmail credentials manually:

```bash
# Install test tool (if not already installed)
npm install -g nodemailer

# Create test script (see test-email.js below)
node test-email.js
```

### Step 2: Check Server Logs

Look for these log messages:

✅ **Success**:
```
"Email service initialized successfully"
"Email sent to user@example.com: <messageId>"
```

❌ **Failure**:
```
"Email service not configured"
"Failed to send email to user@example.com"
```

### Step 3: Enable Debug Logging

Temporarily add debug logging to email service:

1. Edit `src/services/email.service.ts`
2. Add console logs in the `sendEmail` method
3. Restart the server
4. Try creating a user again

---

## 🔐 Gmail Security Settings Checklist

- [ ] 2-Step Verification enabled
- [ ] App Password generated (not regular password)
- [ ] App Password copied without spaces
- [ ] "Less secure app access" NOT needed (use App Password instead)
- [ ] No recent security alerts from Google
- [ ] Account not locked or suspended

---

## 🚀 Quick Fix (Most Common Solution)

**The most common issue is the Gmail App Password format.**

1. **Generate new App Password**:
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Other (Custom name)"
   - Name it "AI Health Companion"
   - Click "Generate"

2. **Copy the 16-character password** (it will look like: `abcd efgh ijkl mnop`)

3. **Update .env** (remove all spaces):
   ```env
   SMTP_PASSWORD=abcdefghijklmnop
   ```

4. **Restart the server**:
   ```bash
   # Stop the server (Ctrl+C)
   npm run dev
   ```

5. **Test by creating a new user**

---

## 📝 Alternative Email Providers

If Gmail continues to have issues, consider these alternatives:

### SendGrid (Recommended for Production)

```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

### Mailgun

```env
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=postmaster@your-domain.mailgun.org
SMTP_PASSWORD=your-mailgun-password
```

### AWS SES

```env
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=your-ses-smtp-username
SMTP_PASSWORD=your-ses-smtp-password
```

---

## 🔍 Check Email Delivery Status

### Method 1: Check Response

When creating a user, the API response includes `emailSent` status:

```json
{
  "success": true,
  "data": {
    "user": { ... },
    "temporaryPassword": "TempPass123!",
    "emailSent": true  // ← Check this
  }
}
```

### Method 2: Check Logs

```bash
Get-Content logs/combined.log | Select-String "Email sent to"
```

### Method 3: Test Connection

Create a test script to verify SMTP connection:

```javascript
// test-email-connection.js
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransporter({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: 'irahwizz@gmail.com',
    pass: 'rlze lzlt kyrz bcex' // Your app password
  }
});

transporter.verify((error, success) => {
  if (error) {
    console.error('❌ SMTP Connection Failed:', error);
  } else {
    console.log('✅ SMTP Connection Successful!');
  }
});
```

Run it:
```bash
node test-email-connection.js
```

---

## ⚠️ Important Notes

1. **App Password vs Regular Password**: 
   - ❌ Don't use your Gmail login password
   - ✅ Use a generated App Password

2. **Spaces in Password**: 
   - Gmail shows app passwords with spaces (e.g., `abcd efgh ijkl mnop`)
   - ❌ Don't include spaces in .env
   - ✅ Remove spaces: `abcdefghijklmnop`

3. **Restart Required**: 
   - After changing .env, always restart the server
   - Environment variables are loaded at startup

4. **Check Spam Folder**: 
   - First-time emails often go to spam
   - Check recipient's spam/junk folder

---

## 📞 Still Not Working?

If emails still aren't sending after trying all solutions:

1. **Check the API response** - Does it say `emailSent: true`?
2. **Check error logs** - Any SMTP errors?
3. **Try a different email provider** - SendGrid, Mailgun, etc.
4. **Contact me** - Share the error logs for further assistance

---

## 🎯 Quick Checklist

- [ ] Gmail App Password generated (not regular password)
- [ ] App Password in .env without spaces
- [ ] Server restarted after .env changes
- [ ] `sendEmail: true` in user creation request
- [ ] Checked spam folder
- [ ] Checked error logs
- [ ] SMTP connection test passed
- [ ] Firewall/antivirus not blocking port 587

---

**Last Updated**: 2026-04-28
