import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({Key? key}) : super(key: key);

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
    _loadLogs();
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
      setState(() {
        if (loadMore) {
          _logs.addAll(data['logs']);
        } else {
          _logs = data['logs'];
        }
        _hasMore = _currentPage < data['pagination']['totalPages'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      setState(() => _currentPage++);
      _loadLogs(loadMore: true);
    }
  }

  void _onActionFilterChanged(String? value) {
    setState(() => _actionFilter = value ?? '');
    _loadLogs();
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'SCHOOL_CREATED':
        return Colors.green;
      case 'SCHOOL_DEACTIVATED':
        return Colors.red;
      case 'USER_PROMOTED':
        return Colors.blue;
      case 'SCHOOL_UPDATED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'SCHOOL_CREATED':
        return Icons.add_business;
      case 'SCHOOL_DEACTIVATED':
        return Icons.block;
      case 'USER_PROMOTED':
        return Icons.person_add;
      case 'SCHOOL_UPDATED':
        return Icons.edit;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('System Audit Logs'),
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by action:', style: TextStyle()),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _actionFilter.isEmpty ? null : _actionFilter,
                  hint: const Text('All Actions'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Actions')),
                    DropdownMenuItem(
                        value: 'SCHOOL_CREATED', child: Text('School Created')),
                    DropdownMenuItem(
                        value: 'SCHOOL_UPDATED', child: Text('School Updated')),
                    DropdownMenuItem(
                        value: 'SCHOOL_ACTIVATED',
                        child: Text('School Activated')),
                    DropdownMenuItem(
                        value: 'SCHOOL_DEACTIVATED',
                        child: Text('School Deactivated')),
                    DropdownMenuItem(
                        value: 'USER_PROMOTED', child: Text('User Promoted')),
                  ],
                  onChanged: _onActionFilterChanged,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadLogs,
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: _isLoading && _logs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Text(
                          'No audit logs found',
                          style:
                              TextStyle(fontSize: 18, color: subtleTextColor),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            _loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: _logs.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _logs.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }

                            final log = _logs[index];
                            return Card(
                              color: surfaceColor,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getActionColor(log['action_type']),
                                  child: Icon(
                                    _getActionIcon(log['action_type']),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  log['action_description'] ?? 'Unknown Action',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: onSurfaceColor),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Action: ${log['action_type']}',
                                        style:
                                            TextStyle(color: subtleTextColor)),
                                    if (log['school_name'] != null)
                                      Text('School: ${log['school_name']}',
                                          style: TextStyle(
                                              color: subtleTextColor)),
                                    Text('Admin: ${log['admin_email']}',
                                        style:
                                            TextStyle(color: subtleTextColor)),
                                    Text(
                                        'Time: ${_formatDateTime(log['timestamp'])}',
                                        style:
                                            TextStyle(color: subtleTextColor)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => _showLogDetails(log),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Provider.of<ThemeProvider>(context).getSurfaceColor(context),
        title: Text('Audit Log Details',
            style: TextStyle(
                color: Provider.of<ThemeProvider>(context)
                    .getOnSurfaceColor(context))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Action Type', log['action_type']),
              _buildDetailRow('Description', log['action_description']),
              _buildDetailRow('Admin', log['admin_email']),
              if (log['school_name'] != null)
                _buildDetailRow('School', log['school_name']),
              _buildDetailRow('IP Address', log['ip_address'] ?? 'N/A'),
              _buildDetailRow('User Agent', log['user_agent'] ?? 'N/A'),
              _buildDetailRow('Timestamp', _formatDateTime(log['timestamp'])),
              if (log['previous_value'] != null)
                _buildDetailRow('Previous Value', log['previous_value']),
              if (log['new_value'] != null)
                _buildDetailRow('New Value', log['new_value']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Provider.of<ThemeProvider>(context)
                      .getOnSurfaceColor(context)),
            ),
          ),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context)
                          .getOnSurfaceColor(context)))),
        ],
      ),
    );
  }
}
