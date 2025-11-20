import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  // Initial settings (in minutes)
  int _studyDurationMinutes = 25;
  int _breakDurationMinutes = 5;

  // Timer state
  late int _timeLeft; // Time left in seconds
  bool _isRunning = false;
  late Timer _timer;
  bool _isStudyMode = true; // true for study, false for break

  @override
  void initState() {
    super.initState();
    _timeLeft = _studyDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Timer Formatting
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Main Timer Logic
  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        // Time is up!
        _timer.cancel();
        _isRunning = false;

        // Show a message and switch modes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isStudyMode
                  ? 'Time for a break! Take 5 minutes.'
                  : 'Break over! Back to studying.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 4),
          ),
        );

        // Switch mode and reset time
        setState(() {
          _isStudyMode = !_isStudyMode;
          _timeLeft = (_isStudyMode ? _studyDurationMinutes : _breakDurationMinutes) * 60;
        });
      }
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _isStudyMode = true;
      _timeLeft = _studyDurationMinutes * 60;
    });
  }

  // Function to build an increment/decrement control for settings
  Widget _buildSettingControl({
    required String label,
    required int value,
    required Function(int) onUpdate,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrement Button
            _buildIconButton(
              icon: Icons.remove,
              onPressed: value > 1 ? () => onUpdate(value - 1) : null,
              color: value > 1 ? Theme.of(context).primaryColor : Colors.grey,
            ),

            // Value Display
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ),

            // Increment Button
            _buildIconButton(
              icon: Icons.add,
              onPressed: value < 60 ? () => onUpdate(value + 1) : null,
              color: value < 60 ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  // Helper for consistent button styling
  Widget _buildIconButton({required IconData icon, required VoidCallback? onPressed, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress for the progress indicator
    int totalTime = _isStudyMode ? _studyDurationMinutes * 60 : _breakDurationMinutes * 60;
    // Calculate the fractional amount remaining (1.0 is full, 0.0 is empty)
    double progress = totalTime > 0 ? (_timeLeft / totalTime) : 1.0;

    // The LinearProgressIndicator shows time elapsed, so we need the inverse for the bar fill.
    // The bar fills as time decreases (from left to right)
    double linearProgressValue = progress;

    // Determine the color scheme for the timer box
    final primaryColor = Theme.of(context).primaryColor;
    const timerTextColor = Colors.white;

    // --- FIX: Create a darker color manually since primaryColor is a simple Color, not a MaterialColor swatch. ---
    final darkerPrimaryColor = Color.fromARGB(
      primaryColor.alpha,
      (primaryColor.red * 0.7).round().clamp(0, 255), // Darken the red component
      (primaryColor.green * 0.7).round().clamp(0, 255), // Darken the green component
      (primaryColor.blue * 0.7).round().clamp(0, 255), // Darken the blue component
    );
    // --- END FIX ---


    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _isStudyMode ? 'FOCUS TIME' : 'BREAK TIME',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                // --- RECTANGULAR TIMER BOX WITH GRADIENT AND LINEAR PROGRESS ---
                Container(
                  width: double.infinity, // Take max width from ConstrainedBox (500)
                  height: 200, // Fixed height for a sleek rectangular look
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Apply the fixed gradient using the theme color and the manually darkened color
                    gradient: LinearGradient(
                      colors: [primaryColor, darkerPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Linear Progress Bar at the top
                      Align(
                        alignment: Alignment.topCenter,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: linearProgressValue),
                            duration: const Duration(milliseconds: 900),
                            builder: (context, value, child) {
                              // FIX: Use primaryColor for the background color instead of a shade
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 8, // Thin progress bar height
                                backgroundColor: primaryColor.withOpacity(0.3), // Changed to primaryColor.withOpacity
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade200), // Accent color for progress
                              );
                            },
                          ),
                        ),
                      ),

                      // Time Display (Centered)
                      Center(
                        child: Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            fontSize: 110, // Max font size for prominence
                            fontWeight: FontWeight.w200, // Thin font weight for clean look
                            color: timerTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- TIMER CONTROL BUTTONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start/Pause Button
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 30),
                      label: Text(_isRunning ? 'Pause' : (_timeLeft == (_isStudyMode ? _studyDurationMinutes : _breakDurationMinutes) * 60 ? 'Start' : 'Resume')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.orange.shade700 : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Reset Button
                    ElevatedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh, size: 30, color: Colors.black54),
                      label: const Text('Reset', style: TextStyle(color: Colors.black54)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // --- SETTINGS CONTROLS ---
                const Text(
                  'Adjust Durations',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Study Length Setting
                    _buildSettingControl(
                      label: 'Study Length (min)',
                      value: _studyDurationMinutes,
                      onUpdate: (newValue) {
                        if (!_isRunning) {
                          setState(() {
                            _studyDurationMinutes = newValue;
                            // Only reset time if it's currently in study mode
                            if (_isStudyMode) _timeLeft = newValue * 60;
                          });
                        }
                      },
                    ),

                    // Break Length Setting
                    _buildSettingControl(
                      label: 'Break Length (min)',
                      value: _breakDurationMinutes,
                      onUpdate: (newValue) {
                        if (!_isRunning) {
                          setState(() {
                            _breakDurationMinutes = newValue;
                            // Only reset time if it's currently in break mode
                            if (!_isStudyMode) _timeLeft = newValue * 60;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}