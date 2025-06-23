import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity/widgets/upcoming_workout_row.dart';
import 'package:fitnessapp/view/activity/widgets/what_train_row.dart';
import 'package:fitnessapp/view/workour_detail_view/ABworkoutDetailView.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/view/workout_schedule_view/workout_schedule_view.dart';  // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_button.dart';
import '../workour_detail_view/workour_detail_view.dart';
import '../workour_detail_view/FullBodyWorkoutDetailView.dart';
import '../workour_detail_view/LowerBodyDetailView.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {

  List<Map<String, dynamic>> upcomingWorkouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingWorkouts();
  }

  Future<void> _loadUpcomingWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get current date at start of day
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfWeek = startOfDay.add(const Duration(days: 7));

        final snapshot = await FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('scheduled')
            .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
            .where('dateTime', isLessThan: endOfWeek)
            .orderBy('dateTime')
            .limit(5)  // Limit to next 5 workouts
            .get();

        setState(() {
          upcomingWorkouts = snapshot.docs
              .map((doc) => {
                    ...doc.data(),
                    'id': doc.id,
                    'image': _getWorkoutImage(doc.data()['workout']),
                  })
              .toList();
          isLoading = false;
        });
      } catch (e) {
        print("Error loading workouts: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getWorkoutImage(String workoutType) {
    // Map workout types to their respective images
    switch (workoutType.toLowerCase()) {
      case 'upperbody':
        return "assets/images/Workout1.png";
      case 'lowerbody':
        return "assets/images/Workout2.png";
      case 'ab workout':
        return "assets/images/Workout3.png";
      default:
        return "assets/images/Workout1.png";
    }
  }

  List whatArr = [
    {
      "image": "assets/images/what_1.png",
      "title": "Upper Body Workout",
      "exercises": "10 Exercises",
      "time": "40mins"
    },
    {
      "image": "assets/images/what_2.png",
      "title": "Lower Body Workout",
      "exercises": "5 Exercises",
      "time": "30mins"
    },
    {
      "image": "assets/images/what_3.png",
      "title": "AB Workout",
      "exercises": "8 Exercises",
      "time": "30mins"
    },
    {
      "image": "assets/images/what_1.png",
      "title": "Full Body Workout",
      "exercises": "11 Exercises",
      "time": "45mins"
    }
  ];

  List whatTrainList = [
    {
      "title": "Upper Body",
      "exercises": "10 Exercises",
      "time": "40 Minutes",
      "image": "assets/images/Workout1.png",
    },
    {
      "title": "Lower Body",
      "exercises": "5 Exercises",
      "time": "30 Minutes",
      "image": "assets/images/Workout2.png",
    },
    {
      "title": "Ab Workout",
      "exercises": "8 Exercises",
      "time": "30 Minutes",
      "image": "assets/images/Workout3.png",
    },
    {
      "title": "Full Body",
      "exercises": "11 Exercises",
      "time": "45 Minutes",
      "image": "assets/images/Workout1.png",
    }
  ];

  void _handleSeeMore() {
    // You can navigate to a workout list screen or show more workouts
    Navigator.pushNamed(context, '/WorkoutListScreen');  // Implement this route
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
              title: const Text(
                "Workout Tracker",
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ];
        },
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.grayColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 15),  // Adjusted padding
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(  // Added Expanded
                          child: Text(
                            "Daily Workout Schedule",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(  // Wrapped in Container for better control
                          width: 80,  // Fixed width
                          height: 30,  // Fixed height
                          child: RoundButton(
                            title: "Check",
                            type: RoundButtonType.bgGradient,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                WorkoutScheduleView.routeName
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Workout",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : upcomingWorkouts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "No upcoming workouts scheduled",
                                  style: TextStyle(color: AppColors.grayColor),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: upcomingWorkouts.length,
                              itemBuilder: (context, index) {
                                final workout = upcomingWorkouts[index];
                                final dateTime = (workout['dateTime'] as Timestamp).toDate();
                                final formattedTime = DateFormat('MMM dd, hh:mm a').format(dateTime);
                                
                                return UpcomingWorkoutRow(
                                  wObj: {
                                    "image": workout['image'],
                                    "title": "${workout['workout']} - ${workout['difficulty']}",
                                    "time": formattedTime,
                                    "repetitions": workout['repetitions'],
                                    "weights": workout['weights'],
                                  },
                                );
                              },
                            ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "What Do You Want to Train",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                 ListView.builder(
  padding: EdgeInsets.zero,
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: whatArr.length,
  itemBuilder: (context, index) {
    var wObj = whatArr[index] as Map? ?? {};
    String workoutType = wObj["title"] ?? "";
return InkWell(
  onTap: () {
    if (workoutType.toLowerCase() == "upper body workout") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WorkoutDetailView(dObj: wObj)),
      );
    } else if (workoutType.toLowerCase() == "lower body workout") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LowerBodyWorkoutDetailView(dObj: wObj)), // Make sure this class exists
      );
    } else if (workoutType.toLowerCase() == "ab workout") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ABWorkoutDetailView(dObj: wObj)), // Make sure this class exists
      );
    } else if (workoutType.toLowerCase() == "full body workout") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FullBodyWorkoutDetailView(dObj: wObj)), // Make sure this class exists
      );
    }
  },
  child: WhatTrainRow(wObj: wObj),
);
  },
),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          )),
      ),
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
    ),
  );

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    color: AppColors.whiteColor,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 35),
      FlSpot(2, 70),
      FlSpot(3, 40),
      FlSpot(4, 80),
      FlSpot(5, 25),
      FlSpot(6, 70),
      FlSpot(7, 35),
    ],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    color: AppColors.whiteColor.withOpacity(0.5),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: false,
    ),
    spots: const [
      FlSpot(1, 80),
      FlSpot(2, 50),
      FlSpot(3, 90),
      FlSpot(4, 40),
      FlSpot(5, 80),
      FlSpot(6, 35),
      FlSpot(7, 60),
    ],
  );

  SideTitles get rightTitles => SideTitles(
    getTitlesWidget: rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: AppColors.whiteColor,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }
    return text;
  }
}
