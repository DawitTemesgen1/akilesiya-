// lib/admin only/admin_user_management_screen.dart
// Import the Admin Hub
import 'package:amde_haymanot_abalat_guday/admin%20only/admin_edit%20user.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/admin_hub.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:iconsax/iconsax.dart';

// --- Amharic Localization Strings for Admin User Management ---
abstract class AmharicStringsUserAdmin {
  static const String screenTitle = 'የተጠቃሚዎች አስተዳደር';
  static const String tabVerified = 'የጸደቁ';
  static const String tabPending = 'በመጠባበቅ ላይ';
  static const String settingsButton = 'ማስተካከያዎች';
  static const String loading = 'በመጫን ላይ...';
  static const String error = 'ስህተት:';
  static const String noVerifiedUsers = 'የጸደቁ ተጠቃሚዎች አልተገኙም።';
  static const String noPendingUsers = 'ለማጽደቅ የሚጠባበቁ ተጠቃሚዎች የሉም።';
  static const String noName = 'ስም የለም';
  static const String noEmail = 'ኢሜይል የለም';
  static const String verifyButton = 'አጽድቅ';
  static const String userUpdateSuccess = 'የተጠቃሚው መረጃ በተሳካ ሁኔታ ተዘምኗል።';
  static const String userUpdateFailed = 'የተጠቃሚውን መረጃ ማዘመን አልተሳካም።';
}

// --- Colors and constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);
const Color successColor = Color(0xFF198754);
const Color dangerColor = Color(0xFFDC3545);

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});
  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Create global keys to allow refreshing from the parent
  final GlobalKey<UserListViewState> _verifiedListKey =
      GlobalKey<UserListViewState>();
  final GlobalKey<UserListViewState> _pendingListKey =
      GlobalKey<UserListViewState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _refreshAllLists() {
    _verifiedListKey.currentState?.loadUsers();
    _pendingListKey.currentState?.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AmharicStringsUserAdmin.screenTitle,
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold)), // Translated
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: accentColor,
          tabs: [
            Tab(
                text: AmharicStringsUserAdmin.tabVerified,
                icon: const Icon(Iconsax.user_tick)), // Translated
            Tab(
                text: AmharicStringsUserAdmin.tabPending,
                icon: const Icon(Iconsax.user_add)) // Translated
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserListView(
              key: _verifiedListKey,
              isVerified: true,
              onUpdate: _refreshAllLists),
          UserListView(
              key: _pendingListKey,
              isVerified: false,
              onUpdate: _refreshAllLists),
        ],
      ),
      // --- FIX: This now navigates to the Admin Hub ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AdminHubScreen())),
        label: Text(AmharicStringsUserAdmin.settingsButton,
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold)), // Translated
        icon: const Icon(Iconsax.setting_3),
        backgroundColor: primaryColor,
      ),
    );
  }
}

// The UserListView widget remains the same as the previous correct version, but is included here
class UserListView extends StatefulWidget {
  final bool isVerified;
  final VoidCallback onUpdate;
  const UserListView(
      {super.key, required this.isVerified, required this.onUpdate});
  @override
  State<UserListView> createState() => UserListViewState();
}

class UserListViewState extends State<UserListView> {
  late Future<List<dynamic>> _usersFuture;
  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() {
    setState(() {
      _usersFuture = UserAdminService.getUsers(isVerified: widget.isVerified)
          .then((res) => res['success'] == true
              ? res['data']
              : throw Exception(res['message']));
    });
  }

  Future<void> _verifyUser(String userId) async {
    final result = await UserAdminService.verifyUser(userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              result['message'] ??
                  (result['success'] == true
                      ? AmharicStringsUserAdmin.userUpdateSuccess
                      : AmharicStringsUserAdmin.userUpdateFailed),
              style: GoogleFonts.notoSansEthiopic()), // Translated fallback
          backgroundColor:
              result['success'] == true ? successColor : dangerColor));
      if (result['success'] == true) widget.onUpdate();
    }
  }

  void _navigateToEditScreen(
      BuildContext context, String userId, String userName) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
          builder: (_) =>
              AdminEditUserScreen(userId: userId, userName: userName)),
    )
        .then((didUpdate) {
      if (didUpdate == true) widget.onUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 10),
                Text(AmharicStringsUserAdmin.loading,
                    style: GoogleFonts.notoSansEthiopic(color: primaryColor))
              ])); // Translated
        if (snapshot.hasError)
          return Center(
              child: Text("${AmharicStringsUserAdmin.error} ${snapshot.error}",
                  style: GoogleFonts.notoSansEthiopic())); // Translated
        final users = snapshot.data ?? [];
        if (users.isEmpty)
          return Center(
              child: Text(
                  widget.isVerified
                      ? AmharicStringsUserAdmin.noVerifiedUsers // Translated
                      : AmharicStringsUserAdmin.noPendingUsers, // Translated
                  style: GoogleFonts.notoSansEthiopic(color: Colors.grey)));

        return RefreshIndicator(
          onRefresh: () async => loadUsers(),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(user['full_name']?[0] ?? '?',
                          style: GoogleFonts.notoSansEthiopic())),
                  title: Text(
                      user['full_name'] ?? AmharicStringsUserAdmin.noName,
                      style: GoogleFonts.notoSansEthiopic()), // Translated
                  subtitle: Text(
                      user['email'] ?? AmharicStringsUserAdmin.noEmail,
                      style: GoogleFonts.notoSansEthiopic()), // Translated
                  trailing: widget.isVerified
                      ? Icon(
                          user['is_active'] == 1
                              ? Iconsax.unlock
                              : Iconsax.lock,
                          color: user['is_active'] == 1
                              ? successColor
                              : dangerColor)
                      : ElevatedButton(
                          onPressed: () => _verifyUser(user['id']),
                          child: Text(AmharicStringsUserAdmin.verifyButton,
                              style: GoogleFonts
                                  .notoSansEthiopic())), // Translated
                  onTap: () => widget.isVerified
                      ? _navigateToEditScreen(
                          context, user['id'], user['full_name'])
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
