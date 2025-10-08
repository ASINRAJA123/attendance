// screens/student/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // --- India Full Bounding Box ---
  static const double minLat = 6.5546079;   // Kanyakumari
  static const double maxLat = 35.6745457;  // Ladakh
  static const double minLon = 68.1113787;  // Gujarat
  static const double maxLon = 97.395561;   // Arunachal Pradesh

  // --- Attendance Logic ---
  Future<void> _markAttendance() async {
    if (_otpController.text.length != 6) {
      showSnackBar(context, 'Please enter a valid 6-digit OTP.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // --- Location Permission ---
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        showSnackBar(context, 'Location permission denied.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // --- Fetch current location with timeout ---
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Location fetch timed out."),
      );

      double lat = position.latitude;
      double lon = position.longitude;

      if (!(lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon)) {
        showSnackBar(context, 'You are not inside the allowed location.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // --- Token check ---
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        showSnackBar(context, 'Authentication error.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // --- API Call ---
      final result = await _apiService.markAttendance(_otpController.text, token);
      final message = result['message'] ?? 'Attendance marked successfully!';
      showSnackBar(context, message);
      _otpController.clear();

    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
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
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 48, color: primaryAccent),
                const SizedBox(height: 16),
                const Text(
                  'Mark Your Attendance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the 6-digit code provided by your teacher.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: secondaryText),
                ),
                const SizedBox(height: 32),

                // --- OTP Input ---
                TextField(
                  controller: _otpController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                    color: primaryBlack,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '******',
                    hintStyle: TextStyle(
                      letterSpacing: 16,
                      fontSize: 28,
                      color: Colors.grey.shade300,
                      fontFamily: 'monospace',
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryAccent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: primaryAccent))
                        : ElevatedButton.icon(
                            key: const ValueKey('submit_button'),
                            onPressed: _markAttendance,
                            icon: const Icon(Icons.check, color: primaryBlack),
                            label: const Text(
                              'SUBMIT ATTENDANCE',
                              style: TextStyle(
                                color: primaryBlack,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
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
