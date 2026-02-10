import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getUserDetails(widget.userId);
    if (result['success'] == true) {
      setState(() => _userData = result['data']);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Widget _buildInfoCard() {
    final user = _userData?['user'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', user?['full_name']),
            _buildInfoRow('Email', user?['email']),
            _buildInfoRow('School', user?['school_name']),
            _buildInfoRow('Role', user?['role']),
            _buildInfoRow(
                'Status', user?['is_active'] == 1 ? 'Active' : 'Inactive'),
            _buildInfoRow('Verified', user?['is_verified'] == 1 ? 'Yes' : 'No'),
            _buildInfoRow(
                'Last Login',
                user?['last_login'] != null
                    ? _formatDate(user?['last_login'])
                    : 'Never'),
            _buildInfoRow('Member Since', _formatDate(user?['created_at'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'Not available')),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userData?['user']['full_name'] ?? 'User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  // Add more cards for custom fields, attendance, etc.
                ],
              ),
            ),
    );
  }
}
