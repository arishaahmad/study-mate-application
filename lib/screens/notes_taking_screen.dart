import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

// --- PAPER TEXTURE PAINTER ---
enum PaperType { blank, lines, squared }

class PaperPainter extends CustomPainter {
  final PaperType type;
  PaperPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    if (type == PaperType.blank) return;

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.1) // Reddish lines to match theme
      ..strokeWidth = 1.0;

    if (type == PaperType.lines) {
      for (double i = 30; i < size.height; i += 28) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
      }
    } else if (type == PaperType.squared) {
      double step = 25.0;
      for (double i = 0; i < size.width; i += step) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
      }
      for (double i = 0; i < size.height; i += step) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NotesTakingScreen extends StatefulWidget {
  const NotesTakingScreen({super.key});

  @override
  State<NotesTakingScreen> createState() => _NotesTakingScreenState();
}

class _NotesTakingScreenState extends State<NotesTakingScreen> {
  final supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  File? _selectedFile;
  String? _selectedFileType;

  // Default Paper Style
  PaperType _currentPaperStyle = PaperType.lines;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final data = await supabase.from('notes').select().eq('user_id', user.id).order('created_at', ascending: false);
      setState(() { _notes = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- ACTIONS ---

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() { _selectedFile = File(image.path); _selectedFileType = 'image'; });
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) setState(() { _selectedFile = File(result.files.single.path!); _selectedFileType = 'pdf'; });
  }

  Future<void> _deleteNote(dynamic id) async {
    await supabase.from('notes').delete().eq('id', id);
    Navigator.pop(context); // Close detail view
    _fetchNotes();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    String? fileUrl;

    if (_selectedFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';
      final path = 'uploads/$fileName';
      await supabase.storage.from('note-attachments').upload(path, _selectedFile!);
      fileUrl = supabase.storage.from('note-attachments').getPublicUrl(path);
    }

    await supabase.from('notes').insert({
      'user_id': supabase.auth.currentUser!.id,
      'title': _titleController.text,
      'content': _contentController.text,
      'file_url': fileUrl,
      'file_type': _selectedFileType,
    });

    _titleController.clear(); _contentController.clear();
    setState(() { _selectedFile = null; _selectedFileType = null; });
    Navigator.pop(context);
    _fetchNotes();
  }

  // --- VIEWS ---

  void _showNoteDetail(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            title: Text(note['title'] ?? "Note"),
            actions: [
              IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => _deleteNote(note['id'])),
            ],
          ),
          body: CustomPaint(
            painter: PaperPainter(_currentPaperStyle),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note['file_url'] != null)
                      _buildAttachmentBtn(note),
                    const SizedBox(height: 20),
                    Text(note['content'] ?? "", style: const TextStyle(fontSize: 18, height: 1.6)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBtn(Map<String, dynamic> note) {
    return ActionChip(
      avatar: Icon(note['file_type'] == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: Colors.white, size: 16),
      label: const Text("Open Attachment", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
      onPressed: () => launchUrl(Uri.parse(note['file_url'])),
    );
  }

  void _showNoteEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(hintText: "Title", border: InputBorder.none, hintStyle: TextStyle(fontWeight: FontWeight.bold))),
              TextField(controller: _contentController, decoration: const InputDecoration(hintText: "Note body...", border: InputBorder.none), maxLines: 5),
              if (_selectedFile != null) ListTile(leading: const Icon(Icons.attach_file, color: Colors.red), title: const Text("File attached"), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setModalState(() => _selectedFile = null))),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.image, color: Colors.red), onPressed: () async { await _pickImage(); setModalState(() {}); }),
                  IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () async { await _pickPDF(); setModalState(() {}); }),
                  const Spacer(),
                  ElevatedButton(onPressed: _saveNote, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Save", style: TextStyle(color: Colors.white))),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF4), // Subtle paper color
      appBar: AppBar(
        title: const Text("My Notebook", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<PaperType>(
            icon: const Icon(Icons.layers),
            onSelected: (val) => setState(() => _currentPaperStyle = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: PaperType.lines, child: Text("Ruled")),
              const PopupMenuItem(value: PaperType.squared, child: Text("Squared")),
              const PopupMenuItem(value: PaperType.blank, child: Text("Blank")),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return GestureDetector(
            onTap: () => _showNoteDetail(note),
            child: Card(
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: PaperPainter(_currentPaperStyle),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                      const Divider(color: Colors.red, thickness: 1),
                      Expanded(child: Text(note['content'], style: const TextStyle(fontSize: 12), maxLines: 5)),
                      if (note['file_url'] != null) const Align(alignment: Alignment.bottomRight, child: Icon(Icons.attachment, size: 14, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNoteEditor,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}