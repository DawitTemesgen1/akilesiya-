import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class SystemAdminService {
  // Dashboard Statistics
  // In getDashboardStats method, add better error handling:
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await ApiService.get('/system-admin/dashboard');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        // Ensure we have proper data structure
        final data = body['data'] ?? {};

        // Ensure schools and users objects exist
        if (data['schools'] == null) {
          data['schools'] = {'total_schools': 0, 'active_schools': 0};
        }
        if (data['users'] == null) {
          data['users'] = {
            'total_users': 0,
            'active_users': 0,
            'total_admins': 0
          };
        }
        if (data['recentActivity'] == null) {
          data['recentActivity'] = [];
        }

        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch dashboard stats',
        'data': {
          'schools': {'total_schools': 0, 'active_schools': 0},
          'users': {'total_users': 0, 'active_users': 0, 'total_admins': 0},
          'recentActivity': [],
          'growthStats': []
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': {
          'schools': {'total_schools': 0, 'active_schools': 0},
          'users': {'total_users': 0, 'active_users': 0, 'total_admins': 0},
          'recentActivity': [],
          'growthStats': []
        }
      };
    }
  }

  // Schools Management
  static Future<Map<String, dynamic>> getSchools(
      {int page = 1,
      int limit = 20,
      String search = '',
      String status = ''}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (status.isNotEmpty) 'status': status,
      };

      final response = await ApiService.get('/system-admin/schools',
          queryParams: queryParams);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch schools'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // In system_admin_service.dart, update the getSchoolDetail method:
  static Future<Map<String, dynamic>> getSchoolDetail(String schoolId) async {
    try {
      final response = await ApiService.get('/system-admin/schools/$schoolId');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        // Ensure we have proper data structure
        final data = body['data'] ?? {};

        // Ensure all required fields exist with proper defaults
        if (data['school'] == null) {
          data['school'] = {};
        }
        if (data['statistics'] == null) {
          data['statistics'] = {
            'total_members': 0,
            'active_members': 0,
            'verified_members': 0,
            'admin_count': 0,
            'regular_users': 0
          };
        }
        if (data['roleDistribution'] == null) {
          data['roleDistribution'] = [];
        }
        if (data['recentActivity'] == null) {
          data['recentActivity'] = [];
        }
        if (data['growthData'] == null) {
          data['growthData'] = [];
        }

        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch school details',
        'data': {
          'school': {},
          'statistics': {
            'total_members': 0,
            'active_members': 0,
            'verified_members': 0,
            'admin_count': 0,
            'regular_users': 0
          },
          'roleDistribution': [],
          'recentActivity': [],
          'growthData': []
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': {
          'school': {},
          'statistics': {
            'total_members': 0,
            'active_members': 0,
            'verified_members': 0,
            'admin_count': 0,
            'regular_users': 0
          },
          'roleDistribution': [],
          'recentActivity': [],
          'growthData': []
        }
      };
    }
  }
// Add these methods if not already present:

  static Future<Map<String, dynamic>> updateSchool(
      String schoolId, Map<String, dynamic> schoolData) async {
    try {
      final response =
          await ApiService.put('/system-admin/schools/$schoolId', schoolData);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update school'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeSuperiorAdmin(
      String schoolId, String userId) async {
    try {
      final response = await ApiService.post(
        '/system-admin/schools/$schoolId/remove-admin',
        {'userId': userId},
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to remove admin rights'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createSchool(
      Map<String, dynamic> schoolData) async {
    try {
      final response =
          await ApiService.post('/system-admin/schools', schoolData);
      final body = json.decode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to create school'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleSchoolStatus(
      String schoolId, bool isActive) async {
    try {
      final response = await ApiService.patch(
          '/system-admin/schools/$schoolId/status', {'is_active': isActive});
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update school status'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> promoteToSuperiorAdmin(
      String schoolId, String userId) async {
    try {
      final response = await ApiService.post(
          '/system-admin/schools/$schoolId/promote-admin', {'userId': userId});
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to promote user'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
// Add to existing SystemAdminService class

// User Management
  static Future<Map<String, dynamic>> searchUsers({
    String query = '',
    String schoolId = '',
    String role = '',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (query.isNotEmpty) 'search': query,
        if (schoolId.isNotEmpty) 'school_id': schoolId,
        if (role.isNotEmpty) 'role': role,
      };

      final response =
          await ApiService.get('/system-admin/users', queryParams: queryParams);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to search users'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Platform Analytics
  static Future<Map<String, dynamic>> getPlatformAnalytics({
    String period = '30d', // 7d, 30d, 90d, 1y
  }) async {
    try {
      final response =
          await ApiService.get('/system-admin/analytics?period=$period');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch analytics'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// System Settings
  static Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await ApiService.get('/system-admin/settings');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch settings'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSystemSettings(
      Map<String, dynamic> settings) async {
    try {
      final response = await ApiService.put('/system-admin/settings', settings);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update settings'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// User Management
  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final response = await ApiService.get('/system-admin/users/$userId');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch user details'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleUserStatus(
      String userId, bool isActive) async {
    try {
      final response = await ApiService.patch(
          '/system-admin/users/$userId/status', {'is_active': isActive});
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update user status'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Audit Logs
  static Future<Map<String, dynamic>> getAuditLogs(
      {int page = 1, int limit = 50, String actionType = ''}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (actionType.isNotEmpty) 'action_type': actionType,
      };

      final response = await ApiService.get('/system-admin/audit-logs',
          queryParams: queryParams);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch audit logs'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
