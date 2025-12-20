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
    // Fetch conversations where I am involved
    return supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) {
      return data.where((c) => c['user_a'] == myId || c['user_b'] == myId).toList().cast<Map<String, dynamic>>();
    });
  }

  // --- RENAME / SAVE CONTACT FUNCTION ---
  Future<void> _renameConversation(String conversationId, String currentName) async {
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Save Contact Name"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Give this chat a name so you can remember it easily:"),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Chat Name",
                hintText: "e.g. John - Math Helper",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  // Update the 'topic' column in Supabase
                  await supabase
                      .from('conversations')
                      .update({'topic': controller.text.trim()})
                      .eq('id', conversationId);

                  if (mounted) Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact saved successfully!")),
                  );
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text("Save"),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("No messages yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final c = convos[index];
              final isUserA = c['user_a'] == myId;
              final defaultLabel = isUserA ? "Helper" : "Requester";

              // This is the saved name (Topic) or the default
              final chatName = c['topic'] ?? "Chat with $defaultLabel";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.chat_bubble_outline)
                  ),
                  title: Text(
                    chatName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      c['last_message'] ?? "Start chatting...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  // --- EDIT BUTTON ---
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _renameConversation(c['id'], chatName),
                    tooltip: "Rename / Save Contact",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          conversationId: c['id'],
                          otherUserName: chatName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}