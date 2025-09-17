// screens/student/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:geolocator/geolocator.dart'; // ✅ For location
import 'package:phone_state/phone_state.dart'; // ✅ For phone call state
import 'package:permission_handler/permission_handler.dart'; // ✅ For runtime permission

import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // ✅ Your geofence coordinates
  static const double minLat = 11.010377;
  static const double maxLat = 29.233193;
  static const double minLon = -8.961771;
  static const double maxLon = 40.620639;

  Future<bool> _isOnCall() async {
    try {
      var phonePermission = await Permission.phone.status;
      if (!phonePermission.isGranted) {
        phonePermission = await Permission.phone.request();
      }
      if (!phonePermission.isGranted) {
        showSnackBar(context, 'Phone state permission denied.', isError: true);
        return true; // Block if no permission
      }

      // ✅ Correct way: PhoneState.stream.first
      PhoneStateStatus status = (await PhoneState.stream.first) as PhoneStateStatus;

      return (status == PhoneStateStatus.CALL_INCOMING ||
          status == PhoneStateStatus.CALL_STARTED);
    } catch (e) {
      debugPrint("Phone state check failed: $e");
      return false; // fallback: allow
    }
  }

  Future<void> _markAttendance() async {
    if (_otpController.text.length != 6) {
      showSnackBar(context, 'Please enter a valid 6-digit OTP.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // ✅ Step 0: Check phone call status
      if (await _isOnCall()) {
        showSnackBar(
            context, 'Attendance cannot be marked while you are on a call.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Step 1: Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showSnackBar(context, 'Location permission denied.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Step 2: Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      debugPrint("Current Location: lat=$lat, lon=$lon");

      // ✅ Step 3: Check if inside geofence
      if (!(lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon)) {
        showSnackBar(context, 'You are not inside the allowed location.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // ✅ Step 4: Continue with OTP submission
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        showSnackBar(context, 'Authentication error.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final result =
          await _apiService.markAttendance(_otpController.text, token);
      final message = result['message'] ?? 'Attendance marked successfully!';
      showSnackBar(context, message);
      _otpController.clear();
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icon and Header
                Icon(
                  Icons.pin_outlined,
                  size: 48,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mark Your Attendance',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code provided by your teacher.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Themed OTP Input
                SizedBox(
                  width: 260, // keeps digits aligned
                  child: TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 24, // even spacing
                      fontFamily: 'monospace', // ensures alignment
                      color: theme.primaryColor,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: TextStyle(letterSpacing: 24),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Animated Submission Button
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            key: const ValueKey('button'),
                            onPressed: _markAttendance,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Submit Attendance'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
