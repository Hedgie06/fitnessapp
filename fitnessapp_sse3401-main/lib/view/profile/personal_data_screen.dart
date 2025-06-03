import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDataScreen extends StatelessWidget {
  static String routeName = "/PersonalDataScreen";
  final Map<String, String> userData;

  const PersonalDataScreen({Key? key, required this.userData}) : super(key: key);

  String _formatLabel(String key) {
    // Convert camelCase to Title Case with spaces
    String label = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match m) => ' ${m[1]}',
    );
    // Capitalize first letter and trim any extra spaces
    label = label[0].toUpperCase() + label.substring(1).trim();
    return label;
  }

  Future<Map<String, String>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return {
          'email': doc.data()?['email'] ?? '',
          'password': doc.data()?['password'] ?? '',
        };
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(
          "Personal Data",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          Map<String, String> formattedData = {
            'First Name': userData['firstName'] ?? '',
            'Last Name': userData['lastName'] ?? '',
            'Email': snapshot.data?['email'] ?? '',
            'Password': snapshot.data?['password'] ?? '',
            'Height': '${userData['height'] ?? ''} cm',
            'Weight': '${userData['weight'] ?? ''} kg',
            'BMI': userData['bmi'] ?? '',
            'Goal': userData['goal'] ?? '',
          };

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: formattedData.length,
            itemBuilder: (context, index) {
              String key = formattedData.keys.elementAt(index);
              String value = formattedData[key] ?? '';
              return _buildInfoTile(key, value);
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grayColor.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.grayColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
