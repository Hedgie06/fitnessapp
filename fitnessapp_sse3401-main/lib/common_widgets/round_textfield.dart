import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String icon;
  final TextInputType textInputType;
  final bool isObscureText;
  final Widget? rightIcon;
  final String? Function(String?)? validator; // Add validator parameter

  const RoundTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.textInputType = TextInputType.text,
    this.isObscureText = false,
    this.rightIcon,
    this.validator, // Add validator to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField( // Change from TextField to TextFormField
        controller: controller,
        keyboardType: textInputType,
        obscureText: isObscureText,
        validator: validator, // Add validator
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Image.asset(icon, width: 20, height: 20),
          ),
          suffixIcon: rightIcon,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.grayColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
