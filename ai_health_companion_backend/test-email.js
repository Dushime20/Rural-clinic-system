/**
 * Email Service Test Script
 * Tests SMTP connection and sends a test email
 */

require('dotenv').config();
const nodemailer = require('nodemailer');

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

async function testEmailService() {
  log('\n🧪 Testing Email Service Configuration\n', colors.cyan);
  log('━'.repeat(60), colors.blue);

  // Step 1: Check environment variables
  log('\n📋 Step 1: Checking Environment Variables', colors.yellow);
  
  const config = {
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',
    user: process.env.SMTP_USER,
    password: process.env.SMTP_PASSWORD,
    fromName: process.env.SMTP_FROM_NAME || 'AI Health Companion',
  };

  log(`   SMTP Host: ${config.host || '❌ NOT SET'}`, config.host ? colors.green : colors.red);
  log(`   SMTP Port: ${config.port}`, colors.green);
  log(`   SMTP Secure: ${config.secure}`, colors.green);
  log(`   SMTP User: ${config.user || '❌ NOT SET'}`, config.user ? colors.green : colors.red);
  log(`   SMTP Password: ${config.password ? '✅ SET (length: ' + config.password.length + ')' : '❌ NOT SET'}`, 
      config.password ? colors.green : colors.red);
  log(`   From Name: ${config.fromName}`, colors.green);

  if (!config.host || !config.user || !config.password) {
    log('\n❌ Email service not configured properly!', colors.red);
    log('   Please set SMTP_HOST, SMTP_USER, and SMTP_PASSWORD in .env file', colors.yellow);
    process.exit(1);
  }

  // Step 2: Create transporter
  log('\n📧 Step 2: Creating Email Transporter', colors.yellow);
  
  const transporter = nodemailer.createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    auth: {
      user: config.user,
      pass: config.password,
    },
    debug: true, // Enable debug output
  });

  log('   ✅ Transporter created', colors.green);

  // Step 3: Verify connection
  log('\n🔌 Step 3: Verifying SMTP Connection', colors.yellow);
  
  try {
    await transporter.verify();
    log('   ✅ SMTP connection verified successfully!', colors.green);
  } catch (error) {
    log('   ❌ SMTP connection failed!', colors.red);
    log(`   Error: ${error.message}`, colors.red);
    
    if (error.message.includes('Invalid login')) {
      log('\n💡 Troubleshooting Tips:', colors.yellow);
      log('   1. Make sure you\'re using a Gmail App Password, not your regular password', colors.cyan);
      log('   2. Generate App Password: https://myaccount.google.com/apppasswords', colors.cyan);
      log('   3. Remove spaces from the app password in .env file', colors.cyan);
      log('   4. Enable 2-Step Verification first', colors.cyan);
    }
    
    process.exit(1);
  }

  // Step 4: Send test email
  log('\n📨 Step 4: Sending Test Email', colors.yellow);
  
  const testEmail = process.argv[2] || config.user; // Use command line arg or send to self
  
  log(`   Sending to: ${testEmail}`, colors.cyan);

  const mailOptions = {
    from: `"${config.fromName}" <${config.user}>`,
    to: testEmail,
    subject: '✅ Email Service Test - AI Health Companion',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .success { background: #d4edda; border-left: 4px solid #28a745; padding: 15px; margin: 20px 0; border-radius: 5px; }
          .info { background: #d1ecf1; border-left: 4px solid #17a2b8; padding: 15px; margin: 20px 0; border-radius: 5px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✅ Email Service Test</h1>
            <p>AI Health Companion</p>
          </div>
          <div class="content">
            <div class="success">
              <strong>🎉 Success!</strong>
              <p>Your email service is configured correctly and working!</p>
            </div>
            
            <h3>📋 Configuration Details</h3>
            <ul>
              <li><strong>SMTP Host:</strong> ${config.host}</li>
              <li><strong>SMTP Port:</strong> ${config.port}</li>
              <li><strong>SMTP User:</strong> ${config.user}</li>
              <li><strong>From Name:</strong> ${config.fromName}</li>
              <li><strong>Test Time:</strong> ${new Date().toLocaleString()}</li>
            </ul>
            
            <div class="info">
              <strong>ℹ️ Next Steps:</strong>
              <ul>
                <li>Your email service is ready to send user credentials</li>
                <li>New users will receive welcome emails automatically</li>
                <li>Check spam folder if emails don't appear in inbox</li>
              </ul>
            </div>
            
            <p>If you received this email, your email service is working perfectly!</p>
            
            <p>Best regards,<br><strong>AI Health Companion Team</strong></p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
Email Service Test - AI Health Companion

✅ Success! Your email service is configured correctly and working!

Configuration Details:
- SMTP Host: ${config.host}
- SMTP Port: ${config.port}
- SMTP User: ${config.user}
- From Name: ${config.fromName}
- Test Time: ${new Date().toLocaleString()}

Next Steps:
- Your email service is ready to send user credentials
- New users will receive welcome emails automatically
- Check spam folder if emails don't appear in inbox

If you received this email, your email service is working perfectly!

Best regards,
AI Health Companion Team
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    log('   ✅ Test email sent successfully!', colors.green);
    log(`   Message ID: ${info.messageId}`, colors.cyan);
    log(`   Recipient: ${testEmail}`, colors.cyan);
    
    log('\n━'.repeat(60), colors.blue);
    log('\n🎉 All Tests Passed!', colors.green);
    log('\n📬 Check your inbox (and spam folder) for the test email', colors.yellow);
    log('   If you received it, your email service is working correctly!\n', colors.cyan);
    
  } catch (error) {
    log('   ❌ Failed to send test email!', colors.red);
    log(`   Error: ${error.message}`, colors.red);
    
    if (error.code === 'EAUTH') {
      log('\n💡 Authentication Error - Troubleshooting:', colors.yellow);
      log('   1. Verify your Gmail App Password is correct', colors.cyan);
      log('   2. Make sure there are no spaces in the password', colors.cyan);
      log('   3. Generate a new App Password if needed', colors.cyan);
      log('   4. Restart the server after updating .env', colors.cyan);
    }
    
    process.exit(1);
  }
}

// Run the test
log('\n🚀 Starting Email Service Test...', colors.cyan);
testEmailService().catch((error) => {
  log(`\n❌ Unexpected error: ${error.message}`, colors.red);
  console.error(error);
  process.exit(1);
});
