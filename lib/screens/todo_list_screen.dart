import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;

  // We use a StreamController to allow manual refreshes + live updates
  late Stream<List<Map<String, dynamic>>> _todosStream;

  final List<String> _tempDeletedIds = [];

  @override
  void initState() {
    super.initState();
    // Initialize the stream normally
    _todosStream = _getTodosStream();
  }

  Stream<List<Map<String, dynamic>>> _getTodosStream() {
    return supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((dataList) => dataList.cast<Map<String, dynamic>>());
  }

  // FORCE REFRESH FUNCTION
  void _refreshTasks() {
    setState(() {
      _todosStream = _getTodosStream();
    });
  }

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
              primary: Theme.of(context).primaryColor,
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

  Future<void> _addTask() async {
    final taskText = _taskController.text.trim();
    final userId = supabase.auth.currentUser?.id;

    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a task description.')));
      return;
    }
    if (userId == null) return;

    // 1. Clear UI immediately for better feel
    _taskController.clear();
    setState(() => _selectedDueDate = null);

    try {
      // 2. Insert to Database
      await supabase.from('todos').insert({
        'user_id': userId,
        'task': taskText,
        'is_complete': false,
        'due_date': _selectedDueDate?.toIso8601String(),
      });

      // 3. FORCE REFRESH: This makes it show up instantly
      _refreshTasks();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
    }
  }

  Future<void> _toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      await supabase.from('todos').update({'is_complete': !currentStatus}).eq('id', taskId);
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await supabase.from('todos').delete().eq('id', taskId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
    }
  }

  Widget _buildTaskTile(Map<String, dynamic> task) {
    final primaryColor = Theme.of(context).primaryColor;
    final taskId = task['id'] as String;
    final taskText = task['task'] as String;
    final isComplete = task['is_complete'] as bool;
    final dueDateRaw = task['due_date'];
    DateTime? dueDate;

    if (dueDateRaw is String) {
      dueDate = DateTime.tryParse(dueDateRaw)?.toLocal();
    }
    final bool isOverdue = dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Dismissible(
      key: Key(taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        // Hide instantly
        setState(() {
          _tempDeletedIds.add(taskId);
        });
        // Delete in background
        _deleteTask(taskId);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Checkbox(
            value: isComplete,
            onChanged: (bool? newValue) => _toggleTaskStatus(taskId, isComplete),
            activeColor: primaryColor,
          ),
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
          trailing: Icon(Icons.drag_handle, color: Colors.grey.shade300),
          onTap: () => _toggleTaskStatus(taskId, isComplete),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study To-Do List', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              labelText: 'Add a new task...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                              prefixIcon: Icon(Icons.note_add_outlined, color: primaryColor),
                            ),
                            onSubmitted: (value) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _addTask,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 5),
                            child: const Icon(Icons.add, color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDueDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                              ),
                              child: Text(
                                _selectedDueDate == null ? 'No Date Selected' : DateFormat.yMMMd().format(_selectedDueDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _todosStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));

                    final allTasks = snapshot.data ?? [];
                    final visibleTasks = allTasks.where((task) => !_tempDeletedIds.contains(task['id'])).toList();

                    if (visibleTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            const Text('You have no tasks! Time to start adding.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: visibleTasks.length,
                      itemBuilder: (context, index) => _buildTaskTile(visibleTasks[index]),
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