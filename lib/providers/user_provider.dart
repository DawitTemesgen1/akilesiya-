import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'dart:developer' as developer;

class UserProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userProfile;
  String? _avatarUrl;
  List<String> _roles = [];

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get avatarUrl => _avatarUrl;
  List<String> get roles => _roles;

  // =======================================================
  // --- MODIFICATIONS START HERE ---
  // =======================================================

  /// A general check for any administrative role.
  bool get isAdmin {
    return _roles.contains('system_admin') || // ADDED
        _roles.contains('superior_admin') ||
        _roles.contains('plan_admin') ||
        _roles.contains('development_admin') ||
        _roles.contains('grade_admin') ||
        _roles.contains('attendance_admin') ||
        _roles.contains('library_admin');
  }

  /// A specific check for the highest-level administrator.
  bool get isSystemAdmin => _roles.contains('system_admin');

  /// A centralized check to determine if the user has permission
  /// to manage the public homepage posts.
  bool get canManagePublicPosts {
    return _roles.contains('system_admin') || _roles.contains('superior_admin');
  }

  // =======================================================
  // --- MODIFICATIONS END HERE ---
  // =======================================================

  String? get tenantId => _userProfile?['tenant_id'];

  UserProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      await fetchUserProfile();
    } else {
      _isLoading = false;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> handleSuccessfulAuth() async {
    _isLoggedIn = true;
    await fetchUserProfile();
  }

  Future<void> handleLogout() async {
    await ApiService.deleteToken();
    _isLoggedIn = false;
    _userProfile = null;
    _avatarUrl = null;
    _roles = [];
    notifyListeners();
  }

  List<String> _allowedScreens = []; // Added for Screen Permissions
  List<String> get allowedScreens => _allowedScreens;

  // ... (getters)

  void _processProfileData(Map<String, dynamic> profileData) {
    _userProfile = profileData;
    final imagePath = profileData['profile_image_url'];
    _avatarUrl = (imagePath != null && imagePath.isNotEmpty)
        ? (imagePath.startsWith('http')
            ? imagePath
            : '${ApiService.baseUrl.replaceAll('/api', '')}/$imagePath')
        : null;
    _isLoggedIn = true;

    _roles = (profileData['role'] is String)
        ? (profileData['role'] as String)
            .split(',')
            .where((r) => r.isNotEmpty)
            .toList()
        : [];

    // Parse Allowed Screens
    _allowedScreens = (profileData['allowed_screens'] is List)
        ? List<String>.from(profileData['allowed_screens'])
        : [];

    // Handle custom_fields_detail list from backend
    if (profileData['custom_fields_detail'] is List) {
      final details = profileData['custom_fields_detail'] as List;
      for (var item in details) {
        if (item is Map) {
          final name = item['field_name'];
          final value = item['field_value'];
          if (name != null) {
            _userProfile![name] =
                value; // Merge to root for ProfileScreen access
          }
        }
      }
    }

    // Also ensure custom_field_values exists as a map (legacy support)
    if (profileData['custom_field_values'] is Map) {
      // It's already there
    } else {
      if (_userProfile != null) {
        _userProfile!['custom_field_values'] = <String, dynamic>{};
      }
    }

    developer.log("--- UserProvider: Data Processed ---", name: "UserProvider");
    developer.log("Final roles: $_roles", name: "UserProvider");
    developer.log("Allowed Screens: $_allowedScreens", name: "UserProvider");
    developer.log("Is System Admin: $isSystemAdmin",
        name: "UserProvider"); // For debugging
    developer.log("Can Manage Public Posts: $canManagePublicPosts",
        name: "UserProvider"); // For debugging
    developer.log(
        "Final custom fields: ${_userProfile?['custom_field_values']}",
        name: "UserProvider");
  }

  Future<void> fetchUserProfile() async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final response = await AuthService.getMe();
      if (response['success'] == true && response['data'] != null) {
        _processProfileData(response['data']);
      } else {
        throw Exception(
            response['message'] ?? 'Failed to process user profile.');
      }
    } catch (e) {
      developer.log("Failed to fetch initial profile: $e. Logging out.",
          name: "UserProvider", error: e);
      await handleLogout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    developer.log("--- UserProvider: Refreshing Profile ---",
        name: "UserProvider");
    try {
      final result = await ProfileService.getMyProfile();
      if (result['success'] == true && result['data'] != null) {
        _processProfileData(result['data']);
        notifyListeners();
      } else {
        developer.log("Profile refresh failed: ${result['message']}",
            name: "UserProvider");
      }
    } catch (e) {
      developer.log("Error during profile refresh: $e",
          name: "UserProvider", error: e);
    }
  }

  void updateAvatar(String newFilename) {
    if (_userProfile != null) {
      _userProfile!['profile_image_url'] = newFilename;
      _avatarUrl = newFilename.startsWith('http')
          ? newFilename
          : '${ApiService.baseUrl.replaceAll('/api', '')}/$newFilename';
      notifyListeners();
    }
  }
}
