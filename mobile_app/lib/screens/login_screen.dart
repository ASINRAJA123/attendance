// screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import 'teacher_main_screen.dart';
import 'student_dashboard_screen.dart';

// --- UI Color Palette ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final role = Provider.of<AuthProvider>(context, listen: false).userRole;

      if (!mounted) return;

      if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherMainScreen()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        );
      } else {
        showSnackBar(context, 'Unknown role. Cannot navigate.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- 1. App Icon ---
                    Icon(
                      Icons.school_outlined,
                      size: 72,
                      color: primaryAccent,
                    ),
                    const SizedBox(height: 24),
                    
                    // --- 2. Welcome Header ---
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log in to continue to your dashboard.',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- 3. Professional Text Fields ---
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration(label: 'Email Address'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@'))
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _buildInputDecoration(label: 'Password'),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Password cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 40),

                    // --- 4. Sleek Login Button with Animation ---
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                key: ValueKey('loading'),
                                color: primaryAccent,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                key: const ValueKey('button'),
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: primaryBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable InputDecoration for a consistent look ---
  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: secondaryText),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryAccent, width: 2),
      ),
    );
  }
}