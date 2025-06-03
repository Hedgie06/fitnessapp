import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final List<Map<String, dynamic>> achievements = const [
    {
      "title": "Early Bird",
      "description": "Complete 5 workouts before 8 AM",
      "icon": Icons.wb_sunny,
      "unlocked": true,
    },
    {
      "title": "Workout Warrior",
      "description": "Complete 4 different workouts in one day",
      "icon": Icons.fitness_center,
      "unlocked": false,
    },
    {
      "title": "Consistency King",
      "description": "Maintain a 10-day workout streak",
      "icon": Icons.run_circle,
      "unlocked": false,
    },
    {
      "title": "Weight Loss Champion",
      "description": "Lose 5kg from your starting weight",
      "icon": Icons.trending_down,
      "unlocked": false,
    },
    {
      "title": "Muscle Builder",
      "description": "Complete 20 strength training sessions",
      "icon": Icons.sports_gymnastics,
      "unlocked": false,
    },
    {
      "title": "Perfect Form",
      "description": "Score 100% on workout form tracking",
      "icon": Icons.star,
      "unlocked": true,
    },
    {
      "title": "Social Butterfly",
      "description": "Share 10 workout results",
      "icon": Icons.share,
      "unlocked": true,
    },
    {
      "title": "Goal Crusher",
      "description": "Achieve your first fitness goal",
      "icon": Icons.emoji_events,
      "unlocked": false,
    },
  ];

  // Track redeemed states
  late List<bool> redeemed;

  @override
  void initState() {
    super.initState();
    redeemed = List.generate(achievements.length, (_) => false);
    _loadRedeemedStatus();
  }

  Future<void> _loadRedeemedStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('achievements')
          .where('redeemed', isEqualTo: true)
          .get();
      final redeemedIds = snapshot.docs.map((doc) => doc.id).toSet();
      setState(() {
        for (int i = 0; i < achievements.length; i++) {
          final title = achievements[i]["title"] as String;
          if (redeemedIds.contains(title)) {
            redeemed[i] = true;
          }
        }
      });
    } catch (e) {
      print('Error loading redeemed achievements: $e');
    }
  }

  void _handleRedeem(int index) async {
    if (redeemed[index]) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('achievements')
          .doc(achievements[index]["title"])
          .set({
        'redeemed': true,
      }, SetOptions(merge: true));
      setState(() {
        redeemed[index] = true;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Voucher Claimed!"),
          content: const Text("You have received a special voucher. Family Voucher for RM5.00"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error redeeming achievement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(
          "Achievements",
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
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final bool isUnlocked = achievement["unlocked"];
          final bool isRedeemed = redeemed[index];
          return _buildAchievementCard(
            achievement["title"],
            achievement["description"],
            achievement["icon"],
            isUnlocked,
            isRedeemed,
            index,
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    bool unlocked,
    bool isRedeemed,
    int index
  ) {
    final Color cardColor = isRedeemed
      ? Colors.green
      : unlocked
        ? AppColors.primaryColor1
        : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked ? AppColors.whiteColor.withOpacity(0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 35,
              color: unlocked ? AppColors.whiteColor : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? AppColors.whiteColor : Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: unlocked
                    ? AppColors.whiteColor.withOpacity(0.8)
                    : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!unlocked)
            Icon(
              Icons.lock,
              size: 20,
              color: Colors.grey.shade600,
            )
          else if (isRedeemed)
            const Text(
              "Redeemed",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          else
            ElevatedButton(
              onPressed: () => _handleRedeem(index),
              child: const Text("Redeem"),
            ),
        ],
      ),
    );
  }
}
