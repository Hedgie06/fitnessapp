
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/common.dart';
import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  static String routeName = "/WorkoutScheduleView";
  const WorkoutScheduleView({Key? key}) : super(key: key);

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  late DateTime _selectedDateAppBBar;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  Map<int, List<Map<String, dynamic>>> scheduledWorkouts = {};

  List eventArr = [
    {
      "name": "Ab Workout",
      "start_time": "22/06/2023 07:30 AM",
    },
    {
      "name": "Upperbody Workout",
      "start_time": "07/06/2023 09:00 AM",
    },
    {
      "name": "Lowerbody Workout",
      "start_time": "07/06/2023 03:00 PM",
    },
    {
      "name": "Ab Workout",
      "start_time": "08/06/2023 10:30 AM",
    },
    {
      "name": "Upperbody Workout",
      "start_time": "08/06/2023 09:00 AM",
    },
    {
      "name": "Lowerbody Workout",
      "start_time": "08/06/2023 03:00 PM",
    },
    {
      "name": "Ab Workout",
      "start_time": "09/06/2023 07:30 AM",
    },
    {
      "name": "Upperbody Workout",
      "start_time": "09/06/2023 09:00 AM",
    },
    {
      "name": "Lowerbody Workout",
      "start_time": "09/06/2023 03:00 PM",
    }
  ];

  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    setDayEventWorkoutList();
    _loadScheduledWorkouts();
  }

  Future<void> _loadScheduledWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get start and end of selected date
      final start = DateTime(_selectedDateAppBBar.year, _selectedDateAppBBar.month, _selectedDateAppBBar.day);
      final end = start.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(user.uid)
          .collection('scheduled')
          .where('dateTime', isGreaterThanOrEqualTo: start)  // Remove Timestamp.fromDate
          .where('dateTime', isLessThan: end)  // Remove Timestamp.fromDate
          .get();

      Map<int, List<Map<String, dynamic>>> newSchedule = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timeSlot = data['timeSlot'] as int;
        if (!newSchedule.containsKey(timeSlot)) {
          newSchedule[timeSlot] = [];
        }
        newSchedule[timeSlot]!.add({...data, 'id': doc.id});
      }

      setState(() {
        scheduledWorkouts = newSchedule;
      });
    }
  }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = eventArr.map((wObj) {
      return {
        "name": wObj["name"],
        "start_time": wObj["start_time"],
        "date": stringToDate(wObj["start_time"].toString(),
            formatStr: "dd/MM/yyyy hh:mm aa")
      };
    }).where((wObj) {
      return dateToStartDate(wObj["date"] as DateTime) == date;
    }).toList();

    if( mounted  ) {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Workout Schedule",
          style: TextStyle(
              color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateAppBBar = _selectedDateAppBBar.subtract(const Duration(days: 1));
                      setDayEventWorkoutList();
                      _loadScheduledWorkouts();
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateAppBBar,
                      firstDate: DateTime.now().subtract(const Duration(days: 140)),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDateAppBBar = picked;
                        setDayEventWorkoutList();
                        _loadScheduledWorkouts();
                      });
                    }
                  },
                  child: Text(
                    _dateFormat.format(_selectedDateAppBBar),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateAppBBar = _selectedDateAppBBar.add(const Duration(days: 1));
                      setDayEventWorkoutList();
                      _loadScheduledWorkouts();
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var timelineDataWidth = (media.width * 1.5) - (80 + 40);
                      var availWidth = (media.width * 1.2) - (80 + 40);
                      var slotArr = selectDayEventArr.where((wObj) {
                        return (wObj["date"] as DateTime).hour == index;
                      }).toList();

                      return _buildTimeSlot(index, availWidth);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: AppColors.grayColor.withOpacity(0.2),
                        height: 1,
                      );
                    },
                    itemCount: 24),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddScheduleView(
                    date: _selectedDateAppBBar,
                  )));
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlot(int hour, double availWidth) {
    final workouts = scheduledWorkouts[hour] ?? [];
    final timeString = "${hour.toString().padLeft(2, '0')}:00";
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,  // Increased height for better visibility
      decoration: BoxDecoration(
        color: hour % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          // Time indicator
          SizedBox(
            width: 60,
            child: Text(
              timeString,
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Workout indicators
          Expanded(
            child: workouts.isEmpty 
                ? Container(
                    height: 2,
                    color: Colors.grey.withOpacity(0.2),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.secondaryG),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              workout['workout'],
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${workout['difficulty']} • ${workout['repetitions']} reps",
                              style: TextStyle(
                                color: AppColors.whiteColor.withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
