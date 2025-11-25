import 'package:amde_haymanot_abalat_guday/system%20admin/user_detail.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

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
    return Card(
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
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : Text(
                    (user['full_name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
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
            Text(user['email']),
            Text('School: ${user['school_name']}'),
            if (user['spiritual_class'] != null)
              Text('Class: ${user['spiritual_class']}'),
            Text('Role: ${user['role']}'),
            Text('Joined: ${_formatDate(user['created_at'])}'),
          ],
        ),
        // In _buildUserCard function, update the trailing widget:
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                user['is_active'] == 1 ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: user['is_active'] == 1 ? Colors.green : Colors.red,
                ),
              ),
              backgroundColor:
                  user['is_active'] == 1 ? Colors.green[50] : Colors.red[50],
            ),
            if (user['role'].contains('superior_admin'))
              Chip(
                label: const Text(
                  'Superior Admin',
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                ),
                backgroundColor: Colors.blue[50],
              ),
          ],
        ),
        onTap: () => _showUserActions(user),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Promote User'),
          ),
        ],
      ),
    );
  }

  void _confirmPromotion(Map<String, dynamic> user) async {
    Navigator.pop(context); // Close the dialog

    // Show loading indicator
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlaySize = overlay.size;

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

      Navigator.pop(context); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully promoted ${user['full_name']} to Superior Admin!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the user list to show updated role
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to promote user: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error promoting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
              foregroundColor: Colors.white,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
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
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _schoolFilter.isEmpty ? null : _schoolFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by School',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('All Schools')),
                          ..._schools.map<DropdownMenuItem<String>>((school) {
                            return DropdownMenuItem(
                              value: school['id'],
                              child: Text(school['name']),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _schoolFilter = value ?? '');
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _roleFilter.isEmpty ? null : _roleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All Roles')),
                          DropdownMenuItem(
                              value: 'user', child: Text('Regular Users')),
                          DropdownMenuItem(
                              value: 'superior_admin',
                              child: Text('Superior Admins')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Other Admins')),
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
