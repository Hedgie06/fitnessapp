import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class UpcomingWorkoutRow extends StatelessWidget {
  final Map wObj;

  const UpcomingWorkoutRow({Key? key, required this.wObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = wObj["isCompleted"] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.lightGrayColor : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              wObj["image"].toString(),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["title"].toString(),
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  wObj["time"].toString(),
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 10,
                  ),
                ),
                if (wObj["repetitions"] != null)
                  Text(
                    "${wObj["repetitions"]} reps • ${wObj["weights"]}kg",
                    style: TextStyle(
                      color: AppColors.primaryColor1,
                      fontSize: 10,
                    ),
                  ),
                if (isCompleted)
                  const Text(
                    "✅ Completed",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
