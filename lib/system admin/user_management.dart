import 'package:amde_haymanot_abalat_guday/system%20admin/user_detail.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  String _searchQuery = '';
  String _schoolFilter = '';
  String _roleFilter = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _schools = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSchools();
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final result = await SystemAdminService.searchUsers(
      query: _searchQuery,
      schoolId: _schoolFilter,
      role: _roleFilter,
      page: _currentPage,
      limit: _itemsPerPage,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        if (loadMore) {
          _users.addAll(data['users']);
        } else {
          _users = data['users'];
        }
        _hasMore = _currentPage < data['pagination']['totalPages'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchools() async {
    final result = await SystemAdminService.getSchools();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _schools = result['data']['schools']);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      setState(() => _currentPage++);
      _loadUsers(loadMore: true);
    }
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _loadUsers();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String tooltip =
        '${user['full_name'] ?? 'Unknown User'}\n${user['email']}\nRole: ${user['role']}';
    return Tooltip(
      message: tooltip,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: ClipOval(
              child: (user['profile_image_url'] != null)
                  ? Image.network(
                      user['profile_image_url'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Text(
                        (user['full_name'] ?? 'U')[0].toUpperCase(),
                      ),
                    )
                  : Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                    ),
            ),
          ),
          title: Text(
            user['full_name'] ?? 'Unknown User',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['email'],
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user['school_name'] ?? 'No School',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (user['spiritual_class'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'Class: ${user['spiritual_class']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Role: ${user['role']}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['is_active'] == 1
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user['is_active'] == 1 ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color:
                            user['is_active'] == 1 ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (user['role'].toString().contains('superior_admin'))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Superior Admin',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () => _showUserActions(user),
        ),
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _viewUserDetails(user);
              },
            ),
            ListTile(
              leading: Icon(
                  user['is_active'] == 1 ? Icons.block : Icons.check_circle),
              title: Text(
                  user['is_active'] == 1 ? 'Deactivate User' : 'Activate User'),
              onTap: () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
            ),
            // In _showUserActions function, update the promote option:
            if (!user['role'].contains('superior_admin') &&
                !user['role'].contains('system_admin'))
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Promote to Superior Admin'),
                onTap: () {
                  Navigator.pop(context);
                  _promoteToSuperiorAdmin(user);
                },
              ),
            if (user['role'].contains('superior_admin'))
              ListTile(
                leading: const Icon(Icons.person_off),
                title: const Text('Demote from Superior Admin'),
                onTap: () {
                  Navigator.pop(context);
                  _demoteFromSuperiorAdmin(user);
                },
              ),
          ],
        ),
      ),
    );
  }

// In user_management.dart, update these functions:
// Add this function to your _UserManagementScreenState class
  void _promoteToSuperiorAdmin(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Superior Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Are you sure you want to promote ${user['full_name']} to Superior Admin?'),
            const SizedBox(height: 16),
            const Text(
              'This user will gain administrative privileges for their school and will be able to:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Manage users in their school'),
                  Text('• View and edit school settings'),
                  Text('• Access administrative features'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmPromotion(user),
            child: const Text('Promote User'),
          ),
        ],
      ),
    );
  }

  void _confirmPromotion(Map<String, dynamic> user) async {
    Navigator.pop(context); // Close the dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text('Promoting ${user['full_name']}...'),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await SystemAdminService.promoteToSuperiorAdmin(
        user['tenant_id'], // School ID
        user['id'], // User ID
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Successfully promoted ${user['full_name']} to Superior Admin!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh the user list to show updated role
        _loadUsers();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to promote user: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error promoting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _demoteFromSuperiorAdmin(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote from Superior Admin'),
        content: Text(
            'Are you sure you want to remove Superior Admin privileges from ${user['full_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDemotion(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
            child: const Text('Demote User'),
          ),
        ],
      ),
    );
  }

  void _confirmDemotion(Map<String, dynamic> user) async {
    Navigator.pop(context);

    // You would need to create a backend endpoint for demotion
    // For now, this is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demotion functionality coming soon!')),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userId: user['id']),
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    final newStatus = user['is_active'] != 1;
    final result =
        await SystemAdminService.toggleUserStatus(user['id'], newStatus);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      _loadUsers(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _onSearch(value),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue:
                            _schoolFilter.isEmpty ? null : _schoolFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by School',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('All Schools')),
                          ..._schools.map<DropdownMenuItem<String>>((school) {
                            return DropdownMenuItem(
                              value: school['id'].toString(),
                              child: Text(
                                school['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _schoolFilter = value ?? '');
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _roleFilter.isEmpty ? null : _roleFilter,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All')),
                          DropdownMenuItem(
                              value: 'user', child: Text('Regular')),
                          DropdownMenuItem(
                              value: 'superior_admin', child: Text('Superior')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() => _roleFilter = value ?? '');
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading && _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            _loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: _users.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _users.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildUserCard(_users[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
