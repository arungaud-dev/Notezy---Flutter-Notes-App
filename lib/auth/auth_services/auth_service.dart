import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. User ka current state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 2. Current user
  User? get currentUser => _auth.currentUser;
// Display name parameter add kiya
  Future<String?> createUser(
      String email, String password, String displayName) async {
    try {
      debugPrint(
          "----------------------------------------------- Name: $displayName Email: $email, Password: $password");
      // Create user (this also signs in the user)
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      debugPrint(
          "-----------------------------------------------AFTER CREATE,  Name: $displayName Email: $email, Password: $password");

      // Set display name
      await userCredential.user?.updateDisplayName(displayName);

      debugPrint(
          "-----------------------------------------------AFTER NAME SET,  Name: $displayName Email: $email, Password: $password");

      // Ensure the auth's currentUser is reloaded so displayName becomes available
      await _auth.currentUser?.reload();

      // Get the updated user reference
      final updatedUser = _auth.currentUser;
      debugPrint(
          'After signup - uid: ${updatedUser?.uid}, name: ${updatedUser?.displayName}');

      // Optional: if you also store user profile in Firestore, write displayName there too.

      return null; // success
    } on FirebaseAuthException catch (e) {
      // existing error handling...
      switch (e.code) {
        case 'email-already-in-use':
          return 'यह email पहले से registered है';
        case 'invalid-email':
          return 'Email address गलत है';
        case 'weak-password':
          return 'Password कम से कम 6 characters का होना चाहिए';
        case 'operation-not-allowed':
          return 'Email/Password authentication enabled नहीं है';
        default:
          return 'Account create करने में error: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return 'कुछ गलत हो गया। फिर से try करें';
    }
  }

//   Future<String?> createUser(
//       String email, String password, String displayName) async {
//     try {
//       // User create karo
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//
//       // Display name set karo
//       await userCredential.user?.updateDisplayName(displayName);
//
//       // Optional: User ko reload karo taaki updated info mil jaye
//       await userCredential.user?.reload();
//
//       return null; // Success - no error
//     } on FirebaseAuthException catch (e) {
//       switch (e.code) {
//         case 'email-already-in-use':
//           return 'यह email पहले से registered है';
//         case 'invalid-email':
//           return 'Email address गलत है';
//         case 'weak-password':
//           return 'Password कम से कम 6 characters का होना चाहिए';
//         case 'operation-not-allowed':
//           return 'Email/Password authentication enabled नहीं है';
//         default:
//           return 'Account create करने में error: ${e.message}';
//       }
//     } catch (e) {
//       debugPrint('Unexpected error: $e');
//       return 'कुछ गलत हो गया। फिर से try करें';
//     }
//   }

  // 4. Login user with proper error handling
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success - no error
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'यह email registered नहीं है';
        case 'wrong-password':
          return 'Password गलत है';
        case 'invalid-email':
          return 'Email address गलत है';
        case 'user-disabled':
          return 'यह account disable कर दिया गया है';
        case 'too-many-requests':
          return 'बहुत सारी attempts। कुछ देर बाद try करें';
        default:
          return 'Login करने में error: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return 'कुछ गलत हो गया। फिर से try करें';
    }
  }

  // 5. Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 6. Password reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'यह email registered नहीं है';
        case 'invalid-email':
          return 'Email address गलत है';
        default:
          return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'कुछ गलत हो गया';
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<void> createUser(String email, String password) async {
//     try {
//       await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//     } catch (e) {
//       debugPrint("");
//     }
//   }
//
//   Future<void> loginUser(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//     } catch (e) {
//       debugPrint("");
//     }
//   }
// }
