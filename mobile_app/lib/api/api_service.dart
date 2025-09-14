// api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart'; // Import the new model

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to localhost on your machine
  static const String _baseUrl = 'http://localhost:5001/api';

  // ---------------- LOGIN ----------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception('Login Failed: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error connecting to server during login: $e');
    }
  }

  // ---------------- GENERATE OTP (UPDATED) ----------------
  Future<String> generateOtp(String period, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/teacher/otp/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // ADDED: Send the period in the body
        body: jsonEncode({'period': period}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data['otp'];
      } else {
        throw Exception('Failed to generate OTP: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error connecting to server during OTP generation: $e');
    }
  }

  // ---------------- MARK ATTENDANCE ----------------
  Future<Map<String, dynamic>> markAttendance(String otp, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/student/attendance/mark'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception('Failed to mark attendance: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error connecting to server during attendance marking: $e');
    }
  }

  // ---------------- GET ATTENDANCE HISTORY (NEW) ----------------
  Future<DailyAttendance> getAttendanceHistory(String date, String token) async {
    try {
      // The date should be in 'YYYY-MM-DD' format
      final uri = Uri.parse('$_baseUrl/student/attendance/history?date=$date');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return DailyAttendance.fromJson(data);
      } else {
        throw Exception('Failed to fetch history: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error fetching attendance history: $e');
    }
  }

  // api/api_service.dart

// ... (keep all existing functions: login, generateOtp, markAttendance, getAttendanceHistory)

  // ---------------- GET TEACHER ATTENDANCE REPORT (NEW) ----------------
  Future<List<Map<String, String>>> getTeacherAttendanceReport(String date, String period, String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/teacher/attendance/report').replace(queryParameters: {
        'date': date,
        'period': period,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // The result is a List<dynamic>, we need to cast it properly
        return List<Map<String, String>>.from(data.map((item) => {
          'name': item['name'].toString(),
          'rollNumber': item['rollNumber'].toString(),
        }));
      } else {
        throw Exception('Failed to fetch report: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error fetching teacher report: $e');
    }
  }
}