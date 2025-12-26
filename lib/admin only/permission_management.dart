import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

// --- UI Theme Constants ---
const Color kAdminBackgroundColor = Color.fromARGB(255, 1, 37, 100);
const Color kAdminCardColor = Color.fromARGB(255, 1, 37, 100);
const Color kAdminPrimaryAccent = Color(0xFFFFD700);
const Color kAdminSecondaryText = Color(0xFFFFD700);

// --- View Modes ---
const String kRolePermissionView = 'የሚና ፈቃድ';
const String kDepartmentPermissionView = 'የዕቅድ ክፍል ፈቃድ';
const String kScreenPermissionView = 'የሚና ስክሪን ፈቃድ';
const String kUserScreenPermissionView = 'የተጠቃሚ ስክሪን ፈቃድ';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allDepartments = [];
  List<Map<String, dynamic>> _allScreens = [];
  final List<Map<String, dynamic>> _allRoles = [
    {'id': 1, 'role_name': 'user', 'display_name': 'ተራ አባል'},
    {'id': 2, 'role_name': 'admin', 'display_name': 'አስተዳዳሪ'},
    {'id': 3, 'role_name': 'superior_admin', 'display_name': 'የላቀ አስተዳዳሪ'}
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _logError(String functionName, Object e, StackTrace s) {
    developer.log('Error in $functionName',
        name: 'SuperAdminDashboard', error: e, stackTrace: s);
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // --- ROBUST, SEQUENTIAL DATA FETCHING ---
      final usersResponse = await ApiService.get('/admin/permissions/users');
      final deptsResponse =
          await ApiService.get('/admin/permissions/departments');
      final screensResponse =
          await ApiService.get('/admin/permissions/screens');

      if (mounted) {
        setState(() {
          final usersData = json.decode(usersResponse.body);
          final deptsData = json.decode(deptsResponse.body);
          final screensData = json.decode(screensResponse.body);
          _allUsers = List<Map<String, dynamic>>.from(
              usersData is List ? usersData : (usersData['data'] ?? []));
          _allDepartments = List<Map<String, dynamic>>.from(
              deptsData is List ? deptsData : (deptsData['data'] ?? []));
          _allScreens = List<Map<String, dynamic>>.from(
              screensData is List ? screensData : (screensData['data'] ?? []));
        });
      }
    } catch (e, s) {
      _logError('_initializeData', e, s);
      if (mounted) setState(() => _error = 'መረጃን በማምጣት ላይ ስህተት ተፈጥሯል።');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: GoogleFonts.notoSansEthiopic()),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuperiorAdmin =
        Provider.of<UserProvider>(context).roles.contains('superior_admin');

    if (!isSuperiorAdmin) {
      return Scaffold(
        backgroundColor: kAdminBackgroundColor,
        appBar: AppBar(
          title: Text('የአስተዳደር ማዕከል', style: GoogleFonts.notoSansEthiopic()),
          backgroundColor: kAdminBackgroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Text('ይህ ገጽ ለየላቀ አስተዳዳሪ ብቻ ነው።',
              style: GoogleFonts.notoSansEthiopic(color: kAdminPrimaryAccent)),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kAdminBackgroundColor,
        appBar: AppBar(
          title: Text('የአስተዳደር ማዕከል', style: GoogleFonts.notoSansEthiopic()),
          backgroundColor: kAdminBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh), onPressed: _initializeData)
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: kAdminPrimaryAccent,
            labelColor: kAdminPrimaryAccent,
            unselectedLabelColor: kAdminSecondaryText,
            labelStyle:
                GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: kScreenPermissionView),
              Tab(text: kUserScreenPermissionView),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kAdminPrimaryAccent))
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.redAccent)))
                : TabBarView(
                    children: [
                      ScreenManagerView(
                          users: _allUsers,
                          allScreens: _allScreens,
                          allRoles: _allRoles,
                          showSnackbar: _showSnackbar),
                      UserScreenManagerView(
                          users: _allUsers,
                          allScreens: _allScreens,
                          showSnackbar: _showSnackbar),
                    ],
                  ),
      ),
    );
  }
}

// --- WIDGET FOR ROLE PERMISSION VIEW (Tab 1) ---
class RoleManagerView extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  final Future<void> Function() onRefresh;
  final Function(String, {bool isError}) showSnackbar;
  const RoleManagerView(
      {super.key,
      required this.allUsers,
      required this.onRefresh,
      required this.showSnackbar});

  @override
  State<RoleManagerView> createState() => _RoleManagerViewState();
}

class _RoleManagerViewState extends State<RoleManagerView> {
  List<Map<String, dynamic>> _filteredUsers = [];
  final _searchController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedBudin;
  String? _selectedAgelgilotKifil;
  List<String> _allDepartmentOptions = [];
  List<String> _allBudinOptions = [];
  List<String> _allAgelgilotKifilOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.allUsers;
    _populateDropdowns();
    _searchController.addListener(_performFilter);
  }

  @override
  void didUpdateWidget(covariant RoleManagerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allUsers != oldWidget.allUsers) {
      _populateDropdowns();
      _performFilter();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _populateDropdowns() {
    try {
      _allDepartmentOptions = widget.allUsers
          .map((u) => u['department'])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      _allBudinOptions = widget.allUsers
          .map((u) => u['budin'])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      _allAgelgilotKifilOptions = widget.allUsers
          .map((u) => u['agelgilot_kifil'])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (e, s) {
      developer.log('Error populating dropdowns',
          name: 'RoleManagerView._populateDropdowns', error: e, stackTrace: s);
    }
  }

  void _performFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = widget.allUsers.where((user) {
        final name = user['full_name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(query) || email.contains(query);
        if (!matchesSearch) return false;
        final matchesDept = _selectedDepartment == null ||
            user['department'] == _selectedDepartment;
        final matchesBudin =
            _selectedBudin == null || user['budin'] == _selectedBudin;
        final matchesAgelgilot = _selectedAgelgilotKifil == null ||
            user['agelgilot_kifil'] == _selectedAgelgilotKifil;
        return matchesDept && matchesBudin && matchesAgelgilot;
      }).toList();
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await ApiService.post('/admin/permissions/update-role',
          {'target_user_id': userId, 'new_role': newRole});
      widget.showSnackbar('የአባሉ ሚና በተሳካ ሁኔታ ተቀይሯል።');
      await widget.onRefresh();
    } catch (e, s) {
      final msg = 'የሚና ለውጥ ስህተት: ${e.toString()}';
      developer.log(msg,
          name: 'RoleManagerView._updateUserRole', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    }
  }

  Future<void> _removeUser(String userId, String userName) async {
    final confirmed = await _showConfirmationDialog(
        context: context,
        title: '$userNameን ለማጥፋት',
        content:
            'ማስጠንቀቂያ! ይህ ድርጊት የአባሉን አካውንት እና ሁሉንም ተያያዥ መረጃዎች በቋሚነት ያጠፋል። ይህንን ድርጊት መቀልበስ አይቻልም።',
        confirmText: 'አጥፋ',
        isDestructive: true);
    if (confirmed != true) return;
    try {
      await ApiService.delete('/admin/permissions/delete-user/$userId');
      widget.showSnackbar('አባሉ በተሳካ ሁኔታ ተወግዷል።');
      await widget.onRefresh();
    } catch (e, s) {
      final msg = 'የማጥፋት ስህተት: ${e.toString()}';
      developer.log(msg,
          name: 'RoleManagerView._removeUser', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    }
  }

  void _showEditRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'user';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kAdminCardColor,
          title: Text('${user['full_name']} - ሚና አስተካክል',
              style: GoogleFonts.notoSansEthiopic(color: kAdminPrimaryAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                  title: Text('ተራ አባል', style: GoogleFonts.notoSansEthiopic()),
                  value: 'user',
                  groupValue: selectedRole,
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                  activeColor: kAdminPrimaryAccent),
              RadioListTile<String>(
                  title: Text('አስተዳዳሪ', style: GoogleFonts.notoSansEthiopic()),
                  value: 'admin',
                  groupValue: selectedRole,
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                  activeColor: kAdminPrimaryAccent),
              RadioListTile<String>(
                  title:
                      Text('የላቀ አስተዳዳሪ', style: GoogleFonts.notoSansEthiopic()),
                  value: 'superior_admin',
                  groupValue: selectedRole,
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                  activeColor: kAdminPrimaryAccent),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeUser(user['id'], user['full_name']);
                },
                child: Text('አባሉን አስወግድ',
                    style:
                        GoogleFonts.notoSansEthiopic(color: Colors.redAccent))),
            const Spacer(),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ይቅር',
                    style: GoogleFonts.notoSansEthiopic(
                        color: kAdminSecondaryText))),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserRole(user['id'], selectedRole);
              },
              child: Text('አስቀምጥ', style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Text("በዚህ ማጣሪያ ምንም ተጠቃሚ አልተገኘም።",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kAdminSecondaryText)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final role = user['role'] ?? 'user';
                    return Card(
                      color: kAdminCardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(user['full_name']?[0] ?? '?')),
                        title: Text(user['full_name'] ?? 'ስም የሌለው',
                            style: GoogleFonts.notoSansEthiopic(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(user['email'] ?? 'ኢሜይል የለም',
                            style: TextStyle(color: kAdminSecondaryText)),
                        trailing: Chip(
                          label: Text(role,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                          backgroundColor: role == 'superior_admin'
                              ? Colors.red.shade900
                              : role == 'admin'
                                  ? Colors.orange.shade900
                                  : Colors.blue.shade900,
                          side: BorderSide.none,
                        ),
                        onTap: () => _showEditRoleDialog(user),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
                labelText: 'በስም ወይም በኢሜይል ፈልግ',
                labelStyle: GoogleFonts.notoSansEthiopic(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildDropdown(
                      _selectedDepartment,
                      _allDepartmentOptions,
                      (val) => setState(() {
                            _selectedDepartment = val;
                            _performFilter();
                          }),
                      'ዋና ቡድን')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildDropdown(
                      _selectedBudin,
                      _allBudinOptions,
                      (val) => setState(() {
                            _selectedBudin = val;
                            _performFilter();
                          }),
                      'ልዩ ኅብረት')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildDropdown(
                      _selectedAgelgilotKifil,
                      _allAgelgilotKifilOptions,
                      (val) => setState(() {
                            _selectedAgelgilotKifil = val;
                            _performFilter();
                          }),
                      'የአገልግሎት ክፍል')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items,
      ValueChanged<String?> onChanged, String label) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(label,
          style: GoogleFonts.notoSansEthiopic(
              fontSize: 14, color: kAdminSecondaryText)),
      items: [
        DropdownMenuItem(
            value: null,
            child: Text("ሁሉም", style: GoogleFonts.notoSansEthiopic())),
        ...items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item,
                style: GoogleFonts.notoSansEthiopic(),
                overflow: TextOverflow.ellipsis)))
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}

// --- WIDGET FOR DEPARTMENT PERMISSION VIEW (Tab 2) ---
class DepartmentManagerView extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> allDepartments;
  final Function(String, {bool isError}) showSnackbar;
  const DepartmentManagerView(
      {super.key,
      required this.users,
      required this.allDepartments,
      required this.showSnackbar});

  @override
  State<DepartmentManagerView> createState() => _DepartmentManagerViewState();
}

class _DepartmentManagerViewState extends State<DepartmentManagerView> {
  Map<String, dynamic>? _selectedUser;
  Set<String> _currentUserDeptPerms = {};
  bool _isDetailLoading = false;
  bool _isSaving = false;

  Future<void> _selectUser(Map<String, dynamic> user) async {
    setState(() {
      _selectedUser = user;
      _isDetailLoading = true;
    });
    try {
      final response = await ApiService.get(
          '/admin/permissions/user-department-permissions/${user['id']}');
      if (mounted) {
        final data = json.decode(response.body);
        final permissions = data is List ? data : (data['data'] ?? []);
        setState(() => _currentUserDeptPerms =
            Set<String>.from(permissions.map((e) => e.toString())));
      }
    } catch (e, s) {
      final msg = 'የተጠቃሚ ፈቃዶችን በማምጣት ላይ ስህተት ተፈጥሯል።: $e';
      developer.log(msg,
          name: 'DepartmentManager._selectUser', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isDetailLoading = false);
    }
  }

  Future<void> _saveDeptPerms() async {
    if (_selectedUser == null) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.post(
          '/admin/permissions/update-department-permissions', {
        'target_user_id': _selectedUser!['id'],
        'department_ids': _currentUserDeptPerms.toList()
      });
      widget.showSnackbar('የክፍል ፈቃዶች በተሳካ ሁኔታ ተቀምጠዋል');
    } catch (e, s) {
      final msg = 'ፈቃዶችን በማስቀመጥ ላይ ስህተት ተፈጥሯል: $e';
      developer.log(msg,
          name: 'DepartmentManager._saveDeptPerms', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              final user = widget.users[index];
              final isSelected = _selectedUser?['id'] == user['id'];
              return Card(
                color: isSelected
                    ? kAdminPrimaryAccent.withOpacity(0.25)
                    : kAdminCardColor,
                child: ListTile(
                  title: Text(user['full_name'],
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
                  onTap: () => _selectUser(user),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1, color: kAdminCardColor),
        Expanded(
          flex: 3,
          child: _selectedUser == null
              ? Center(
                  child: Text("ፈቃዶችን ለማስተዳደር ተጠቃሚ ይምረጡ",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kAdminPrimaryAccent)))
              : _isDetailLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              "የ'${_selectedUser!['full_name']}' የክፍል ፈቃዶች",
                              style: GoogleFonts.notoSansEthiopic(
                                  color: kAdminPrimaryAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.allDepartments.length,
                            itemBuilder: (context, index) {
                              final dept = widget.allDepartments[index];
                              return CheckboxListTile(
                                title: Text(dept['name'],
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white)),
                                value:
                                    _currentUserDeptPerms.contains(dept['id']),
                                onChanged: (isChecked) {
                                  setState(() {
                                    if (isChecked == true)
                                      _currentUserDeptPerms.add(dept['id']);
                                    else
                                      _currentUserDeptPerms.remove(dept['id']);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveDeptPerms,
                                  child: _isSaving
                                      ? const CircularProgressIndicator(
                                          color: kAdminBackgroundColor,
                                        )
                                      : Text("አስቀምጥ",
                                          style:
                                              GoogleFonts.notoSansEthiopic()))),
                        )
                      ],
                    ),
        ),
      ],
    );
  }
}

// --- WIDGET FOR SCREEN PERMISSION VIEW (Tab 3) ---
class ScreenManagerView extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> allScreens;
  final List<Map<String, dynamic>> allRoles;
  final Function(String, {bool isError}) showSnackbar;
  const ScreenManagerView(
      {super.key,
      required this.users,
      required this.allScreens,
      required this.allRoles,
      required this.showSnackbar});

  @override
  State<ScreenManagerView> createState() => _ScreenManagerViewState();
}

class _ScreenManagerViewState extends State<ScreenManagerView> {
  String? _selectedRoleName;
  Set<int> _currentScreenPerms = {};
  bool _isDetailLoading = false;
  bool _isSaving = false;

  Future<void> _selectRole(String roleName) async {
    setState(() {
      _selectedRoleName = roleName;
      _isDetailLoading = true;
      _currentScreenPerms.clear();
    });
    try {
      final response = await ApiService.get(
          '/admin/permissions/screen-permissions-for-role/$roleName');
      if (mounted) {
        final data = json.decode(response.body);
        final permissions = data is List ? data : (data['data'] ?? []);
        setState(() => _currentScreenPerms =
            Set<int>.from(permissions.map((e) => e as int)));
      }
    } catch (e, s) {
      final msg = 'የስክሪን ፈቃዶችን በማምጣት ላይ ስህተት ተፈጥሯል: $e';
      developer.log(msg,
          name: 'ScreenManager._selectRole', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isDetailLoading = false);
    }
  }

  Future<void> _saveScreenPerms() async {
    if (_selectedRoleName == null || _selectedRoleName!.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.post('/admin/permissions/update-screen-permissions', {
        'p_role_name': _selectedRoleName,
        'p_screen_ids': _currentScreenPerms.toList()
      });
      widget.showSnackbar('የስክريን ፈቃዶች በተሳካ ሁኔታ ተቀምጠዋል');
    } catch (e, s) {
      final msg = 'ፈቃዶችን በማስቀመጥ ላይ ስህተት ተፈጥሯል: $e';
      developer.log(msg,
          name: 'ScreenManager._saveScreenPerms', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleName,
                  decoration: InputDecoration(
                    labelText: 'ሚና ይምረጡ',
                    labelStyle: GoogleFonts.notoSansEthiopic(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: widget.allRoles
                      .map((r) => DropdownMenuItem<String>(
                            value: r['role_name'] as String,
                            child: Text(r['display_name'] as String,
                                style: GoogleFonts.notoSansEthiopic()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _selectRole(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving || _selectedRoleName == null
                    ? null
                    : _saveScreenPerms,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text('አስቀምጥ', style: GoogleFonts.notoSansEthiopic()),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kAdminCardColor),
        Expanded(
          child: _selectedRoleName == null
              ? Center(
                  child: Text('ሚና ይምረጡ',
                      style: GoogleFonts.notoSansEthiopic(
                          color: kAdminPrimaryAccent)))
              : _isDetailLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.allScreens.length,
                      itemBuilder: (context, index) {
                        final screen = widget.allScreens[index];
                        return Card(
                          color: kAdminCardColor,
                          child: CheckboxListTile(
                            title: Text(screen['display_name'],
                                style: GoogleFonts.notoSansEthiopic(
                                    color: Colors.white)),
                            subtitle: Text(screen['screen_key'],
                                style: const TextStyle(
                                    color: kAdminSecondaryText)),
                            value: _currentScreenPerms.contains(screen['id']),
                            onChanged: (isChecked) {
                              setState(() {
                                if (isChecked == true) {
                                  _currentScreenPerms.add(screen['id']);
                                } else {
                                  _currentScreenPerms.remove(screen['id']);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class AttendancePreviewView extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function(String, {bool isError}) showSnackbar;
  const AttendancePreviewView(
      {super.key, required this.users, required this.showSnackbar});

  @override
  State<AttendancePreviewView> createState() => _AttendancePreviewViewState();
}

class _AttendancePreviewViewState extends State<AttendancePreviewView> {
  final Set<String> _selectedUserIds = {};
  bool _isComputing = false;
  Map<String, Map<String, int>> _perUserStats = {};
  Map<String, int> _overallStats = {
    'present': 0,
    'absent': 0,
    'late': 0,
    'permission': 0
  };

  void _toggleSelection(Map<String, dynamic> user) {
    final id = user['id'].toString();
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
      } else {
        _selectedUserIds.add(id);
      }
    });
  }

  Future<void> _computeSummary() async {
    if (_selectedUserIds.isEmpty) return;
    setState(() {
      _isComputing = true;
      _perUserStats = {};
      _overallStats = {'present': 0, 'absent': 0, 'late': 0, 'permission': 0};
    });
    try {
      for (final uid in _selectedUserIds) {
        final history =
            await AttendanceService.getAttendanceHistoryForUser(uid);
        final Map<String, int> counters = {
          'present': 0,
          'absent': 0,
          'late': 0,
          'permission': 0
        };
        for (final rec in history) {
          final status = (rec['status'] as String?) ?? 'unknown';
          if (counters.containsKey(status))
            counters[status] = counters[status]! + 1;
        }
        _perUserStats[uid] = counters;
        _overallStats.update('present', (v) => v + counters['present']!);
        _overallStats.update('absent', (v) => v + counters['absent']!);
        _overallStats.update('late', (v) => v + counters['late']!);
        _overallStats.update('permission', (v) => v + counters['permission']!);
      }
    } catch (e) {
      widget.showSnackbar('ማጠቃለያ ማስላ አልተሳካም: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isComputing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              final user = widget.users[index];
              final id = user['id'].toString();
              final selected = _selectedUserIds.contains(id);
              return Card(
                color: selected
                    ? kAdminPrimaryAccent.withOpacity(0.25)
                    : kAdminCardColor,
                child: CheckboxListTile(
                  value: selected,
                  title: Text(user['full_name'] ?? '',
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
                  subtitle: Text(user['email'] ?? '',
                      style: GoogleFonts.notoSansEthiopic(
                          color: kAdminSecondaryText)),
                  onChanged: (_) => _toggleSelection(user),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1, color: kAdminCardColor),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isComputing || _selectedUserIds.isEmpty
                            ? null
                            : _computeSummary,
                        child: _isComputing
                            ? const CircularProgressIndicator()
                            : Text('ማጠቃለያ አስላ',
                                style: GoogleFonts.notoSansEthiopic()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedUserIds.isEmpty)
                  Center(
                    child: Text('ተጠቃሚዎችን ይምረጡ',
                        style: GoogleFonts.notoSansEthiopic(
                            color: kAdminPrimaryAccent)),
                  )
                else if (_isComputing)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _statChip(
                          'የተገኙ', _overallStats['present']!, Colors.green),
                      _statChip('የቀሩ', _overallStats['absent']!, Colors.red),
                      _statChip('ያረፈዱ', _overallStats['late']!, Colors.orange),
                      _statChip(
                          'በፍቃድ', _overallStats['permission']!, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _perUserStats.entries.map((entry) {
                        final uid = entry.key;
                        final stats = entry.value;
                        final user = widget.users.firstWhere(
                            (u) => u['id'].toString() == uid,
                            orElse: () => {});
                        final name = user['full_name'] ?? uid;
                        return Card(
                          color: kAdminCardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(name,
                                style: GoogleFonts.notoSansEthiopic(
                                    color: Colors.white)),
                            subtitle: Text(
                                'ተገኘ: ${stats['present']} • ቀረ: ${stats['absent']} • አርፈደ: ${stats['late']} • በፍቃድ: ${stats['permission']}',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: kAdminSecondaryText)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, int value, Color color) {
    return Chip(
      label:
          Text('$label: $value', style: const TextStyle(color: Colors.white)),
      backgroundColor: Color.alphaBlend(Colors.black.withOpacity(0.2), color),
      side: BorderSide.none,
    );
  }
}

// --- HELPER DIALOG (Used by RoleManagerView) ---
Future<bool?> _showConfirmationDialog(
    {required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false}) {
  return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: kAdminCardColor,
            title: Text(title, style: GoogleFonts.notoSansEthiopic()),
            content: Text(content, style: GoogleFonts.notoSansEthiopic()),
            actions: [
              TextButton(
                  child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic()),
                  onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor:
                        isDestructive ? Colors.redAccent : kAdminPrimaryAccent),
                child: Text(confirmText, style: GoogleFonts.notoSansEthiopic()),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ));
}

// --- WIDGET FOR USER SCREEN PERMISSION VIEW (New Tab) ---
class UserScreenManagerView extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> allScreens;
  final Function(String, {bool isError}) showSnackbar;
  const UserScreenManagerView(
      {super.key,
      required this.users,
      required this.allScreens,
      required this.showSnackbar});

  @override
  State<UserScreenManagerView> createState() => _UserScreenManagerViewState();
}

class _UserScreenManagerViewState extends State<UserScreenManagerView> {
  Map<String, dynamic>? _selectedUser;
  Set<int> _currentUserScreenPerms = {}; // Using Screen IDs (int)
  bool _isDetailLoading = false;
  bool _isSaving = false;

  Future<void> _selectUser(Map<String, dynamic> user) async {
    setState(() {
      _selectedUser = user;
      _isDetailLoading = true;
      _currentUserScreenPerms.clear();
    });
    try {
      final response = await ApiService.get(
          '/admin/permissions/screen-permissions-for-user/${user['id']}');
      if (mounted) {
        final data = json.decode(response.body);
        final permissions = data is List ? data : (data['data'] ?? []);
        setState(() => _currentUserScreenPerms =
            Set<int>.from(permissions.map((e) => e as int)));
      }
    } catch (e, s) {
      final msg = 'የተጠቃሚ ስክሪን ፈቃዶችን በማምጣት ላይ ስህተት ተፈጥሯል: $e';
      developer.log(msg,
          name: 'UserScreenManager._selectUser', error: e, stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isDetailLoading = false);
    }
  }

  Future<void> _saveUserScreenPerms() async {
    if (_selectedUser == null) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.post(
          '/admin/permissions/update-user-screen-permissions', {
        'user_id': _selectedUser!['id'],
        'screen_ids': _currentUserScreenPerms.toList()
      });
      widget.showSnackbar('የተጠቃሚ ስክሪን ፈቃዶች በተሳካ ሁኔታ ተቀምጠዋል');
    } catch (e, s) {
      final msg = 'ፈቃዶችን በማስቀመጥ ላይ ስህተት ተፈጥሯል: $e';
      developer.log(msg,
          name: 'UserScreenManager._saveUserScreenPerms',
          error: e,
          stackTrace: s);
      widget.showSnackbar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              final user = widget.users[index];
              final isSelected = _selectedUser?['id'] == user['id'];
              return Card(
                color: isSelected
                    ? kAdminPrimaryAccent.withOpacity(0.25)
                    : kAdminCardColor,
                child: ListTile(
                  title: Text(user['full_name'] ?? 'No Name',
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
                  subtitle: Text(user['role'] ?? '',
                      style: const TextStyle(
                          color: kAdminSecondaryText, fontSize: 12)),
                  onTap: () => _selectUser(user),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1, color: kAdminCardColor),
        Expanded(
          flex: 3,
          child: _selectedUser == null
              ? Center(
                  child: Text("ፈቃዶችን ለማስተዳደር ተጠቃሚ ይምረጡ",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kAdminPrimaryAccent)))
              : _isDetailLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              "የ'${_selectedUser!['full_name']}' ስክሪን ፈቃዶች",
                              style: GoogleFonts.notoSansEthiopic(
                                  color: kAdminPrimaryAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.allScreens.length,
                            itemBuilder: (context, index) {
                              final screen = widget.allScreens[index];
                              return CheckboxListTile(
                                title: Text(screen['display_name'],
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white)),
                                subtitle: Text(screen['screen_key'],
                                    style: const TextStyle(
                                        color: Colors.white30, fontSize: 10)),
                                value: _currentUserScreenPerms
                                    .contains(screen['id']),
                                onChanged: (isChecked) {
                                  setState(() {
                                    if (isChecked == true)
                                      _currentUserScreenPerms.add(screen['id']);
                                    else
                                      _currentUserScreenPerms
                                          .remove(screen['id']);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed:
                                      _isSaving ? null : _saveUserScreenPerms,
                                  child: _isSaving
                                      ? const CircularProgressIndicator(
                                          color: kAdminBackgroundColor,
                                        )
                                      : Text("አስቀምጥ",
                                          style:
                                              GoogleFonts.notoSansEthiopic()))),
                        )
                      ],
                    ),
        ),
      ],
    );
  }
}
