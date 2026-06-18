import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/l10n/disease_name_translations.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/models/diagnosis_models.dart';
import '../../data/models/clinic_models.dart';
import '../widgets/clinic_recommendation_card.dart';
import '../widgets/pattern_analysis_notice.dart';
import '../widgets/clinic_specialty_filter.dart';
import '../../../../core/theme/theme_extensions.dart';

class DiagnosisResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> diagnosisData;
  const DiagnosisResultPage({super.key, required this.diagnosisData});

  @override
  ConsumerState<DiagnosisResultPage> createState() =>
      _DiagnosisResultPageState();
}

class _DiagnosisResultPageState extends ConsumerState<DiagnosisResultPage> {
  DiagnosisResponse? _diagnosis;
  Map<String, dynamic>? _patient;
  List<NearbyPharmacy> _nearbyPharmacies = [];
  bool _isGeneratingPdf = false;
  bool _isHistorical = false; // Flag to indicate historical diagnosis
  
  // Translation state
  Map<String, dynamic>? _translatedReport;
  Map<String, String>? _translatedDiseaseNames; // Map of English -> Kinyarwanda disease names
  bool _isTranslating = false;
  bool _translationFailed = false;
  
  // Clinic filter state
  List<String> _selectedSpecialties = [];
  List<ClinicRecommendation> get _filteredClinics {
    final clinics = _diagnosis?.recommendations?.clinics ?? [];
    if (_selectedSpecialties.isEmpty) return clinics;
    return clinics
        .where(
          (clinic) => clinic.specialties.any(
            (s) => _selectedSpecialties.contains(s),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _extractData();
    // Check and translate if needed after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndTranslate();
    });
  }

  Future<void> _checkAndTranslate() async {
    final locale = Localizations.localeOf(context);
    
    // Only translate if user selected Kinyarwanda
    if (locale.languageCode == 'rw' && _diagnosis != null) {
      await _translateReport();
    }
  }

  Future<void> _translateReport() async {
    if (_diagnosis == null) return;
    
    setState(() {
      _isTranslating = true;
      _translationFailed = false;
    });
    
    try {
      final diagnosisId = _diagnosis!.id;
      
      // Use ApiService with automatic auth token
      // Translation can take 2-3+ minutes for large reports with prescriptions
      final apiService = ApiService();
      final response = await apiService.get(
        '/diagnosis/$diagnosisId/translate',
        options: Options(
          receiveTimeout: const Duration(seconds: 180), // 3 minutes for translation
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final result = response.data;
        if (result['success'] == true && result['translated'] != null) {
          setState(() {
            _translatedReport = result['translated'] as Map<String, dynamic>;
            _translatedDiseaseNames = (result['translatedDiseaseNames'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(key, value.toString())) ?? {};
            _isTranslating = false;
          });
          
          // Initialize global disease name translations
          if (_translatedDiseaseNames != null && _translatedDiseaseNames!.isNotEmpty) {
            DiseaseNameTranslations().initialize(_translatedDiseaseNames);
          }
        } else {
          throw Exception('Translation response invalid');
        }
      } else if (response.statusCode == 503) {
        // Service unavailable - translation service down
        debugPrint('Translation service unavailable');
        setState(() {
          _isTranslating = false;
          _translationFailed = true;
        });
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Translation API error: ${e.message}');
      debugPrint('Status code: ${e.response?.statusCode}');
      if (e.response?.statusCode == 503) {
        debugPrint('Translation service unavailable');
      } else if (e.response?.statusCode == 401) {
        debugPrint('Authentication error - user not logged in');
      }
      setState(() {
        _isTranslating = false;
        _translationFailed = true;
      });
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() {
        _isTranslating = false;
        _translationFailed = true;
      });
    }
  }

  /// Get display text based on locale - returns translated or original
  String _getDisplayText(String originalText, String? translatedText) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'rw' && translatedText != null && translatedText.isNotEmpty) {
      return translatedText;
    }
    return originalText;
  }

  /// Get translated disease name (for all predictions, not just primary)
  String _getTranslatedDiseaseName(String englishName) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'rw' && _translatedDiseaseNames != null) {
      return _translatedDiseaseNames![englishName] ?? englishName;
    }
    return englishName;
  }

  /// Get display list based on locale - returns translated or original
  List<String> _getDisplayList(List<String> originalList, List<dynamic>? translatedList) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'rw' && translatedList != null && translatedList.isNotEmpty) {
      return translatedList.cast<String>();
    }
    return originalList;
  }

  void _extractData() {
    try {
      final diagnosisRaw = widget.diagnosisData['diagnosis'];
      if (diagnosisRaw is DiagnosisResponse) {
        _diagnosis = diagnosisRaw;
      } else if (diagnosisRaw is Map<String, dynamic>) {
        _diagnosis = DiagnosisResponse.fromJson(diagnosisRaw);
      }

      final patientRaw = widget.diagnosisData['patient'];
      if (patientRaw is Map<String, dynamic>) {
        _patient = patientRaw;
      } else if (patientRaw is Map) {
        _patient = Map<String, dynamic>.from(patientRaw);
      }

      final pharmaciesRaw = widget.diagnosisData['nearbyPharmacies'];
      if (pharmaciesRaw is List) {
        _nearbyPharmacies =
            pharmaciesRaw.map((p) {
              if (p is NearbyPharmacy) return p;
              return NearbyPharmacy.fromJson(p as Map<String, dynamic>);
            }).toList();
      }

      // Check if this is a historical diagnosis
      _isHistorical = widget.diagnosisData['isHistorical'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error extracting diagnosis data: $e');
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String get _patientName {
    if (_patient == null) return 'Unknown';
    return '${_patient!['firstName'] ?? ''} ${_patient!['lastName'] ?? ''}'
        .trim();
  }

  int get _patientAge {
    final dob = _patient?['dateOfBirth'];
    if (dob == null) return 0;
    try {
      return DateTime.now().difference(DateTime.parse(dob.toString())).inDays ~/
          365;
    } catch (_) {
      return 0;
    }
  }

  String get _patientGender => (_patient?['gender'] ?? '—').toString();

  String get _patientPhone =>
      (_patient?['phoneNumber'] ?? _patient?['phone'] ?? '—').toString();

  String get _diagnosisDate {
    if (_diagnosis == null) return '—';
    return DateFormat('dd MMM yyyy, HH:mm').format(_diagnosis!.diagnosisDate);
  }

  AIPrediction? get _topPrediction =>
      _diagnosis?.aiPredictions.isNotEmpty == true
          ? _diagnosis!.aiPredictions.first
          : null;

  Color _confidenceColor(double c) {
    if (c >= 0.7) return Colors.green;
    if (c >= 0.4) return Colors.orange;
    return Colors.red;
  }

  // ── PDF generation ────────────────────────────────────────────────────────

  Future<File> _buildPdf() async {
    final pdf = pw.Document();
    final top = _topPrediction;
    final date = _diagnosisDate;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AI Health Companion',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Diagnosis Report — $date',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Divider(),
              ],
            ),
        build:
            (_) => [
              // Patient info
              pw.Text(
                'Patient Information',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                data: [
                  ['Name', _patientName],
                  ['Age', '$_patientAge years'],
                  ['Gender', _patientGender],
                  ['Phone', _patientPhone],
                ],
                cellStyle: const pw.TextStyle(fontSize: 11),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),

              // Primary diagnosis
              if (top != null) ...[
                pw.Text(
                  'Primary Diagnosis',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table.fromTextArray(
                  data: [
                    ['Disease', top.disease],
                    [
                      'Confidence',
                      '${(top.confidence * 100).toStringAsFixed(1)}%',
                    ],
                    ['ICD-10', top.icd10Code ?? '—'],
                  ],
                  cellStyle: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 16),
              ],

              // Other predictions
              if ((_diagnosis?.aiPredictions.length ?? 0) > 1) ...[
                pw.Text(
                  'Differential Diagnoses',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table.fromTextArray(
                  headers: ['Disease', 'Confidence', 'ICD-10'],
                  data:
                      _diagnosis!.aiPredictions
                          .skip(1)
                          .map(
                            (p) => [
                              p.disease,
                              '${(p.confidence * 100).toStringAsFixed(1)}%',
                              p.icd10Code ?? '—',
                            ],
                          )
                          .toList(),
                  cellStyle: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 16),
              ],

              // Recommendations
              if (top?.recommendations?.isNotEmpty == true) ...[
                pw.Text(
                  'Recommendations',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...top!.recommendations!.map(
                  (r) => pw.Bullet(
                    text: r,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // Description
              if (top?.description != null) ...[
                pw.Text(
                  'About This Condition',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  top!.description!,
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 16),
              ],

              // Diet
              if (top?.diet?.isNotEmpty == true) ...[
                pw.Text(
                  'Recommended Diet',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...top!.diet!.map(
                  (d) => pw.Bullet(
                    text: d,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // Workout
              if (top?.workout?.isNotEmpty == true) ...[
                pw.Text(
                  'Lifestyle & Exercise',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...top!.workout!.map(
                  (w) => pw.Bullet(
                    text: w,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // Prescriptions
              if (_diagnosis?.prescriptions?.isNotEmpty == true) ...[
                pw.Text(
                  'Prescriptions',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table.fromTextArray(
                  headers: ['Medication', 'Dosage', 'Frequency', 'Duration'],
                  data:
                      _diagnosis!.prescriptions!
                          .map(
                            (p) => [
                              p.medication,
                              p.dosage,
                              p.frequency,
                              p.duration,
                            ],
                          )
                          .toList(),
                  cellStyle: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 16),
              ],

              // Pharmacies
              if (_nearbyPharmacies.isNotEmpty) ...[
                pw.Text(
                  'Nearby Pharmacies',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table.fromTextArray(
                  headers: ['Pharmacy', 'Distance', 'Phone'],
                  data:
                      _nearbyPharmacies
                          .map(
                            (ph) => [
                              ph.name,
                              ph.distanceText,
                              ph.phoneNumber ?? '—',
                            ],
                          )
                          .toList(),
                  cellStyle: const pw.TextStyle(fontSize: 11),
                ),
              ],

              pw.SizedBox(height: 24),
              pw.Text(
                'This report is AI-generated and must be reviewed by a qualified clinician.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/diagnosis_${_diagnosis?.diagnosisId ?? 'report'}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isGeneratingPdf = true);
    try {
      final file = await _buildPdf();
      await Printing.layoutPdf(
        onLayout: (_) async => file.readAsBytesSync(),
        name: 'Diagnosis_${_diagnosis?.diagnosisId ?? 'report'}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfError('$e')),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _shareReport(String method) async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isGeneratingPdf = true);
    try {
      final file = await _buildPdf();
      final xFile = XFile(file.path, mimeType: 'application/pdf');
      final top = _topPrediction;
      final text =
          'Diagnosis Report for $_patientName\n'
          'Date: $_diagnosisDate\n'
          'Primary Diagnosis: ${top?.disease ?? '—'} '
          '(${((top?.confidence ?? 0) * 100).toStringAsFixed(1)}%)\n'
          'ICD-10: ${top?.icd10Code ?? '—'}\n\n'
          'Generated by AI Health Companion';

      if (method == 'whatsapp') {
        final phone = _patientPhone.replaceAll(RegExp(r'[^\d+]'), '');
        final encoded = Uri.encodeComponent(text);
        final uri = Uri.parse('https://wa.me/$phone?text=$encoded');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // fallback: share sheet
          await Share.shareXFiles([xFile], text: text);
        }
      } else if (method == 'email') {
        final subject = Uri.encodeComponent('Diagnosis Report — $_patientName');
        final body = Uri.encodeComponent(text);
        final uri = Uri.parse('mailto:?subject=$subject&body=$body');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await Share.shareXFiles(
            [xFile],
            text: text,
            subject: 'Diagnosis Report — $_patientName',
          );
        }
      } else {
        await Share.shareXFiles(
          [xFile],
          text: text,
          subject: 'Diagnosis Report — $_patientName',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareError('$e')),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _showShareSheet() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.shareReport,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.adaptiveColor(
                        lightColor: const Color(0xFF25D366),
                        darkColor: const Color(0xFF128C7E),
                      ),
                      child: Icon(
                        Icons.chat,
                        color: context.adaptiveColor(
                          lightColor: Colors.white,
                          darkColor: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(l10n.whatsapp),
                    subtitle: Text(l10n.sendToPatientWhatsapp),
                    onTap: () {
                      Navigator.pop(context);
                      _shareReport('whatsapp');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.infoColor,
                      child: Icon(Icons.email, color: Colors.white),
                    ),
                    title: Text(l10n.emailLabel),
                    subtitle: Text(l10n.sendViaEmail),
                    onTap: () {
                      Navigator.pop(context);
                      _shareReport('email');
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    title: Text(l10n.other),
                    subtitle: Text(l10n.shareViaAnyApp),
                    onTap: () {
                      Navigator.pop(context);
                      _shareReport('other');
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_diagnosis == null) {
      return Scaffold(
        appBar: AppHeader(title: l10n.diagnosisResults, subtitle: ''),
        body: Center(child: Text(l10n.noDiagnosisData)),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppHeader(
        title: l10n.diagnosisReport,
        subtitle: _diagnosis!.diagnosisId,
        actions: [
          if (_isGeneratingPdf)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: l10n.downloadPDF,
              onPressed: _downloadPdf,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.share,
              onPressed: _showShareSheet,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translation loading indicator
            if (_isTranslating) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translatingToKinyarwanda,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Translation failed notice
            if (_translationFailed) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translationFailed,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Historical diagnosis indicator
            if (_isHistorical) _buildHistoricalDiagnosisNotice(),
            if (_isHistorical) const SizedBox(height: 16),
            _buildPatientCard(),
            const SizedBox(height: 16),
            _buildPrimaryDiagnosisCard(),
            if ((_diagnosis!.aiPredictions.length) > 1) ...[
              const SizedBox(height: 16),
              _buildDifferentialCard(),
            ],
            const SizedBox(height: 16),
            _buildRecommendationsCard(),
            if (_topPrediction?.description != null) ...[
              const SizedBox(height: 16),
              _buildDescriptionCard(),
            ],
            if (_topPrediction?.diet?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildListCard(
                l10n.recommendedDiet,
                Icons.restaurant,
                Colors.orange,
                _getDisplayList( // Use translated list
                  _topPrediction!.diet!,
                  _translatedReport?['diet'] as List<dynamic>?,
                ),
              ),
            ],
            if (_topPrediction?.workout?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildListCard(
                l10n.lifestyleAndExercise,
                Icons.fitness_center,
                Colors.blue,
                _getDisplayList( // Use translated list
                  _topPrediction!.workout!,
                  _translatedReport?['workout'] as List<dynamic>?,  // Fixed: use 'workout' key
                ),
              ),
            ],
            if (_diagnosis!.prescriptions?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildPrescriptionsCard(),
            ],
            // Pharmacy recommendations section (hide for historical diagnoses)
            if (!_isHistorical && _diagnosis!.prescriptions?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              if (_nearbyPharmacies.isNotEmpty)
                _buildPharmaciesCard()
              else
                _buildNoPharmaciesCard(),
            ],
            // Clinic recommendations section (NEW)
            if (_diagnosis!.hasClinicsRecommended) ...[
              const SizedBox(height: 16),
              // Pattern analysis notice (if applicable)
              if (_diagnosis!.hasPatternAnalysis)
                PatternAnalysisNotice(
                  patternAnalysis: _diagnosis!.patternAnalysis!,
                ),
              const SizedBox(height: 16),
              // Specialty filter (only show if there are clinics to filter)
              if (_diagnosis!.hasClinics)
                ClinicSpecialtyFilter(
                  clinics: _diagnosis!.recommendations!.clinics!,
                  selectedSpecialties: _selectedSpecialties,
                  onFilterChanged: (selected) {
                    setState(() {
                      _selectedSpecialties = selected;
                    });
                  },
                ),
              if (_diagnosis!.hasClinics)
                const SizedBox(height: 8),
              _buildClinicsCard(),
            ],
            const SizedBox(height: 16),
            _buildDisclaimerCard(),
            const SizedBox(height: 16),
            _buildActionRow(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── section cards ─────────────────────────────────────────────────────────

  Widget _buildHistoricalDiagnosisNotice() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historicalDiagnosis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.historicalDiagnosisNotice,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.chipBackground(color),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Patient card ──────────────────────────────────────────────────────────

  Widget _buildPatientCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return _buildSectionCard(
      title: l10n.patientInformation,
      icon: Icons.person,
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  _patientName.isNotEmpty ? _patientName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _patientName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_patientAge ${l10n.years} • $_patientGender',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.phone, _patientPhone),
          _buildInfoRow(l10n.diagnosisDate, _diagnosisDate),
          _buildInfoRow(l10n.reportID, _diagnosis?.diagnosisId ?? '—'),
        ],
      ),
    );
  }

  // ── Primary diagnosis card ────────────────────────────────────────────────

  Widget _buildPrimaryDiagnosisCard() {
    final l10n = AppLocalizations.of(context)!;
    final top = _topPrediction;
    if (top == null) return const SizedBox.shrink();
    final color = _confidenceColor(top.confidence);
    final pct = (top.confidence * 100).toStringAsFixed(1);

    // Disease name - use translated version if available
    final displayDisease = _getTranslatedDiseaseName(top.disease);

    return _buildSectionCard(
      title: l10n.primaryDiagnosis,
      icon: Icons.medical_services,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  displayDisease, // Always English for medical accuracy
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (top.icd10Code != null) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.icd10}: ${top.icd10Code}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Confidence bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.confidence,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    pct,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: top.confidence,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Differential diagnoses ────────────────────────────────────────────────

  Widget _buildDifferentialCard() {
    final l10n = AppLocalizations.of(context)!;
    final others = _diagnosis!.aiPredictions.skip(1).toList();
    return _buildSectionCard(
      title: l10n.differentialDiagnoses,
      icon: Icons.compare_arrows,
      color: Colors.orange,
      child: Column(
        children:
            others.map((p) {
              final pct = (p.confidence * 100).toStringAsFixed(1);
              final color = _confidenceColor(p.confidence);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTranslatedDiseaseName(p.disease),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (p.icd10Code != null)
                            Text(
                              '${l10n.icd10}: ${p.icd10Code}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── Recommendations ───────────────────────────────────────────────────────

  Widget _buildRecommendationsCard() {
    final l10n = AppLocalizations.of(context)!;
    final recs = _topPrediction?.recommendations ?? [];
    if (recs.isEmpty) return const SizedBox.shrink();
    
    // Get translated recommendations (they map to precautions in backend)
    final displayRecs = _getDisplayList(
      recs,
      _translatedReport?['precautions'] as List<dynamic>?,
    );
    
    return _buildSectionCard(
      title: l10n.recommendations,
      icon: Icons.lightbulb_outline,
      color: Colors.teal,
      child: Column(
        children:
            displayRecs // Use translated list
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(r, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // ── Prescriptions ─────────────────────────────────────────────────────────

  Widget _buildPrescriptionsCard() {
    final l10n = AppLocalizations.of(context)!;
    final prescriptions = _diagnosis!.prescriptions!;
    final translatedPrescriptions = _translatedReport?['prescriptions'] as List<dynamic>?;
    
    return _buildSectionCard(
      title: l10n.prescriptions,
      icon: Icons.medication,
      color: Colors.purple,
      child: Column(
        children:
            prescriptions.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              
              // Get translated values if available
              final translatedPrescription = translatedPrescriptions != null && 
                                             index < translatedPrescriptions.length
                  ? translatedPrescriptions[index] as Map<String, dynamic>
                  : null;
              
              final dosage = translatedPrescription?['dosage'] ?? p.dosage;
              final frequency = translatedPrescription?['frequency'] ?? p.frequency;
              final duration = translatedPrescription?['duration'] ?? p.duration;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.medication,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(l10n.dosage, dosage),
                    _buildInfoRow(l10n.frequency, frequency),
                    _buildInfoRow(l10n.duration, duration),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── Pharmacies ────────────────────────────────────────────────────────────

  Widget _buildPharmaciesCard() {
    final l10n = AppLocalizations.of(context)!;
    // Calculate total prescribed medicines for "Has all" badge
    final totalPrescribedMedicines = _diagnosis?.prescriptions?.length ?? 0;
    
    return _buildSectionCard(
      title: l10n.nearbyPharmacies,
      icon: Icons.local_pharmacy,
      color: Colors.green,
      child: Column(
        children:
            _nearbyPharmacies.map((ph) {
              // Check if pharmacy has all prescribed medicines
              final hasAllMedicines = totalPrescribedMedicines > 0 && 
                                      ph.medicines.length == totalPrescribedMedicines;
              
              return InkWell(
                onTap: () => _showPharmacyDetails(ph),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hasAllMedicines 
                        ? Colors.green.withValues(alpha: 0.08)  // Highlight if has all
                        : Colors.green.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasAllMedicines
                          ? Colors.green.withValues(alpha: 0.4)  // Stronger border if has all
                          : Colors.green.withValues(alpha: 0.2),
                      width: hasAllMedicines ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(
                            Icons.local_pharmacy,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ph.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // "Has all medicines" badge
                                if (hasAllMedicines) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.hasAllMedicines,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ph.distanceText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ph.fullAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Available medicines
                    if (ph.medicines.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.availableMedicines,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${ph.medicines.length}/${totalPrescribedMedicines}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasAllMedicines ? Colors.green.shade700 : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...ph.medicines.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.displayName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (m.strength != null)
                                      Text(
                                        m.strength!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    m.priceText,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          m.isAvailable
                                              ? Colors.green.withValues(
                                                alpha: 0.12,
                                              )
                                              : Colors.red.withValues(
                                                alpha: 0.12,
                                              ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      m.stockText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            m.isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Action buttons
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (ph.phoneNumber != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  final uri = Uri.parse('tel:${ph.phoneNumber}');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.cannotOpenDialer),
                                          backgroundColor: context.errorColor,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Error launching phone dialer: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${l10n.error}: $e'),
                                        backgroundColor: context.errorColor,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.phone, size: 16),
                              label: Text(l10n.call),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        if (ph.phoneNumber != null) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final uri = Uri.parse(
                                  'https://maps.google.com/?q=${ph.latitude},${ph.longitude}',
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.cannotOpenMaps),
                                        backgroundColor: context.errorColor,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                debugPrint('Error launching maps: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${l10n.error}: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.navigation, size: 16),
                            label: Text(l10n.navigate),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              );
            }).toList(),
      ),
    );
  }

  void _showPharmacyDetails(NearbyPharmacy pharmacy) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pharmacy name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pharmacy.isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.active,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Details
              _buildPharmacyDetailRow(
                Icons.location_on,
                l10n.address,
                pharmacy.fullAddress,
              ),
              const SizedBox(height: 12),
              if (pharmacy.distance != null)
                _buildPharmacyDetailRow(
                  Icons.directions,
                  l10n.distance,
                  pharmacy.distanceText,
                ),
              if (pharmacy.distance != null) const SizedBox(height: 12),
              if (pharmacy.phoneNumber != null)
                _buildPharmacyDetailRow(
                  Icons.phone,
                  l10n.phone,
                  pharmacy.phoneNumber!,
                ),
              if (pharmacy.phoneNumber != null) const SizedBox(height: 12),
              if (pharmacy.openingHours != null)
                _buildPharmacyDetailRow(
                  Icons.access_time,
                  l10n.openingHours,
                  pharmacy.openingHours!,
                ),
              if (pharmacy.openingHours != null) const SizedBox(height: 12),
              _buildPharmacyDetailRow(
                Icons.gps_fixed,
                l10n.coordinates,
                '${pharmacy.latitude.toStringAsFixed(4)}, ${pharmacy.longitude.toStringAsFixed(4)}',
              ),

              // Available medicines
              if (pharmacy.medicines.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.availableMedicines,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...pharmacy.medicines.map(
                  (m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.displayName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (m.strength != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  m.strength!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              m.priceText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: m.isAvailable
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                m.stockText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: m.isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (pharmacy.phoneNumber != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            final uri = Uri.parse('tel:${pharmacy.phoneNumber}');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          } catch (e) {
                            debugPrint('Error launching phone dialer: $e');
                          }
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(l10n.call),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (pharmacy.phoneNumber != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          final uri = Uri.parse(
                            'https://maps.google.com/?q=${pharmacy.latitude},${pharmacy.longitude}',
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          debugPrint('Error launching maps: $e');
                        }
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: Text(l10n.navigate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildPharmacyDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoPharmaciesCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return _buildSectionCard(
      title: l10n.pharmacyRecommendations,
      icon: Icons.local_pharmacy,
      color: Colors.orange,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.noNearbyPharmaciesFound,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noNearbyPharmaciesMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade800,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.suggestions}:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSuggestionItem(l10n.contactPharmaciesDirectly),
                _buildSuggestionItem(l10n.trySearchingPharmaciesTab),
                _buildSuggestionItem(l10n.considerAlternativeBrands),
                _buildSuggestionItem(l10n.checkBackLater),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/pharmacies');
              },
              icon: const Icon(Icons.local_pharmacy),
              label: Text(l10n.browseAllPharmacies),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.warningColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Clinic recommendations ────────────────────────────────────────────────

  Widget _buildClinicsCard() {
    final l10n = AppLocalizations.of(context)!;
    final clinics = _filteredClinics; // Use filtered clinics
    final totalClinics = _diagnosis?.recommendations?.clinics?.length ?? 0;
    final reason = _diagnosis?.recommendations?.clinicRecommendationReason;
    
    // Don't show anything if clinics weren't recommended at all
    if (_diagnosis?.recommendations?.clinics == null) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: l10n.clinicRecommendations,
      icon: Icons.local_hospital,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Historical diagnosis clinic search indicator
          if (_isHistorical) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.lightBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.lightBlue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.clinicLocationNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.lightBlue.shade900,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Explanation based on reason
          if (reason != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getClinicReasonExplanation(reason),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Show message if NO clinics found at all (empty array from backend)
          if (totalClinics == 0) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.amber.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_off_outlined,
                      size: 48,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSpecializedClinicsFound,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.noSpecializedClinicsMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l10n.suggestions}:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSuggestionItem(l10n.visitGeneralMedicineClinic),
                        _buildSuggestionItem(l10n.expandSearchRadius),
                        _buildSuggestionItem(l10n.contactPrimaryCareDoctor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show filtered message if filters are active
            if (_selectedSpecialties.isNotEmpty && clinics.length < totalClinics) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 18, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.showingClinicsFiltered(clinics.length, totalClinics),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Show message if no clinics match filter
            if (clinics.isEmpty && totalClinics > 0) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.filter_alt_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noClinicsMatchFilter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tryDifferentSpecialties,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              // Clinic cards
              ...clinics.map((clinic) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClinicRecommendationCard(clinic: clinic),
              )),
          ],
        ],
      ),
    );
  }

  String _getClinicReasonExplanation(String reason) {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if we have pharmacy recommendations
    // Use _nearbyPharmacies list (populated by Flutter) instead of backend recommendations
    final bool hasPharmacies = _nearbyPharmacies.isNotEmpty;
    final bool hasPharmacyRecommendations = _diagnosis?.recommendations?.pharmacies.isNotEmpty ?? false;
    
    // Normalize reason to handle both spaces and underscores
    final normalizedReason = reason.toLowerCase().replaceAll('_', ' ');
    
    // DEBUG: Print values to console
    debugPrint('=== CLINIC MESSAGE DEBUG ===');
    debugPrint('Reason from backend: $reason');
    debugPrint('Normalized reason: $normalizedReason');
    debugPrint('Has pharmacies (from _nearbyPharmacies): $hasPharmacies');
    debugPrint('Nearby pharmacies count: ${_nearbyPharmacies.length}');
    debugPrint('Backend pharmacies count: ${_diagnosis?.recommendations?.pharmacies.length ?? 0}');
    debugPrint('');
    debugPrint('Pattern checks:');
    debugPrint('  - Contains "persistent": ${normalizedReason.contains('persistent')}');
    debugPrint('  - Contains "recurring": ${normalizedReason.contains('recurring')}');
    debugPrint('  - Contains "chronic": ${normalizedReason.contains('chronic')}');
    debugPrint('  - Contains "no pharmacy": ${normalizedReason.contains('no pharmacy')}');
    debugPrint('==========================');
    
    // IMPORTANT: If backend says "no pharmacy" but we actually found pharmacies,
    // ignore that reason and use default message instead
    final shouldIgnoreNoPharmacyReason = normalizedReason.contains('no pharmacy') && hasPharmacies;
    
    if (shouldIgnoreNoPharmacyReason) {
      debugPrint('⚠️ Backend said no_pharmacy but pharmacies were found! Using default message.');
    }
    
    // Handle persistent/chronic conditions
    if (!shouldIgnoreNoPharmacyReason && normalizedReason.contains('persistent')) {
      if (hasPharmacies) {
        return l10n.persistentConditionMessage;
      }
      return l10n.persistentConditionNoPharmacyMessage;
    }
    
    // Handle recurring patterns
    if (!shouldIgnoreNoPharmacyReason && normalizedReason.contains('recurring')) {
      if (hasPharmacies) {
        return l10n.recurringPatternMessage;
      }
      return l10n.recurringPatternNoPharmacyMessage;
    }
    
    // Handle chronic conditions
    if (!shouldIgnoreNoPharmacyReason && normalizedReason.contains('chronic')) {
      if (hasPharmacies) {
        return l10n.chronicConditionMessage;
      }
      return l10n.chronicConditionNoPharmacyMessage;
    }
    
    // Handle no pharmacy found case (only if pharmacies were NOT actually found)
    if (!shouldIgnoreNoPharmacyReason && normalizedReason.contains('no pharmacy') && !hasPharmacies) {
      return l10n.noPharmacyFoundMessage;
    }
    
    // Default message - check if pharmacies are available
    if (hasPharmacies) {
      return l10n.defaultClinicMessage;
    }
    
    return l10n.defaultClinicNoPharmacyMessage;
  }

  // ── Disease description ───────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    final l10n = AppLocalizations.of(context)!;
    
    // Get translated description
    final displayDescription = _getDisplayText(
      _topPrediction!.description!,
      _translatedReport?['description'] as String?,
    );
    
    return _buildSectionCard(
      title: l10n.aboutThisCondition,
      icon: Icons.info_outline,
      color: Colors.indigo,
      child: Text(
        displayDescription, // Use translated text
        style: const TextStyle(fontSize: 13, height: 1.6),
      ),
    );
  }

  // ── Generic list card (diet / workout) ────────────────────────────────────

  Widget _buildListCard(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return _buildSectionCard(
      title: title,
      icon: icon,
      color: color,
      child: Column(
        children:
            items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_right, size: 18, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // ── Disclaimer ────────────────────────────────────────────────────────────

  Widget _buildDisclaimerCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.adaptiveColor(
          lightColor: Colors.amber.withValues(alpha: 0.08),
          darkColor: const Color(0xFF3A2E1E),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.adaptiveColor(
            lightColor: Colors.amber.withValues(alpha: 0.4),
            darkColor: const Color(0xFFFFB74D).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: context.adaptiveColor(
              lightColor: Colors.amber,
              darkColor: const Color(0xFFFFB74D),
            ),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.disclaimer,
              style: TextStyle(
                fontSize: 12,
                color: context.adaptiveColor(
                  lightColor: Colors.black87,
                  darkColor: const Color(0xFFE0E0E0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom action row ─────────────────────────────────────────────────────

  Widget _buildActionRow() {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/diagnosis'),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.newDiagnosis),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isGeneratingPdf ? null : _showShareSheet,
            icon: const Icon(Icons.share),
            label: Text(l10n.shareReport),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
