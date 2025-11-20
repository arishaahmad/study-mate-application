import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Get the Supabase client instance
final supabase = Supabase.instance.client;

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;

  // Storing the stream as a late variable ensures it is initialized once.
  // This is the key fix for maintaining a single, continuous real-time connection,
  // preventing the need to exit and re-enter the screen for updates.
  late final Stream<List<Map<String, dynamic>>> _todosStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream only once when the widget is created
    _todosStream = _getTodosStream();
  }

  // Method to fetch the real-time stream of To-Do items for the current user.
  Stream<List<Map<String, dynamic>>> _getTodosStream() {
    // Using the stream() method for real-time updates from Supabase.
    return supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true) // Sort by creation time
        .map((dataList) => dataList.cast<Map<String, dynamic>>());
  }

  // Function to open the date picker
  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Red theme color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  // Method to add a new task
  Future<void> _addTask() async {
    final taskText = _taskController.text.trim();
    final userId = supabase.auth.currentUser?.id; // Check for user ID

    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task description.')),
      );
      return;
    }

    // Check if user is logged in before inserting
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: You must be logged in to add a task.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await supabase.from('todos').insert({
        'user_id': userId,
        'task': taskText,
        'is_complete': false,
        'due_date': _selectedDueDate?.toIso8601String(), // Add due date
      });

      _taskController.clear(); // Clear the input field
      setState(() {
        _selectedDueDate = null; // Clear the selected date
      });

    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: Database or RLS error. ${e.toString()}')),
      );
    }
  }

  // Method to toggle the completion status of a task
  Future<void> _toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      // This database update correctly triggers the Supabase real-time stream.
      await supabase.from('todos').update({
        'is_complete': !currentStatus,
      }).eq('id', taskId);
      // NO setState() is needed here. The StreamBuilder handles the UI refresh instantly.
    } catch (e) {
      print('Error toggling task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: ${e.toString()}')),
      );
    }
  }

  // Method to delete a task
  Future<void> _deleteTask(String taskId) async {
    try {
      await supabase.from('todos').delete().eq('id', taskId);
      // UI updates automatically
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: ${e.toString()}')),
      );
    }
  }

  // Helper widget to build a single task tile
  Widget _buildTaskTile(Map<String, dynamic> task) {
    final primaryColor = Theme.of(context).primaryColor;
    final taskId = task['id'] as String;
    final taskText = task['task'] as String;
    final isComplete = task['is_complete'] as bool;
    final dueDateRaw = task['due_date'];
    DateTime? dueDate;

    // Safely parse the due date string
    if (dueDateRaw is String) {
      // Convert to local time for accurate comparison/display
      dueDate = DateTime.tryParse(dueDateRaw)?.toLocal();
    }

    // Check if the due date is in the past
    final bool isOverdue = dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Dismissible(
      key: ValueKey(taskId), // Unique key for the task
      direction: DismissDirection.endToStart, // Swipe right-to-left
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this task?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("CANCEL", style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                  ),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteTask(taskId);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          // Checkbox to toggle completion status
            leading: Checkbox(
              value: isComplete,
              onChanged: (bool? newValue) {
                // Trigger the database update
                _toggleTaskStatus(taskId, isComplete);
              },
              activeColor: primaryColor,
            ),

            // Task Text and Due Date
            title: Text(
              taskText,
              style: TextStyle(
                fontSize: 16,
                decoration: isComplete ? TextDecoration.lineThrough : null,
                color: isComplete ? Colors.grey.shade600 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: dueDate != null
                ? Text(
              'Due: ${DateFormat.yMMMd().format(dueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: isComplete ? Colors.grey : (isOverdue ? Colors.red.shade600 : Colors.black54),
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            )
                : const Text('No Due Date', style: TextStyle(fontSize: 12, color: Colors.black45)),

            // Swipe indicator
            trailing: Icon(
              Icons.drag_handle,
              color: Colors.grey.shade300,
            ),

            onTap: () {
              // Tapping also toggles the status
              _toggleTaskStatus(taskId, isComplete);
            }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Study To-Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: <Widget>[
              // --- TASK INPUT AREA ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        // Text Field for new task
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              labelText: 'Add a new task...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              prefixIcon: Icon(Icons.note_add_outlined, color: primaryColor),
                            ),
                            onSubmitted: (value) => _addTask(), // Allows adding task via keyboard enter
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Add Button
                        SizedBox(
                          height: 56, // Match height of TextField
                          child: ElevatedButton(
                            onPressed: _addTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // DUE DATE SELECTOR
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDueDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                              ),
                              child: Text(
                                _selectedDueDate == null
                                    ? 'No Date Selected'
                                    : DateFormat.yMMMd().format(_selectedDueDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Clear Date Button
                        if (_selectedDueDate != null)
                          IconButton(
                            onPressed: () => setState(() => _selectedDueDate = null),
                            icon: const Icon(Icons.clear, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- TO-DO LIST STREAM BUILDER ---
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  // Using the initialized stream from initState for stability and real-time updates
                  stream: _todosStream,
                  builder: (context, snapshot) {
                    // 1. Error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading tasks: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // 2. Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    // 3. Data available state
                    final tasks = snapshot.data;

                    if (tasks == null || tasks.isEmpty) {
                      // Empty state
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            const Text(
                              'You have no tasks! Time to start adding.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    // 4. List View of Tasks
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskTile(tasks[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}