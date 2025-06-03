import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;
  
  const PasswordStrengthWidget({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requirements = [
      {'text': 'At least 8 characters', 'met': password.length >= 8},
      {'text': 'At least 1 uppercase letter', 'met': RegExp(r'[A-Z]').hasMatch(password)},
      {'text': 'At least 1 lowercase letter', 'met': RegExp(r'[a-z]').hasMatch(password)},
      {'text': 'At least 1 number', 'met': RegExp(r'[0-9]').hasMatch(password)},
      {'text': 'At least 1 special character (!@#\$&*~)', 'met': RegExp(r'[!@#\$&*~]').hasMatch(password)},
    ];

    // Filter only unmet requirements
    final unmetRequirements = requirements.where((req) => !(req['met']! as bool)).toList();

    if (unmetRequirements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 8),
            Text(
              'Password requirements met',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must have:',
          style: TextStyle(
            color: AppColors.grayColor,
            fontSize: 12,
          ),
        ),
        ...unmetRequirements.map((req) => _buildRequirementRow(req['text']! as String)).toList(),
      ],
    );
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
