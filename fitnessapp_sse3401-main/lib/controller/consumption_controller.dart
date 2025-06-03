import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/consumption_model.dart';

class ConsumptionController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Add new consumption
  Future<void> addConsumption(ConsumptionModel consumption) async {
    final user = _auth.currentUser;
    if (user != null) {
      consumption.userId = user.uid;
      
      // Create a year-month subfolder for better organization
      final date = consumption.timestamp;
      final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      // Convert DateTime to Timestamp for Firestore
      final Map<String, dynamic> data = consumption.toMap();
      data['timestamp'] = Timestamp.fromDate(consumption.timestamp);
      
      // Store under users/{userId}/consumptions/{yearMonth}/items/{consumptionId}
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('consumptions')
          .doc(yearMonth)
          .collection('items')
          .add(data);

      await _updateDailyTotals(consumption);
    }
  }

  // Get today's consumptions
  Future<List<ConsumptionModel>> getTodayConsumptions() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final now = DateTime.now();
        final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('consumptions')
            .doc(yearMonth)
            .collection('items')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ConsumptionModel.fromMap(data);
        }).toList();

      } catch (e) {
        print("Error getting consumptions: $e");
        return [];
      }
    }
    return [];
  }

  // Get consumptions for a specific time range
  Future<List<ConsumptionModel>> getConsumptionsForRange(DateTime start, DateTime end) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Calculate the year-months we need to query
        final months = _getMonthsBetween(start, end);
        List<ConsumptionModel> allConsumptions = [];

        // Query each month's subcollection
        for (String yearMonth in months) {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('consumptions')
              .doc(yearMonth)
              .collection('items')
              .where('timestamp', isGreaterThanOrEqualTo: start)
              .where('timestamp', isLessThan: end)
              .get();

          final consumptions = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ConsumptionModel.fromMap(data);
          }).toList();

          allConsumptions.addAll(consumptions);
        }

        return allConsumptions;
      } catch (e) {
        print("Error getting consumptions range: $e");
        return [];
      }
    }
    return [];
  }

  // Helper method to get list of year-months between two dates
  List<String> _getMonthsBetween(DateTime start, DateTime end) {
    List<String> months = [];
    DateTime current = DateTime(start.year, start.month);
    
    while (current.isBefore(end) || current.year == end.year && current.month == end.month) {
      months.add('${current.year}-${current.month.toString().padLeft(2, '0')}');
      current = DateTime(current.year + (current.month == 12 ? 1 : 0),
          current.month == 12 ? 1 : current.month + 1);
    }
    
    return months;
  }

  // Get daily totals
  Future<Map<String, dynamic>> getDailyTotals() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_totals')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {'waterTotal': 0.0, 'caloriesTotal': 0};
    }
    return {'waterTotal': 0.0, 'caloriesTotal': 0};
  }

  // Update daily totals
  Future<void> _updateDailyTotals(ConsumptionModel consumption) async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_totals')
          .doc(dateStr);

      await docRef.set({
        'caloriesTotal': FieldValue.increment(consumption.type == 'food' ? consumption.value : 0),
        'waterTotal': FieldValue.increment(consumption.type == 'water' ? consumption.value : 0),
        'date': now,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateCalories(double calories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('consumption')
          .doc(startOfDay.toIso8601String())
          .set({
        'calories': FieldValue.increment(calories),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<double> getCurrentCalories() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_totals')
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data()?['caloriesTotal'] != null) {
        return (doc.data()?['caloriesTotal'] as num).toDouble();
      }
    }
    return 0.0;
  }
}
