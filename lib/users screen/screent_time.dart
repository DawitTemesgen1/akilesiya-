// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;
// import 'dart:convert';

// // Packages used only for the Android implementation
// import 'package:usage_stats/usage_stats.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // Your app's services
// import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

// // --- Notification Service (Unchanged) ---
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void initialize() {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     _notificationsPlugin.initialize(initializationSettings);
//   }

//   static Future<void> showNotification(
//       {required int id, required String title, required String body}) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'usage_limit_channel',
//       'Usage Limit Alerts',
//       channelDescription:
//           'Notifications for when an app usage limit is exceeded.',
//       importance: Importance.max,
//       priority: Priority.high,
//       ongoing: true,
//       autoCancel: false,
//     );
//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);
//     await _notificationsPlugin.show(id, title, body, notificationDetails);
//   }
// }

// // Enum to manage the different time views (Unchanged)
// enum TimePeriod { daily, weekly, monthly }

// // ===============================================================
// // MAIN SCREEN WIDGET (PLATFORM DISPATCHER - Unchanged)
// // ===============================================================
// class ScreenTimeScreen extends StatelessWidget {
//   const ScreenTimeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     NotificationService.initialize();
//     bool isSupported = !kIsWeb && Platform.isAndroid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Digital Wellbeing'),
//         backgroundColor: const Color(0xFF00796B),
//       ),
//       backgroundColor: const Color(0xFFF0F2F5),
//       body: isSupported
//           ? const _AndroidScreenTimeView()
//           : const _UnsupportedPlatformWidget(),
//     );
//   }
// }

// // ===============================================================
// // WIDGET FOR ANDROID (THE FULL-FEATURED DASHBOARD - Unchanged)
// // ===============================================================

// class _AndroidScreenTimeView extends StatefulWidget {
//   const _AndroidScreenTimeView({Key? key}) : super(key: key);

//   @override
//   __AndroidScreenTimeViewState createState() => __AndroidScreenTimeViewState();
// }

// class __AndroidScreenTimeViewState extends State<_AndroidScreenTimeView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _hasPermission = false;
//   bool _isLoadingPermission = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _checkPermission();
//   }

//   Future<void> _checkPermission() async {
//     bool? granted = await UsageStats.checkUsagePermission();
//     if (mounted) {
//       setState(() {
//         _hasPermission = granted ?? false;
//         _isLoadingPermission = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoadingPermission) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (!_hasPermission) {
//       return _buildPermissionRequestUI(onGranted: () {
//         setState(() {
//           _hasPermission = true;
//         });
//       });
//     }

//     return Column(
//       children: [
//         TabBar(
//           controller: _tabController,
//           labelColor: const Color(0xFF00796B),
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: const Color(0xFF00796B),
//           tabs: const [
//             Tab(icon: Icon(Icons.today), text: 'Daily'),
//             Tab(icon: Icon(Icons.view_week), text: 'Weekly'),
//             Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
//           ],
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: const [
//               _UsageView(period: TimePeriod.daily),
//               _UsageView(period: TimePeriod.weekly),
//               _UsageView(period: TimePeriod.monthly),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPermissionRequestUI({required VoidCallback onGranted}) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.security, size: 60, color: Colors.orange),
//             const SizedBox(height: 20),
//             const Text('Permission Required',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 10),
//             const Text(
//                 'To show your digital habits, this app needs access to your device\'s usage data.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.black54)),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00796B),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 textStyle: const TextStyle(fontSize: 16),
//               ),
//               onPressed: () async {
//                 await UsageStats.grantUsagePermission();
//                 bool? granted = await UsageStats.checkUsagePermission();
//                 if (granted == true) {
//                   onGranted();
//                 }
//               },
//               child: const Text('Grant Permission'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ===============================================================
// // A SINGLE VIEW FOR A GIVEN TIME PERIOD (DAILY, WEEKLY, MONTHLY)
// // ===============================================================
// class _UsageView extends StatefulWidget {
//   final TimePeriod period;
//   const _UsageView({Key? key, required this.period}) : super(key: key);

//   @override
//   __UsageViewState createState() => __UsageViewState();
// }

// class __UsageViewState extends State<_UsageView>
//     with AutomaticKeepAliveClientMixin {
//   Map<String, Duration> _aggregatedUsage = {};
//   bool _isLoading = true;
//   Map<String, int> _appLimits = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await _loadLimits();
//     await _loadUsageStats();
//   }

//   Future<void> _loadLimits() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys();
//     final limits = <String, int>{};
//     for (String key in keys) {
//       if (key.startsWith('limit_')) {
//         limits[key.substring(6)] = prefs.getInt(key) ?? 0;
//       }
//     }
//     if (mounted) setState(() => _appLimits = limits);
//   }

//   Future<void> _loadUsageStats() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);

//     DateTime endDate = DateTime.now();
//     DateTime startDate;
//     switch (widget.period) {
//       case TimePeriod.weekly:
//         startDate = endDate.subtract(const Duration(days: 7));
//         break;
//       case TimePeriod.monthly:
//         startDate = endDate.subtract(const Duration(days: 30));
//         break;
//       case TimePeriod.daily:
//         startDate = DateTime(endDate.year, endDate.month, endDate.day);
//         break;
//     }

//     try {
//       Map<String, UsageInfo> rawData =
//           await UsageStats.queryAndAggregateUsageStats(startDate, endDate);
//       var sortedEntries = rawData.entries.toList()
//         ..sort((a, b) => (double.tryParse(b.value.totalTimeInForeground!) ?? 0)
//             .compareTo(double.tryParse(a.value.totalTimeInForeground!) ?? 0));

//       Map<String, Duration> usageMap = {};
//       for (var entry in sortedEntries) {
//         final durationMillis =
//             double.tryParse(entry.value.totalTimeInForeground!) ?? 0;
//         if (durationMillis > 0) {
//           usageMap[entry.key] = Duration(milliseconds: durationMillis.round());
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _aggregatedUsage = usageMap;
//         });
//         if (widget.period == TimePeriod.daily) {
//           _sendUsageDataToBackend(usageMap);
//         }
//         _checkLimitsAndNotify();
//       }
//     } catch (e) {
//       debugPrint("Error fetching usage stats for ${widget.period}: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _sendUsageDataToBackend(Map<String, Duration> usageMap) async {
//     try {
//       final usageDataPayload = usageMap.entries
//           .map((entry) => {
//                 'packageName': entry.key,
//                 'durationInSeconds': entry.value.inSeconds,
//               })
//           .toList();

//       if (usageDataPayload.isNotEmpty) {
//         await ApiService.post('screentime', {'usageData': usageDataPayload});
//         debugPrint('Successfully sent screen time data to backend.');
//       }
//     } catch (e) {
//       debugPrint('Failed to send screen time data to backend: $e');
//     }
//   }

//   void _checkLimitsAndNotify() {
//     if (widget.period != TimePeriod.daily) return;

//     _appLimits.forEach((packageName, limitInMinutes) {
//       if (limitInMinutes > 0) {
//         final usageInMinutes = _aggregatedUsage[packageName]?.inMinutes ?? 0;
//         if (usageInMinutes >= limitInMinutes) {
//           NotificationService.showNotification(
//             id: packageName.hashCode,
//             title: 'Usage Limit Reached',
//             body:
//                 'You have used ${_formatAppName(packageName)} for $usageInMinutes minutes today.',
//           );
//         }
//       }
//     });
//   }

//   Future<void> _showSetLimitDialog(String packageName) async {
//     final TextEditingController controller = TextEditingController();
//     int? currentLimit = _appLimits[packageName];
//     if (currentLimit != null && currentLimit > 0) {
//       controller.text = currentLimit.toString();
//     }

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Set Daily Limit for ${_formatAppName(packageName)}'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: 'Limit in minutes (0 to remove)',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () async {
//                 final int limit = int.tryParse(controller.text) ?? 0;
//                 final prefs = await SharedPreferences.getInstance();
//                 if (limit > 0) {
//                   await prefs.setInt('limit_$packageName', limit);
//                 } else {
//                   await prefs.remove('limit_$packageName');
//                 }
//                 _loadLimits();
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_aggregatedUsage.isEmpty) {
//       return const Center(child: Text("No usage in this period."));
//     }

//     var top5 = _aggregatedUsage.entries.take(5).toList();

//     return RefreshIndicator(
//       onRefresh: _loadData,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Text(
//             'Top 5 Apps',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 200,
//             child: BarChart(_buildBarChart(top5)),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'All Apps by Usage',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 8),
//           ..._aggregatedUsage.entries.map((entry) {
//             final limit = _appLimits[entry.key] ?? 0;
//             final hasExceeded = limit > 0 && entry.value.inMinutes >= limit;
//             return _buildSummaryCard(
//                 entry.key, entry.value, limit, hasExceeded);
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(
//       String packageName, Duration duration, int limit, bool hasExceeded) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       color: hasExceeded ? Colors.red.shade100 : null,
//       child: ListTile(
//         leading: Icon(
//           hasExceeded ? Icons.warning_amber_rounded : Icons.bar_chart,
//           color: hasExceeded ? Colors.red : null,
//         ),
//         title: Text(_formatAppName(packageName),
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: hasExceeded
//             ? Text('Limit Exceeded: ${_formatDuration(duration)} / ${limit}m',
//                 style: TextStyle(
//                     color: Colors.red.shade900, fontWeight: FontWeight.bold))
//             : Text('Usage: ${_formatDuration(duration)}'),
//         trailing: IconButton(
//           icon: Icon(limit > 0 ? Icons.lock_clock : Icons.lock_open,
//               color: Colors.blueGrey),
//           onPressed: () => _showSetLimitDialog(packageName),
//         ),
//       ),
//     );
//   }

//   String _formatAppName(String packageName) {
//     if (packageName.contains('.')) {
//       var name = packageName.split('.').last;
//       return name[0].toUpperCase() + name.substring(1);
//     }
//     return packageName;
//   }

//   String _formatDuration(Duration d) {
//     if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
//     if (d.inMinutes > 0) return '${d.inMinutes}m';
//     return '${d.inSeconds}s';
//   }

//   // ==========================================================
//   // --- NEW, SIMPLIFIED BAR CHART FUNCTION ---
//   // ==========================================================
//   BarChartData _buildBarChart(List<MapEntry<String, Duration>> top5) {
//     return BarChartData(
//       alignment: BarChartAlignment.spaceAround,
//       maxY: top5.isEmpty ? 10 : top5.first.value.inMinutes.toDouble() * 1.2,
//       barTouchData: BarTouchData(
//         // Tooltip is simplified to its most basic form
//         touchTooltipData: BarTouchTooltipData(
//           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//             String appName = _formatAppName(top5[group.x.toInt()].key);
//             String usage = _formatDuration(top5[group.x.toInt()].value);
//             return BarTooltipItem(
//               '$appName\n$usage',
//               const TextStyle(color: Colors.white, fontSize: 12),
//             );
//           },
//         ),
//       ),
//       titlesData: FlTitlesData(
//         show: true,
//         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             // Instead of SideTitleWidget, we return a simple Text widget.
//             // This is guaranteed to be compatible and avoids constructor errors.
//             getTitlesWidget: (double value, TitleMeta meta) {
//               final appName = _formatAppName(top5[value.toInt()].key);
//               return Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   appName.length > 5 ? appName.substring(0, 5) : appName,
//                   style: const TextStyle(
//                       fontSize: 10, fontWeight: FontWeight.bold),
//                 ),
//               );
//             },
//             reservedSize: 38,
//           ),
//         ),
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 40,
//             getTitlesWidget: (value, meta) {
//               if (value % 20 == 0) return Text('${value.toInt()}m');
//               return const Text('');
//             },
//           ),
//         ),
//       ),
//       borderData: FlBorderData(show: false),
//       barGroups: top5.asMap().entries.map((entry) {
//         return BarChartGroupData(
//           x: entry.key,
//           barRods: [
//             BarChartRodData(
//               toY: entry.value.value.inMinutes.toDouble(),
//               color: const Color(0xFF00796B),
//               width: 16,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ],
//         );
//       }).toList(),
//       gridData: FlGridData(show: true, drawVerticalLine: false),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// // ===============================================================
// // WIDGET FOR UNSUPPORTED PLATFORMS (WEB, DESKTOP - Unchanged)
// // ===============================================================
// class _UnsupportedPlatformWidget extends StatelessWidget {
//   const _UnsupportedPlatformWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext inContext) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.desktop_windows, size: 60, color: Colors.grey),
//             SizedBox(height: 20),
//             Text('Feature Not Available',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center),
//             SizedBox(height: 10),
//             Text(
//                 'Tracking and limiting app usage is only available on Android due to platform security restrictions.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.black54)),
//           ],
//         ),
//       ),
//     );
//   }
// }
