import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;
  bool _isLoading = false;
  String? _error;

  // Appwrite client setup
  final Client _client = Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1')
      .setProject('6a1f4b0000054fa8444d');
  late final Account _account;

  AuthProvider() {
    _account = Account(_client);
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _userEmail = email;
      _userId = session.userId;
      notifyListeners();
    } on AppwriteException catch (e) {
      _error = e.message ?? 'Login failed';
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    try {
      // Create user
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      // Send verification code
      await _account.createVerification(
        url: 'https://thebird.app/verify',
      );
      notifyListeners();
    } on AppwriteException catch (e) {
      _error = e.message ?? 'Sign up failed';
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _account.deleteSession(sessionId: 'current');
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    _setLoading(true);
    try {
      await _account.createVerification(
        url: 'https://thebird.app/verify',
      );
    } catch (e) {
      debugPrint('Send verification error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmailCode(String code) async {
    _setLoading(true);
    try {
      // Using the user ID from the current session
      final userId = _userId ?? '';
      await _account.updateVerification(
        userId: userId,
        secret: code,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Verify email error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String contact) async {
    _setLoading(true);
    try {
      await _account.createRecovery(
        email: contact,
        url: 'https://thebird.app/reset-password',
      );
    } catch (e) {
      debugPrint('Send password reset error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPasswordWithCode(String code, String newPassword) async {
    _setLoading(true);
    try {
      final userId = _userId ?? '';
      await _account.updateRecovery(
        userId: userId,
        secret: code,
        password: newPassword,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
