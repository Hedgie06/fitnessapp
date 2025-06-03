class WaterIntakeModel {
  final String id;
  final String userId;
  final double amount; // in milliliters
  final DateTime timestamp;
  final double dailyGoal; // Daily water intake goal

  WaterIntakeModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    this.dailyGoal = 2000, // Default 2L per day
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp,
      'dailyGoal': dailyGoal,
    };
  }

  static WaterIntakeModel fromMap(Map<String, dynamic> map) {
    return WaterIntakeModel(
      id: map['id'],
      userId: map['userId'],
      amount: (map['amount'] ?? 0).toDouble(),
      timestamp: map['timestamp'].toDate(),
      dailyGoal: (map['dailyGoal'] ?? 2000).toDouble(),
    );
  }
}
