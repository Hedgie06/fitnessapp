import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Add this import
import '../model/workout_schedule_model.dart';
import '../model/user_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/user_photo_model.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html; // Remove dart:html import

class FitnessController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // BMI Methods
  Future<void> updateBMI(String bmi, String status) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'bmi': bmi,
        'bmiStatus': status,
        'lastBmiUpdate': DateTime.now().toIso8601String(),
      });
    }
  }

  String calculateBMI(String height, String weight) {
    try {
      double heightInM = double.parse(height) / 100; // Convert cm to m
      double weightInKg = double.parse(weight);
      double bmi = weightInKg / (heightInM * heightInM);
      return bmi.toStringAsFixed(1);
    } catch (e) {
      return "0.0";
    }
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  // Renamed from getCurrentUserBMIData to getUserBMIData for consistency
  Future<Map<String, dynamic>> getUserBMIData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final height = data['height'] ?? '0';
        final weight = data['weight'] ?? '0';
        final bmi = calculateBMI(height, weight);
        final status = getBMIStatus(double.parse(bmi));

        return {
          'bmi': bmi,
          'status': status,
        };
      }
    }
    return {'bmi': '0.0', 'status': 'Not Available'};
  }

  // Workout Schedule Methods
  Future<String> addWorkoutSchedule(WorkoutScheduleModel workout) async {
    final user = _auth.currentUser;
    if (user != null) {
      workout.userId = user.uid;
      workout.id = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts') // Changed path
          .doc(workout.id)
          .set(workout.toMap());

      return workout.id!;
    }
    throw Exception('User not authenticated');
  }

  Future<List<WorkoutScheduleModel>> getWorkoutSchedules() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts') // Changed path
          .orderBy('dateTime', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutScheduleModel.fromMap(doc.data()))
          .toList();
    }
    return [];
  }

  Future<void> updateWorkoutStatus(String workoutId, bool isCompleted) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts') // Changed path
          .doc(workoutId)
          .update({'isCompleted': isCompleted});
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts') // Changed path
          .doc(workoutId)
          .delete();
    }
  }

  // Add new method to track workout history
  Future<void> addWorkoutHistory(Map<String, dynamic> historyData) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Add to workout history subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .add({
        ...historyData,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid
      });

      // Update user's workout stats
      await _updateWorkoutStats(historyData);
    }
  }

  // Helper method to update workout statistics
  Future<void> _updateWorkoutStats(Map<String, dynamic> workoutData) async {
    final user = _auth.currentUser;
    if (user != null) {
      final statsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('workout');

      await statsRef.set({
        'totalWorkouts': FieldValue.increment(1),
        'totalDuration': FieldValue.increment(workoutData['duration'] ?? 0),
        'totalCaloriesBurned': FieldValue.increment(workoutData['caloriesBurned'] ?? 0),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Get user's workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final statsDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('workout')
          .get();

      return statsDoc.data() ??
          {
            'totalWorkouts': 0,
            'totalDuration': 0,
            'totalCalories': 0,
          };
    }
    return {
      'totalWorkouts': 0,
      'totalDuration': 0,
      'totalCalories': 0,
    };
  }

  Future<void> saveUserPhoto(
      dynamic imageFile, String weight, String bmi) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final timestamp = DateTime.now();
        final fileId = timestamp.millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos/${user.uid}/$fileId.jpg');

        // Handle file upload based on platform
        UploadTask uploadTask;
        if (kIsWeb) {
          if (imageFile is html.File) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(imageFile);
            await reader.onLoad.first;
            final bytes = reader.result as Uint8List;
            uploadTask = storageRef.putData(bytes);
          } else {
            throw Exception('Invalid file type for web');
          }
        } else {
          if (imageFile is File) {
            uploadTask = storageRef.putFile(imageFile);
          } else {
            throw Exception('Invalid file type for mobile');
          }
        }

        await uploadTask;
        final imageUrl = await storageRef.getDownloadURL();

        final userPhoto = UserPhotoModel(
          id: fileId,
          userId: user.uid,
          imageUrl: imageUrl,
          weight: weight,
          bmi: bmi,
          timestamp: timestamp,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('photos')
            .doc(fileId)
            .set(userPhoto.toMap());
      } catch (e) {
        print("Error in saveUserPhoto: $e");
        throw Exception('Failed to save photo: $e');
      }
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<List<UserPhotoModel>> getUserPhotos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('photos')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserPhotoModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error in getUserPhotos: $e");
      throw e;
    }
  }

  // Modified method to store workout in users collection
  Future<void> scheduleWorkout(Map<String, dynamic> workoutData) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (!workoutData.containsKey('workout') || 
          !workoutData.containsKey('dateTime')) {
        throw Exception('Missing required workout fields');
      }

      // Ensure proper DateTime conversion with timezone handling
      DateTime workoutDateTime;
      if (workoutData['dateTime'] is DateTime) {
        workoutDateTime = workoutData['dateTime'];
      } else if (workoutData['dateTime'] is Timestamp) {
        // Convert Firebase Timestamp to local DateTime
        workoutDateTime = (workoutData['dateTime'] as Timestamp).toDate().toLocal();
      } else if (workoutData['dateTime'] is String) {
        workoutDateTime = DateTime.parse(workoutData['dateTime']).toLocal();
      } else {
        throw Exception('Invalid dateTime format');
      }

      // Create a clean DateTime object in local time
      final localDateTime = DateTime(
        workoutDateTime.year,
        workoutDateTime.month,
        workoutDateTime.day,
        workoutDateTime.hour,
        workoutDateTime.minute,
      );

      // Convert to UTC for storage
      final utcDateTime = localDateTime.toUtc();

      final workoutRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc();

      final workoutWithMetadata = {
        ...workoutData,
        'id': workoutRef.id,
        'userId': user.uid,
        'created': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'dateTime': Timestamp.fromDate(utcDateTime), // Store in UTC
        'scheduledTime': Timestamp.fromDate(utcDateTime), // Store in UTC
        'localDateTime': localDateTime.toIso8601String(), // Store local time as string
        'timeOfDay': {
          'hour': localDateTime.hour, // Store local hour
          'minute': localDateTime.minute,
        },
        'timezone': localDateTime.timeZoneOffset.inHours, // Store timezone offset
        'dayOfWeek': localDateTime.weekday,
        'status': 'scheduled',
        'isCompleted': false,
        'type': 'scheduled_workout',
      };

      // Save to Firestore
      await workoutRef.set(workoutWithMetadata);

      // Update workout stats
      await _updateWorkoutStats({
        'totalScheduledWorkouts': FieldValue.increment(1),
        'lastScheduled': FieldValue.serverTimestamp(),
        'scheduledTimes': FieldValue.arrayUnion([Timestamp.fromDate(utcDateTime)]),
      });
    }
  }

  // Helper method to update workout statistics in user document
  Future<void> _updateUserWorkoutStats(Map<String, dynamic> statsUpdate) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      
      await userRef.set({
        'workoutStats': statsUpdate,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Method to get all workouts for a user
  Future<List<Map<String, dynamic>>> getAllUserWorkouts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('dateTime', descending: false)
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getScheduledWorkouts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')  // Changed collection path
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'scheduled')
          .orderBy('dateTime')
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data();
        // Convert UTC timestamp back to local time
        if (data['dateTime'] is Timestamp) {
          final utcDateTime = (data['dateTime'] as Timestamp).toDate();
          final localDateTime = utcDateTime.toLocal();
          data['dateTime'] = localDateTime;
        }
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCompletedWorkouts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('isCompleted', isEqualTo: true)
          .orderBy('dateTime', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id,
          }).toList();
    }
    return [];
  }

  // Modified method to store workout completion data
  Future<void> completeWorkout(String workoutId, Map<String, dynamic> completionData) async {
    final user = _auth.currentUser;
    if (user != null) {
      final workoutRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')  // Changed collection path
          .doc(workoutId);

      await workoutRef.update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
        'duration': completionData['duration'],
        'caloriesBurned': completionData['caloriesBurned'],
        'performance': completionData['performance'],
        'notes': completionData['notes'],
      });

      // Store completion history in a subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .add({
            ...completionData,
            'workoutId': workoutId,
            'completedAt': FieldValue.serverTimestamp(),
          });

      await _updateWorkoutStats(completionData);
    }
  }

  Future<void> createWorkout(Map<String, dynamic> workoutData) async {
    final user = _auth.currentUser;
    if (user != null) {
      final workoutRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc();

      await workoutRef.set({
        ...workoutData,
        'id': workoutRef.id,
        'created': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'status': 'active'
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserWorkouts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    }
    return [];
  }
}
