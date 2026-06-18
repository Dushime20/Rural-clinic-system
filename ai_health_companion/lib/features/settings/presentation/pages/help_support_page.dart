import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';

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

  List<Map<String, dynamic>> _getFAQItems(AppLocalizations l10n) {
    return [
      {
        'question': l10n.faqHowDoesAIDiagnosisWork,
        'answer': l10n.faqAIDiagnosisAnswer,
        'category': l10n.faqCategoryAIDiagnosis,
      },
      {
        'question': l10n.faqHowDoIAddNewPatient,
        'answer': l10n.faqAddNewPatientAnswer,
        'category': l10n.faqCategoryPatientManagement,
      },
      {
        'question': l10n.faqIsMyDataSecure,
        'answer': l10n.faqDataSecurityAnswer,
        'category': l10n.faqCategorySecurity,
      },
      {
        'question': l10n.faqCanIExportPatientReports,
        'answer': l10n.faqExportReportsAnswer,
        'category': l10n.faqCategoryReports,
      },
      {
        'question': l10n.faqWhatIfAIDiagnosisIsWrong,
        'answer': l10n.faqAIDiagnosisWrongAnswer,
        'category': l10n.faqCategoryAIDiagnosis,
      },
      {
        'question': l10n.faqHowDoIUpdatePatientInfo,
        'answer': l10n.faqUpdatePatientInfoAnswer,
        'category': l10n.faqCategoryPatientManagement,
      },
      {
        'question': l10n.faqHowDoIFindNearbyPharmacies,
        'answer': l10n.faqFindNearbyPharmaciesAnswer,
        'category': l10n.faqCategoryPharmacies,
      },
    ];
  }

  List<Map<String, dynamic>> _getTutorialSteps(AppLocalizations l10n) {
    return [
      {
        'title': l10n.gettingStarted,
        'description': l10n.gettingStartedDescription,
        'icon': Icons.play_circle_outline,
        'color': AppTheme.primaryColor,
      },
      {
        'title': l10n.aiDiagnosisTutorial,
        'description': l10n.aiDiagnosisTutorialDescription,
        'icon': Icons.psychology,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': l10n.patientManagementTutorial,
        'description': l10n.patientManagementTutorialDescription,
        'icon': Icons.people,
        'color': AppTheme.accentColor,
      },
      {
        'title': l10n.pharmacyFinderTutorial,
        'description': l10n.pharmacyFinderTutorialDescription,
        'icon': Icons.local_pharmacy,
        'color': AppTheme.successColor,
      },
    ];
  }

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: l10n.helpSupportTitle,
        subtitle: l10n.getHelpLearnMore,
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support),
            onPressed: _contactSupport,
            tooltip: l10n.contactSupportTooltip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.faqTab, icon: const Icon(Icons.help_outline)),
            Tab(text: l10n.tutorialsTab, icon: const Icon(Icons.play_circle_outline)),
            Tab(text: l10n.contactTab, icon: const Icon(Icons.contact_support)),
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
    final l10n = AppLocalizations.of(context)!;
    final faqItems = _getFAQItems(l10n);
    
    final filteredFAQs =
        faqItems.where((faq) {
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
              hintText: l10n.searchFAQ,
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
              fillColor: context.surfaceColor,
            ),
          ),
        ),

        // FAQ List
        Expanded(
          child:
              filteredFAQs.isEmpty
                  ? _buildEmptyState(l10n.noFAQItemsFound)
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
    final l10n = AppLocalizations.of(context)!;
    final tutorialSteps = _getTutorialSteps(l10n);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.interactiveTutorials,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.learnHowToUseApp,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          ...tutorialSteps.map((tutorial) {
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
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getSupport,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.needHelpContactSupport,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Contact Methods
          _buildContactMethod(
            l10n.emailSupport,
            l10n.emailSupportDescription,
            Icons.email,
            AppTheme.primaryColor,
            () => _sendEmail(),
          ),

          const SizedBox(height: 16),

          _buildContactMethod(
            l10n.phoneSupport,
            l10n.phoneSupportDescription,
            Icons.phone,
            AppTheme.successColor,
            () => _makePhoneCall(),
          ),

          const SizedBox(height: 16),

          _buildContactMethod(
            l10n.liveChat,
            l10n.liveChatDescription,
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
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
                l10n.supportHours,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildHoursRow(l10n.mondayFriday, l10n.mondayFridayHours),
          _buildHoursRow(l10n.saturday, l10n.saturdayHours),
          _buildHoursRow(l10n.sunday, l10n.sundayClosed),
          _buildHoursRow(l10n.emergency, l10n.emergency24x7),
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
    final l10n = AppLocalizations.of(context)!;
    
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
                l10n.reportAnIssue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.foundBugReportIt,
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
                foregroundColor: context.adaptiveColor(
                  lightColor: Colors.white,
                  darkColor: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.report),
              label: Text(l10n.reportIssue),
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
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.tutorialDialogTitle(tutorial['title'])),
            content: Text(
              l10n.tutorialWillBeImplemented(tutorial['title']),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.closeTutorial),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.startingTutorial(tutorial['title']),
                      ),
                      backgroundColor: tutorial['color'],
                    ),
                  );
                },
                child: Text(l10n.startTutorial),
              ),
            ],
          ),
    );
  }

  void _contactSupport() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.contactSupportDialog),
            content: Text(
              l10n.howToContactSupport,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendEmail();
                },
                child: Text(l10n.emailButton),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _makePhoneCall();
                },
                child: Text(l10n.callButton),
              ),
            ],
          ),
    );
  }

  void _sendEmail() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.openingEmailClient),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _makePhoneCall() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.openingPhoneDialer),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _startLiveChat() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.startingLiveChat),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _reportIssue() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.reportIssueDialog),
            content: Text(
              l10n.issueReportingFormWillBeImplemented,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.issueReportedSuccessfully),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: Text(l10n.submitButton),
              ),
            ],
          ),
    );
  }
}
