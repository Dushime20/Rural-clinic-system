import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';

class PharmacyStockPage extends StatefulWidget {
  const PharmacyStockPage({super.key});

  @override
  State<PharmacyStockPage> createState() => _PharmacyStockPageState();
}

class _PharmacyStockPageState extends State<PharmacyStockPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '';
  bool _isLoading = false;

  List<String> _getCategories(AppLocalizations l10n) {
    return [
      l10n.allCategory,
      l10n.antibioticsCategory,
      l10n.analgesicsCategory,
      l10n.antidiabeticCategory,
      l10n.cardiovascularCategory,
      l10n.respiratoryCategory,
    ];
  }

  final List<Map<String, dynamic>> _stockData = [
    {
      'name': 'Amoxicillin 500mg',
      'category': 'Antibiotics',
      'totalStock': 450,
      'lowStockThreshold': 100,
      'locations': [
        {'name': 'Kigali Health Center', 'stock': 150, 'status': 'Good'},
        {'name': 'Gasabo Medical Center', 'stock': 45, 'status': 'Low'},
        {'name': 'Nyarugenge Clinic', 'stock': 200, 'status': 'Good'},
        {'name': 'Remera Clinic', 'stock': 55, 'status': 'Low'},
      ],
    },
    {
      'name': 'Paracetamol 500mg',
      'category': 'Analgesics',
      'totalStock': 800,
      'lowStockThreshold': 150,
      'locations': [
        {'name': 'Kigali Health Center', 'stock': 300, 'status': 'Good'},
        {'name': 'Gasabo Medical Center', 'stock': 250, 'status': 'Good'},
        {'name': 'Nyarugenge Clinic', 'stock': 150, 'status': 'Good'},
        {'name': 'Remera Clinic', 'stock': 100, 'status': 'Low'},
      ],
    },
    {
      'name': 'Metformin 850mg',
      'category': 'Antidiabetic',
      'totalStock': 120,
      'lowStockThreshold': 100,
      'locations': [
        {'name': 'Kigali Health Center', 'stock': 80, 'status': 'Low'},
        {'name': 'Gasabo Medical Center', 'stock': 40, 'status': 'Critical'},
        {'name': 'Nyarugenge Clinic', 'stock': 0, 'status': 'Out'},
        {'name': 'Remera Clinic', 'stock': 0, 'status': 'Out'},
      ],
    },
    {
      'name': 'Ibuprofen 400mg',
      'category': 'Analgesics',
      'totalStock': 600,
      'lowStockThreshold': 120,
      'locations': [
        {'name': 'Kigali Health Center', 'stock': 200, 'status': 'Good'},
        {'name': 'Gasabo Medical Center', 'stock': 180, 'status': 'Good'},
        {'name': 'Nyarugenge Clinic', 'stock': 120, 'status': 'Good'},
        {'name': 'Remera Clinic', 'stock': 100, 'status': 'Low'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStock {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategory == l10n.allCategory || _selectedCategory.isEmpty) return _stockData;
    
    // Map localized category names back to English for data filtering
    final categoryMap = {
      l10n.antibioticsCategory: 'Antibiotics',
      l10n.analgesicsCategory: 'Analgesics',
      l10n.antidiabeticCategory: 'Antidiabetic',
      l10n.cardiovascularCategory: 'Cardiovascular',
      l10n.respiratoryCategory: 'Respiratory',
    };
    
    final englishCategory = categoryMap[_selectedCategory] ?? _selectedCategory;
    return _stockData
        .where((item) => item['category'] == englishCategory)
        .toList();
  }

  Color _getStockStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Good':
        return context.successColor;
      case 'Low':
        return context.warningColor;
      case 'Critical':
        return context.errorColor;
      case 'Out':
        return context.iconColor;
      default:
        return context.iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    
    // Initialize selected category if not set
    if (_selectedCategory.isEmpty) {
      _selectedCategory = categories[0];
    }
    
    return Scaffold(
      appBar: AppHeader(
        title: l10n.stockManagementTitle,
        subtitle: l10n.monitorMedicationInventory,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: l10n.addStockTooltip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.adaptiveColor(
            lightColor: Colors.white,
            darkColor: Colors.white,
          ),
          unselectedLabelColor: context.adaptiveColor(
            lightColor: Colors.white70,
            darkColor: Colors.white60,
          ),
          indicatorColor: context.adaptiveColor(
            lightColor: Colors.white,
            darkColor: Colors.white,
          ),
          tabs: [
            Tab(text: l10n.overviewTab),
            Tab(text: l10n.alertsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildAlertsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refreshStock,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.syncELMIS),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    
    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  l10n.totalItems,
                  '${_stockData.length}',
                  Icons.inventory_2,
                  context.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  l10n.lowStock,
                  '${_getLowStockCount()}',
                  Icons.warning,
                  context.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  l10n.outOfStock,
                  '${_getOutOfStockCount()}',
                  Icons.error,
                  context.errorColor,
                ),
              ),
            ],
          ),
        ),

        // Category Filter
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),

        // Stock List
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStock.length,
                    itemBuilder: (context, index) {
                      final item = _filteredStock[index];
                      return _buildStockCard(item);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    final l10n = AppLocalizations.of(context)!;
    final alerts =
        _stockData.where((item) {
          return item['totalStock'] < item['lowStockThreshold'];
        }).toList();

    return alerts.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: context.successColor.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noStockAlerts,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.allMedicationsAdequatelyStocked,
                style: TextStyle(color: context.secondaryTextColor),
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final item = alerts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.errorColor.withOpacity(0.1),
                  child: Icon(
                    Icons.warning,
                    color: context.errorColor,
                  ),
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${l10n.totalStockLabel.replaceAll('{stock}', '${item['totalStock']}')}\n${l10n.thresholdLabel.replaceAll('{threshold}', '${item['lowStockThreshold']}')}',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showReorderDialog(item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.errorColor,
                  ),
                  child: Text(l10n.reorderButton),
                ),
              ),
            );
          },
        );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: context.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> item) {
    final totalStock = item['totalStock'] as int;
    final threshold = item['lowStockThreshold'] as int;
    final stockPercentage = (totalStock / threshold * 100).clamp(0, 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              totalStock < threshold
                  ? context.errorColor.withOpacity(0.1)
                  : context.successColor.withOpacity(0.1),
          child: Icon(
            Icons.medication,
            color: totalStock < threshold ? context.errorColor : context.successColor,
          ),
        ),
        title: Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item['category']),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: stockPercentage / 100,
                    backgroundColor: context.containerColor,
                    color: totalStock < threshold ? context.errorColor : context.successColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalStock units',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.stockByLocation,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...List.generate((item['locations'] as List).length, (index) {
                  final location = item['locations'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(location['name'])),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStockStatusColor(
                              context,
                              location['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${location['stock']} units',
                            style: TextStyle(
                              color: _getStockStatusColor(context, location['status']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getLowStockCount() {
    return _stockData.where((item) {
      return item['totalStock'] < item['lowStockThreshold'] &&
          item['totalStock'] > 0;
    }).length;
  }

  int _getOutOfStockCount() {
    return _stockData.where((item) => item['totalStock'] == 0).length;
  }

  void _refreshStock() {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.stockDataSynchronized),
          backgroundColor: context.successColor,
        ),
      );
    });
  }

  void _showReorderDialog(Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.reorderMedicationTitle),
            content: Text(
              l10n.reorderMedicationMessage.replaceAll('{medication}', item['name']),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancelButton),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.reorderRequestSubmitted),
                      backgroundColor: context.successColor,
                    ),
                  );
                },
                child: Text(l10n.submitRequestButton),
              ),
            ],
          ),
    );
  }
}
