import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your computer's local network IP address here, not localhost.
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

  // ---------------- GENERATE OTP ----------------
  Future<String> generateOtp(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/teacher/otp/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
  Future<String> markAttendance(String otp, String token) async {
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
        return data['message'];
      } else {
        // Show actual backend error message instead of generic "network error"
        throw Exception('Failed to mark attendance: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error connecting to server during attendance marking: $e');
    }
  }
}
