// screens/teacher_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'teacher/teacher_otp_screen.dart';
import 'teacher/teacher_report_screen.dart';
import 'login_screen.dart'; // Import for navigation after logout

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TeacherOtpScreen(),
    TeacherReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final title = user?.name ?? 'Teacher';

    return Scaffold(
      backgroundColor: whiteBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Professional Custom Header ---
            _buildCustomHeader(context, title),

            // --- 2. Animated Body Content ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
          ],
        ),
      ),
      // --- 3. Sleek Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: whiteBackground,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              activeIcon: Icon(Icons.qr_code_scanner),
              label: 'Generate OTP',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Report',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlack,
          unselectedItemColor: secondaryText,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }

  // Helper widget for the custom header
  Widget _buildCustomHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primaryAccent.withOpacity(0.3),
            child: const Icon(Icons.school_outlined, size: 28, color: primaryBlack),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 14, color: secondaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: secondaryText),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}