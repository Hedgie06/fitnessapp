import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_profile_model.dart';

class UserProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfileModel> getUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        var profileModel = UserProfileModel.fromMap(snapshot.data() ?? {});
        profileModel.bmi = profileModel.calculateBMI();
        return profileModel;
      }
    }
    return UserProfileModel();
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(profile.toMap());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
