# 🔧 Quick Fix: User Not Receiving Email

## 🎯 Most Likely Issue

Your Gmail App Password might have **spaces** or be **incorrect**.

---

## ⚡ Quick Fix (5 Minutes)

### Step 1: Generate New Gmail App Password

1. Go to: **https://myaccount.google.com/apppasswords**
2. If prompted, enable **2-Step Verification** first
3. Select:
   - App: **Mail**
   - Device: **Other (Custom name)**
   - Name it: **AI Health Companion**
4. Click **Generate**
5. Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

### Step 2: Update .env File

Open `ai_health_companion_backend/.env` and update:

```env
SMTP_PASSWORD=abcdefghijklmnop
```

**⚠️ IMPORTANT**: Remove ALL spaces from the password!

### Step 3: Restart Server

```bash
# Stop the server (Ctrl+C if running)
cd ai_health_companion_backend
npm run dev
```

### Step 4: Test Email Service

```bash
# In a new terminal
cd ai_health_companion_backend
npm run test:email
```

This will:
- ✅ Check your SMTP configuration
- ✅ Verify connection to Gmail
- ✅ Send a test email to your Gmail account

### Step 5: Check Your Inbox

1. Check your **inbox** for the test email
2. If not there, check **spam/junk folder**
3. If you received it, emails are working! ✅

---

## 🧪 Test Creating a User

Once the test email works, try creating a new user:

```bash
# 1. Login as admin
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'

# 2. Copy the accessToken from response

# 3. Create a test user (replace YOUR_TOKEN)
curl -X POST http://localhost:5000/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "firstName": "Test",
    "lastName": "User",
    "role": "DOCTOR",
    "sendEmail": true
  }'
```

Check the response for:
```json
{
  "success": true,
  "data": {
    "emailSent": true  // ← Should be true
  }
}
```

---

## 📋 Checklist

- [ ] Generated new Gmail App Password
- [ ] Copied password WITHOUT spaces
- [ ] Updated `.env` file
- [ ] Restarted the server
- [ ] Ran `npm run test:email`
- [ ] Received test email (check spam too)
- [ ] Created test user with `sendEmail: true`
- [ ] User received welcome email

---

## ❌ Still Not Working?

### Check Logs

```bash
# Check for email errors
Get-Content ai_health_companion_backend/logs/error.log -Tail 20

# Check for email success
Get-Content ai_health_companion_backend/logs/combined.log -Tail 50 | Select-String "email"
```

### Common Error Messages

**"Invalid login"** → App Password is wrong or has spaces
**"Connection timeout"** → Firewall blocking port 587
**"Email service not configured"** → Missing SMTP_* variables in .env

### Get More Help

See the detailed troubleshooting guide:
- **EMAIL_TROUBLESHOOTING.md** - Complete troubleshooting guide
- **USER_CREATION_WORKFLOW.md** - User creation process

---

## 💡 Pro Tips

1. **Always use App Password**, never your regular Gmail password
2. **Remove spaces** from the app password in .env
3. **Restart server** after changing .env
4. **Check spam folder** for first-time emails
5. **Test with `npm run test:email`** before creating users

---

## 🎯 Expected Result

When everything works:

1. ✅ `npm run test:email` sends email successfully
2. ✅ You receive the test email (inbox or spam)
3. ✅ Creating a user returns `emailSent: true`
4. ✅ New user receives welcome email with credentials
5. ✅ Logs show: `"Email sent to user@example.com"`

---

**Last Updated**: 2026-04-28
