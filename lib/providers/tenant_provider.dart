import 'package:flutter/material.dart';

/// Represents the data for a single "Sunday School" (Tenant).
class Tenant {
  final String id;
  final String name;
  final String? logoUrl;
  final Color primaryColor;
  final Color accentColor;

  Tenant({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.primaryColor,
    required this.accentColor,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      primaryColor:
          _colorFromHex(json['primaryColor']) ?? const Color(0xFF012564),
      accentColor:
          _colorFromHex(json['accentColor']) ?? const Color(0xFFFFD700),
    );
  }

  static Color? _colorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    final hexCode = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return null;
    }
  }
}

/// A global state provider to hold the currently active tenant's information.
class TenantProvider extends ChangeNotifier {
  Tenant? _currentTenant;

  Tenant? get currentTenant => _currentTenant;
  bool get hasTenant => _currentTenant != null;

  void setTenant(Map<String, dynamic> tenantJson) {
    _currentTenant = Tenant.fromJson(tenantJson);
    notifyListeners();
  }

  void clearTenant() {
    _currentTenant = null;
    notifyListeners();
  }
}
