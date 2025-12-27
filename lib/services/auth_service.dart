import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';


class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Register new user
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Sign up with Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user == null) {
        throw Exception('Erreur lors de l\'inscription');
      }

      // Wait a moment for auth session to be fully established
      await Future.delayed(const Duration(milliseconds: 500));

      // Create user profile in database
      await _supabase.from(AppConstants.tableUsers).insert({
        'id': response.user!.id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Save session locally
      await LocalStorageService.saveUserSession(
        userId: response.user!.id,
        email: email,
      );

      return UserModel(
        id: response.user!.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Supabase Auth
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // Fetch user profile
      final userData = await _supabase
          .from(AppConstants.tableUsers)
          .select()
          .eq('id', response.user!.id)
          .single();

      // Save session locally
      await LocalStorageService.saveUserSession(
        userId: response.user!.id,
        email: email,
      );

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
      await LocalStorageService.clearUserSession();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null && LocalStorageService.isLoggedIn;
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final userData = await _supabase
          .from(AppConstants.tableUsers)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}