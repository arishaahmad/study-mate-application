import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/dashboard_screen.dart'; // NEW: Import the Dashboard Screen

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  // Global key to uniquely identify the form and allow validation.
  final _formKey = GlobalKey<FormState>();

  late final SupabaseClient supabase;

  // Form state variables
  String _email = '';
  String _password = '';
  String _name = '';
  String? _selectedDepartment;
  int? _selectedYear;

  // List of available departments for the dropdown
  static const List<String> departments = [
    'Computer Eng',
    'Software Eng',
    'Industrial',
    'Mechanical',
    'Aerospace',
    'Cybersecurity',
    'Civil',
  ];

  // List of available years (1-4)
  static const List<int> years = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    // Initialize Supabase client instance
    supabase = Supabase.instance.client;
  }

  // Function to handle form submission
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
              const Text('Creating account...', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 10),
        ),
      );

      try {
        final AuthResponse response = await supabase.auth.signUp(
          email: _email,
          password: _password,
          data: {
            // This data will be available in user_metadata and used by the Dashboard screen
            'full_name': _name,
            'department': _selectedDepartment,
            'year': _selectedYear,
          },
        );

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.user != null) {

          // Redirect to Dashboard and prevent going back to Sign Up
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success! Account created. Welcome, $_name!'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (response.session == null) {
          // If email confirmation is required
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration complete! Please check your email to confirm your account.'),
              backgroundColor: Colors.orange.shade600,
              duration: const Duration(seconds: 6),
            ),
          );
        }

      } on AuthException catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        print('Supabase Auth Error: ${error.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed: ${error.message}'),
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

  // Helper function for building a custom input field.
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

  // Helper function for building the dropdowns.
  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required List<T> items,
    T? value,
    required Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
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
        isExpanded: true,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: (newValue) {
          onChanged(newValue);
          // Also update the state for immediate visual change
          if (T == String) {
            setState(() => _selectedDepartment = newValue as String?);
          } else if (T == int) {
            setState(() => _selectedYear = newValue as int?);
          }
        },
        validator: validator,
        onSaved: onChanged, // Saves the latest selected value
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Welcome! Please provide your details to get started.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 1. Full Name Input
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

          // 2. Email Input
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

          // 3. Password Input
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

          // 4. Department Dropdown
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

          // 5. Year Dropdown
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

          // Sign Up Button
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
              'Sign Up',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}