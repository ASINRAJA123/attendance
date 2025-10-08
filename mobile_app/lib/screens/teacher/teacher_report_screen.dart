// screens/teacher/teacher_report_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

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
      _studentList = [];
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryAccent,
              onPrimary: primaryBlack,
              onSurface: primaryBlack,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryBlack),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      if (_selectedPeriod != null) _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Column(
        children: [
          _buildFilterCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  "Present Students",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                  ),
                ),
                const Spacer(),
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _studentList.length.toString(),
                      style: const TextStyle(
                        color: primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryAccent))
                  : _studentList.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _studentList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = _studentList[index];
                            return StudentReportCard(student: student, index: index);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: primaryBlack, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Report Date", style: TextStyle(color: secondaryText, fontSize: 13)),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlack, fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: secondaryText),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.grey.shade200),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return ChoiceChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedPeriod = selected ? period : null);
                  if (selected) _fetchReport();
                },
                labelStyle: TextStyle(
                  color: isSelected ? primaryBlack : secondaryText,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.grey.shade100,
                selectedColor: primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? primaryAccent : Colors.grey.shade300,
                  ),
                ),
                pressElevation: 0.0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class StudentReportCard extends StatelessWidget {
  final Map<String, String> student;
  final int index;

  const StudentReportCard({super.key, required this.student, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: whiteBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryAccent.withOpacity(0.5),
            foregroundColor: primaryBlack,
            child: Text((index + 1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlack),
              ),
              const SizedBox(height: 2),
              Text(
                "Roll No: ${student['rollNumber']!}",
                style: const TextStyle(color: secondaryText, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 72, color: primaryAccent.withOpacity(0.8)),
            const SizedBox(height: 20),
            const Text(
              "No Records Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "No students have marked attendance for the selected date and period.",
              style: TextStyle(fontSize: 15, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}