import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Access the client initialized in main.dart
  final supabase = Supabase.instance.client;

  bool _isLoading = true;

  // User details (View Only)
  String _fullName = '';
  String _email = '';
  String _department = '';
  String _year = '';

  // List of unique course codes derived from the schedule
  List<String> _enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  /// Fetches User Metadata and Schedule Data
  Future<void> _fetchProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. Fetch unique courses from the 'schedules' table
      final scheduleResponse = await supabase
          .from('schedules')
          .select('course_code')
          .eq('user_id', user.id);

      // Extract codes and remove duplicates to show a clean "Course List"
      final List<dynamic> data = scheduleResponse;
      final Set<String> uniqueCodes = {};

      for (var item in data) {
        if (item['course_code'] != null && item['course_code'].toString().isNotEmpty) {
          uniqueCodes.add(item['course_code'].toString());
        }
      }

      if (mounted) {
        setState(() {
          // Load basic user info from Auth Metadata
          _email = user.email ?? '';
          _fullName = user.userMetadata?['full_name'] ?? 'Student';
          _department = user.userMetadata?['department'] ?? 'Not Set';
          _year = user.userMetadata?['year'] ?? 'Not Set';

          _enrolledCourses = uniqueCodes.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        // No Actions (Save button removed)
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- PROFILE HEADER ---
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _email,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            // --- ACADEMIC DETAILS SECTION ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Academic Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Read-Only Info Cards
            _buildInfoCard(Icons.school, "Department", _department),
            const SizedBox(height: 10),
            _buildInfoCard(Icons.calendar_today, "Year", _year),

            const SizedBox(height: 30),

            // --- ENROLLED COURSES SECTION ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            if (_enrolledCourses.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.class_outlined, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text(
                      "No courses found in schedule.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
            // Displays courses as a list of chips
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _enrolledCourses.map((code) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(Icons.book, size: 14, color: Colors.white),
                      ),
                      label: Text(
                        code,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: primaryColor.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent info rows
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : "Not specified",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}