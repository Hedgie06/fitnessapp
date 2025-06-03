import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  static String routeName = "/UserProfileScreen";

  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _auth = FirebaseAuth.instance;
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userData.exists) {
        setState(() {
          userName = "${userData['firstName']} ${userData['lastName']}";
          userEmail = userData['email'] ?? "";
        });
      }
    }
  }

  Future<void> _handleEditProfile() async {
    // Navigate to edit profile screen
    // TODO: Implement edit profile navigation
  }

  Future<void> _handleChangePassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: userEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $userEmail')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.blackColor),
                  ),
                ],
              ),
              SizedBox(height: media.width * 0.05),

              // Account Section
              Text(
                "Account",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: media.width * 0.02),
              
              // Account Buttons
              _buildButton("Edit Profile", Icons.edit, _handleEditProfile),
              _buildButton("Change Password", Icons.lock, _handleChangePassword),
              _buildButton("Contact Support", Icons.support_agent, () {
                // TODO: Implement support contact
              }),
              _buildButton("Logout", Icons.logout, _handleLogout, 
                isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed, 
      {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive 
              ? Colors.red.shade400 
              : AppColors.primaryColor1,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, color: AppColors.whiteColor),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(color: AppColors.whiteColor),
            ),
          ],
        ),
      ),
    );
  }
}