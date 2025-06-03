import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class WorkoutSessionScreen extends StatefulWidget {
  final Map workoutData;
  static String routeName = "/WorkoutSessionScreen";

  const WorkoutSessionScreen({Key? key, required this.workoutData}) : super(key: key);

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  int _currentExerciseIndex = 0;
  List<Map<String, dynamic>> exercises = [];
  String _selectedWorkout = "";
  List<Map<String, dynamic>> _availableWorkouts = [];
  int _heartRate = 70; // Starting resting heart rate
  double _caloriesBurned = 0;
  Timer? _vitalTimer;
  Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadAvailableWorkouts();
  }

  Future<void> _loadAvailableWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        
        final snapshot = await FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('scheduled')
            .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
            .orderBy('dateTime')
            .get();

        setState(() {
          _availableWorkouts = snapshot.docs
              .where((doc) => doc.data()['workout'] != null) // Filter out null workouts
              .map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'name': data['workout'],
                  'difficulty': data['difficulty'] ?? 'Normal',
                  'time': DateFormat('hh:mm a').format((data['dateTime'] as Timestamp).toDate()),
                };
              })
              .toList();
          
          // If we have workouts and none selected, select the first one
          if (_availableWorkouts.isNotEmpty && _selectedWorkout.isEmpty) {
            _selectedWorkout = _availableWorkouts[0]['id'];
          }
        });
      } catch (e) {
        print("Error loading workouts: $e");
      }
    }
  }

  void _startVitalsSimulation() {
    _vitalTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_isRunning) return;

      setState(() {
        // Simulate heart rate between 120-170 BPM during exercise
        // With small random fluctuations
        _heartRate = _heartRate < 120 
            ? _heartRate + _random.nextInt(10) // Gradual increase
            : 120 + _random.nextInt(50); // Maintain exercise range

        // Cap heart rate at 170 BPM
        if (_heartRate > 170) _heartRate = 170;

        // Calculate calories burned based on intensity
        // Roughly 7-12 calories per minute depending on heart rate
        double intensityFactor = (_heartRate - 120) / 50; // 0 to 1 scale
        double baseCaloriesPerMinute = 7 + (5 * intensityFactor);
        _caloriesBurned += baseCaloriesPerMinute / 30; // Per 2 seconds
      });
    });
  }

  void _startTimer() {
    if (_selectedWorkout.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a workout first')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });

    _startVitalsSimulation(); // Start vitals monitoring
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      // Gradually decrease heart rate when paused
      _vitalTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        setState(() {
          _heartRate = _heartRate - 5;
          if (_heartRate <= 70) {
            _heartRate = 70;
            _vitalTimer?.cancel();
          }
        });
      });
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _currentExerciseIndex = 0;
      _heartRate = 70;
      _caloriesBurned = 0;
    });
    _timer?.cancel();
    _vitalTimer?.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vitalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(
          "Workout Session",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_availableWorkouts.isNotEmpty) Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedWorkout.isNotEmpty ? _selectedWorkout : null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Select Workout",
                ),
                items: _availableWorkouts.map((workout) {
                  return DropdownMenuItem<String>(
                    value: workout['id'],
                    child: Text(
                      "${workout['name']} (${workout['difficulty']}) - ${workout['time']}",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWorkout = newValue;
                    });
                  }
                },
              ),
            ),

            // Timer Display
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: TextStyle(
                      fontSize: 48,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(
                        icon: _isRunning ? Icons.pause : Icons.play_arrow,
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                      ),
                      _buildCircularButton(
                        icon: Icons.stop,
                        onPressed: _resetTimer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    "Calories",
                    "${(_seconds * 0.4).toStringAsFixed(1)} kcal",
                    Icons.local_fire_department,
                  ),
                  SizedBox(width: 15),
                  _buildStatCard(
                    "Heart Rate",
                    "-- BPM",
                    Icons.favorite,
                  ),
                ],
              ),
            ),

            // Workout Notes - Modified
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Workout Notes",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: media.height * 0.15,
                    ),
                    child: TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Add notes about your workout...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: AppColors.whiteColor,
      ),
      child: Icon(
        icon,
        size: 30,
        color: AppColors.primaryColor1,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    String displayValue = value;
    Color valueColor = AppColors.blackColor;

    if (title == "Heart Rate") {
      displayValue = "$_heartRate BPM";
      // Color code heart rate
      if (_heartRate < 120) valueColor = Colors.green;
      else if (_heartRate < 150) valueColor = Colors.orange;
      else valueColor = Colors.red;
    } else if (title == "Calories") {
      displayValue = "${_caloriesBurned.toStringAsFixed(1)} kcal";
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.primaryColor2.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor1),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grayColor,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
