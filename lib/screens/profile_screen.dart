import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;

  // User details from 'profiles' table
  String _fullName = '';
  String _email = '';
  String _department = '';
  String _year = '';

  // Course codes from 'schedules' table
  List<String> _enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchCompleteProfile();
  }

  Future<void> _fetchCompleteProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. Fetch User Info from the 'profiles' table
      // Based on your screenshot, columns are: id, full_name, department, year
      final profileResponse = await supabase
          .from('profiles')
          .select('full_name, department, year')
          .eq('id', user.id)
          .single();

      // 2. Fetch Course Codes from the 'schedules' table
      // Your screenshot shows the column is 'course_code', NOT 'code'
      final scheduleResponse = await supabase
          .from('schedules')
          .select('course_code')
          .eq('user_id', user.id);

      final List<dynamic> scheduleData = scheduleResponse;
      final Set<String> uniqueCodes = {};

      for (var item in scheduleData) {
        if (item['course_code'] != null) {
          uniqueCodes.add(item['course_code'].toString());
        }
      }

      if (mounted) {
        setState(() {
          _email = user.email ?? '';

          // Using .toString() handles the 'int2' error for 'year'
          _fullName = (profileResponse['full_name'] ?? 'Student').toString();
          _department = (profileResponse['department'] ?? 'Not Set').toString();
          _year = (profileResponse['year'] ?? 'N/A').toString();

          _enrolledCourses = uniqueCodes.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
            Text(_fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),

            const SizedBox(height: 32),

            // --- ACADEMIC DETAILS ---
            _buildSectionHeader(primaryColor, "Academic Info"),
            _buildInfoCard(Icons.school, "Department", _department),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.calendar_today, "Year", "Year $_year"),

            const SizedBox(height: 32),

            // --- ENROLLED COURSES ---
            _buildSectionHeader(primaryColor, "Enrolled Courses"),
            if (_enrolledCourses.isEmpty)
              _buildEmptyCourses()
            else
              _buildCourseGrid(primaryColor),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionHeader(Color color, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ),
        const Divider(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCourses() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text("No courses found in your schedule.", style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildCourseGrid(Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _enrolledCourses.map((code) => Chip(
          label: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: color.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        )).toList(),
      ),
    );
  }
}