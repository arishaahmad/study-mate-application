import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/chat_screen.dart';

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

  // --- DELETE FUNCTION ---
  Future<void> _deleteRequest(String id) async {
    try {
      await supabase.from('help_requests').delete().eq('id', id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request deleted. Chats will be saved.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- START CHAT FUNCTION (UPDATED) ---
  Future<void> _startChat(String requestId, String ownerId, String courseCode) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

    // Prevent chatting with yourself
    if (ownerId == myId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You cannot chat with yourself.")));
      return;
    }

    try {
      // 1. Check if conversation already exists
      final existing = await supabase
          .from('conversations')
          .select()
          .eq('request_id', requestId)
          .eq('user_b', myId)
          .maybeSingle();

      String conversationId;

      if (existing != null) {
        conversationId = existing['id'];
      } else {
        // 2. Create new conversation AND SAVE THE TOPIC
        final newConvo = await supabase.from('conversations').insert({
          'request_id': requestId,
          'user_a': ownerId,
          'user_b': myId,
          'topic': 'Chat: $courseCode', // <--- This saves the context permanently!
          'last_message': 'Chat started'
        }).select().single();
        conversationId = newConvo['id'];
      }

      // 3. Navigate
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversationId: conversationId, otherUserName: "Student"),
          ),
        );
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error starting chat: $e")));
    }
  }

  // Stream logic
  Stream<List<Map<String, dynamic>>> _getHelpRequestsStream() {
    return supabase
        .from('help_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  // Post logic
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error posting: $e")));
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
              TextField(controller: courseController, decoration: const InputDecoration(labelText: "Course Code (e.g. CNG 465)")),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Subject / Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Details (Optional)")),
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
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final myId = supabase.auth.currentUser?.id;

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(child: Text("No help requests yet.", style: TextStyle(color: Colors.grey.shade600)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final ownerId = post['user_id'];
              final isMyPost = ownerId == myId;

              // Standard Date Formatting (No extra packages needed)
              final dateStr = post['created_at'].toString().split('T')[0];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                              label: Text(post['course_code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              visualDensity: VisualDensity.compact
                          ),
                          if (isMyPost)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRequest(post['id']),
                              tooltip: "Delete Request",
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                      if (post['description'] != null) ...[
                        const SizedBox(height: 5),
                        Text(post['description'], style: const TextStyle(fontSize: 14)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateStr, style: const TextStyle(color: Colors.grey)),
                          if (!isMyPost)
                            ElevatedButton.icon(
                              // Pass the course code here to save it as the Topic
                              onPressed: () => _startChat(post['id'], ownerId, post['course_code']),
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text("Message"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                        ],
                      ),
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