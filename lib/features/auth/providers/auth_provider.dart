import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _userModel?.isAdmin ?? false;
  bool get needsProfile => _isInitialized && _firebaseUser != null && (_userModel == null || _userModel!.roomNumber.isEmpty);
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    _userModel = null;
    _isInitialized = false;
    notifyListeners();

    if (user != null) {
      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userModel = UserModel.fromMap(doc.data()!, user.uid);
        } else {
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            roomNumber: '',
            dormName: '');
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
          _userModel = newUser;
        }
      } catch (e) {
        debugPrint('Error loading user: $e');
      }
    }

    _isInitialized = true;
    notifyListeners();
  }
  

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) { _setLoading(false); return false; }
        final googleAuth = await googleUser.authentication;
        await _auth.signInWithCredential(GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken));
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _msg(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({required String email, required String password,
    required String name, required String roomNumber, required String dormName}) async {
    _setLoading(true); _errorMessage = null;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = UserModel(uid: cred.user!.uid, email: email, name: name,
        roomNumber: roomNumber, dormName: dormName);
      await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
      await cred.user!.updateDisplayName(name);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _msg(e.code); return false;
    } finally { _setLoading(false); }
  }

  Future<void> updateDormInfo({required String dormName, required String roomNumber}) async {
    if (_firebaseUser == null) return;
    await _db.collection('users').doc(_firebaseUser!.uid).update(
      {'dormName': dormName, 'roomNumber': roomNumber});
    _userModel = _userModel?.copyWith(dormName: dormName, roomNumber: roomNumber);
    notifyListeners();
  }

  Future<void> logout() async {
    if (!kIsWeb) await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }

  String _msg(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-credential': return 'Incorrect email or password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      default: return 'An error occurred. Please try again.';
    }
  }
}
