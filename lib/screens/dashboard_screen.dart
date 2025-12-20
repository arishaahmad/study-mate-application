import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/signup_screen.dart';
import 'package:studymate/screens/pomodoro_timer_screen.dart';
import 'package:studymate/screens/todo_list_screen.dart';
import 'package:studymate/screens/schedule_screen.dart';
import 'package:studymate/screens/profile_screen.dart';
import 'package:studymate/screens/help_forum.dart'; // <--- ADDED THIS IMPORT

final supabase = Supabase.instance.client;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Map<String, String> _getUserData() {
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    return {
      'name': metadata?['full_name'] ?? 'StudyMate User',
      'dept': metadata?['department'] ?? 'Student',
    };
  }

  // --- YOUR NEW PROFILE HEADER ---
  Widget _buildProfileHeader(BuildContext context) {
    final userData = _getUserData();
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 35, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userData['name']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(userData['dept']!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // --- YOUR NEW SMALLER CARD DESIGN ---
  Widget _buildSmallFeatureCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Color> gradientColors,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        // --- YOUR NEW BACKGROUND GRADIENT ---
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, primaryColor.withOpacity(0.05), primaryColor.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('StudyMate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 20),

                _buildProfileHeader(context),

                const SizedBox(height: 32),
                const Text('Workspace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // --- TOOLS GRID ---
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSmallFeatureCard(
                      context,
                      title: 'Pomodoro',
                      icon: Icons.timer_rounded,
                      gradientColors: [Colors.orangeAccent, Colors.redAccent],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroTimerScreen())),
                    ),
                    _buildSmallFeatureCard(
                      context,
                      title: 'Schedule',
                      icon: Icons.calendar_today_rounded,
                      gradientColors: [Colors.tealAccent.shade700, Colors.teal],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleScreen())),
                    ),
                    _buildSmallFeatureCard(
                      context,
                      title: 'Tasks',
                      icon: Icons.check_circle_rounded,
                      gradientColors: [Colors.blueAccent, Colors.indigo],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ToDoListScreen())),
                    ),
                    // --- I ADDED THIS 4TH CARD FOR THE FORUM ---
                    _buildSmallFeatureCard(
                      context,
                      title: 'Help Forum',
                      icon: Icons.live_help_rounded,
                      gradientColors: [Colors.purpleAccent, Colors.deepPurple],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpForumScreen())),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await supabase.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}