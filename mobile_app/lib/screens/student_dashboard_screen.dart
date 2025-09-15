// screens/student_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student/attendance_history_screen.dart'; // Ensure this file exists
import 'student/otp_screen.dart'; // Ensure this file exists

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  // IMPORTANT: For IndexedStack or PageView, you would create the screens once.
  // For a simple switcher like this, it's fine.
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
    // Get theme colors for consistency
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final user = Provider.of<AuthProvider>(context).user;
    final title = user?.name ?? 'Student';
    final subtitle = user?.rollNumber ?? user?.email ?? '';

    return Scaffold(
      // The AppBar is removed in favor of a custom header in the body
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Custom Header Section
            _buildCustomHeader(context, title, subtitle, primaryColor),

            // 2. Animated Body Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Padding(
                  // Add padding around the actual screen content
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // Use a Key to tell the AnimatedSwitcher that the widget has changed
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            ),
          ],
        ),
      ),
      // 3. Styled Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_outlined),
            activeIcon: Icon(Icons.pin),
            label: 'Enter OTP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'My Attendance',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Theming properties
        backgroundColor: Colors.white,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed, // Important for background color
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
      ),
    );
  }

  // Helper widget for the custom header
  Widget _buildCustomHeader(BuildContext context, String title, String subtitle, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.person_outline, size: 32, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $title',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.logout_outlined, color: Colors.grey[700]),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}