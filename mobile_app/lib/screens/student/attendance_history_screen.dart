// screens/student/attendance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- THIS IS THE CORRECTED LINE
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  DailyAttendance? _dailyAttendance;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch attendance for today when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendanceHistory();
    });
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _dailyAttendance = null; // Clear previous data
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
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAttendanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Date Selector
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Selected Date'),
              subtitle: Text(DateFormat('dd-MMM-yyyy').format(_selectedDate)),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _selectDate(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Attendance List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyAttendance == null || _dailyAttendance!.records.isEmpty
                    ? Center(
                        child: Text(
                        'No attendance records found for this date.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ))
                    : RefreshIndicator(
                      onRefresh: _fetchAttendanceHistory,
                      child: ListView.builder(
                          itemCount: _dailyAttendance!.records.length,
                          itemBuilder: (context, index) {
                            final record = _dailyAttendance!.records[index];
                            return AttendanceCard(record: record);
                          },
                        ),
                    ),
          ),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const AttendanceCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status.toLowerCase() == 'present';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.period,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPresent ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPresent ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Marked by:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              record.markedBy,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}