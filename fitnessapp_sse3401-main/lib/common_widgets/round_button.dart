import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum RoundButtonType { bgGradient, textGradient }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType? type;
  final VoidCallback onPressed;
  final double? width;  // Add width parameter
  final double? height; // Add height parameter

  const RoundButton({
    Key? key,
    required this.title,
    this.type,
    required this.onPressed,
    this.width,      // Optional width
    this.height = 45, // Default height 45
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,  // Use provided width or wrap content
      height: height,
      decoration: BoxDecoration(
        gradient: type == RoundButtonType.bgGradient
            ? LinearGradient(colors: AppColors.primaryG)
            : null,
        borderRadius: BorderRadius.circular(25),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.symmetric(horizontal: 15),
        color: type == RoundButtonType.bgGradient
            ? Colors.transparent
            : AppColors.whiteColor,
        elevation: 0,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: FittedBox(  // Add FittedBox to prevent text overflow
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: TextStyle(
              color: type == RoundButtonType.bgGradient
                  ? AppColors.whiteColor
                  : AppColors.primaryColor1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
