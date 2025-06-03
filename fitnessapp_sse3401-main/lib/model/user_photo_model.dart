import 'package:cloud_firestore/cloud_firestore.dart';

class UserPhotoModel {
  String? id;
  String? userId;
  String? imageUrl;
  String? weight;
  String? bmi;
  DateTime? timestamp; // Changed from dateTaken to timestamp for consistency

  UserPhotoModel({
    this.id,
    this.userId,
    this.imageUrl,
    this.weight,
    this.bmi,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'weight': weight,
      'bmi': bmi,
      'timestamp': timestamp?.toIso8601String(), // Convert DateTime to string
    };
  }

  static UserPhotoModel fromMap(Map<String, dynamic> map) {
    return UserPhotoModel(
      id: map['id'],
      userId: map['userId'],
      imageUrl: map['imageUrl'],
      weight: map['weight'],
      bmi: map['bmi'],
      timestamp: map['timestamp'] is DateTime 
          ? map['timestamp'] 
          : DateTime.parse(map['timestamp']),
    );
  }
}
