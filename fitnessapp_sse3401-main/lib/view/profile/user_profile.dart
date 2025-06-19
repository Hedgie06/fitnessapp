import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/profile/edit_profile_screen.dart';
import 'package:fitnessapp/view/profile/settings_screen.dart';
import 'package:fitnessapp/view/profile/widgets/setting_row.dart';
import 'package:fitnessapp/view/profile/widgets/title_subtitle_cell.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/view/profile/personal_data_screen.dart';
import '../../common_widgets/round_button.dart';
import 'package:fitnessapp/view/profile/contact_us_screen.dart';
import 'package:fitnessapp/view/profile/privacy_policy_screen.dart';
import '../../services/gemini_service.dart';
import '../../model/chat_message.dart';
import '../../services/auth_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool positive = false;
  String userFirstName = "";
  String userLastName = "";
  String userGoal = ""; // Add this
  String userGoalDetails = ""; // Add this
  String userHeight = "";
  String userWeight = "";
  String userBMI = "";

  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  String calculateBMI(String height, String weight) {
    try {
      double heightInM = double.parse(height) / 100; // Convert cm to m
      double weightInKg = double.parse(weight);
      double bmi = weightInKg / (heightInM * heightInM);
      return bmi.toStringAsFixed(1); // Returns BMI with 1 decimal place
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            userFirstName = snapshot.data()?['firstName'] ?? "";
            userLastName = snapshot.data()?['lastName'] ?? "";
            userGoal = snapshot.data()?['goal'] ?? ""; // Get goal
            userGoalDetails =
                snapshot.data()?['goal_description'] ?? ""; // Get goal details
            userHeight = snapshot.data()?['height'] ?? "";
            userWeight = snapshot.data()?['weight'] ?? "";
            userBMI = calculateBMI(userHeight, userWeight);
          });
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      final authService = AuthService();
      await authService.signOut();

      if (mounted) {
        // Navigate to login and clear all routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  void _handleEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          userData: {
            'firstName': userFirstName,
            'lastName': userLastName,
            'height': userHeight,
            'weight': userWeight,
          },
        ),
      ),
    );

    // Reload user data if profile was updated
    if (result == true) {
      _loadUserData();
    }
  }

  List accountArr = [
    {
      "image": "assets/icons/p_personal.png",
      "name": "Personal Data",
      "tag": "1"
    },
    {
      "icon": Icons.star,
      "name": "Chat with FitQuest AI",
      "tag": "3",
      "isIcon": true
    },
  ];

  // Modify SettingRow widget to handle either image or icon
  Widget _buildAccountItem(Map iObj) {
    return SettingRow(
      icon: iObj["isIcon"] == true ? null : iObj["image"].toString(),
      iconData: iObj["isIcon"] == true ? iObj["icon"] as IconData : null,
      title: iObj["name"].toString(),
      onPressed: () => _handleAccountOption(iObj["tag"].toString()),
    );
  }

  void _handleAccountOption(String tag) {
    switch (tag) {
      case "1": // Personal Data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalDataScreen(
              userData: {
                'firstName': userFirstName,
                'lastName': userLastName,
                'height': userHeight,
                'weight': userWeight,
                'bmi': userBMI,
                'goal': userGoal,
              },
            ),
          ),
        );
        break;
      
        break;
      case "3": // Chat with Gemini
        _showGeminiChat();
        break;
    }
  }

  void _showGeminiChat() {
    // Don't reset messages when opening chat
    // Only add welcome message if messages list is empty
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: "Hi! I'm your FitQuest AI Assistant. How can I help you today?",
        isBot: true,
      ));
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            void _sendMessage() async {
              final message = _messageController.text.trim();
              if (message.isEmpty) return;

              setStateDialog(() {
                _messages.add(ChatMessage(text: message, isBot: false));
                _messageController.clear();
                _isLoading = true;
              });

              try {
                final response =
                    await _geminiService.getFitnessResponse(message);
                setStateDialog(() {
                  _messages.add(ChatMessage(text: response, isBot: true));
                  _isLoading = false;
                });
              } catch (e) {
                setStateDialog(() {
                  _messages.add(ChatMessage(
                    text: "Sorry, I encountered an error. Please try again.",
                    isBot: true,
                  ));
                  _isLoading = false;
                });
              }
            }

            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: AppColors.primaryG),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.whiteColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "FitQuest AI Assistant",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                setStateDialog(() {
                                  _messages.clear();
                                  _messages.add(ChatMessage(
                                    text:
                                        "Hi! I'm your fitness AI assistant. How can I help you today?",
                                    isBot: true,
                                  ));
                                });
                              },
                              child: Text(
                                "New",
                                style: TextStyle(
                                  color: AppColors.primaryColor1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildChatMessage(
                            message.text,
                            isBot: message.isBot,
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              maxLines: null, // Allow multiple lines
                              textInputAction: TextInputAction.newline, // Enable line breaks
                              decoration: InputDecoration(
                                hintText: "Type your message...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12), // Add vertical padding
                              ),
                              style: TextStyle(fontSize: 14),
                              keyboardType: TextInputType.multiline, // Enable multiline input
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: AppColors.primaryColor1),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatMessage(String message, {bool isBot = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.whiteColor,
                size: 12,
              ),
            ),
          if (!isBot) SizedBox(width: 40),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot
                    ? AppColors.lightGrayColor
                    : AppColors.primaryColor2.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text.rich(
                TextSpan(
                  children: _parseTextWithBold(message),
                ),
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isBot)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor1,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.whiteColor,
                size: 12,
              ),
            ),
          if (isBot) SizedBox(width: 40),
        ],
      ),
    );
  }

  List<TextSpan> _parseTextWithBold(String text) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'<b>(.*?)</b>|([^<]+)');

    for (Match match in exp.allMatches(text)) {
      if (match.group(1) != null) {
        // Bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        // Regular text
        spans.add(TextSpan(text: match.group(2)));
      }
    }

    return spans;
  }

  List otherArr = [
    {"image": "assets/icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {
      "image": "assets/icons/p_privacy.png",
      "name": "Privacy Policy",
      "tag": "6"
    },
    {"image": "assets/icons/p_setting.png", "name": "Settings", "tag": "7"},
  ];

  void _handleOtherOption(String tag) {
    switch (tag) {
      case "5": // Contact Us
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsScreen()),
        );
        break;
      case "6": // Privacy Policy
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
        break;
      case "7": // Settings
        Navigator.pushNamed(context, SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/images/user.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userFirstName.isEmpty && userLastName.isEmpty
                              ? "Your Profile"
                              : "$userFirstName $userLastName",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userGoal.isEmpty ? "Choose Your Program" : userGoal,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userGoalDetails,
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: RoundButton(
                      title: "Edit",
                      type:
                          RoundButtonType.bgGradient, // Changed from primaryBG
                      onPressed: _handleEditProfile,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                userFirstName.isEmpty
                    ? "Your Profile"
                    : "Hello, $userFirstName",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: userHeight.isEmpty ? "--" : "$userHeight cm",
                      subtitle: "Height",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: userWeight.isEmpty ? "--" : "$userWeight kg",
                      subtitle: "Weight",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: userBMI == "--" ? "--" : "$userBMI",
                      subtitle: "BMI",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return _buildAccountItem(iObj);
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/p_notification.png",
                                height: 15, width: 15, fit: BoxFit.contain),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                "Pop-up Notification",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            CustomAnimatedToggleSwitch<bool>(
                              current: positive,
                              values: [false, true],
                              dif: 0.0,
                              indicatorSize: Size.square(30.0),
                              animationDuration:
                                  const Duration(milliseconds: 200),
                              animationCurve: Curves.linear,
                              onChanged: (b) => setState(() => positive = b),
                              iconBuilder: (context, local, global) {
                                return const SizedBox();
                              },
                              defaultCursor: SystemMouseCursors.click,
                              onTap: () => setState(() => positive = !positive),
                              iconsTappable: false,
                              wrapperBuilder: (context, global, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                        left: 10.0,
                                        right: 10.0,
                                        height: 30.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: positive
                                                  ? AppColors
                                                      .primaryG // When ON
                                                  : [
                                                      Colors.grey.shade300,
                                                      Colors.grey.shade400
                                                    ], // When OFF
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(30.0)),
                                          ),
                                        )),
                                    child,
                                  ],
                                );
                              },
                              foregroundIndicatorBuilder: (context, global) {
                                return SizedBox.fromSize(
                                  size: const Size(10, 10),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: positive
                                          ? AppColors.whiteColor
                                          : Colors.grey.shade400,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black38,
                                            spreadRadius: 0.05,
                                            blurRadius: 1.1,
                                            offset: const Offset(0.0, 0.8))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () =>
                              _handleOtherOption(iObj["tag"].toString()),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: AppColors.whiteColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _handleLogout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.whiteColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Logout",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
