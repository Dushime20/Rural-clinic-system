import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/patient_card.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/widgets/app_header.dart';

class PatientListPage extends ConsumerStatefulWidget {
  const PatientListPage({super.key});

  @override
  ConsumerState<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientListPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Recent', 'Critical', 'Follow-up'];

  // Mock patient data
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'name': 'John Doe',
      'age': 45,
      'gender': 'Male',
      'lastVisit': '2024-01-15',
      'status': 'Follow-up',
      'diagnosis': 'Hypertension',
      'isCritical': false,
    },
    {
      'id': '2',
      'name': 'Mary Johnson',
      'age': 32,
      'gender': 'Female',
      'lastVisit': '2024-01-14',
      'status': 'Recent',
      'diagnosis': 'Diabetes Type 2',
      'isCritical': true,
    },
    {
      'id': '3',
      'name': 'Robert Smith',
      'age': 28,
      'gender': 'Male',
      'lastVisit': '2024-01-13',
      'status': 'Recent',
      'diagnosis': 'Common Cold',
      'isCritical': false,
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'age': 55,
      'gender': 'Female',
      'lastVisit': '2024-01-12',
      'status': 'Follow-up',
      'diagnosis': 'Arthritis',
      'isCritical': false,
    },
    {
      'id': '5',
      'name': 'Michael Brown',
      'age': 38,
      'gender': 'Male',
      'lastVisit': '2024-01-11',
      'status': 'Critical',
      'diagnosis': 'Pneumonia',
      'isCritical': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _getFilteredPatients();

    return Scaffold(
      appBar: AppHeader(
        title: 'Patients',
        subtitle: '${filteredPatients.length} patients found',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPatientDialog(),
            tooltip: 'Add Patient',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'Search patients...',
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Patient Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredPatients.length} patients',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last updated: ${_getLastUpdateTime()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Patient List
          Expanded(
            child:
                filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PatientCard(
                            patient: patient,
                            onTap:
                                () => context.go('/patient/${patient['id']}'),
                            onEdit: () => _showEditPatientDialog(patient),
                            onDelete: () => _showDeletePatientDialog(patient),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPatientDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPatients() {
    var filtered =
        _patients.where((patient) {
          final matchesSearch = patient['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

          final matchesFilter =
              _selectedFilter == 'All' ||
              patient['status'].toString().toLowerCase() ==
                  _selectedFilter.toLowerCase();

          return matchesSearch && matchesFilter;
        }).toList();

    // Sort by last visit date (most recent first)
    filtered.sort((a, b) => b['lastVisit'].compareTo(a['lastVisit']));

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPatientDialog(),
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Patient'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Patients'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _filters.map((filter) {
                    return RadioListTile<String>(
                      title: Text(filter),
                      value: filter,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showAddPatientDialog() {
    context.go('/patient/add');
  }

  void _showEditPatientDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit ${patient['name']}'),
            content: const Text('Patient edit form will be implemented here.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient updated successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDeletePatientDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Patient'),
            content: Text(
              'Are you sure you want to delete ${patient['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient deleted successfully'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  String _getLastUpdateTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
