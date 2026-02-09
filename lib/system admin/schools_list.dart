import 'package:amde_haymanot_abalat_guday/system%20admin/create_school.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/school_detail.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';

class SchoolsListScreen extends StatefulWidget {
  const SchoolsListScreen({super.key});

  @override
  State<SchoolsListScreen> createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  List<dynamic> _schools = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  String _searchQuery = '';
  String _statusFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final result = await SystemAdminService.getSchools(
      page: _currentPage,
      limit: _itemsPerPage,
      search: _searchQuery,
      status: _statusFilter == 'all' ? '' : _statusFilter,
    );

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        if (loadMore) {
          _schools.addAll(data['schools']);
        } else {
          _schools = data['schools'];
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
      _loadSchools(loadMore: true);
    }
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _loadSchools();
  }

  void _onStatusFilterChanged(String? value) {
    setState(() => _statusFilter = value ?? 'all');
    _loadSchools();
  }

  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.tryParse(value) ?? 0;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Widget _buildSchoolCard(Map<String, dynamic> school) {
    final totalMembers = _safeParseInt(school['total_members']);
    final activeMembers = _safeParseInt(school['active_members']);
    final isActive = _safeParseBool(school['is_active']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            (school['name']?.toString().isNotEmpty ?? false)
                ? school['name'][0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          school['name']?.toString() ?? 'ያልታወቀ ትምህርት ቤት', // ተተርጉሟል
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('አባላት: $activeMembers ንቁ / $totalMembers ጠቅላላ'), // ተተርጉሟል
            if (school['pastor_name'] != null)
              Text('ፓስተር: ${school['pastor_name']}'), // ተተርጉሟል
            Text('የተፈጠረበት ቀን: ${_formatDate(school['created_at'])}'), // ተተርጉሟል
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                isActive ? 'ንቁ' : 'ንቁ ያልሆነ', // ተተርጉሟል
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
              backgroundColor: isActive ? Colors.green[50] : Colors.red[50],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolDetailScreen(
                schoolId: school['id'],
                heroTag: 'school-${school['id']}',
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ትምህርት ቤቶችን ያቀናብሩ'), // ተተርጉሟል
      ),
      body: Column(
        children: [
          // የፍለጋ እና የማጣሪያ ክፍል
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ትምህርት ቤቶችን ይፈልጉ...', // ተተርጉሟል
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  onChanged: (value) => _onSearch(value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('ሁኔታ:'), // ተተርጉሟል
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(
                            value: 'all',
                            child: Text('ሁሉም ትምህርት ቤቶች')), // ተተርጉሟል
                        DropdownMenuItem(
                            value: 'active',
                            child: Text('ንቁ የሆኑ ብቻ')), // ተተርጉሟል
                        DropdownMenuItem(
                            value: 'inactive',
                            child: Text('ንቁ ያልሆኑ ብቻ')), // ተተርጉሟል
                      ],
                      onChanged: _onStatusFilterChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // የትምህርት ቤቶች ዝርዝር
          Expanded(
            child: _isLoading && _schools.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _schools.isEmpty
                    ? const Center(
                        child: Text(
                          'ምንም ትምህርት ቤቶች አልተገኙም', // ተተርጉሟል
                          style: TextStyle(fontSize: 18, color: Colors.grey),
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
                          itemCount: _schools.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _schools.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildSchoolCard(_schools[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSchoolScreen()),
          ).then((_) {
            _loadSchools();
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }
}
