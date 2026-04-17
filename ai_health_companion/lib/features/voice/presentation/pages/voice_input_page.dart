import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';

class VoiceInputPage extends StatefulWidget {
  final Function(String)? onTextCaptured;
  
  const VoiceInputPage({super.key, this.onTextCaptured});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcribedText = '';
  String _selectedLanguage = 'Kinyarwanda';
  double _confidence = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _listeningTimer;
  int _listeningSeconds = 0;

  final List<String> _supportedLanguages = [
    'Kinyarwanda',
    'English',
    'French',
    'Swahili'
  ];
  final List<String> _recognizedSymptoms = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listeningTimer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  void _startListening() {
    _animationController.repeat(reverse: true);
    _listeningSeconds = 0;
    _listeningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _listeningSeconds++);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (_isListening && mounted) _simulateVoiceRecognition();
    });
  }

  void _stopListening() {
    _animationController.stop();
    _animationController.reset();
    _listeningTimer?.cancel();
    
    if (_transcribedText.isNotEmpty) {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isProcessing = false);
          _extractSymptoms();
        }
      });
    }
  }

  void _simulateVoiceRecognition() {
    final mockTranscriptions = {
      'Kinyarwanda': 'Mfite ububabare bw\'umutwe, umuriro, no kuruhuka',
      'English': 'I have a headache, fever, and fatigue',
      'French': 'J\'ai mal à la tête, de la fièvre et de la fatigue',
      'Swahili': 'Nina maumivu ya kichwa, homa, na uchovu',
    };

    setState(() {
      _transcribedText = mockTranscriptions[_selectedLanguage] ?? '';
      _confidence = 0.92;
    });
  }

  void _extractSymptoms() {
    setState(() {
      _recognizedSymptoms.clear();
      _recognizedSymptoms.addAll(['Headache', 'Fever', 'Fatigue']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_recognizedSymptoms.length} symptoms recognized'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearTranscription() {
    setState(() {
      _transcribedText = '';
      _recognizedSymptoms.clear();
      _confidence = 0.0;
    });
  }

  void _useTranscription() {
    if (widget.onTextCaptured != null) {
      widget.onTextCaptured!(_transcribedText);
    }
    Navigator.pop(context, {
      'text': _transcribedText,
      'symptoms': _recognizedSymptoms,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Voice Input',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 32),
            _buildVoiceAnimation(),
            const SizedBox(height: 32),
            if (_transcribedText.isNotEmpty) _buildTranscription(),
            if (_recognizedSymptoms.isNotEmpty) _buildRecognizedSymptoms(),
            if (_transcribedText.isNotEmpty) _buildActionButtons(),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Language',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _supportedLanguages.map((language) {
              final isSelected = language == _selectedLanguage;
              return ChoiceChip(
                label: Text(language),
                selected: isSelected,
                onSelected: _isListening
                    ? null
                    : (selected) {
                        if (selected) {
                          setState(() => _selectedLanguage = language);
                        }
                      },
                selectedColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAnimation() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [AppTheme.primaryColor, AppTheme.accentColor]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: _isProcessing ? null : _toggleListening,
                      child: Center(
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _isListening
                ? 'Listening... (${_listeningSeconds}s)'
                : _isProcessing
                    ? 'Processing...'
                    : 'Tap to start speaking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _isListening ? AppTheme.primaryColor : Colors.grey.shade600,
            ),
          ),
          if (_isListening) ...[
            const SizedBox(height: 8),
            Text(
              'Speak clearly in $_selectedLanguage',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranscription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transcription',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _confidence > 0.8
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _confidence > 0.8 ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: _confidence > 0.8 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(_confidence * 100).toInt()}% confident',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _confidence > 0.8 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(_transcribedText, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedSymptoms() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recognized Symptoms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recognizedSymptoms.map((symptom) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      symptom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _clearTranscription,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _useTranscription,
              icon: const Icon(Icons.check),
              label: const Text('Use This'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Tips for better recognition',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('Speak clearly and at a normal pace'),
            _buildTip('Minimize background noise'),
            _buildTip('Hold device 6-12 inches from mouth'),
            _buildTip('Describe symptoms in complete sentences'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.blue.shade900)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('How to use Voice Input'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Select your preferred language\n\n'
            '2. Tap the microphone button to start\n\n'
            '3. Speak clearly about the symptoms\n\n'
            '4. Tap again to stop recording\n\n'
            '5. Review the transcription and recognized symptoms\n\n'
            '6. Tap "Use This" to apply to diagnosis',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
