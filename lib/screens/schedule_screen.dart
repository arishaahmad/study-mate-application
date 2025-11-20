import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Get Supabase client
  final supabase = Supabase.instance.client;

  // This list stores the classes.
  // Structure: {'id': '...', 'day': 'Mon', 'time': '08:40 - 09:30', 'code': '...', 'room': '...'}
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = true;

  // Hardcoded Time Slots (Rows) - Must match exactly what you save
  final List<String> _timeSlots = [
    "08:40 - 09:30",
    "09:40 - 10:30",
    "10:40 - 11:30",
    "11:40 - 12:30",
    "12:40 - 13:30",
    "13:40 - 14:30",
    "14:40 - 15:30",
    "15:40 - 16:30",
    "16:40 - 17:30",
    "17:40 - 18:30",
    "18:40 - 19:30",
    "19:40 - 20:30",
  ];

  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  // --- SUPABASE FUNCTIONS ---

  Future<void> _fetchClasses() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('schedules')
          .select()
          .eq('user_id', userId);

      setState(() {
        // Map the Supabase response to our list
        _myClasses = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading schedule: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addClassToSupabase(String day, String time, String code, String room) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Insert into Supabase
      final response = await supabase.from('schedules').insert({
        'user_id': userId,
        'day': day,
        'time_slot': time,
        'course_code': code,
        'room': room,
      }).select(); // .select() returns the inserted row including the new ID

      // 2. Update Local State
      setState(() {
        _myClasses.add(response.first);
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding class: $e')));
      }
    }
  }

  Future<void> _deleteClassFromSupabase(String id) async {
    try {
      // 1. Delete from Supabase
      await supabase.from('schedules').delete().eq('id', id);

      // 2. Update Local State
      setState(() {
        _myClasses.removeWhere((element) => element['id'] == id);
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting class: $e')));
      }
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(110),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(100),
                    3: FixedColumnWidth(100),
                    4: FixedColumnWidth(100),
                    5: FixedColumnWidth(100),
                    6: FixedColumnWidth(100),
                    7: FixedColumnWidth(100),
                  },
                  border: TableBorder.all(color: Colors.grey.shade300),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // HEADER ROW
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: [
                        _buildHeaderCell("Time"),
                        ..._days.map((day) => _buildHeaderCell(day)),
                      ],
                    ),
                    // DATA ROWS
                    ..._timeSlots.asMap().entries.map((entry) {
                      String timeText = entry.value;
                      return TableRow(
                        children: [
                          _buildTimeCell(timeText),
                          ..._days.map((day) => _buildClassCell(day, timeText)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildTimeCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
    );
  }

  Widget _buildClassCell(String day, String time) {
    // Find class match in our list
    final classData = _myClasses.firstWhere(
          (c) => c['day'] == day && c['time_slot'] == time,
      orElse: () => {},
    );

    if (classData.isEmpty) {
      return const SizedBox(height: 60);
    }

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(classData),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF8BC34A), // Green
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              classData['course_code'] ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
            ),
            Text(
              classData['room'] ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---

  void _showDeleteDialog(Map<String, dynamic> classData) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Remove Class?"),
          content: Text("Remove ${classData['course_code']} from schedule?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  _deleteClassFromSupabase(classData['id']);
                  Navigator.pop(ctx);
                },
                child: const Text("Remove", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  void _showAddClassDialog() {
    String selectedDay = _days[0];
    String selectedTime = _timeSlots[0];
    final codeController = TextEditingController();
    final roomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Add Class"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: "Course Code (e.g. CNG 465)"),
                      ),
                      TextField(
                        controller: roomController,
                        decoration: const InputDecoration(labelText: "Room (e.g. TZ-22)"),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text("Day: "),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: selectedDay,
                            items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (val) => setDialogState(() => selectedDay = val!),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Time: "),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: selectedTime,
                            items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t.split(' ')[0]))).toList(),
                            onChanged: (val) => setDialogState(() => selectedTime = val!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (codeController.text.isNotEmpty) {
                        // Call the Supabase Function
                        _addClassToSupabase(
                            selectedDay,
                            selectedTime,
                            codeController.text,
                            roomController.text
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            }
        );
      },
    );
  }
}