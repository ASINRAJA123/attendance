// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './widgets/auth_wrapper.dart';

// --- Define the app's color palette as constants ---
const Color primaryAccent = Color(0xFFA4DFFF);
const Color primaryBlack = Color(0xFF000000);
const Color whiteBackground = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFF616161);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Define the modern, professional app theme ---
    final appTheme = ThemeData(
      useMaterial3: true,

      // 1. Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        primary: primaryAccent,
        onPrimary: primaryBlack, // Text color on primary color
        background: whiteBackground,
        surface: whiteBackground,
        brightness: Brightness.light,
      ),

      // 2. Scaffold Background
      scaffoldBackgroundColor: whiteBackground,

      // 3. Text Theme with Google Fonts for a modern feel
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
        bodyColor: primaryBlack,
        displayColor: primaryBlack,
      ),

      // 4. Input Field Theme for text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50, // A very light fill for contrast
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        labelStyle: const TextStyle(color: secondaryText),
      ),

      // 5. Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: primaryBlack,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins', // Ensure font consistency
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0, // A flatter, more modern look
        ),
      ),

      // 6. Card Theme  <-- CORRECTED HERE
      cardTheme: CardThemeData(
        color: whiteBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),

      // 7. Chip Theme for choice chips
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryAccent,
        labelStyle: const TextStyle(
          color: secondaryText,
          fontWeight: FontWeight.bold,
        ),
        secondaryLabelStyle: const TextStyle(
          color: primaryBlack, // Label style when selected
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        pressElevation: 0,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}