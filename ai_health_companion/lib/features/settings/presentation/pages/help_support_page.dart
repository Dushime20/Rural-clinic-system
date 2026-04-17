import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class HelpSupportPage extends ConsumerStatefulWidget {
  const HelpSupportPage({super.key});

  @override
  ConsumerState<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends ConsumerState<HelpSupportPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How does AI diagnosis work?',
      'answer':
          'The AI diagnosis feature uses machine learning models trained on medical data to analyze symptoms, vital signs, and patient information to provide probable disease predictions with confidence scores.',
      'category': 'AI Diagnosis',
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'Yes! The app is designed to work offline. All patient data and AI models are stored locally on your device. Data will automatically sync when you\'re back online.',
      'category': 'Offline Mode',
    },
    {
      'question': 'How do I add a new patient?',
      'answer':
          'Go to the Patients tab and tap the "+" button or "Add Patient" button. Fill out the patient information form with personal, medical, and contact details.',
      'category': 'Patient Management',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Yes, all patient data is encrypted and stored securely. The app complies with healthcare privacy standards and uses end-to-end encryption.',
      'category': 'Security',
    },
    {
      'question': 'How do I sync my data?',
      'answer':
          'Data syncs automatically when you have an internet connection. You can also manually sync by going to the Sync Status page and tapping "Sync Now".',
      'category': 'Data Sync',
    },
    {
      'question': 'Can I export patient reports?',
      'answer':
          'Yes, you can export diagnosis reports and patient data. Use the export button in the diagnosis results or patient details pages.',
      'category': 'Reports',
    },
    {
      'question': 'What if the AI diagnosis is wrong?',
      'answer':
          'The AI provides suggestions based on symptoms, but always consult with qualified healthcare professionals for final diagnosis and treatment decisions.',
      'category': 'AI Diagnosis',
    },
    {
      'question': 'How do I update patient information?',
      'answer':
          'Go to the patient\'s detail page and tap the edit button. You can update any patient information including medical history and contact details.',
      'category': 'Patient Management',
    },
  ];

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': 'Getting Started',
      'description': 'Learn the basics of using the AI Health Companion app',
      'icon': Icons.play_circle_outline,
      'color': AppTheme.primaryColor,
    },
    {
      'title': 'AI Diagnosis',
      'description': 'How to perform AI-powered disease diagnosis',
      'icon': Icons.psychology,
      'color': AppTheme.secondaryColor,
    },
    {
      'title': 'Patient Management',
      'description': 'Adding and managing patient records',
      'icon': Icons.people,
      'color': AppTheme.accentColor,
    },
    {
      'title': 'Offline Mode',
      'description': 'Working without internet connection',
      'icon': Icons.cloud_off,
      'color': AppTheme.warningColor,
    },
    {
      'title': 'Data Sync',
      'description': 'Synchronizing data with cloud servers',
      'icon': Icons.sync,
      'color': AppTheme.successColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'Help & Support',
        subtitle: 'Get help and learn more',
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support),
            onPressed: _contactSupport,
            tooltip: 'Contact Support',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
            Tab(text: 'Tutorials', icon: Icon(Icons.play_circle_outline)),
            Tab(text: 'Contact', icon: Icon(Icons.contact_support)),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFAQTab(),
                  _buildTutorialsTab(),
                  _buildContactTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQTab() {
    final filteredFAQs =
        _faqItems.where((faq) {
          return faq['question'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              faq['answer'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              faq['category'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search FAQ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // FAQ List
        Expanded(
          child:
              filteredFAQs.isEmpty
                  ? _buildEmptyState('No FAQ items found')
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFAQs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildFAQCard(faq),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              faq['category'],
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Tutorials',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn how to use the app with step-by-step guides',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          ..._tutorialSteps.map((tutorial) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTutorialCard(tutorial),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _startTutorial(tutorial),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tutorial['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  tutorial['icon'],
                  color: tutorial['color'],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow, color: tutorial['color'], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Support',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Need help? Contact our support team',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Contact Methods
          _buildContactMethod(
            'Email Support',
            'Send us an email and we\'ll respond within 24 hours',
            Icons.email,
            AppTheme.primaryColor,
            () => _sendEmail(),
          ),

          const SizedBox(height: 16),

          _buildContactMethod(
            'Phone Support',
            'Call our support line for immediate assistance',
            Icons.phone,
            AppTheme.successColor,
            () => _makePhoneCall(),
          ),

          const SizedBox(height: 16),

          _buildContactMethod(
            'Live Chat',
            'Chat with our support team in real-time',
            Icons.chat,
            AppTheme.accentColor,
            () => _startLiveChat(),
          ),

          const SizedBox(height: 24),

          // Support Hours
          _buildSupportHours(),

          const SizedBox(height: 24),

          // Report Issue
          _buildReportIssue(),
        ],
      ),
    );
  }

  Widget _buildContactMethod(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportHours() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Support Hours',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildHoursRow('Monday - Friday', '9:00 AM - 6:00 PM'),
          _buildHoursRow('Saturday', '10:00 AM - 4:00 PM'),
          _buildHoursRow('Sunday', 'Closed'),
          _buildHoursRow('Emergency', '24/7 via email'),
        ],
      ),
    );
  }

  Widget _buildHoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            hours,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIssue() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: AppTheme.errorColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Report an Issue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Found a bug or experiencing issues? Report it to help us improve the app.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reportIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.report),
              label: const Text('Report Issue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _startTutorial(Map<String, dynamic> tutorial) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${tutorial['title']} Tutorial'),
            content: Text(
              'Interactive tutorial for "${tutorial['title']}" will be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Starting ${tutorial['title']} tutorial...',
                      ),
                      backgroundColor: tutorial['color'],
                    ),
                  );
                },
                child: const Text('Start Tutorial'),
              ),
            ],
          ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Support'),
            content: const Text(
              'How would you like to contact our support team?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendEmail();
                },
                child: const Text('Email'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _makePhoneCall();
                },
                child: const Text('Call'),
              ),
            ],
          ),
    );
  }

  void _sendEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening phone dialer...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _startLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting live chat...'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Issue'),
            content: const Text(
              'Issue reporting form will be implemented here.',
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
                      content: Text('Issue reported successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }
}
