import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';

class PlatformAnalyticsScreen extends StatefulWidget {
  const PlatformAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<PlatformAnalyticsScreen> createState() =>
      _PlatformAnalyticsScreenState();
}

class _PlatformAnalyticsScreenState extends State<PlatformAnalyticsScreen> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _selectedPeriod = '30d';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final result =
        await SystemAdminService.getPlatformAnalytics(period: _selectedPeriod);
    if (result['success'] == true) {
      setState(() => _analyticsData = result['data']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildStatCard(
      String title, dynamic value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    final growthData = _analyticsData?['userGrowth'] ?? [];

    if (growthData.isEmpty) {
      return const Center(child: Text('ምንም የእድገት መረጃ የለም'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'የተጠቃሚዎች እድገት',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...growthData
                .map<Widget>((data) => ListTile(
                      title: Text(data['date'] ?? ''),
                      trailing: Chip(
                        label: Text('+${data['new_users']}'),
                      ),
                      subtitle: Text('ጠቅላላ: ${data['cumulative_users']}'),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // =======================================================
    // --- የተስተካከለው ክፍል ይኸውና ---
    // =======================================================
    // ከሰርቨር የሚመጣውን መረጃ በጥንቃቄ ወደ ቁጥር መቀየር
    final rawAvg = _analyticsData?['schoolStats']?['avg_members_per_school'];
    double avgMembers = 0.0;
    if (rawAvg is num) {
      avgMembers = rawAvg.toDouble();
    } else if (rawAvg is String) {
      avgMembers = double.tryParse(rawAvg) ?? 0.0;
    }
    // =======================================================
    // --- የማስተካከያው መጨረሻ ---
    // =======================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text('የፕላትፎርም ትንታኔ'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            dropdownColor: Theme.of(context).primaryColor,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            items: const [
              DropdownMenuItem(value: '7d', child: Text('ያለፉት 7 ቀናት')),
              DropdownMenuItem(value: '30d', child: Text('ያለፉት 30 ቀናት')),
              DropdownMenuItem(value: '90d', child: Text('ያለፉት 90 ቀናት')),
              DropdownMenuItem(value: '1y', child: Text('ያለፈው ዓመት')),
            ],
            onChanged: (value) {
              setState(() => _selectedPeriod = value!);
              _loadAnalytics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ቁልፍ መለኪያዎች
                  const Text(
                    'ቁልፍ መለኪያዎች',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'ጠቅላላ ትምህርት ቤቶች',
                        _analyticsData?['schoolStats']?['total_schools'] ?? 0,
                        Icons.school,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'ንቁ ትምህርት ቤቶች',
                        _analyticsData?['schoolStats']?['active_schools'] ?? 0,
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'አባላት/ት/ቤት (አማካይ)',
                        avgMembers
                            .toStringAsFixed(1), // <<< የተስተካከለውን ተለዋዋጭ መጠቀም
                        Icons.people,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'ንቁ ተጠቃሚዎች (30ቀን)',
                        _analyticsData?['activityMetrics']
                                ?['active_users_30d'] ??
                            0,
                        Icons.person,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // የእድገት ሰንጠረዥ
                  _buildGrowthChart(),

                  const SizedBox(height: 32),

                  // የሚና ስርጭት
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'የሚና ስርጭት',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ...(_analyticsData?['roleDistribution'] ?? [])
                              .map<Widget>((role) => ListTile(
                                    leading:
                                        Icon(_getRoleIcon(role['role_type'])),
                                    title: Text(
                                        _formatRoleType(role['role_type'])),
                                    trailing: Chip(
                                        label: Text(role['count'].toString())),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getRoleIcon(String roleType) {
    switch (roleType) {
      case 'system_admin':
        return Icons.security;
      case 'superior_admin':
        return Icons.admin_panel_settings;
      case 'other_admin':
        return Icons.manage_accounts;
      default:
        return Icons.person;
    }
  }

  String _formatRoleType(String roleType) {
    switch (roleType) {
      case 'system_admin':
        return 'የስርዓት አስተዳዳሪዎች';
      case 'superior_admin':
        return 'ዋና አስተዳዳሪዎች';
      case 'other_admin':
        return 'ሌሎች አስተዳዳሪዎች';
      default:
        return 'መደበኛ ተጠቃሚዎች';
    }
  }
}
