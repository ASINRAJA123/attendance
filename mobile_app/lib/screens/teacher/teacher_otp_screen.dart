// screens/teacher/teacher_otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../api/api_service.dart';
import '../../utils/snackbar_helper.dart';

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

class TeacherOtpScreen extends StatefulWidget {
  const TeacherOtpScreen({super.key});

  @override
  State<TeacherOtpScreen> createState() => _TeacherOtpScreenState();
}

class _TeacherOtpScreenState extends State<TeacherOtpScreen> {
  final ApiService _apiService = ApiService();

  final List<String> _periods = [
    '09:00 AM - 10:00 AM', '10:00 AM - 11:00 AM', '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM', '02:00 PM - 03:00 PM',
  ];
  String? _selectedPeriod;

  String? _otp;
  int _countdown = 60;
  Timer? _timer;
  bool _isLoading = false;

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() {
          _otp = null;
          _selectedPeriod = null;
        });
      }
    });
  }

  Future<void> _generateOtp() async {
    if (_selectedPeriod == null) {
      showSnackBar(context, 'Please select a period.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      showSnackBar(context, 'Authentication error.', isError: true);
      setState(() => _isLoading = false);
      return;
    }
    try {
      final otp = await _apiService.generateOtp(_selectedPeriod!, token);
      setState(() => _otp = otp);
      _startTimer();
      HapticFeedback.lightImpact();
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: _otp == null
                ? _buildOtpGenerationCard()
                : _buildOtpDisplayCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpGenerationCard() {
    return Container(
      key: const ValueKey('generate_card'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: whiteBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate New OTP',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a period to generate a secure code for student attendance.',
            style: TextStyle(fontSize: 15, color: secondaryText),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(color: Colors.grey.shade200),
          ),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return ChoiceChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedPeriod = selected ? period : null);
                },
                labelStyle: TextStyle(
                  color: isSelected ? primaryBlack : secondaryText,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.grey.shade100,
                selectedColor: primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? primaryAccent : Colors.grey.shade300,
                  ),
                ),
                pressElevation: 0.0,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryAccent))
                : ElevatedButton.icon(
                    onPressed: _selectedPeriod != null ? _generateOtp : null,
                    icon: const Icon(Icons.key_rounded, color: primaryBlack),
                    label: const Text(
                      'GENERATE OTP',
                      style: TextStyle(
                        color: primaryBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpDisplayCard() {
    final seconds = _countdown.toString().padLeft(2, '0');

    return Container(
      key: const ValueKey('display_card'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: whiteBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Active OTP for',
            style: TextStyle(fontSize: 15, color: secondaryText),
          ),
          Text(
            _selectedPeriod!,
            style: TextStyle(fontSize: 17, color: primaryBlack, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: whiteBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryAccent, width: 2),
            ),
            child: Text(
              _otp!,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: primaryBlack,
                letterSpacing: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Expires in 00:$seconds',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}