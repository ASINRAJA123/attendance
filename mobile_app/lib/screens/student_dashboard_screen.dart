// screens/student_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student/attendance_history_screen.dart';
import 'student/otp_screen.dart';
import 'login_screen.dart'; // Import for navigation after logout

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    OtpScreen(),
    AttendanceHistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final title = user?.name ?? 'Student';
    final subtitle = user?.rollNumber ?? user?.email ?? '';

    return Scaffold(
      backgroundColor: whiteBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Professional Custom Header ---
            _buildCustomHeader(context, title, subtitle),

            // --- 2. Animated Body Content ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                // The key tells the AnimatedSwitcher that the widget has changed
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
              icon: Icon(Icons.pin_drop_outlined),
              activeIcon: Icon(Icons.pin_drop),
              label: 'Mark Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent, // Uses container's color
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
  Widget _buildCustomHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primaryAccent.withOpacity(0.3),
            child: const Icon(Icons.person_outline, size: 28, color: primaryBlack),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: secondaryText),
                  ),
                ]
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