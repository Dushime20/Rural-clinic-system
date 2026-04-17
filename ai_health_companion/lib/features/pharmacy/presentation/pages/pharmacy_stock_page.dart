import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_header.dart';

class PharmacyStockPage extends StatefulWidget {
  const PharmacyStockPage({super.key});

  @override
  State<PharmacyStockPage> createState() => _PharmacyStockPageState();
}

class _PharmacyStockPageState extends State<PharmacyStockPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Antibiotics',
    'Analgesics',
    'Antidiabetic',
    'Cardiovascular',
    'Respiratory',
  ];

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
    if (_selectedCategory == 'All') return _stockData;
    return _stockData
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'Good':
        return Colors.green;
      case 'Low':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      case 'Out':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Stock Management',
        subtitle: 'Monitor medication inventory',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: 'Add Stock',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Alerts')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildAlertsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refreshStock,
        icon: const Icon(Icons.refresh),
        label: const Text('Sync e-LMIS'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Summary Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Items',
                  '${_stockData.length}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Low Stock',
                  '${_getLowStockCount()}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Out of Stock',
                  '${_getOutOfStockCount()}',
                  Icons.error,
                  Colors.red,
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
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
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
    final alerts =
        _stockData.where((item) {
          return item['totalStock'] < item['lowStockThreshold'];
        }).toList();

    return alerts.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
              const SizedBox(height: 16),
              const Text(
                'No Stock Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'All medications are adequately stocked',
                style: TextStyle(color: Colors.grey[600]),
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
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.warning, color: Colors.red[700]),
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Total Stock: ${item['totalStock']} units\nThreshold: ${item['lowStockThreshold']} units',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showReorderDialog(item);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reorder'),
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              totalStock < threshold ? Colors.red[100] : Colors.green[100],
          child: Icon(
            Icons.medication,
            color: totalStock < threshold ? Colors.red[700] : Colors.green[700],
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
                    backgroundColor: Colors.grey[300],
                    color: totalStock < threshold ? Colors.red : Colors.green,
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
                const Text(
                  'Stock by Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              location['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${location['stock']} units',
                            style: TextStyle(
                              color: _getStockStatusColor(location['status']),
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
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock data synchronized with e-LMIS'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showReorderDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reorder Medication'),
            content: Text(
              'Would you like to create a reorder request for ${item['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reorder request submitted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
    );
  }
}
