import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

class LowerBodyWorkoutDetailView extends StatelessWidget {
  final Map dObj;

  LowerBodyWorkoutDetailView({Key? key, required this.dObj}) : super(key: key);

  List exercisesArr = [
  {
  "name": "Lower Body – With Dumbbells",
  "set": [
    { "image": "assets/images/warmUp.png", "title": "Warm Up", "value": "05:00" },
    { "image": "assets/images/dumbbellSquats.png", "title": "Dumbbell Squats", "value": "15x" },
    { "image": "assets/images/dumbbellLunges.png", "title": "Dumbbell Lunges", "value": "10x (each leg)" },
    { "image": "assets/images/dumbbellDeadlifts.png", "title": "Dumbbell Deadlifts", "value": "12x" },
    { "image": "assets/images/rest.png", "title": "Rest and Hydrate", "value": "01:00" },
    { "image": "assets/images/coolingDown.png", "title": "Cool Down Stretch", "value": "02:00" }
  ]
},
   {
  "name": "Lower Body – No Equipment",
  "set": [
    { "image": "assets/images/warmUp.png", "title": "Warm Up", "value": "05:00" },
    { "image": "assets/images/dumbbellSquats.png", "title": "Bodyweight Squats", "value": "15x" },
    { "image": "assets/images/wallSit.png", "title": "Wall Sit", "value": "00:45" },
    { "image": "assets/images/calfRaise.png", "title": "Calf Raises", "value": "20x" },
    { "image": "assets/images/rest.png", "title": "Rest and Hydrate", "value": "01:00" },
    { "image": "assets/images/coolingDown.png", "title": "Cool Down Stretch", "value": "02:00" }
  ]
}
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Lower Body Workout",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryG),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: media.width * 0.05),

              // Larger "Lower Body Workout" Title
              Text(
                "Lower Body Workout",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 36,  // Increased font size for prominence
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,  // Add some space between letters for style
                ),
              ),
              
              SizedBox(height: media.width * 0.05),
              Text(
                "${dObj["exercises"].toString()} | ${dObj["time"].toString()} | 320 Calories Burn",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: media.width * 0.05),


              // Displaying Exercises (Still Inside Cards)
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: exercisesArr.length,
                itemBuilder: (context, index) {
                  var sObj = exercisesArr[index] as Map? ?? {};
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sObj["name"].toString(),
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              itemCount: sObj["set"].length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var exercise = sObj["set"][index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        exercise["image"],
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "${exercise["title"]} - ${exercise["value"]}",
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: media.width * 0.1),

              // Centralized Workout Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Workout Description",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "This lower body workout targets your legs, glutes, and core. It will enhance strength, mobility, and endurance. The exercises included will provide a full lower body burn.",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
