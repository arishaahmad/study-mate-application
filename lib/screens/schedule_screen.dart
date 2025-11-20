import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // --- STATE VARIABLES ---

  // This list stores the classes added by the user.
  // Each item is a Map: {'day': 'Mon', 'time': '08:40 - 09:30', 'code': '...','room': '...'}
  final List<Map<String, String>> _myClasses = [];

  // Hardcoded Time Slots (Rows)
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

  // Hardcoded Days (Columns)
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

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
      // Floating Button to Add Classes
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        // Scroll 1: Vertical (Time)
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Scroll 2: Horizontal (Days)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  // Column Widths: Time is wider (110), Days are 100
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
                    // 1. HEADER ROW (Days)
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: [
                        _buildHeaderCell("Time"),
                        ..._days.map((day) => _buildHeaderCell(day)),
                      ],
                    ),

                    // 2. DATA ROWS (Time Slots)
                    ..._timeSlots.asMap().entries.map((entry) {
                      // int timeIndex = entry.key;
                      String timeText = entry.value;

                      return TableRow(
                        children: [
                          _buildTimeCell(timeText),
                          // Create a cell for each day (Mon-Sun)
                          ..._days.map((day) => _buildClassCell(day, timeText)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
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
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildTimeCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildClassCell(String day, String time) {
    // Find if there is a class at this Day & Time
    final classData = _myClasses.firstWhere(
          (c) => c['day'] == day && c['time'] == time,
      orElse: () => {}, // Return empty map if not found
    );

    if (classData.isEmpty) {
      return const SizedBox(height: 60); // Empty cell
    }

    return GestureDetector(
      onLongPress: () => _deleteClass(classData), // Option to delete on long press
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF8BC34A), // Green color
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              classData['code'] ?? '',
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

  // --- LOGIC FUNCTIONS ---

  void _deleteClass(Map<String, String> classData) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Remove Class?"),
          content: Text("Remove ${classData['code']} from schedule?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  setState(() {
                    _myClasses.remove(classData);
                  });
                  Navigator.pop(ctx);
                },
                child: const Text("Remove", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  void _showAddClassDialog() {
    // Temporary variables to store form input
    String selectedDay = _days[0];
    String selectedTime = _timeSlots[0];
    final codeController = TextEditingController();
    final roomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder is needed to update Dropdowns inside the Dialog
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
                            items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t.split(' ')[0]))).toList(), // Show only start time for brevity
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
                        // Save to the main state
                        setState(() {
                          // Remove any existing class in that slot first to avoid overlap (optional)
                          _myClasses.removeWhere((c) => c['day'] == selectedDay && c['time'] == selectedTime);

                          // Add new class
                          _myClasses.add({
                            'day': selectedDay,
                            'time': selectedTime,
                            'code': codeController.text,
                            'room': roomController.text,
                          });
                        });
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