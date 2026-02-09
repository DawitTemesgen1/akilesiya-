import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoteAdminScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const PromoteAdminScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<PromoteAdminScreen> createState() => _PromoteAdminScreenState();
}

class _PromoteAdminScreenState extends State<PromoteAdminScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // --- Translation Maps for dynamic content ---
  final Map<String, String> _roleTranslations = {
    'user': 'ተጠቃሚ',
    'admin': 'አስተዳዳሪ',
    'superior_admin': 'የበላይ አስተዳዳሪ',
    'platform_admin': 'የፕላትፎርም አስተዳዳሪ',
    'library_admin': 'የቤተ-መጽሐፍት አስተዳዳሪ',
  };

  final Map<String, String> _actionTranslations = {
    'Promote': 'መሾም',
    'Demote': 'መሻር',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final result = await SystemAdminService.searchUsers(
      schoolId: widget.schoolId,
      limit: 1000,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _users = result['data']['users'] ?? [];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "ተጠቃሚዎችን መጫን አልተቻለም።"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
  }

  List<String> _parseRoles(String? roleString) {
    if (roleString == null || roleString.isEmpty) return ['user'];
    return roleString
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
  }

  bool _isSuperiorAdmin(Map<String, dynamic> user) {
    final roles = _parseRoles(user['role']?.toString());
    return roles.contains('superior_admin');
  }

  Future<void> _toggleSuperiorAdminStatus(
      Map<String, dynamic> user, bool shouldBeAdmin) async {
    final userName = user['full_name'] ?? 'ይህ ተጠቃሚ';
    final actionText = shouldBeAdmin
        ? _actionTranslations['Promote']!
        : _actionTranslations['Demote']!;

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
              Expanded(
                child: Text(
                  shouldBeAdmin
                      ? '$userNameን በመሾም ላይ...'
                      : 'የ$userNameን ሚና በማዘመን ላይ...',
                  style: GoogleFonts.notoSansEthiopic(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Map<String, dynamic> result;
    if (shouldBeAdmin) {
      result = await SystemAdminService.promoteToSuperiorAdmin(
          widget.schoolId, user['id']);
    } else {
      result = await SystemAdminService.removeSuperiorAdmin(
          widget.schoolId, user['id']);
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('የ$userName ሚና በተሳካ ሁኔታ ተዘምኗል!',
              style: GoogleFonts.notoSansEthiopic()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ተጠቃሚውን $actionText ማድረግ አልተቻለም: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isSuperior = _isSuperiorAdmin(user);
    final List<String> roles = _parseRoles(user['role']?.toString());
    final bool isPlatformAdmin = roles.contains('platform_admin');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isSuperior
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSuperior
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).primaryColor,
            child: isPlatformAdmin
                ? const Icon(Iconsax.crown_1, color: Colors.white, size: 24)
                : Text(
                    (user['full_name']?.toString().isNotEmpty ?? false)
                        ? user['full_name'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
          title: Text(
            user['full_name']?.toString() ?? 'ያልታወቀ ተጠቃሚ',
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['email']?.toString() ?? 'ኢሜል የለም'),
              const SizedBox(height: 6),
              if (roles.isNotEmpty)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: roles.map((role) {
                    return Chip(
                      label: Text(
                        _roleTranslations[role] ??
                            role.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 0),
                      backgroundColor: role == 'superior_admin'
                          ? Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.15),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                )
            ],
          ),
          trailing: isPlatformAdmin
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child:
                      Icon(Iconsax.shield_tick, color: Colors.green, size: 28),
                )
              : Switch(
                  value: isSuperior,
                  onChanged: (newValue) {
                    _toggleSuperiorAdminStatus(user, newValue);
                  },
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('አስተዳዳሪዎችን ያቀናብሩ: ${widget.schoolName}',
            style: GoogleFonts.notoSansEthiopic()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'በስም ወይም በኢሜል ይፈልጉ...',
                hintStyle: GoogleFonts.notoSansEthiopic(),
                prefixIcon: const Icon(Iconsax.search_normal_1),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Card(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Iconsax.info_circle,
                        color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'የበላይ አስተዳዳሪነትን ለመስጠት ወይም ለመሻር ማብሪያውን ይጠቀሙ። ይህ በሌሎች ሚናዎች ላይ ተጽዕኖ አይኖረውም።',
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text('ለዚህ ትምህርት ቤት ምንም ተጠቃሚዎች አልተገኙም።',
                            style: GoogleFonts.notoSansEthiopic()))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(_filteredUsers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
