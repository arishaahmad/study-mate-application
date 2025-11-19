import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/signup_screen.dart'; // NEW: Import the SignUpScreen for Log Out

// Get the Supabase client instance (initialized in main.dart)
final supabase = Supabase.instance.client;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Function to get the current user's name.
  // We'll use the metadata stored during sign-up for a quick display.
  String _getUserName() {
    final user = supabase.auth.currentUser;
    // Check for the 'full_name' field in the user metadata (data passed during sign-up)
    final userName = user?.userMetadata?['full_name'] as String?;

    // Return the name if found, or a generic placeholder if not.
    return userName ?? 'StudyMate';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyMate Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false, // Prevents back button to sign-up after success
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Large welcome icon
            Icon(
              Icons.school_outlined,
              color: Theme.of(context).primaryColor,
              size: 100,
            ),
            const SizedBox(height: 24),

            // Welcome message with user's name
            Text(
              'Welcome, $userName!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle text
            const Text(
              'Your profile is set up and your study journey begins now.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // Optional: Logout button for quick testing
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();
                // Navigate back to the sign-up screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Log Out (For Testing)',
                style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.8), fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}