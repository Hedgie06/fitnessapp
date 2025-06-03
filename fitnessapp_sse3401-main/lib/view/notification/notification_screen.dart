import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/notification/widgets/notification_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = "/NotificationScreen";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notificationArr = [
    {
      "image": "assets/images/Workout1.png",
      "title": "Morning Workout Reminder",
      "time": "7:00 AM",
      "description": "Start your day with an energizing workout session"
    },
    {
      "image": "assets/images/Workout2.png", 
      "title": "Breakfast Time",
      "time": "8:00 AM",
      "description": "Time for a healthy breakfast (300-400 calories)"
    },
    {
      "image": "assets/images/Workout3.png",
      "title": "Mid-Morning Snack",
      "time": "10:30 AM",
      "description": "Have a light snack (150 calories)"
    },
    {
      "image": "assets/images/Workout1.png",
      "title": "Lunch Reminder",
      "time": "1:00 PM",
      "description": "Time for lunch (500-600 calories)"
    },
    {
      "image": "assets/images/Workout2.png",
      "title": "Afternoon Workout",
      "time": "4:00 PM",
      "description": "Complete your cardio session"
    },
    {
      "image": "assets/images/Workout3.png",
      "title": "Pre-Workout Snack",
      "time": "3:30 PM",
      "description": "Light protein snack (200 calories)"
    },
    {
      "image": "assets/images/Workout1.png",
      "title": "Post-Workout Meal",
      "time": "5:30 PM",
      "description": "Protein-rich recovery meal (400 calories)"
    },
    {
      "image": "assets/images/Workout2.png",
      "title": "Dinner Time",
      "time": "7:30 PM",
      "description": "Light dinner (400-500 calories)"
    },
    {
      "image": "assets/images/Workout3.png",
      "title": "Daily Calorie Check",
      "time": "9:00 PM",
      "description": "Review your daily calorie intake target"
    },
    {
      "image": "assets/images/Workout1.png",
      "title": "Bedtime Reminder",
      "time": "10:00 PM",
      "description": "Avoid eating close to bedtime for better sleep"
    }
  ];

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            "Daily Reminders",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700),
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
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
            )
          ],
        ),
        body: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            itemBuilder: ((context, index) {
              var nObj = notificationArr[index] as Map? ?? {};
              return NotificationRow(nObj: nObj);
            }),
            separatorBuilder: (context, index) {
              return Divider(
                color: AppColors.grayColor.withOpacity(0.5),
                height: 1,
              );
            },
            itemCount: notificationArr.length));
  }
}
