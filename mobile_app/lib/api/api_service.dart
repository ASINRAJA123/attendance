import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your computer's local network IP address here, not localhost.
  static const String _baseUrl = 'http://localhost:5001/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Login Failed: ${error['message']}');
      }
    } catch (e) {
      // Catch network errors or other exceptions
      throw Exception('Could not connect to the server. Please check your network.');
    }
  }

  Future<String> generateOtp(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/teacher/otp/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['otp'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to generate OTP: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }

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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to mark attendance: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server.');
    }
  }
}