import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TodayTargetCell extends StatelessWidget {
  final String icon;
  final double current;
  final double target;
  final String unit;
  final String title;

  const TodayTargetCell({
    Key? key,
    required this.icon,
    required this.current,
    required this.target,
    required this.unit,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progressPercentage = (current / target).clamp(0.0, 1.0);

    String displayCurrent = current >= 100
        ? current.toStringAsFixed(0)
        : current.toStringAsFixed(1);
    String displayTarget =
        target >= 100 ? target.toStringAsFixed(0) : target.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$displayCurrent/$displayTarget $unit",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                "${(progressPercentage * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: progressPercentage >= 1.0
                      ? Colors.green
                      : AppColors.grayColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressPercentage >= 1.0
                  ? Colors.green
                  : AppColors.primaryColor1,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
