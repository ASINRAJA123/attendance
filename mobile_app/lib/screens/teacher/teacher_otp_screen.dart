// screens/teacher/teacher_otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../api/api_service.dart';
import '../../utils/snackbar_helper.dart';

class TeacherOtpScreen extends StatefulWidget {
  const TeacherOtpScreen({super.key});

  @override
  State<TeacherOtpScreen> createState() => _TeacherOtpScreenState();
}

class _TeacherOtpScreenState extends State<TeacherOtpScreen> {
  final ApiService _apiService = ApiService();

  // --- Configuration for Time Slots ---
  final List<String> _periods = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
  ];
  String? _selectedPeriod;
  // ------------------------------------

  String? _otp;
  int _countdown = 20;
  Timer? _timer;
  bool _isLoading = false;

  void _startTimer() {
    _countdown = 20;
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
          _selectedPeriod = null; // Reset period selection
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
    final minutes = (_countdown / 60).floor().toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_otp != null) ...[
          Text('Period: $_selectedPeriod', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Share this OTP with your students:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Center(
            child: Text(_otp!, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, letterSpacing: 12)),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('Expires in $minutes:$seconds', style: const TextStyle(fontSize: 18, color: Colors.red)),
          ),
        ] else ...[
          const Text('Select a Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _periods.map((period) {
              return ChoiceChip(
                label: Text(period),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  setState(() {
                    _selectedPeriod = selected ? period : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              onPressed: _selectedPeriod != null ? _generateOtp : null,
              icon: const Icon(Icons.vpn_key),
              label: const Text('Generate OTP'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ],
    );
  }
}