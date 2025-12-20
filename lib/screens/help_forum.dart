import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// REMOVED: import 'package:timeago/timeago.dart' as timeago;

class HelpForumScreen extends StatefulWidget {
  const HelpForumScreen({super.key});

  @override
  State<HelpForumScreen> createState() => _HelpForumScreenState();
}

class _HelpForumScreenState extends State<HelpForumScreen> {
  final supabase = Supabase.instance.client;

  String? _myDepartment;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDepartment();
  }

  Future<void> _fetchUserDepartment() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _myDepartment = user.userMetadata?['department'];
          _isLoadingProfile = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Stream<List<Map<String, dynamic>>> _getHelpRequestsStream() {
    return supabase
        .from('help_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  Future<void> _postRequest(String course, String title, String desc) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final deptTag = _myDepartment ?? 'General';

      await supabase.from('help_requests').insert({
        'user_id': user.id,
        'department': deptTag,
        'course_code': course,
        'title': title,
        'description': desc,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showCreateDialog() {
    final courseController = TextEditingController();
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ask for Help"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Posting as: ${_myDepartment ?? 'Student'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: "Course Code (e.g. CNG 465)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Subject / Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Details (Optional)", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (courseController.text.isNotEmpty && titleController.text.isNotEmpty) {
                _postRequest(courseController.text, titleController.text, descController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text("Post Request"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Help Forum"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text("Ask for Help", style: TextStyle(color: Colors.white)),
      ),
      body: _isLoadingProfile
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getHelpRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("No help requests yet.", style: TextStyle(color: Colors.grey)),
                  const Text("Be the first to ask!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              // --- UPDATED DATE LOGIC (NO PACKAGE) ---
              // Just show the date part (YYYY-MM-DD)
              final String dateStr = post['created_at'].toString().split('T')[0];

              final postDept = post['department'] ?? 'General';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Chip(
                                label: Text(post['course_code'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                backgroundColor: Colors.blue.shade50,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -4),
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Text(postDept, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                            ],
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      if (post['description'] != null && post['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          post['description'],
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}