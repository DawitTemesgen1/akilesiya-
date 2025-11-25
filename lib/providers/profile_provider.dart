// import 'package:flutter/material.dart';
// import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';

// class ProfileProvider extends ChangeNotifier {
//   Map<String, dynamic>? _userProfile;
//   bool _isLoading = true;
//   String? _error;

//   Map<String, dynamic>? get userProfile => _userProfile;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> fetchProfile() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//     try {
//       _userProfile = await ProfileService.getMyProfile();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
