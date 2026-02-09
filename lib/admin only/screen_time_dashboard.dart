// import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
// import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconsax/iconsax.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';

// // ===============================================================
// // MAIN ADMIN DASHBOARD (LIST OF USERS)
// // ===============================================================
// class AdminScreenTimeDashboard extends StatefulWidget {
//   const AdminScreenTimeDashboard({Key? key}) : super(key: key);

//   @override
//   _AdminScreenTimeDashboardState createState() =>
//       _AdminScreenTimeDashboardState();
// }

// class _AdminScreenTimeDashboardState extends State<AdminScreenTimeDashboard> {
//   List<Map<String, dynamic>> _users = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserSummary();
//   }

//   Future<void> _fetchUserSummary() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final response = await ApiService.get('screentime/users');
//       final body = json.decode(response.body);

//       if (mounted) {
//         if (body['success'] == true) {
//           setState(() {
//             _users = List<Map<String, dynamic>>.from(body['data']);
//           });
//         } else {
//           throw Exception(body['message'] ?? 'Failed to load user data.');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//         });
//         debugPrint("Error fetching screen time summary: $e");
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // --- MODIFICATION IS HERE ---
//   // This function is now more robust and will not crash.
//   // ==========================================================
//   String _formatTotalDuration(dynamic seconds) {
//     int totalSeconds = 0;

//     if (seconds is num) {
//       // If it's already a number (int, double), use it directly.
//       totalSeconds = seconds.toInt();
//     } else if (seconds is String) {
//       // If it's a string, try to parse it. Default to 0 if parsing fails.
//       totalSeconds = int.tryParse(seconds) ?? 0;
//     }

//     if (totalSeconds == 0) return "No Data";

//     final duration = Duration(seconds: totalSeconds);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);

//     if (hours > 0) {
//       return '${hours}h ${minutes}m';
//     } else if (minutes > 0) {
//       return '${minutes}m';
//     } else {
//       return '< 1m';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('User Screen Time')),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//           child: CircularProgressIndicator(color: AppTheme.primary));
//     }

//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Iconsax.warning_2, color: AppTheme.danger, size: 60),
//               const SizedBox(height: 16),
//               Text(
//                 'An error occurred',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _error!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: AppTheme.textSecondary),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: const Icon(Iconsax.refresh),
//                 label: const Text("Retry"),
//                 onPressed: _fetchUserSummary,
//               )
//             ],
//           ),
//         ),
//       );
//     }

//     if (_users.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Iconsax.user_remove,
//                 size: 60, color: AppTheme.textSecondary),
//             const SizedBox(height: 16),
//             Text(
//               "No screen time data found for any user.",
//               style: AppTheme.bodyText,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: const Icon(Iconsax.refresh),
//               label: const Text("Refresh"),
//               onPressed: _fetchUserSummary,
//             )
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _fetchUserSummary,
//       child: ListView.builder(
//         itemCount: _users.length,
//         itemBuilder: (context, index) {
//           final user = _users[index];
//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: user['profile_image_url'] != null &&
//                         user['profile_image_url'].isNotEmpty
//                     ? CachedNetworkImageProvider(user['profile_image_url'])
//                     : null,
//                 child: (user['profile_image_url'] == null ||
//                         user['profile_image_url'].isEmpty)
//                     ? Text(user['full_name']?[0] ?? 'U')
//                     : null,
//               ),
//               title: Text(user['full_name'] ?? 'Unknown User'),
//               subtitle: Text(
//                   'Total Usage: ${_formatTotalDuration(user['total_duration_seconds'])}'),
//               trailing: const Icon(Iconsax.arrow_right_3),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AdminUserDetailScreen(
//                       userId: user['id'],
//                       userName: user['full_name'] ?? 'User',
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ===============================================================
// // DETAILED USAGE SCREEN FOR A SINGLE USER (Unchanged)
// // ===============================================================
// class AdminUserDetailScreen extends StatefulWidget {
//   final String userId;
//   final String userName;
//   const AdminUserDetailScreen(
//       {Key? key, required this.userId, required this.userName})
//       : super(key: key);

//   @override
//   _AdminUserDetailScreenState createState() => _AdminUserDetailScreenState();
// }

// class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
//   List<Map<String, dynamic>> _logs = [];
//   Map<DateTime, double> _dailyTotals = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//   }

//   Future<void> _fetchDetails() async {
//     setState(() => _isLoading = true);
//     try {
//       final response =
//           await ApiService.get('screentime/users/${widget.userId}');
//       final body = json.decode(response.body);
//       if (mounted && body['success']) {
//         final logs = List<Map<String, dynamic>>.from(body['data']);
//         setState(() {
//           _logs = logs;
//           _processChartData(logs);
//         });
//       }
//     } catch (e) {
//       // Handle error
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _processChartData(List<Map<String, dynamic>> logs) {
//     final Map<DateTime, double> totals = {};
//     for (var log in logs) {
//       final date = DateTime.parse(log['log_date']);
//       final durationMinutes =
//           ((log['duration_seconds'] as num).toDouble()) / 60.0;
//       totals.update(date, (value) => value + durationMinutes,
//           ifAbsent: () => durationMinutes);
//     }
//     setState(() => _dailyTotals = totals);
//   }

//   String _formatDuration(dynamic seconds) {
//     final duration = Duration(seconds: (seconds as num).toInt());
//     if (duration.inHours > 0)
//       return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
//     if (duration.inMinutes > 0) return '${duration.inMinutes}m';
//     return '${duration.inSeconds}s';
//   }

//   String _formatAppName(String packageName) {
//     if (packageName.contains('.')) {
//       var name = packageName.split('.').last;
//       return name[0].toUpperCase() + name.substring(1);
//     }
//     return packageName;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.userName)),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _logs.isEmpty
//               ? const Center(
//                   child: Text("No usage data recorded for this user."))
//               : CustomScrollView(
//                   slivers: [
//                     SliverPadding(
//                       padding: const EdgeInsets.all(16),
//                       sliver: SliverToBoxAdapter(
//                           child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Daily Usage (Last 7 Days)",
//                               style: GoogleFonts.poppins(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             height: 200,
//                             child: _dailyTotals.isNotEmpty
//                                 ? BarChart(_buildChartData())
//                                 : const Center(
//                                     child: Text("No data for chart.")),
//                           ),
//                           const SizedBox(height: 24),
//                           Text("Detailed Log",
//                               style: GoogleFonts.poppins(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                         ],
//                       )),
//                     ),
//                     SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final log = _logs[index];
//                           return ListTile(
//                             leading: const Icon(Iconsax.mobile,
//                                 color: AppTheme.primary),
//                             title:
//                                 Text(_formatAppName(log['app_package_name'])),
//                             subtitle: Text(DateFormat.yMMMd()
//                                 .format(DateTime.parse(log['log_date']))),
//                             trailing: Text(
//                                 _formatDuration(log['duration_seconds']),
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold)),
//                           );
//                         },
//                         childCount: _logs.length,
//                       ),
//                     )
//                   ],
//                 ),
//     );
//   }

//   BarChartData _buildChartData() {
//     final sortedEntries = _dailyTotals.entries.toList()
//       ..sort((a, b) => a.key.compareTo(b.key));

//     final recentEntries = sortedEntries.take(7).toList();

//     return BarChartData(
//       alignment: BarChartAlignment.spaceAround,
//       barGroups: recentEntries.map((entry) {
//         return BarChartGroupData(
//           x: entry.key.day,
//           barRods: [
//             BarChartRodData(
//                 toY: entry.value,
//                 color: AppTheme.primary,
//                 width: 16,
//                 borderRadius: BorderRadius.circular(4)),
//           ],
//         );
//       }).toList(),
//       titlesData: FlTitlesData(
//         leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             getTitlesWidget: (value, meta) => Text(DateFormat.E().format(
//                 recentEntries
//                     .firstWhere((e) => e.key.day == value.toInt())
//                     .key)),
//           ),
//         ),
//         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       ),
//       borderData: FlBorderData(show: false),
//       gridData: FlGridData(show: true, drawVerticalLine: false),
//     );
//   }
// }
