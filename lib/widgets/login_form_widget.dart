import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/dashboard_screen.dart';
import 'package:studymate/screens/signup_screen.dart'; // For the 'Sign Up' link

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final SupabaseClient supabase;

  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    // Get the shared Supabase client instance
    supabase = Supabase.instance.client;
  }

  // Function to handle the login submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 16),
              const Text('Logging in...', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 10),
        ),
      );

      try {
        // --- SUPABASE LOGIN CALL ---
        final AuthResponse response = await supabase.auth.signInWithPassword(
          email: _email,
          password: _password,
        );
        // --- END SUPABASE LOGIN CALL ---

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.user != null && response.session != null) {
          // Success: Navigate to Dashboard and clear the navigation history
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login successful! Welcome back!'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Should generally be caught by AuthException, but good for safety
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login failed: Invalid credentials or account not confirmed.'),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }

      } on AuthException catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        print('Supabase Auth Error: ${error.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.message}'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        print('General Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  // Helper function for building a custom input field (copied from sign-up for consistency).
  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.lock_open_outlined,
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome Back to StudyMate',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 1. Email Input
            _buildTextField(
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _email = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email.';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value ?? '')) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),

            // 2. Password Input
            _buildTextField(
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (value) => _password = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Link back to Sign Up
            TextButton(
              onPressed: () {
                // Navigate back to the Sign Up Screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: Text(
                "Don't have an account? Register Now",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}