import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import 'teacher_dashboard_screen.dart';
import 'student_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    print('[LOGIN] Login button pressed.');

    if (!_formKey.currentState!.validate()) {
      print('[LOGIN] Form validation failed.');
      return;
    }

    FocusScope.of(context).unfocus();
    print('[LOGIN] Focus removed.');

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text.trim(), _passwordController.text.trim());
      print('[LOGIN] SUCCESS: Logged in.');

      final role = Provider.of<AuthProvider>(context, listen: false).userRole;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
          );
        } else if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
          );
        } else {
          showSnackBar(context, 'Unknown role. Cannot navigate.', isError: true);
        }
      });
    } catch (e) {
      print('[LOGIN] ERROR: $e');
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance App Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty) ? 'Password cannot be empty' : null,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
