// screens/student/attendance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161); // A professional grey for less emphasis

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  DailyAttendance? _dailyAttendance;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceHistory();
    });
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _dailyAttendance = null;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      showSnackBar(context, 'Authentication error.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await _apiService.getAttendanceHistory(dateString, token);
      setState(() => _dailyAttendance = result);
    } catch (e) {
      if (!e.toString().toLowerCase().contains('not found')) {
        showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // --- Theming the Date Picker ---
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryAccent,
              onPrimary: primaryBlack,
              onSurface: primaryBlack,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBlack,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchAttendanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        children: [
          // --- 1. Sleek Date Selector ---
          _buildDateSelector(context),
          const SizedBox(height: 8),

          // --- 2. Animated Content Area ---
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryAccent))
                  : _dailyAttendance == null || _dailyAttendance!.records.isEmpty
                      ? _EmptyHistoryState(date: _selectedDate, onRefresh: _fetchAttendanceHistory)
                      : RefreshIndicator(
                          onRefresh: _fetchAttendanceHistory,
                          color: primaryAccent,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _dailyAttendance!.records.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final record = _dailyAttendance!.records[index];
                              return AttendanceCard(record: record);
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: whiteBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month_outlined, color: primaryBlack),
              const SizedBox(width: 16),
              Text(
                DateFormat('MMMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(
                  color: primaryBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Aesthetic Empty State Widget ---
class _EmptyHistoryState extends StatelessWidget {
  final DateTime date;
  final Future<void> Function() onRefresh;

  const _EmptyHistoryState({required this.date, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: primaryAccent,
      child: Center(
        child: ListView( // Added ListView to enable pull-to-refresh
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 72, color: primaryAccent.withOpacity(0.8)),
                  const SizedBox(height: 20),
                  const Text(
                    "No Records Found",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "There are no attendance records for ${DateFormat('MMMM dd').format(date)}.",
                    style: const TextStyle(fontSize: 15, color: secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. Professional Attendance Card ---
class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const AttendanceCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final bool isPresent = record.status.toLowerCase() == 'present';

    return Container(
      decoration: BoxDecoration(
        color: whiteBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon styling
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule, color: primaryBlack, size: 20),
                ),
                const SizedBox(width: 12),
                // Period Text
                Expanded(
                  child: Text(
                    record.period,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryBlack),
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPresent ? primaryAccent.withOpacity(0.3) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isPresent ? primaryBlack : secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Colors.grey.shade200, height: 1),
            ),
            // Marked By Text
            Text.rich(
              TextSpan(
                text: 'Marked by: ',
                style: const TextStyle(color: secondaryText, fontSize: 13),
                children: [
                  TextSpan(
                    text: record.markedBy,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlack),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}