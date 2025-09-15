// screens/teacher/teacher_report_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({super.key});

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

class _TeacherReportScreenState extends State<TeacherReportScreen> {
  final ApiService _apiService = ApiService();

  final List<String> _periods = [
    '09:00 AM - 10:00 AM', '10:00 AM - 11:00 AM', '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM', '02:00 PM - 03:00 PM',
  ];
  String? _selectedPeriod;
  DateTime _selectedDate = DateTime.now();

  List<Map<String, String>> _studentList = [];
  bool _isLoading = false;

  Future<void> _fetchReport() async {
    if (_selectedPeriod == null) {
      showSnackBar(context, "Please select a period.", isError: true);
      return;
    }
    setState(() {
      _isLoading = true;
      _studentList = []; // Clear previous results
    });
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await _apiService.getTeacherAttendanceReport(dateString, _selectedPeriod!, token);
      setState(() => _studentList = result);
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
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      if (_selectedPeriod != null) _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildFilterCard(theme),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text("Present Students", style: theme.textTheme.titleMedium),
              const Spacer(),
              if (!_isLoading)
                Chip(
                  label: Text(_studentList.length.toString()),
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _studentList.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _studentList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final student = _studentList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                child: Text((index + 1).toString()),
                              ),
                              title: Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text("Roll No: ${student['rollNumber']!}"),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard(ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text("Report Date"),
              subtitle: Text(DateFormat('dd MMMM, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _selectDate(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return ChoiceChip(
                    label: Text(period),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedPeriod = selected ? period : null);
                      if (selected) _fetchReport();
                    },
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// A beautiful, reusable widget for empty states.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No Records Found",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "No students have marked attendance for the selected date and period.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}