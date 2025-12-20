import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Use File? for Android
  File? _selectedFile;
  String? _selectedFileType;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- ANDROID OPTIMIZED PICKERS ---

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path); // Works on Android
        _selectedFileType = 'image';
      });
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!); // Works on Android
        _selectedFileType = 'pdf';
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      String? fileUrl;

      if (_selectedFile != null) {
        // Create a unique name for the file
        final extension = _selectedFileType == 'pdf' ? 'pdf' : 'jpg';
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final path = 'uploads/$fileName';

        // Upload the file from the Android path
        await supabase.storage.from('note-attachments').upload(path, _selectedFile!);
        fileUrl = supabase.storage.from('note-attachments').getPublicUrl(path);
      }

      final user = supabase.auth.currentUser;
      await supabase.from('notes').insert({
        'user_id': user!.id,
        'title': _titleController.text,
        'content': _contentController.text,
        'file_url': fileUrl,
        'file_type': _selectedFileType,
      });

      _titleController.clear();
      _contentController.clear();
      setState(() { _selectedFile = null; _selectedFileType = null; });
      Navigator.pop(context);
      _fetchNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  // --- UI BUILDING ---

  void _showNoteEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Note Title", border: InputBorder.none, hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: "Type your notes here...", border: InputBorder.none),
                maxLines: 5,
              ),
              if (_selectedFile != null)
                _buildFilePreview(setModalState),
              const Divider(),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.add_a_photo_outlined, color: Colors.blue), onPressed: () async { await _pickImage(); setModalState(() {}); }),
                  IconButton(icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red), onPressed: () async { await _pickPDF(); setModalState(() {}); }),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(Function setModalState) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(_selectedFileType == 'image' ? Icons.image : Icons.picture_as_pdf, color: Colors.blue),
          const SizedBox(width: 10),
          const Expanded(child: Text("Attachment ready", style: TextStyle(fontSize: 12))),
          IconButton(icon: const Icon(Icons.cancel), onPressed: () => setModalState(() => _selectedFile = null))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _notes.length,
        itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNoteEditor,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (note['file_url'] != null) launchUrl(Uri.parse(note['file_url']));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Expanded(child: Text(note['content'], style: const TextStyle(fontSize: 12), maxLines: 5, overflow: TextOverflow.ellipsis)),
              if (note['file_url'] != null)
                Icon(note['file_type'] == 'image' ? Icons.image : Icons.picture_as_pdf, size: 16, color: Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }
}