import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class AuthController {
  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$&*~)';
    }
    return null;
  }

  Future<void> signUpUser(UserModel user, String password) async {
    // Check password strength
    String? validationError = validatePassword(password);
    if (validationError != null) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: validationError,
      );
    }

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: user.email!, password: password);
      user.uid = cred.user!.uid;
      await _saveUserData(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeProfile(UserModel user) async {
    try {
      await _saveUserData(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGoal(String uid, String goal) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'goal': goal});
  }

  Future<void> _saveUserData(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }
}