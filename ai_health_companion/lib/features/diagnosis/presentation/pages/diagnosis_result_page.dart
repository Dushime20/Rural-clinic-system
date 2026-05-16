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

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/models/diagnosis_models.dart';

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

  @override
  void initState() {
    super.initState();
    _extractData();
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
          SnackBar(content: Text('PDF error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _shareReport(String method) async {
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
            content: Text('Share error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _showShareSheet() {
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
                  const Text(
                    'Share Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF25D366),
                      child: Icon(Icons.chat, color: Colors.white),
                    ),
                    title: const Text('WhatsApp'),
                    subtitle: const Text("Send to patient's WhatsApp"),
                    onTap: () {
                      Navigator.pop(context);
                      _shareReport('whatsapp');
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.email, color: Colors.white),
                    ),
                    title: const Text('Email'),
                    subtitle: const Text('Send via email'),
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
                    title: const Text('Other'),
                    subtitle: const Text('Share via any app'),
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
    if (_diagnosis == null) {
      return Scaffold(
        appBar: AppHeader(title: 'Diagnosis Results', subtitle: ''),
        body: const Center(child: Text('No diagnosis data available')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'Diagnosis Report',
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
              tooltip: 'Download PDF',
              onPressed: _downloadPdf,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
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
                'Recommended Diet',
                Icons.restaurant,
                Colors.orange,
                _topPrediction!.diet!,
              ),
            ],
            if (_topPrediction?.workout?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildListCard(
                'Lifestyle & Exercise',
                Icons.fitness_center,
                Colors.blue,
                _topPrediction!.workout!,
              ),
            ],
            if (_diagnosis!.prescriptions?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildPrescriptionsCard(),
            ],
            // Pharmacy recommendations section
            if (_diagnosis!.prescriptions?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              if (_nearbyPharmacies.isNotEmpty)
                _buildPharmaciesCard()
              else
                _buildNoPharmaciesCard(),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
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
    return _buildSectionCard(
      title: 'Patient Information',
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
                      '$_patientAge yrs • $_patientGender',
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
          _buildInfoRow('Phone', _patientPhone),
          _buildInfoRow('Diagnosis Date', _diagnosisDate),
          _buildInfoRow('Report ID', _diagnosis?.diagnosisId ?? '—'),
        ],
      ),
    );
  }

  // ── Primary diagnosis card ────────────────────────────────────────────────

  Widget _buildPrimaryDiagnosisCard() {
    final top = _topPrediction;
    if (top == null) return const SizedBox.shrink();
    final color = _confidenceColor(top.confidence);
    final pct = (top.confidence * 100).toStringAsFixed(1);

    return _buildSectionCard(
      title: 'Primary Diagnosis',
      icon: Icons.medical_services,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  top.disease,
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
              'ICD-10: ${top.icd10Code}',
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
                  const Text(
                    'Confidence',
                    style: TextStyle(
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
    final others = _diagnosis!.aiPredictions.skip(1).toList();
    return _buildSectionCard(
      title: 'Differential Diagnoses',
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
                            p.disease,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (p.icd10Code != null)
                            Text(
                              'ICD-10: ${p.icd10Code}',
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
    final recs = _topPrediction?.recommendations ?? [];
    if (recs.isEmpty) return const SizedBox.shrink();
    return _buildSectionCard(
      title: 'Recommendations',
      icon: Icons.lightbulb_outline,
      color: Colors.teal,
      child: Column(
        children:
            recs
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
    final prescriptions = _diagnosis!.prescriptions!;
    return _buildSectionCard(
      title: 'Prescriptions',
      icon: Icons.medication,
      color: Colors.purple,
      child: Column(
        children:
            prescriptions.map((p) {
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
                    _buildInfoRow('Dosage', p.dosage),
                    _buildInfoRow('Frequency', p.frequency),
                    _buildInfoRow('Duration', p.duration),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── Pharmacies ────────────────────────────────────────────────────────────

  Widget _buildPharmaciesCard() {
    // Calculate total prescribed medicines for "Has all" badge
    final totalPrescribedMedicines = _diagnosis?.prescriptions?.length ?? 0;
    
    return _buildSectionCard(
      title: 'Nearby Pharmacies',
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
                                        'Has all medicines',
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
                          const Text(
                            'Available Medicines',
                            style: TextStyle(
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
                                        const SnackBar(
                                          content: Text('Cannot open phone dialer'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Error launching phone dialer: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.phone, size: 16),
                              label: const Text('Call'),
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
                                      const SnackBar(
                                        content: Text('Cannot open maps'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                debugPrint('Error launching maps: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.navigation, size: 16),
                            label: const Text('Navigate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
                            child: const Text(
                              'Active',
                              style: TextStyle(
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
                'Address',
                pharmacy.fullAddress,
              ),
              const SizedBox(height: 12),
              if (pharmacy.distance != null)
                _buildPharmacyDetailRow(
                  Icons.directions,
                  'Distance',
                  pharmacy.distanceText,
                ),
              if (pharmacy.distance != null) const SizedBox(height: 12),
              if (pharmacy.phoneNumber != null)
                _buildPharmacyDetailRow(
                  Icons.phone,
                  'Phone',
                  pharmacy.phoneNumber!,
                ),
              if (pharmacy.phoneNumber != null) const SizedBox(height: 12),
              if (pharmacy.openingHours != null)
                _buildPharmacyDetailRow(
                  Icons.access_time,
                  'Opening Hours',
                  pharmacy.openingHours!,
                ),
              if (pharmacy.openingHours != null) const SizedBox(height: 12),
              _buildPharmacyDetailRow(
                Icons.gps_fixed,
                'Coordinates',
                '${pharmacy.latitude.toStringAsFixed(4)}, ${pharmacy.longitude.toStringAsFixed(4)}',
              ),

              // Available medicines
              if (pharmacy.medicines.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Available Medicines',
                  style: TextStyle(
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
                        label: const Text('Call'),
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
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
    return _buildSectionCard(
      title: 'Pharmacy Recommendations',
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
                  'No Nearby Pharmacies Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We couldn\'t find any pharmacies within 50 km that have the prescribed medicines in stock.',
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
                        'Suggestions:',
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
                _buildSuggestionItem('Contact pharmacies directly to check availability'),
                _buildSuggestionItem('Try searching in the Pharmacies tab'),
                _buildSuggestionItem('Consider alternative medicine brands'),
                _buildSuggestionItem('Check back later as stock updates regularly'),
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
              label: const Text('Browse All Pharmacies'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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

  // ── Disease description ───────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return _buildSectionCard(
      title: 'About This Condition',
      icon: Icons.info_outline,
      color: Colors.indigo,
      child: Text(
        _topPrediction!.description!,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This report is AI-generated and intended to assist — '
              'not replace — clinical judgment. All diagnoses must be '
              'confirmed by a qualified healthcare professional.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom action row ─────────────────────────────────────────────────────

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/diagnosis'),
            icon: const Icon(Icons.refresh),
            label: const Text('New Diagnosis'),
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
            label: const Text('Share Report'),
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
