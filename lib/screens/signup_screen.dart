import 'package:flutter/material.dart';
import 'package:studymate/widgets/signup_form_widget.dart';
import 'package:studymate/screens/login_screen.dart'; // Import the Login Screen

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- UPDATED TITLE: StudyMate ---
        title: const Text(
          'StudyMate', // Use the application name
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: true,
        // This pulls the deep red color from main.dart
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        // Subtle light red/pink to white gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Use colors based on the red primary color
            colors: [Theme.of(context).primaryColor.withOpacity(0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column( // Wrapper for form and link
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- NEW BRANDING TEXT ---
                  Text(
                    'Your Student Life Together. METU NCC.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your StudyMate account.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // --- SIGN UP FORM ---
                  const SignUpFormWidget(),

                  // --- LOGIN OPTION LINK (Confirmed present) ---
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Navigate to the new LoginScreen
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Already have an account? Log In",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}