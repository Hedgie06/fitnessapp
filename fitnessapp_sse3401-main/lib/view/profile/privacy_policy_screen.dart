import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static String routeName = "/PrivacyPolicyScreen";
  
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: AppColors.whiteColor, size: 40),
                  const SizedBox(width: 15),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "Information We Collect",
              content: "We collect information that you provide directly to us, including but not limited to your name, email address, and fitness data.",
            ),
            _buildSection(
              title: "How We Use Your Information",
              content: "We use the information we collect to provide, maintain, and improve our services, and to communicate with you.",
            ),
            _buildSection(
              title: "Data Security",
              content: "We implement appropriate security measures to protect your personal information against unauthorized access or disclosure.",
            ),
            _buildSection(
              title: "Your Rights",
              content: "You have the right to access, update, or delete your personal information at any time through your account settings.",
            ),
            _buildSection(
              title: "Updates to This Policy",
              content: "We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page.",
            ),
            const SizedBox(height: 20),
            Text(
              "Last updated: ${DateTime.now().year}",
              style: TextStyle(
                color: AppColors.grayColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryColor2.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: AppColors.grayColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
