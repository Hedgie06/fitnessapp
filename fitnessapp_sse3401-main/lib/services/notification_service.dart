import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addNotification({
    required String title,
    required String type,
    String? image,
    Map<String, dynamic>? additionalData,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'type': type,
        'image': image ?? _getDefaultImage(type),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': additionalData,
      });
    }
  }

  String _getDefaultImage(String type) {
    switch (type) {
      case 'workout':
        return 'assets/images/Workout1.png';
      case 'food':
        return 'assets/images/Workout2.png';
      case 'water':
        return 'assets/images/Workout3.png';
      case 'profile':
        return 'assets/images/user.png';
      default:
        return 'assets/images/Workout1.png';
    }
  }

  Stream<QuerySnapshot> getNotifications() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots();
    }
    return Stream.empty();
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }
}
