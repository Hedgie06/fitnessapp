import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common_widgets/round_button.dart';
import '../../utils/common.dart';
import '../workour_detail_view/widgets/icon_title_next_row.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  DateTime selectedTime = DateTime.now();
  String selectedWorkout = "Upperbody";
  String selectedDifficulty = "Beginner";
  int repetitions = 10;
  double weights = 5.0;
  
  List<String> workoutTypes = ["Upperbody", "Lowerbody", "Fullbody", "Ab Workout"];
  List<String> difficultyLevels = ["Beginner", "Intermediate", "Advanced"];

  void _showWorkoutPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: ListView.builder(
          itemCount: workoutTypes.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(workoutTypes[index]),
            onTap: () {
              setState(() {
                selectedWorkout = workoutTypes[index];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: ListView.builder(
          itemCount: difficultyLevels.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(difficultyLevels[index]),
            onTap: () {
              setState(() {
                selectedDifficulty = difficultyLevels[index];
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showRepetitionsPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 40,
          onSelectedItemChanged: (index) {
            setState(() {
              repetitions = index + 1;
            });
          },
          children: List.generate(50, (index) => Center(
            child: Text("${index + 1} reps",
              style: TextStyle(color: AppColors.blackColor),
            ),
          )),
        ),
      ),
    );
  }

  void _showWeightsPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 40,
          onSelectedItemChanged: (index) {
            setState(() {
              weights = (index + 1) * 2.5;
            });
          },
          children: List.generate(40, (index) => Center(
            child: Text("${(index + 1) * 2.5} kg",
              style: TextStyle(color: AppColors.blackColor),
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Create a DateTime that combines the selected date and time
        final DateTime scheduleDateTime = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('scheduled')
            .add({
          'dateTime': scheduleDateTime,  // Store as DateTime directly
          'workout': selectedWorkout,
          'difficulty': selectedDifficulty,
          'repetitions': repetitions,
          'weights': weights,
          'status': 'scheduled',
          'timeSlot': selectedTime.hour,
          'created': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout scheduled successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule workout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/date.png",
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                          style: TextStyle(color: AppColors.grayColor, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Time",
                      style: TextStyle(
                          color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: media.width * 0.35,
                      child: CupertinoDatePicker(
                        onDateTimeChanged: (newTime) {
                          setState(() {
                            selectedTime = newTime;
                          });
                        },
                        initialDateTime: selectedTime,
                        use24hFormat: false,
                        minuteInterval: 1,
                        mode: CupertinoDatePickerMode.time,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Details Workout",
                      style: TextStyle(
                          color: AppColors.blackColor, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    IconTitleNextRow(
                        icon: "assets/icons/choose_workout.png",
                        title: "Choose Workout",
                        time: selectedWorkout,
                        color: AppColors.lightGrayColor,
                        onPressed: _showWorkoutPicker),
                    const SizedBox(
                      height: 10,
                    ),
                    IconTitleNextRow(
                        icon: "assets/icons/difficulity_icon.png",
                        title: "Difficulty",
                        time: selectedDifficulty,
                        color: AppColors.lightGrayColor,
                        onPressed: _showDifficultyPicker),
                    const SizedBox(
                      height: 10,
                    ),
                    IconTitleNextRow(
                        icon: "assets/icons/repetitions.png",
                        title: "Custom Repetitions",
                        time: "$repetitions reps",
                        color: AppColors.lightGrayColor,
                        onPressed: _showRepetitionsPicker),
                    const SizedBox(
                      height: 10,
                    ),
                    IconTitleNextRow(
                        icon: "assets/icons/repetitions.png",
                        title: "Custom Weights",
                        time: "$weights kg",
                        color: AppColors.lightGrayColor,
                        onPressed: _showWeightsPicker),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: RoundGradientButton(
                title: "Save",
                onPressed: _saveWorkout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}