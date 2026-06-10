# Admin Guide: Managing Clinics

## Overview

As an administrator, you can create and manage clinic users in the AI Health Companion system. Clinics provide specialized care recommendations for patients with recurring, persistent, or chronic conditions.

---

## Table of Contents

1. [Accessing Clinic Management](#accessing-clinic-management)
2. [Creating a New Clinic](#creating-a-new-clinic)
3. [Viewing Clinic Details](#viewing-clinic-details)
4. [Managing Clinic Status](#managing-clinic-status)
5. [Searching and Filtering Clinics](#searching-and-filtering-clinics)
6. [Managing Disease-Specialty Mappings](#managing-disease-specialty-mappings)
7. [Viewing Analytics](#viewing-analytics)
8. [Troubleshooting](#troubleshooting)

---

## Accessing Clinic Management

1. Log in to the Admin Dashboard
2. Click on **"Clinics"** in the left sidebar (between Pharmacies and Medications)
3. You'll see the Clinics management page with a list of all registered clinics

---

## Creating a New Clinic

### Step 1: Open the Creation Wizard

1. Click the **"Create Clinic"** button in the top right
2. A multi-step wizard will open

### Step 2: Basic Information

Fill in the following required fields:
- **Clinic Name**: The official name of the medical facility
- **Manager Name**: The name of the clinic manager (usually a doctor)
- **Email Address**: Manager's professional email (will receive login credentials)
- **Phone Number**: Clinic's contact number

**Example**:
```
Clinic Name: Central Medical Clinic
Manager Name: Dr. Jane Smith
Email: manager@centralmedical.com
Phone: +1 (555) 123-4567
```

Click **"Next"** to continue.

### Step 3: Location Details

Provide the clinic's physical location:
- **Street Address**: Full street address
- **City**: City name
- **District/State**: District or state
- **Country**: Country name
- **Latitude**: Numeric latitude (-90 to 90)
- **Longitude**: Numeric longitude (-180 to 180)

**Finding Coordinates**:
1. Go to [Google Maps](https://maps.google.com)
2. Right-click on the clinic's location
3. Click on the coordinates to copy them
4. The first number is latitude, second is longitude

**Example**:
```
Address: 123 Main Street
City: New York
District: Manhattan
Country: USA
Latitude: 40.7128
Longitude: -74.0060
```

Click **"Next"** to continue.

### Step 3: Medical Specialties

Select at least one medical specialty that the clinic provides:

**Available Specialties**:
- ☐ General Medicine
- ☐ Cardiology (Heart)
- ☐ Dermatology (Skin)
- ☐ Endocrinology (Hormones/Diabetes)
- ☐ Gastroenterology (Digestive System)
- ☐ Neurology (Nervous System)
- ☐ Oncology (Cancer)
- ☐ Orthopedics (Bones/Joints)
- ☐ Pediatrics (Children)
- ☐ Psychiatry (Mental Health)
- ☐ Pulmonology (Lungs)

**Note**: At least one specialty is required.

Click **"Next"** to continue.

### Step 4: Operating Hours (Optional)

Set the clinic's operating hours for each day of the week:
- Select opening and closing times using time pickers
- Leave a day unset if the clinic is closed
- Use 24-hour format (e.g., 09:00 for 9 AM, 17:00 for 5 PM)

**Example**:
```
Monday:    09:00 - 17:00
Tuesday:   09:00 - 17:00
Wednesday: 09:00 - 17:00
Thursday:  09:00 - 17:00
Friday:    09:00 - 17:00
Saturday:  10:00 - 14:00
Sunday:    Closed
```

Click **"Create Clinic"** to finish.

### Step 5: Credentials Display

After successful creation, you'll see:
- ✅ Success message
- 📧 Confirmation that email was sent to the clinic manager
- 🔑 Temporary password display

**Important**: 
- Copy the temporary password using the **"Copy to Clipboard"** button
- Store it securely or share it directly with the clinic manager
- The manager will be required to change this password on first login

**Email Sent**:
The clinic manager will receive an email with:
- Login URL to the Clinic Dashboard
- Their email address
- Temporary password
- Instructions to change password on first login

Click **"Done"** to return to the clinics list.

---

## Viewing Clinic Details

1. In the clinics list, click on any clinic row
2. A details modal will open showing:
   - Basic information (name, manager, contact details)
   - Location details with coordinates
   - Medical specialties (shown as colored badges)
   - Operating hours (shown in a weekly schedule)
   - Active status
   - Creation and last updated dates

3. Click **"Close"** to return to the list

---

## Managing Clinic Status

### Deactivating a Clinic

To temporarily disable a clinic:
1. View the clinic details
2. Click the **"Deactivate"** button
3. Confirm the action
4. The clinic will no longer appear in patient recommendations

**When to Deactivate**:
- Clinic is temporarily closed for renovation
- Clinic has requested to pause recommendations
- Addressing compliance or quality issues

### Reactivating a Clinic

To re-enable a deactivated clinic:
1. View the clinic details
2. Click the **"Activate"** button
3. The clinic will immediately appear in recommendations again

**Note**: Deactivated clinics remain in the system but are excluded from:
- Patient clinic search results
- Diagnosis recommendations
- Public clinic listings

---

## Searching and Filtering Clinics

### Search Bar
Type in the search bar to find clinics by:
- Clinic name
- Manager name
- Email address
- Phone number

**Example**: Type "cardiac" to find all cardiology clinics

### Filters

**By Specialty**:
1. Click the **"Specialty"** dropdown
2. Select a medical specialty
3. Only clinics with that specialty will be shown

**By Status**:
1. Click the **"Status"** dropdown
2. Select "Active" or "Inactive"
3. Filter is applied immediately

**By City**:
1. Click the **"City"** dropdown
2. Select a city from the list
3. Shows only clinics in that city

### Sorting

Click on column headers to sort:
- **Name**: Alphabetical order
- **City**: Alphabetical by city
- **Created Date**: Newest or oldest first

Click again to reverse the sort order.

### Pagination

- Use the page numbers at the bottom to navigate
- Change "Items per page" to show 10, 20, or 50 clinics per page

---

## Managing Disease-Specialty Mappings

Disease-specialty mappings determine which medical specialties are recommended for specific diseases.

### Accessing Mappings

1. Navigate to **"Settings"** > **"Disease Mappings"**
2. You'll see a list of all disease-specialty mappings

### Viewing Mappings

The list shows:
- Disease name
- Primary specialty (main recommendation)
- Secondary specialties (additional recommendations)
- Creation date

### Creating a New Mapping

1. Click **"Add Mapping"**
2. Enter:
   - **Disease Name**: e.g., "Diabetes Type 2"
   - **Primary Specialty**: e.g., "Endocrinology"
   - **Secondary Specialties**: e.g., "General Medicine" (optional)
3. Click **"Create"**

**Example Mapping**:
```
Disease: Asthma
Primary: Pulmonology
Secondary: General Medicine
```

### Editing a Mapping

1. Click on a mapping in the list
2. Modify the specialties
3. Click **"Save Changes"**

### Default Behavior

If no mapping exists for a disease:
- System automatically defaults to **General Medicine**
- No action needed - the system handles it gracefully

---

## Viewing Analytics

### Clinic Recommendation Statistics

1. Navigate to **"Analytics"** > **"Clinic Recommendations"**
2. View statistics showing:
   - Total clinic recommendations made
   - Breakdown by reason:
     - Recurring disease (3+ occurrences in 90 days)
     - Persistent disease (active > 30 days)
     - Chronic condition (matches patient history)
     - No pharmacy found (fallback)
   - Average clinics per recommendation
   - Unique patients receiving recommendations

### Date Range Filtering

- Use the date pickers to select a custom range
- Click **"Apply"** to update statistics
- Default shows last 30 days

### Exporting Data

- Click **"Export CSV"** to download analytics data
- Use for reporting or further analysis in spreadsheets

---

## Troubleshooting

### Clinic Creation Failed

**Problem**: Error message when creating clinic

**Solutions**:
1. Check all required fields are filled
2. Verify email is unique (not already registered)
3. Confirm coordinates are valid (-90 to 90 for latitude, -180 to 180 for longitude)
4. Ensure at least one specialty is selected
5. Check that phone number is in valid format

### Email Not Sent

**Problem**: Clinic created but manager didn't receive email

**Solutions**:
1. Check the manager's spam/junk folder
2. Verify email address is correct in clinic details
3. Manually share the temporary password (displayed after creation)
4. Contact system administrator if email service is down

### Clinic Not Appearing in Recommendations

**Problem**: Clinic exists but patients aren't seeing it

**Check**:
1. Is the clinic **Active**? (View details to confirm)
2. Is the clinic within 100km of the patient's location?
3. Does the clinic's specialty match the patient's diagnosis?
4. Are the clinic's coordinates correct?
5. Is there a disease-specialty mapping for the patient's condition?

**To Test**:
- Temporarily set clinic's specialty to "General Medicine" (covers all conditions)
- Verify coordinates are accurate using Google Maps
- Check if disease has a specialty mapping

### Coordinates Are Incorrect

**Problem**: Clinic appears in wrong location on map

**Solution**:
1. Go to Google Maps and find the correct location
2. Right-click and copy the coordinates
3. Edit the clinic profile with correct coordinates
4. Save changes
5. Verify on the map display

---

## Best Practices

### When Creating Clinics

✅ **DO**:
- Double-check email addresses (typos prevent login)
- Use accurate coordinates from Google Maps
- Select all relevant specialties (more = better recommendations)
- Set realistic operating hours
- Keep clinic names professional and clear

❌ **DON'T**:
- Use personal email addresses (use official clinic emails)
- Guess coordinates (always verify on a map)
- Select specialties the clinic doesn't actually offer
- Leave contact information incomplete

### Managing Active Status

✅ **DO**:
- Deactivate clinics that are permanently closed
- Deactivate temporarily if clinic requests it
- Reactivate as soon as issues are resolved
- Document reason for deactivation (in notes)

❌ **DON'T**:
- Deactivate without notifying the clinic manager
- Leave clinics deactivated longer than necessary
- Use deactivation as punishment (address issues directly)

### Disease Mappings

✅ **DO**:
- Create mappings for common diseases in your region
- Include both primary and secondary specialties
- Review and update mappings periodically
- Get input from medical professionals

❌ **DON'T**:
- Create duplicate mappings for the same disease
- Map diseases to irrelevant specialties
- Delete mappings without checking if they're in use

---

## Support

### Getting Help

- **Technical Issues**: Contact IT support at support@healthcompanion.com
- **Medical Questions**: Consult with clinical staff
- **Feature Requests**: Submit via admin portal feedback form

### Additional Resources

- [Full API Documentation](CLINIC_API_DOCUMENTATION.md)
- [System Architecture Overview](CLINIC_FEATURE_FINAL_STATUS.md)
- [Video Tutorials](https://training.healthcompanion.com/clinics)

---

**Document Version**: 1.0  
**Last Updated**: January 2024  
**For**: AI Health Companion Admin Dashboard
