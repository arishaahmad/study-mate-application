import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studymate/screens/chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getConversations() {
    final myId = supabase.auth.currentUser?.id;
    // We fetch conversations where I am either user_a OR user_b
    return supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) {
      // Filter manually since Supabase Stream query limitations
      return data.where((c) => c['user_a'] == myId || c['user_b'] == myId).toList().cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final myId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Inbox"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final convos = snapshot.data ?? [];

          if (convos.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final c = convos[index];
              // Determine if I am User A or User B, to show "Student" as the other person
              final isUserA = c['user_a'] == myId;
              final otherLabel = isUserA ? "Helper" : "Requester";

              return ListTile(
                leading: CircleAvatar(backgroundColor: primaryColor.withOpacity(0.1), child: const Icon(Icons.person)),
                title: Text("Chat with $otherLabel"),
                subtitle: Text(c['last_message'] ?? "Start chatting...", maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversationId: c['id'],
                        otherUserName: otherLabel,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}