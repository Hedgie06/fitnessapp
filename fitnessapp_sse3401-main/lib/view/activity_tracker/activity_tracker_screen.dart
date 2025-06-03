import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/latest_activity_row.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/today_target_cell.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/consumption_controller.dart';
import '../../model/consumption_model.dart';

class ActivityTrackerScreen extends StatefulWidget {
  static String routeName = "/ActivityTrackerScreen";
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  final ConsumptionController _consumptionController = ConsumptionController();
  
  int touchedIndex = -1;
  String waterIntake = "2L";
  String footSteps = "2400";
  String calories = "800";

  double totalWaterIntake = 0.0; // in Liters
  int totalCalories = 0;
  
  List<Map<String, dynamic>> consumptionArr = [];

  List latestArr = [
    {
      "image": "assets/images/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/images/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
  ];

  double currentWater = 0.0;
  double targetWater = 2.0;  // 2L default
  double currentCalories = 0.0;
  double targetCalories = 2800.0;  // 2800kcal default
  double currentSteps = 0.0;
  double targetSteps = 10000.0;  // 10k steps default

  @override
  void initState() {
    super.initState();
    _loadTargets();
    _loadTodayData();
    _loadCurrentCalories();
  }

  Future<void> _loadTodayData() async {
    try {
      // Load daily totals
      final totals = await _consumptionController.getDailyTotals();
      
      // Load today's consumptions
      final consumptions = await _consumptionController.getTodayConsumptions();
      
      if (mounted) {
        setState(() {
          totalWaterIntake = totals['waterTotal'] ?? 0.0;
          totalCalories = totals['caloriesTotal'] ?? 0;
          waterIntake = "${totalWaterIntake.toStringAsFixed(1)}L";
          calories = totalCalories.toString();
          
          // Convert consumptions to the format expected by the UI
          consumptionArr = consumptions.map((consumption) => {
            "type": consumption.type,
            "icon": consumption.type == "water" ? Icons.water_drop : Icons.restaurant,
            "title": consumption.title,
            "amount": consumption.amount,
            "time": _getTimeAgo(consumption.timestamp),
            "value": consumption.value
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading consumption data: $e");
    }
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Try to load from Firestore first
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (doc.exists && doc.data()?['targets'] != null) {
        final targets = doc.data()!['targets'] as Map<String, dynamic>;
        setState(() {
          targetWater = targets['water'] ?? 2.0;
          targetSteps = targets['steps'] ?? 10000.0;
          targetCalories = targets['calories'] ?? 2800.0;
        });
      } else {
        // Fall back to SharedPreferences
        setState(() {
          targetWater = prefs.getDouble('targetWater') ?? 2.0;
          targetSteps = prefs.getDouble('targetSteps') ?? 10000.0;
          targetCalories = prefs.getDouble('targetCalories') ?? 2800.0;
        });
      }
    }
  }

  Future<void> _loadCurrentCalories() async {
    try {
      final calories = await _consumptionController.getCurrentCalories();
      setState(() {
        currentCalories = calories;
      });
    } catch (e) {
      print("Error loading calories: $e");
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return "About ${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "About ${difference.inHours} hours ago";
    } else {
      return "About ${difference.inDays} days ago";
    }
  }

  void _showTargetOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Daily Targets"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTargetInput("Water Target (L)", targetWater, (val) {
              setState(() => targetWater = val);
            }),
            SizedBox(height: 10),
            _buildTargetInput("Steps Target", targetSteps, (val) {
              setState(() => targetSteps = val);
            }),
            SizedBox(height: 10),
            _buildTargetInput("Calories Target", targetCalories, (val) {
              setState(() => targetCalories = val);
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Save targets to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('targetWater', targetWater);
              await prefs.setDouble('targetSteps', targetSteps);
              await prefs.setDouble('targetCalories', targetCalories);
              
              // Save to Firestore
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'targets': {
                    'water': targetWater,
                    'steps': targetSteps,
                    'calories': targetCalories,
                  }
                });
              }
              
              setState(() {});
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInput(String label, double value, Function(double) onChanged) {
    TextEditingController controller = TextEditingController(text: value.toString());
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (val) {
        double? newVal = double.tryParse(val);
        if (newVal != null) onChanged(newVal);
      },
    );
  }

  Widget _buildTargetOption(
    String title,
    IconData icon, // Changed from String to IconData
    String currentValue,
    Function(String) onChanged,
    String unit,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue.replaceAll(unit, '').trim()
    );
    
    return Container(
      height: 70, // Fixed height
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjusted padding
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              icon,
              size: 24,
              color: AppColors.grayColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  height: 25,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffix: Text(unit, style: const TextStyle(fontSize: 12)),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      onChanged("$value $unit");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewConsumption() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Consumption",
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAddButton(
                    "Water",
                    Icons.water_drop,
                    () => _showWaterInputDialog(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildAddButton(
                    "Food",
                    Icons.food_bank,
                    () => _showFoodInputDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryG),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.whiteColor, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWaterInputDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Water Intake"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffix: Text("ml"),
            hintText: "Enter amount",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              double amount = double.tryParse(controller.text) ?? 0;
              _updateConsumption("water", amount / 1000); // Convert to liters
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showFoodInputDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Food"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Food name",
              ),
            ),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffix: Text("kcal"),
                hintText: "Calories",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              int calories = int.tryParse(caloriesController.text) ?? 0;
              _updateConsumption("food", calories);
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _updateConsumption(String type, dynamic value) async {
    try {
      final consumption = ConsumptionModel(
        name: type == "water" ? "Drinking Water" : "Food Consumed",
        type: type,
        title: type == "water" ? "Drinking Water" : "Food Consumed",
        value: value.toDouble(),
        amount: type == "water" ? "${(value * 1000).toInt()}ml" : "$value kcal",
        timestamp: DateTime.now(),
      );

      await _consumptionController.addConsumption(consumption);
      
      // Refresh the calories display
      await _loadCurrentCalories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added ${consumption.title}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding consumption: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primaryColor2.withOpacity(0.3),
                    AppColors.primaryColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Target",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: _showTargetOptions,
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: AppColors.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: TodayTargetCell(
                                  icon: "assets/icons/water_icon.png",
                                  current: totalWaterIntake,
                                  target: targetWater,
                                  unit: "L",
                                  title: "Water Intake",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TodayTargetCell(
                                  icon: "assets/icons/foot_icon.png",
                                  current: currentSteps,
                                  target: targetSteps,
                                  unit: "steps",
                                  title: "Foot Steps",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.maxFinite,
                      child: TodayTargetCell(
                        icon: "assets/icons/burn_icon.png",
                        current: currentCalories.toDouble(),
                        target: targetCalories,
                        unit: "kcal",
                        title: "Calories",
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Activity Progress",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: ["Weekly", "Monthly"]
                            .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14),
                            )))
                            .toList(),
                        onChanged: (value) {},
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.whiteColor),
                        hint: const Text("Weekly",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.whiteColor, fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 0),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: BarChart(

                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                          tooltipMargin: 10,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String weekDay;
                            switch (group.x) {
                              case 0:
                                weekDay = 'Sunday';
                                break;
                              case 1:
                                weekDay = 'Monday';
                                break;
                              case 2:
                                weekDay = 'Tuesday';
                                break;
                              case 3:
                                weekDay = 'Wednesday';
                                break;
                              case 4:
                                weekDay = 'Thursday';
                                break;
                              case 5:
                                weekDay = 'Friday';
                                break;
                              case 6:
                                weekDay = 'Saturday';
                                break;
                              default:
                                throw Error();
                            }
                            return BarTooltipItem(
                              '$weekDay\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: (rod.toY - 1).toString(),
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles:  AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles:  AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: getTitles,
                            reservedSize: 38,
                          ),
                        ),
                        leftTitles:  AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingGroups(),
                      gridData:  FlGridData(show: false),
                    )

                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Consumption",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: AppColors.primaryColor1),
                    onPressed: _addNewConsumption,
                  ),
                ],
              ),              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FutureBuilder<List<ConsumptionModel>>(
                  future: _consumptionController.getTodayConsumptions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Error loading consumption data: ${snapshot.error}",
                            style: TextStyle(color: AppColors.grayColor),
                          ),
                        ),
                      );
                    }
              
                    final consumptions = snapshot.data ?? [];
                    
                    if (consumptions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "No consumption records for today",
                            style: TextStyle(color: AppColors.grayColor),
                          ),
                        ),
                      );
                    }
              
                    return ListView.separated(
                      padding: const EdgeInsets.all(15),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: consumptions.length,
                      separatorBuilder: (context, index) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final consumption = consumptions[index];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrayColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                consumption.type == "water" ? Icons.water_drop : Icons.restaurant,
                                size: 25,
                                color: AppColors.primaryColor1,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    consumption.title,
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          consumption.amount,
                                          style: const TextStyle(
                                            color: AppColors.grayColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        " • ",
                                        style: TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          _getTimeAgo(consumption.timestamp),
                                          style: const TextStyle(
                                            color: AppColors.grayColor,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.grayColor,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text =  Text('Sun', style: style);
        break;
      case 1:
        text =  Text('Mon', style: style);
        break;
      case 2:
        text =  Text('Tue', style: style);
        break;
      case 3:
        text =  Text('Wed', style: style);
        break;
      case 4:
        text =  Text('Thu', style: style);
        break;
      case 5:
        text =  Text('Fri', style: style);
        break;
      case 6:
        text =  Text('Sat', style: style);
        break;
      default:
        text =  Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    switch (i) {
      case 0:
        return makeGroupData(0, 25, AppColors.primaryG, isTouched: i == touchedIndex); // 25%
      case 1:
        return makeGroupData(1, 50, AppColors.secondaryG, isTouched: i == touchedIndex); // 50%
      case 2:
        return makeGroupData(2, 35, AppColors.primaryG, isTouched: i == touchedIndex); // 35%
      case 3:
        return makeGroupData(3, 45, AppColors.secondaryG, isTouched: i == touchedIndex); // 45%
      case 4:
        return makeGroupData(4, 75, AppColors.primaryG, isTouched: i == touchedIndex); // 75%
      case 5:
        return makeGroupData(5, 30, AppColors.secondaryG, isTouched: i == touchedIndex); // 30%
      case 6:
        return makeGroupData(6, 60, AppColors.primaryG, isTouched: i == touchedIndex); // 60%
      default:
        return throw Error();
    }
  });

  BarChartGroupData makeGroupData(
      int x,
      double y,
      List<Color> barColor,
      {
        bool isTouched = false,

        double width = 22,
        List<int> showTooltips = const [],
      }) {

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(colors: barColor, begin: Alignment.topCenter, end: Alignment.bottomCenter ),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: AppColors.lightGrayColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
