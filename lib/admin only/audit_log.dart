// lib/admin only/user_change_detail_screen.dart

import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

class UserChangeDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const UserChangeDetailScreen(
      {super.key, required this.userId, required this.userName});

  @override
  State<UserChangeDetailScreen> createState() => _UserChangeDetailScreenState();
}

class _UserChangeDetailScreenState extends State<UserChangeDetailScreen> {
  late Future<List<dynamic>> _logsFuture;

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);

  @override
  void initState() {
    super.initState();
    _loadAndReviewLogs();
  }

  void _loadAndReviewLogs() {
    // አስተዳዳሪው ገጹን እንደከፈተ የመዝገብ መረጃዎቹን እንደታዩ አድርጎ ምልክት ያደርጋል
    UserAdminService.markLogsAsReviewed(widget.userId);
    setState(() {
      _logsFuture =
          UserAdminService.getChangeLogForUser(widget.userId).then((res) {
        if (res['success'] == true) return res['data'];
        throw Exception(res['message']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('የ${widget.userName} የለውጥ ታሪክ',
            style: TextStyle(color: onSurfaceColor)),
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("ስህተትፍ ${snapshot.error}",
                    style: TextStyle(color: subtleTextColor))); // ተተርጉሟል
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(
                child: Text("ለዚህ ተጠቃሚ ምንም የልውጥ ታሪክ አልተገኘም።",
                    style: TextStyle(color: subtleTextColor))); // ተተርጉሟል
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                color: surfaceColor,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['field_name'].replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: onSurfaceColor),
                      ),
                      const Divider(),
                      _buildChangeRow('ከዚህ በፊት:', log['old_value']), // ተተርጉሟል
                      _buildChangeRow('አሁን:', log['new_value']), // ተተርጉሟል
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(
                              DateTime.parse(log['created_at']).toLocal()),
                          style:
                              TextStyle(fontSize: 12, color: subtleTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChangeRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subtleTextColor)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(value != null && value.isNotEmpty ? value : '(ባዶ)',
                style: TextStyle(color: onSurfaceColor))), // ተተርጉሟል
      ],
    );
  }
}
