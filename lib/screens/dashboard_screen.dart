import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/signup_screen.dart';
import 'package:studymate/screens/pomodoro_timer_screen.dart'; // NEW: Import the Pomodoro Screen

// Get the Supabase client instance (initialized in main.dart)
final supabase = Supabase.instance.client;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Function to get the current user's name.
  String _getUserName() {
    final user = supabase.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] as String?;
    return userName ?? 'StudyMate User';
  }

  // Widget to define a reusable Feature Card for the grid
  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyMate Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false, // Prevents back button to sign-up after success
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- WELCOME SECTION ---
            Text(
              'Hello, $userName!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to focus? Pick a tool to get started.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),

            // --- FEATURES GRID ---
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Important for SingleChildScrollView
              children: [
                // NEW: Pomodoro Timer Card
                _buildFeatureCard(
                  context,
                  title: 'Pomodoro Timer',
                  icon: Icons.timer_outlined,
                  color: primaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PomodoroTimerScreen()),
                    );
                  },
                ),

                // Placeholder for future features (e.g., To-Do List)
                _buildFeatureCard(
                  context,
                  title: 'To-Do List',
                  icon: Icons.checklist,
                  color: Colors.blueGrey,
                  onTap: () {
                    // Placeholder navigation for future screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('To-Do List feature coming soon!')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 50),

            // --- LOGOUT BUTTON ---
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await supabase.auth.signOut();
                  // Navigate back to the sign-up screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: primaryColor.withOpacity(0.8)),
                label: Text(
                  'Log Out',
                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}