import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/signup_screen.dart';

// 1. Define your Supabase keys here!
// We've extracted the Project URL from your provided key's reference.
const String supabaseUrl = 'https://ffncvpemnputhycyzysc.supabase.co'; // Extracted Project URL
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmbmN2cGVtbnB1dGh5Y3l6eXNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NjY5NDEsImV4cCI6MjA3OTE0Mjk0MX0.iTugppCT-d2uvTxVgOVioyTsXsqwEOQpTHcnaSyoWUc'; // Your Anon Key


void main() async {
  // 2. Ensures that widgets can bind to the platform channels before initializing Supabase.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Supabase with your project keys.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 4. Run the main application widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      theme: ThemeData(
        // Set the primary color to Deep Red (for METU NCC styling)
        primaryColor: Colors.red.shade800,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ).copyWith(
          secondary: Colors.red.shade500, // Accent color
        ),
        // Use a modern font
        fontFamily: 'Inter',
        // Set visual density for modern look
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false, // Keeping with Material 2 styling for now
      ),
      // Start the application on the Sign Up Screen
      home: const SignUpScreen(),
    );
  }
}