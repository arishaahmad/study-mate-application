import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  // Global key to uniquely identify the form and allow validation.
  final _formKey = GlobalKey<FormState>();

  // CHANGE 1: Use 'late final' for the client
  late final SupabaseClient supabase;

  // Form state variables
  String _email = '';
  String _password = '';
  String _name = '';
  String? _selectedDepartment;
  int? _selectedYear;

  // ... (Lists remain the same)
  static const List<String> departments = [
    'Computer Eng',
    'Software Eng',
    'Industrial',
    'Mechanical',
    'Aerospace',
    'Cybersecurity',
    'Civil',
  ];
  static const List<int> years = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    // CHANGE 2: Initialize the Supabase client here, safely, after main() has completed initialization.
    supabase = Supabase.instance.client;
  }

  // Function to handle form submission
  void _submitForm() async { // Asynchronous function for Supabase call
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show loading indicator before API call (optional, but good UX)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 16),
              const Text('Creating account...', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 10), // Show for a longer duration while waiting
        ),
      );

      try {
        // --- SUPABASE SIGN UP CALL ---
        final AuthResponse response = await supabase.auth.signUp(
          email: _email,
          password: _password,
          // Pass user metadata (name, department, year)
          data: {
            'full_name': _name,
            'department': _selectedDepartment,
            'year': _selectedYear,
          },
        );
        // --- END SUPABASE CALL ---

        // Hide loading indicator first
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Check if sign-up was successful (even if confirmation email is required)
        if (response.user != null || response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success! Welcome, $_name! Check your email to confirm your account.'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 4),
            ),
          );
          // Clear the form on successful submission
          _formKey.currentState!.reset();
        }

      } on AuthException catch (error) {
        // Handle specific Supabase Auth errors
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        print('Supabase Auth Error: ${error.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed: ${error.message}'),
            backgroundColor: Theme.of(context).primaryColor, // Deep Red for error
          ),
        );
      } catch (e) {
        // Handle general errors (network, etc.)
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        print('General Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  // Helper functions (_buildTextField, _buildDropdownField) and build method remain the same for brevity.
  // We'll keep the full, detailed version in the final file.

  // Helper function for building a custom input field.
  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    // This widget ensures that all inputs use the primary red theme color for focus and icons.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          // Clean, modern input styling
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).hintColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // RED Focus Border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  // Helper function for building the dropdowns.
  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required List<T> items,
    T? value,
    required Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    // This widget ensures that all dropdowns use the primary red theme color for focus and icons.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          // Clean, modern input styling
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).hintColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // RED Focus Border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
        ),
        isExpanded: true,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: (newValue) {
          onChanged(newValue);
          // Update state to show selected value immediately
          if (T == String) {
            setState(() => _selectedDepartment = newValue as String?);
          } else if (T == int) {
            setState(() => _selectedYear = newValue as int?);
          }
        },
        validator: validator,
        onSaved: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This Container creates the white card, icon, and branding.
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
          children: <Widget>[
            // BOOK ICON (Pulls Theme Color - Deep Red)
            Icon(
              Icons.book_rounded,
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create Your StudyMate Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            // METU NCC Identifier
            const Text(
              'METU NCC',
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Form Fields start here...
            _buildTextField(
              label: 'Full Name',
              icon: Icons.person_outline,
              onSaved: (value) => _name = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name.';
                }
                return null;
              },
            ),

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

            _buildTextField(
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (value) => _password = value!,
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Password must be at least 8 characters long.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField<String>(
              label: 'Department',
              icon: Icons.business_center_outlined,
              items: departments,
              value: _selectedDepartment,
              onChanged: (String? newValue) => _selectedDepartment = newValue,
              validator: (value) {
                if (value == null) {
                  return 'Please select your department.';
                }
                return null;
              },
            ),

            _buildDropdownField<int>(
              label: 'Year',
              icon: Icons.calendar_today_outlined,
              items: years,
              value: _selectedYear,
              onChanged: (int? newValue) => _selectedYear = newValue,
              validator: (value) {
                if (value == null) {
                  return 'Please select your academic year.';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Sign Up Button (Pulls Theme Color - Deep Red)
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}