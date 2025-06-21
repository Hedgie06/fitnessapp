import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumptionModel {
  String? id;
  String? userId;
  String type; // "water" or "food"
  String title;
  String amount;
  String name;
  double value;
  DateTime timestamp;

  ConsumptionModel({
    this.id,
    this.userId,
    required this.type,
    required this.value,
    required this.timestamp,
    this.title = '',
    this.amount = '',
    this.name = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'value': value,
      'timestamp': timestamp,
      'title': title,
      'amount': amount,
      'name': name,
    };
  }

  static ConsumptionModel fromMap(Map<String, dynamic> map) {
    return ConsumptionModel(
      id: map['id'],
      userId: map['userId'],
      type: map['type'] ?? 'water',
      value: (map['value'] is int)
          ? (map['value'] as int).toDouble()
          : (map['value'] as double?) ?? 0.0,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      title: map['title'] ?? '',
      amount: map['amount'] ?? '',
      name: map['name'] ?? '',
    );
  }
}
