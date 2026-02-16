import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 50;
  String _actionFilter = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _loadLogs(loadMore: true);
  }

  Future<void> _loadLogs({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final result = await SystemAdminService.getAuditLogs(
      page: _currentPage,
      limit: _itemsPerPage,
      actionType: _actionFilter,
    );

    if (result['success'] == true) {
      final data = result['data'];
      if (mounted) {
        setState(() {
          if (loadMore) {
            _logs.addAll(data['logs']);
          } else {
            _logs = data['logs'];
          }
          _hasMore = _currentPage < data['pagination']['totalPages'];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  void _onActionFilterChanged(String? value) {
    setState(() => _actionFilter = value ?? '');
    _loadLogs();
  }

  Color _getActionColor(String actionType) {
    if (actionType.contains('CREATE')) return Colors.green;
    if (actionType.contains('DELETE') || actionType.contains('DEACTIVATE')) {
      return Colors.red;
    }
    if (actionType.contains('UPDATE')) return Colors.orange;
    if (actionType.contains('PROMOTED')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getActionIcon(String actionType) {
    if (actionType.contains('CREATE')) return Iconsax.add;
    if (actionType.contains('DELETE') || actionType.contains('DEACTIVATE')) {
      return Iconsax.trash;
    }
    if (actionType.contains('UPDATE')) return Iconsax.edit;
    if (actionType.contains('PROMOTED')) return Iconsax.user_tag;
    return Iconsax.document_text;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: isDark ? Colors.white : Colors.black87,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'Audit Logs',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                primaryColor.withValues(alpha: 0.3),
                                Colors.black
                              ]
                            : [
                                primaryColor.withValues(alpha: 0.1),
                                Colors.white
                              ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildFilterTabs(isDark, primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          _isLoading && _logs.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : _logs.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(isDark))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == _logs.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: primaryColor)),
                              );
                            }
                            final log = _logs[index];
                            return FadeInUp(
                              duration: Duration(
                                  milliseconds: 400 + (index % 10 * 50)),
                              child: _buildLogCard(log, isDark, primaryColor),
                            );
                          },
                          childCount: _logs.length + (_hasMore ? 1 : 0),
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark, Color primaryColor) {
    final filters = [
      {'l': 'All', 'v': ''},
      {'l': 'Creation', 'v': 'CREATE'},
      {'l': 'Updates', 'v': 'UPDATE'},
      {'l': 'Security', 'v': 'DEACTIVATE'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _actionFilter == f['v'];
          return GestureDetector(
            onTap: () => _onActionFilterChanged(f['v']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                f['l']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogCard(
      Map<String, dynamic> log, bool isDark, Color primaryColor) {
    final actionType = log['action_type'] as String;
    final color = _getActionColor(actionType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogDetails(log),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getActionIcon(actionType),
                            color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          log['action_description'] ?? 'System Event',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(log['timestamp']),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMiniInfo(Iconsax.user_octagon,
                      log['admin_email'] ?? 'System', isDark),
                  if (log['target_school_name'] != null)
                    _buildMiniInfo(
                        Iconsax.bank, log['target_school_name'], isDark),
                  if (log['affected_user_name'] != null)
                    _buildMiniInfo(Iconsax.profile_2user,
                        'Target: ${log['affected_user_name']}', isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text,
              size: 60, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No audit logs found',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showLogDetails(Map<String, dynamic> log) {
    final actionType = log['action_type'] as String;
    final color = _getActionColor(actionType);
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text('Log Details',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildDetailRow('Action Type', actionType, color),
                  _buildDetailRow(
                      'Description', log['action_description'], color),
                  _buildDetailRow('Admin', log['admin_email'], Colors.blue),
                  if (log['target_school_name'] != null)
                    _buildDetailRow(
                        'School', log['target_school_name'], Colors.orange),
                  if (log['affected_user_name'] != null)
                    _buildDetailRow('Affected User', log['affected_user_name'],
                        Colors.purple),
                  if (log['affected_user_email'] != null)
                    _buildDetailRow('Affected User Email',
                        log['affected_user_email'], Colors.purple),
                  _buildDetailRow(
                      'IP Address', log['ip_address'] ?? 'N/A', Colors.grey),
                  _buildDetailRow('Timestamp',
                      _formatDateTimeFull(log['timestamp']), Colors.indigo),
                  if (log['previous_value'] != null)
                    _buildJsonView('Previous State', log['previous_value']),
                  if (log['new_value'] != null)
                    _buildJsonView('New State', log['new_value']),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 60),
                child: Text(
                  value ?? 'N/A',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(String title, dynamic value) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value.toString(),
              style: GoogleFonts.jetBrainsMono(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTimeFull(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
