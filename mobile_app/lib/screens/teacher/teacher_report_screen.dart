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
  
  // --- Configuration for Time Slots (should be same as OTP screen) ---
  final List<String> _periods = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
  ];
  String? _selectedPeriod;
  DateTime _selectedDate = DateTime.now();
  // ------------------------------------

  List<Map<String, String>> _studentList = [];
  bool _isLoading = false;

  Future<void> _fetchReport() async {
    if (_selectedPeriod == null) {
      showSnackBar(context, "Please select a period to view the report.", isError: true);
      return;
    }
    setState(() => _isLoading = true);
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
      setState(() {
        _selectedDate = picked;
        _studentList.clear(); // Clear list when date changes
      });
       if(_selectedPeriod != null) _fetchReport(); // Re-fetch if a period is already selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          ListTile(
            title: const Text("Report Date"),
            subtitle: Text(DateFormat('dd MMMM, yyyy').format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 10),
          const Text('Select a Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Wrap(
            spacing: 8.0,
            children: _periods.map((period) {
              return ChoiceChip(
                label: Text(period),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  setState(() {
                    _selectedPeriod = selected ? period : null;
                    _studentList.clear(); // Clear list when period changes
                  });
                  if(selected) _fetchReport();
                },
              );
            }).toList(),
          ),
          const Divider(height: 30),
          // Student List
          Text("Present Students (${_studentList.length})", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _studentList.isEmpty
                    ? const Center(child: Text("No students have marked attendance for this slot."))
                    : ListView.builder(
                        itemCount: _studentList.length,
                        itemBuilder: (context, index) {
                          final student = _studentList[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text((index + 1).toString())),
                              title: Text(student['name']!),
                              subtitle: Text("Roll No: ${student['rollNumber']!}"),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}