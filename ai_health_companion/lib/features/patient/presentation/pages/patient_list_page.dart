import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/patient_service.dart';
import '../../../../shared/widgets/app_header.dart';

class PatientListPage extends ConsumerStatefulWidget {
  const PatientListPage({super.key});

  @override
  ConsumerState<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientListPage> {
  final _searchController = TextEditingController();
  final _patientService = PatientService();

  List<dynamic> _patients = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _patients = [];
      });
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _patientService.getPatients(
      page: _currentPage,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final data = result['data'];
        _patients = data['patients'] as List? ?? [];
        _totalPages = data['pagination']?['pages'] ?? 1;
      } else {
        _error = result['message'];
      }
    });
  }

  Future<void> _deletePatient(dynamic patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Patient'),
            content: Text(
              'Are you sure you want to delete ${patient['firstName']} ${patient['lastName']}?\n\nThis is a soft delete — the record can be restored by an admin.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final result = await _patientService.deletePatient(patient['id']);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success'] == true
              ? '${patient['firstName']} ${patient['lastName']} deleted'
              : result['message'] ?? 'Delete failed',
        ),
        backgroundColor:
            result['success'] == true
                ? AppTheme.successColor
                : AppTheme.errorColor,
      ),
    );

    if (result['success'] == true) _loadPatients(reset: true);
  }

  String _getAge(dynamic patient) {
    final dob = patient['dateOfBirth'];
    if (dob == null) return '—';
    try {
      final birth = DateTime.parse(dob.toString());
      final age = DateTime.now().difference(birth).inDays ~/ 365;
      return '$age yrs';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Patients',
        subtitle: '${_patients.length} patients',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPatients(reset: true),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await context.push('/patient/add');
              _loadPatients(reset: true);
            },
            tooltip: 'Add Patient',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadPatients(reset: true);
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchQuery == val) _loadPatients(reset: true);
                });
              },
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/patient/add');
          _loadPatients(reset: true);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadPatients(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No patients yet' : 'No patients found',
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await context.push('/patient/add');
                _loadPatients(reset: true);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Patient'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPatients(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: _patients.length + (_totalPages > _currentPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _patients.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _currentPage++);
                  _loadPatients();
                },
                child: const Text('Load More'),
              ),
            );
          }
          return _buildPatientCard(_patients[index]);
        },
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    final name =
        '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    final gender = (patient['gender'] ?? '').toString();
    final age = _getAge(patient);
    final patientId = patient['patientId'] ?? '';
    final lastVisit = patient['lastVisit'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await context.push('/patient/${patient['id']}');
          _loadPatients(reset: true);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryColor.withAlpha(26),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$age • $gender • ID: $patientId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (lastVisit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last visit: ${lastVisit.toString().split('T')[0]}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await context.push(
                      '/patient/${patient['id']}/edit',
                      extra: patient,
                    );
                    _loadPatients(reset: true);
                  } else if (action == 'delete') {
                    await _deletePatient(patient);
                  }
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
