import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../providers/auth_provider.dart';
import '../utils/snackbar_helper.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceHistory = [];

  Future<void> _markAttendance() async {
    if (_otpController.text.length != 6) {
      showSnackBar(context, 'Please enter a valid 6-digit OTP.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      showSnackBar(context, 'Authentication error.', isError: true);
      return;
    }
    try {
      final result = await _apiService.markAttendance(_otpController.text, token);

      setState(() {
        _attendanceHistory.insert(0, {
          "teacher": result["teacherName"] ?? "Unknown",
          "timestamp": DateTime.now().toString(),
          "status": "Present ✅",
        });
      });

      showSnackBar(context, "Attendance marked successfully!");
      _otpController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authProvider.user?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- OTP Input Box ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Enter the OTP from your teacher',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, letterSpacing: 16),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                        hintText: '______',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _markAttendance,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark My Attendance'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Attendance History ---
            Expanded(
              child: _attendanceHistory.isEmpty
                  ? const Center(child: Text("No attendance records yet."))
                  : ListView.builder(
                      itemCount: _attendanceHistory.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.verified, color: Colors.green),
                          title: Text("Marked by: ${record['teacher']}"),
                          subtitle: Text("On: ${record['timestamp']}"),
                          trailing: Text(record["status"],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
