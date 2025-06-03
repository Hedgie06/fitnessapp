import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMIDetailScreen extends StatefulWidget {
  static String routeName = "/BMIDetailScreen";
  const BMIDetailScreen({Key? key}) : super(key: key);

  @override
  State<BMIDetailScreen> createState() => _BMIDetailScreenState();
}

class _BMIDetailScreenState extends State<BMIDetailScreen> {
  String userBMI = "";
  String userHeight = "";
  String userWeight = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          userHeight = snapshot.data()?['height'] ?? "";
          userWeight = snapshot.data()?['weight'] ?? "";
          userBMI = calculateBMI(userHeight, userWeight);
        });
      }
    }
  }

  String calculateBMI(String height, String weight) {
    try {
      double heightInM = double.parse(height) / 100;
      double weightInKg = double.parse(weight);
      double bmi = weightInKg / (heightInM * heightInM);
      return bmi.toStringAsFixed(1);
    } catch (e) {
      return "--";
    }
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color getBMIStatusColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Map<String, String> getBMIRecommendations(double bmi) {
    if (bmi < 18.5) {
      return {
        "risk": "Higher risk for: Nutritional deficiencies, osteoporosis, weakened immune system",
        "advice": "Increase caloric intake with nutrient-rich foods, consult a nutritionist, consider strength training"
      };
    } else if (bmi < 25) {
      return {
        "risk": "Lowest risk for health issues",
        "advice": "Maintain current healthy lifestyle with balanced diet and regular exercise"
      };
    } else if (bmi < 30) {
      return {
        "risk": "Higher risk for: Heart disease, high blood pressure, diabetes",
        "advice": "Focus on portion control, increase physical activity, consider consulting healthcare provider"
      };
    }
    return {
      "risk": "High risk for: Severe health conditions, cardiovascular issues, joint problems",
      "advice": "Seek medical guidance, start monitored weight loss program, gradually increase activity"
    };
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    double bmiValue = double.tryParse(userBMI) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "BMI Details",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Text(
                    "Your BMI",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userBMI,
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      getBMIStatus(bmiValue),
                      style: TextStyle(
                        color: getBMIStatusColor(bmiValue),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Current Measurements
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 2)
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Measurements",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMeasurementItem("Height", "$userHeight cm", ""),
                      _buildMeasurementItem("Weight", "$userWeight kg", ""),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BMI Scale Visualization
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BMI Scale",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildBMIScale(bmiValue),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Health Recommendations
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Health Insights",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildHealthInsights(bmiValue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(String title, String value, String iconPath) {
    return Column(
      children: [
        Icon(
          title == "Height" ? Icons.height_rounded : Icons.monitor_weight_outlined,
          size: 30,
          color: AppColors.primaryColor1,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.grayColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIScale(double currentBMI) {
    return Container(
      height: 70,
      child: Stack(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Positioned(
            left: (currentBMI / 40) * MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                Icon(Icons.arrow_drop_down, color: getBMIStatusColor(currentBMI)),
                Text(
                  currentBMI.toStringAsFixed(1),
                  style: TextStyle(
                    color: getBMIStatusColor(currentBMI),
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

  Widget _buildHealthInsights(double bmi) {
    final recommendations = getBMIRecommendations(bmi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Risks:",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(recommendations["risk"]!),
        const SizedBox(height: 10),
        Text(
          "Recommendations:",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(recommendations["advice"]!),
      ],
    );
  }
}
