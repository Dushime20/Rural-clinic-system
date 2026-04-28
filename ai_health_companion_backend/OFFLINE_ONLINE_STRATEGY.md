# 🌐 Offline/Online Strategy for AI Health Companion

## 📋 Executive Summary

The AI Health Companion uses a **hybrid offline/online architecture**:
- ✅ **Patient registration**: Requires internet (must sync with central database)
- ✅ **AI diagnosis**: Works offline (model runs locally on device)
- ✅ **Data sync**: Automatic when internet available

---

## 🎯 Core Principles

### 1. Internet Required For:
- ✅ **Patient registration** (new patients must be in central database)
- ✅ **User authentication** (first login, token refresh)
- ✅ **Initial app setup** (download AI model, datasets)
- ✅ **Data synchronization** (upload diagnoses, prescriptions)
- ✅ **User management** (create/update users)

### 2. Works Offline For:
- ✅ **AI disease prediction** (model runs locally)
- ✅ **View existing patient records** (cached locally)
- ✅ **Create diagnoses** (saved locally, synced later)
- ✅ **View medical recommendations** (datasets cached)
- ✅ **Search symptoms** (local database)

### 3. Hybrid Mode:
- ✅ **Patient lookup** (check local cache first, then online)
- ✅ **Diagnosis history** (show cached + fetch latest online)
- ✅ **Medication lookup** (local database + online updates)

---

## 🏗️ Architecture

### Mobile App Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                  │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────┐         ┌─────────────────┐       │
│  │  Online Mode    │         │  Offline Mode   │       │
│  │                 │         │                 │       │
│  │ - Register      │         │ - AI Diagnosis  │       │
│  │   Patient       │         │ - View Patients │       │
│  │ - Sync Data     │         │ - Create Diag.  │       │
│  │ - Auth          │         │ - View History  │       │
│  └────────┬────────┘         └────────┬────────┘       │
│           │                           │                 │
│           └───────────┬───────────────┘                 │
│                       │                                 │
│           ┌───────────▼───────────┐                     │
│           │   Connectivity Check  │                     │
│           │   (Internet Detector) │                     │
│           └───────────┬───────────┘                     │
│                       │                                 │
│       ┌───────────────┴───────────────┐                 │
│       │                               │                 │
│       ▼                               ▼                 │
│  ┌─────────────┐              ┌─────────────┐          │
│  │ Local DB    │              │ AI Model    │          │
│  │ (SQLite)    │              │ (TFLite)    │          │
│  │             │              │             │          │
│  │ - Patients  │              │ - Symptoms  │          │
│  │ - Diagnoses │              │ - Diseases  │          │
│  │ - Sync Queue│              │ - Datasets  │          │
│  └─────────────┘              └─────────────┘          │
│                                                         │
└─────────────────────────────────────────────────────────┘
                       │
                       │ Internet Available
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Backend API (Node.js + Flask)               │
│                                                          │
│  ┌──────────────┐         ┌──────────────┐             │
│  │  Node.js API │◄───────►│  Flask ML    │             │
│  │  (Port 5000) │         │  (Port 5001) │             │
│  └──────┬───────┘         └──────────────┘             │
│         │                                               │
│         ▼                                               │
│  ┌──────────────┐                                       │
│  │  PostgreSQL  │                                       │
│  │  (Central DB)│                                       │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Workflow Scenarios

### Scenario 1: Patient Registration (REQUIRES INTERNET)

```
User opens app
    ↓
Check internet connection
    ↓
    ├─ ❌ No Internet
    │   └─ Show error: "Patient registration requires internet connection"
    │   └─ Suggest: "Connect to internet to register new patients"
    │
    └─ ✅ Has Internet
        ↓
    Navigate to "Register Patient"
        ↓
    Fill patient details
        ↓
    Submit to backend API
        ↓
    Backend creates patient in PostgreSQL
        ↓
    Return patient ID
        ↓
    Save patient to local SQLite
        ↓
    ✅ Patient registered successfully
```

**Why internet is required:**
- Central database must have all patients
- Prevents duplicate patient IDs
- Ensures data consistency across clinics
- Enables patient lookup from any clinic

---

### Scenario 2: AI Diagnosis (WORKS OFFLINE)

```
User selects patient (from local cache)
    ↓
Enter symptoms
    ↓
Enter vital signs
    ↓
Run AI prediction (LOCAL MODEL)
    ↓
    ├─ Model runs on device (TensorFlow Lite)
    ├─ No internet needed
    └─ Uses local datasets
    ↓
Display prediction results
    ↓
Save diagnosis to local SQLite
    ↓
Add to sync queue
    ↓
Check internet connection
    ↓
    ├─ ❌ No Internet
    │   └─ Keep in sync queue
    │   └─ Show: "Diagnosis saved locally, will sync when online"
    │
    └─ ✅ Has Internet
        ↓
    Sync to backend immediately
        ↓
    Mark as synced
        ↓
    ✅ Diagnosis completed and synced
```

**Why offline works:**
- AI model is embedded in app (TFLite)
- All datasets cached locally
- Diagnosis saved to local database
- Syncs automatically when online

---

### Scenario 3: First-Time App Setup (REQUIRES INTERNET)

```
User installs app
    ↓
First launch
    ↓
Check internet connection
    ↓
    ├─ ❌ No Internet
    │   └─ Show error: "Initial setup requires internet"
    │   └─ Cannot proceed
    │
    └─ ✅ Has Internet
        ↓
    Login screen
        ↓
    User enters credentials
        ↓
    Authenticate with backend
        ↓
    Download AI model (if not bundled)
        ↓
    Download datasets
        ↓
    Download user's clinic data
        ↓
    Cache patients (recent 100)
        ↓
    ✅ Setup complete
        ↓
    App can now work offline
```

---

### Scenario 4: Data Synchronization (WHEN INTERNET AVAILABLE)

```
App detects internet connection
    ↓
Check sync queue
    ↓
Has pending items?
    ↓
    ├─ ❌ No pending items
    │   └─ Do nothing
    │
    └─ ✅ Has pending items
        ↓
    Show sync indicator
        ↓
    Upload diagnoses
        ↓
    Upload prescriptions
        ↓
    Upload lab orders
        ↓
    Download new patients
        ↓
    Download updates
        ↓
    Mark items as synced
        ↓
    ✅ Sync complete
```

---

## 📱 Mobile App Implementation

### Flutter Local Database (SQLite)

```dart
// lib/database/local_database.dart

class LocalDatabase {
  static Database? _database;
  
  // Tables
  static const String PATIENTS_TABLE = 'patients';
  static const String DIAGNOSES_TABLE = 'diagnoses';
  static const String SYNC_QUEUE_TABLE = 'sync_queue';
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'health_companion.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Patients table
        await db.execute('''
          CREATE TABLE $PATIENTS_TABLE (
            id TEXT PRIMARY KEY,
            patient_id TEXT UNIQUE,
            first_name TEXT,
            last_name TEXT,
            date_of_birth TEXT,
            gender TEXT,
            phone_number TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
        
        // Diagnoses table
        await db.execute('''
          CREATE TABLE $DIAGNOSES_TABLE (
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            symptoms TEXT,
            vital_signs TEXT,
            prediction TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            FOREIGN KEY (patient_id) REFERENCES $PATIENTS_TABLE (id)
          )
        ''');
        
        // Sync queue table
        await db.execute('''
          CREATE TABLE $SYNC_QUEUE_TABLE (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity_type TEXT,
            entity_id TEXT,
            action TEXT,
            data TEXT,
            retry_count INTEGER DEFAULT 0,
            created_at TEXT
          )
        ''');
      },
    );
  }
  
  // Save patient locally
  Future<void> savePatient(Patient patient, {bool isSynced = false}) async {
    final db = await database;
    await db.insert(
      PATIENTS_TABLE,
      {
        ...patient.toJson(),
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Save diagnosis locally
  Future<void> saveDiagnosis(Diagnosis diagnosis) async {
    final db = await database;
    await db.insert(
      DIAGNOSES_TABLE,
      {
        ...diagnosis.toJson(),
        'is_synced': 0, // Not synced yet
      },
    );
    
    // Add to sync queue
    await addToSyncQueue('diagnosis', diagnosis.id, 'create', diagnosis.toJson());
  }
  
  // Add to sync queue
  Future<void> addToSyncQueue(
    String entityType,
    String entityId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(SYNC_QUEUE_TABLE, {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'data': jsonEncode(data),
      'retry_count': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      SYNC_QUEUE_TABLE,
      orderBy: 'created_at ASC',
    );
  }
  
  // Mark as synced
  Future<void> markAsSynced(String entityType, String entityId) async {
    final db = await database;
    
    // Update entity
    String table = entityType == 'patient' ? PATIENTS_TABLE : DIAGNOSES_TABLE;
    await db.update(
      table,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [entityId],
    );
    
    // Remove from sync queue
    await db.delete(
      SYNC_QUEUE_TABLE,
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
    );
  }
}
```

---

### Connectivity Service

```dart
// lib/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Check if device has internet
  Future<bool> hasInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    // Verify actual internet access (not just WiFi/mobile connection)
    return await _verifyInternetAccess();
  }
  
  // Verify actual internet access by pinging backend
  Future<bool> _verifyInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/health'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Listen to connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((_) async {
      return await hasInternet();
    });
  }
}
```

---

### Sync Service

```dart
// lib/services/sync_service.dart

class SyncService {
  final LocalDatabase _localDb = LocalDatabase();
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();
  
  bool _isSyncing = false;
  
  // Auto-sync when internet becomes available
  void startAutoSync() {
    _connectivity.onConnectivityChanged.listen((hasInternet) {
      if (hasInternet && !_isSyncing) {
        syncPendingData();
      }
    });
  }
  
  // Sync all pending data
  Future<SyncResult> syncPendingData() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }
    
    _isSyncing = true;
    
    try {
      // Check internet
      bool hasInternet = await _connectivity.hasInternet();
      if (!hasInternet) {
        return SyncResult(success: false, message: 'No internet connection');
      }
      
      // Get pending items
      List<Map<String, dynamic>> pendingItems = 
          await _localDb.getPendingSyncItems();
      
      if (pendingItems.isEmpty) {
        return SyncResult(success: true, message: 'Nothing to sync');
      }
      
      int successCount = 0;
      int failCount = 0;
      
      // Sync each item
      for (var item in pendingItems) {
        try {
          await _syncItem(item);
          successCount++;
        } catch (e) {
          failCount++;
          print('Failed to sync item: $e');
        }
      }
      
      return SyncResult(
        success: failCount == 0,
        message: 'Synced $successCount items, $failCount failed',
        syncedCount: successCount,
        failedCount: failCount,
      );
      
    } finally {
      _isSyncing = false;
    }
  }
  
  // Sync individual item
  Future<void> _syncItem(Map<String, dynamic> item) async {
    String entityType = item['entity_type'];
    String entityId = item['entity_id'];
    String action = item['action'];
    Map<String, dynamic> data = jsonDecode(item['data']);
    
    switch (entityType) {
      case 'diagnosis':
        await _apiService.createDiagnosis(data);
        break;
      case 'prescription':
        await _apiService.createPrescription(data);
        break;
      case 'lab_order':
        await _apiService.createLabOrder(data);
        break;
    }
    
    // Mark as synced
    await _localDb.markAsSynced(entityType, entityId);
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  
  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
  });
}
```

---

### Patient Registration Screen (Requires Internet)

```dart
// lib/screens/register_patient_screen.dart

class RegisterPatientScreen extends StatefulWidget {
  @override
  _RegisterPatientScreenState createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _apiService = ApiService();
  final LocalDatabase _localDb = LocalDatabase();
  
  bool _hasInternet = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _checkInternet();
  }
  
  Future<void> _checkInternet() async {
    bool hasInternet = await _connectivity.hasInternet();
    setState(() {
      _hasInternet = hasInternet;
    });
  }
  
  Future<void> _registerPatient() async {
    // Check internet first
    bool hasInternet = await _connectivity.hasInternet();
    
    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Patient registration requires internet connection'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _checkInternet,
          ),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Register patient online
      Patient patient = await _apiService.registerPatient(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        phoneNumber: _phoneController.text,
      );
      
      // Save to local database
      await _localDb.savePatient(patient, isSynced: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Patient registered successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, patient);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to register patient: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Patient'),
        actions: [
          // Internet status indicator
          Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              _hasInternet ? Icons.wifi : Icons.wifi_off,
              color: _hasInternet ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: !_hasInternet
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patient registration requires internet',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _checkInternet,
                    icon: Icon(Icons.refresh),
                    label: Text('Check Connection'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                child: Column(
                  children: [
                    // Form fields...
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                    ),
                    // ... more fields
                    
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerPatient,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Register Patient'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

---

## 🎯 User Experience

### Online Mode Indicators

```dart
// Show internet status in app bar
AppBar(
  title: Text('AI Health Companion'),
  actions: [
    StreamBuilder<bool>(
      stream: connectivityService.onConnectivityChanged,
      builder: (context, snapshot) {
        bool isOnline = snapshot.data ?? false;
        return Chip(
          avatar: Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: Colors.white,
            size: 16,
          ),
          label: Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: isOnline ? Colors.green : Colors.orange,
        );
      },
    ),
    SizedBox(width: 8),
  ],
)
```

### Sync Status Indicator

```dart
// Show sync status
if (hasPendingSync)
  ListTile(
    leading: Icon(Icons.sync, color: Colors.orange),
    title: Text('$pendingCount items pending sync'),
    subtitle: Text('Will sync when online'),
    trailing: isOnline
        ? ElevatedButton(
            onPressed: () => syncService.syncPendingData(),
            child: Text('Sync Now'),
          )
        : null,
  )
```

---

## 📊 Data Flow Summary

### Patient Registration Flow
```
User → Check Internet → ✅ Online → Register → Backend → Local Cache
                      → ❌ Offline → Show Error
```

### AI Diagnosis Flow
```
User → Select Patient → Enter Symptoms → AI Model (Local) → Save Local → Sync Queue
                                                                       ↓
                                                            ✅ Online → Sync Now
                                                            ❌ Offline → Sync Later
```

### Data Sync Flow
```
Internet Available → Check Sync Queue → Upload Pending → Mark Synced → Download Updates
```

---

## ✅ Implementation Checklist

### Mobile App
- [ ] Implement SQLite local database
- [ ] Add connectivity service
- [ ] Implement sync service
- [ ] Add internet check before patient registration
- [ ] Show online/offline indicator
- [ ] Show sync status
- [ ] Handle sync errors gracefully
- [ ] Test offline diagnosis
- [ ] Test online registration
- [ ] Test auto-sync

### Backend
- [ ] Ensure patient registration endpoint works
- [ ] Add sync endpoints
- [ ] Handle duplicate prevention
- [ ] Add conflict resolution
- [ ] Log sync activities

---

## 🎉 Summary

**Internet Required:**
- ✅ Patient registration (must be in central database)
- ✅ First-time setup
- ✅ User authentication
- ✅ Data synchronization

**Works Offline:**
- ✅ AI diagnosis (local model)
- ✅ View cached patients
- ✅ Create diagnoses (synced later)
- ✅ View medical recommendations

**Best of Both Worlds:**
- Register patients online (ensures data consistency)
- Diagnose offline (works in remote areas)
- Auto-sync when internet available (seamless experience)

---

**Last Updated**: 2026-04-28
