# Admin Dashboard Sidebar Update

## Overview
Updated the admin dashboard sidebar navigation to remove unnecessary tabs and add a new Pharmacies management page.

## Changes Made

### 1. Sidebar Navigation Updates (`Sidebar.tsx`)

#### Removed Tabs:
- ❌ **Appointments** - Not needed for admin view
- ❌ **Prescriptions** - Not needed for admin view  
- ❌ **Lab Orders** - Not needed for admin view

#### Added Tab:
- ✅ **Pharmacies** - New tab for managing registered pharmacies

#### Updated Navigation Order:
1. Dashboard
2. User Management
3. Patients
4. **Pharmacies** ← NEW
5. Medications
6. Diagnoses
7. Reports
8. Audit Logs
9. Notifications
10. Settings (bottom section)

### 2. New Pharmacies Page (`Pharmacies.tsx`)

Created a comprehensive pharmacy management page with the following features:

#### Features:
- **View All Pharmacies**: Display all registered pharmacies in a table
- **Search**: Search by pharmacy name, city, district, or manager name
- **Pharmacy Details**: View detailed information about each pharmacy
- **Status Management**: Activate/deactivate pharmacies
- **Location Info**: Display address, city, district, and GPS coordinates
- **Contact Info**: Show phone number and opening hours
- **Inventory Count**: Display number of medicines registered (if available)

#### Table Columns:
1. **Pharmacy** - Name and manager
2. **Location** - City, district, and address
3. **Contact** - Phone number and opening hours
4. **Status** - Active/Inactive badge
5. **Actions** - View details and toggle status buttons

#### Actions Available:
- 👁️ **View Details**: Opens modal with full pharmacy information
- ✅/❌ **Toggle Status**: Activate or deactivate pharmacy

### 3. Routing Updates (`App.tsx`)

#### Removed Routes:
```tsx
<Route path="appointments" element={<Appointments />} />
<Route path="prescriptions" element={<Prescriptions />} />
<Route path="lab" element={<LabOrders />} />
```

#### Added Route:
```tsx
<Route path="pharmacies" element={<Pharmacies />} />
```

#### Removed Imports:
- `Appointments`
- `Prescriptions`
- `LabOrders`

#### Added Import:
- `Pharmacies`

## API Endpoints Used

### Get All Pharmacies
```
GET /api/v1/pharmacy-manager/map
Authorization: Bearer <token>

Response:
{
  success: true,
  data: {
    pharmacies: [
      {
        id: string,
        name: string,
        managerName?: string,
        phoneNumber?: string,
        address?: string,
        city?: string,
        district?: string,
        country?: string,
        latitude: number,
        longitude: number,
        isActive: boolean,
        openingHours?: string,
        createdAt: string
      }
    ],
    count: number
  }
}
```

### Toggle Pharmacy Status (To Be Implemented)
```
PUT /api/v1/pharmacy-manager/admin/:id/status
Authorization: Bearer <admin_token>
Body: { isActive: boolean }

Note: This endpoint needs to be created in the backend
```

### Get Pharmacy Details (Optional Enhancement)
```
GET /api/v1/pharmacy-manager/admin/pharmacies/:id
Authorization: Bearer <admin_token>

Note: This endpoint can be created to fetch full pharmacy details with medicines
```

## Pharmacy Data Structure

```typescript
interface Pharmacy {
  id: string;
  name: string;
  managerName?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  country?: string;
  latitude: number;
  longitude: number;
  isActive: boolean;
  openingHours?: string;
  createdAt: string;
  medicines?: any[]; // Optional, if fetching with medicines
}
```

## Admin Actions on Pharmacies

### Current Actions:
1. **View All Pharmacies**: See list of all registered pharmacies
2. **Search Pharmacies**: Filter by name, location, or manager
3. **View Details**: See complete pharmacy information
4. **Toggle Status**: Activate or deactivate a pharmacy

### Potential Future Actions:
1. **Edit Pharmacy Info**: Allow admin to update pharmacy details
2. **Delete Pharmacy**: Remove pharmacy from system
3. **View Medicines**: See all medicines in a specific pharmacy
4. **Approve/Reject**: Approve new pharmacy registrations
5. **Send Notifications**: Send messages to pharmacy managers
6. **View Analytics**: See pharmacy performance metrics
7. **Export Data**: Export pharmacy list to CSV/Excel

## Backend Endpoints to Create (Optional)

### 1. Update Pharmacy Status
```typescript
// pharmacy-manager.controller.ts
export const updatePharmacyStatus = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;
    
    const pharmacy = await pharmacyRepo().findOne({ where: { id } });
    if (!pharmacy) throw new AppError('Pharmacy not found', 404);
    
    pharmacy.isActive = isActive;
    await pharmacyRepo().save(pharmacy);
    
    res.status(200).json({
      success: true,
      message: 'Pharmacy status updated',
      data: { pharmacy }
    });
  } catch (error) {
    next(error);
  }
};
```

### 2. Get Pharmacy Details with Medicines
```typescript
// pharmacy-manager.controller.ts
export const getPharmacyDetails = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    
    const pharmacy = await pharmacyRepo().findOne({
      where: { id },
      relations: ['medicines']
    });
    
    if (!pharmacy) throw new AppError('Pharmacy not found', 404);
    
    res.status(200).json({
      success: true,
      data: { pharmacy }
    });
  } catch (error) {
    next(error);
  }
};
```

### 3. Add Routes
```typescript
// pharmacy-manager.routes.ts
router.get('/admin/pharmacies/:id', authenticate, authorize(UserRole.ADMIN), getPharmacyDetails);
router.put('/admin/:id/status', authenticate, authorize(UserRole.ADMIN), updatePharmacyStatus);
```

## User Experience Flow

### Admin Workflow:
1. **Login** as admin
2. **Navigate** to Pharmacies tab in sidebar
3. **View** list of all registered pharmacies
4. **Search** for specific pharmacy (optional)
5. **Click** eye icon to view pharmacy details
6. **Toggle** status to activate/deactivate pharmacy
7. **View** pharmacy location, contact info, and inventory count

### Pharmacy Manager Workflow (Unchanged):
1. **Login** as pharmacist
2. **Register** pharmacy profile
3. **Add** medicines to inventory
4. **Manage** medicine stock and prices
5. Admin can **view** but not edit pharmacy data

## Testing

### To Test the Pharmacies Page:
1. Start backend: `cd ai_health_companion_backend && npm run dev`
2. Start dashboard: `cd admin_dashboard && npm run dev`
3. Login as admin: `admin@clinic.rw` / `Admin@1234`
4. Click "Pharmacies" in sidebar
5. Should display all registered pharmacies

### To Add Test Pharmacies:
1. Create pharmacist users via Users page
2. Login as each pharmacist
3. Register pharmacy profile
4. Add medicines to inventory
5. Login as admin to view all pharmacies

## Files Modified

### Frontend:
- `admin_dashboard/src/components/layout/Sidebar.tsx` - Updated navigation
- `admin_dashboard/src/App.tsx` - Updated routes
- `admin_dashboard/src/pages/Pharmacies.tsx` - NEW PAGE

### Backend (No changes yet):
- Optional: Add admin pharmacy management endpoints

## Visual Changes

### Before:
```
Sidebar Navigation:
- Dashboard
- User Management
- Patients
- Medications
- Appointments ❌
- Diagnoses
- Prescriptions ❌
- Lab Orders ❌
- Reports
- Audit Logs
- Notifications
```

### After:
```
Sidebar Navigation:
- Dashboard
- User Management
- Patients
- Pharmacies ✅ NEW
- Medications
- Diagnoses
- Reports
- Audit Logs
- Notifications
```

## Benefits

1. **Cleaner Navigation**: Removed unnecessary tabs for admin role
2. **Pharmacy Management**: Centralized pharmacy oversight
3. **Better Organization**: Grouped related features together
4. **Admin Control**: Ability to activate/deactivate pharmacies
5. **Visibility**: See all registered pharmacies at a glance
6. **Search & Filter**: Easy to find specific pharmacies

## Status
✅ Sidebar navigation updated
✅ Pharmacies page created
✅ Routes configured
✅ Search functionality implemented
✅ View details modal added
⏳ Toggle status endpoint needs backend implementation
⏳ Waiting for pharmacy data to be populated

---

**Last Updated**: 2026-05-05
**Author**: Kiro AI Assistant
