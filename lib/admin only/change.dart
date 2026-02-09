// lib/admin only/change_history_hub_screen.dart

// --- THIS IS THE CRITICAL FIX ---
// The incorrect import has been replaced with the correct one.
import 'package:amde_haymanot_abalat_guday/admin%20only/audit_log.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
// Assuming you use this for icons

// --- Amharic Localization Strings for Change History Hub ---
abstract class AmharicStringsChangeHistory {
  static const String screenTitle = 'ያልተገመገሙ የተጠቃሚ ለውጦች';
  static const String loading = 'በመጫን ላይ...';
  static const String error = 'ስህተት:';
  static const String noChanges = 'ምንም ያልተገመገሙ የተጠቃሚ ለውጦች የሉም።';
  static const String changes = 'ለውጦች';
  static const String personIcon = 'ሰው';
  static const String fullName = 'ሙሉ ስም';
  static const String reviewChanges = 'ለውጦችን ገምግም';
}

class ChangeHistoryHubScreen extends StatefulWidget {
  const ChangeHistoryHubScreen({super.key});
  @override
  State<ChangeHistoryHubScreen> createState() => _ChangeHistoryHubScreenState();
}

class _ChangeHistoryHubScreenState extends State<ChangeHistoryHubScreen> {
  late Future<List<dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() {
    setState(() {
      _summaryFuture =
          UserAdminService.getUsersWithUnreviewedChanges().then((res) {
        if (res['success'] == true) return res['data'];
        throw Exception(
            res['message'] ?? 'መረጃ መጫን አልተቻለም።'); // Translated fallback
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AmharicStringsChangeHistory.screenTitle,
              style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.bold))), // Translated
      body: FutureBuilder<List<dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(AmharicStringsChangeHistory.loading,
                      style: GoogleFonts.notoSansEthiopic())
                ])); // Translated
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    "${AmharicStringsChangeHistory.error} ${snapshot.error}",
                    style: GoogleFonts.notoSansEthiopic())); // Translated
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(
                child: Text(AmharicStringsChangeHistory.noChanges,
                    style: GoogleFonts.notoSansEthiopic())); // Translated
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSummary(),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final changesCount =
                    user['unreviewed_changes']?.toString() ?? '0';

                return ListTile(
                  title: Text(
                      user['full_name'] ?? AmharicStringsChangeHistory.fullName,
                      style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.w600)), // Translated fallback
                  leading: const Icon(Icons.person),
                  trailing: Badge(
                    label: Text(changesCount,
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white)), // Use Amharic font
                    child: const Icon(Icons.notifications),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (_) => UserChangeDetailScreen(
                                  userId: user['id'],
                                  userName: user['full_name'] ??
                                      AmharicStringsChangeHistory.fullName)),
                        )
                        .then((_) => _loadSummary());
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
