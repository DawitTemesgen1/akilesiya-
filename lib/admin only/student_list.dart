// lib/admin only/student_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/print_data.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';

// --- UI Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color surfaceColor = Color(0xFFF4F7FC);

// --- Filter Options ---
const List<String> spiritualClassOptions = [
  '1ኛ ክፍል',
  '2ኛ ክፍል',
  '3ኛ ክፍል',
  '4ኛ ክፍል',
  '5ኛ ክፍል',
  '6ኛ ክፍል',
  '7ኛ ክፍል',
  '8ኛ ክፍል',
  '9ኛ ክፍል',
  '10ኛ ክፍል',
  '11ኛ ክፍል',
  '12ኛ ክፍል'
];
const List<String> roleOptions = [
  'user',
  'superior_admin',
  'plan_admin',
  'manager',
  'development_admin',
  'grade_admin',
  'attendance_admin',
  'librarian',
  'library_admin',
  'learning_admin'
];

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text('User Cockpit',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const _ManagementTab(),
    );
  }
}

class _ManagementTab extends StatefulWidget {
  const _ManagementTab();
  @override
  State<_ManagementTab> createState() => _ManagementTabState();
}

class _ManagementTabState extends State<_ManagementTab> {
  Future<Map<String, dynamic>>? _statsFuture;
  Future<Map<String, dynamic>>? _usersFuture;

  final _searchController = TextEditingController();
  String? _selectedRole;
  String? _selectedClass;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _statsFuture = UserAdminService.getUserStats();
      _usersFuture = UserAdminService.getDetailedUsers(
        search: _searchController.text,
        role: _selectedRole,
        spiritualClass: _selectedClass,
      );
    });
  }

  Future<void> _showPrintableDocument(String userId) async {
    final profileConfig = context.read<ProfileConfigProvider>();
    final selectedFields = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _PdfFieldSelectorDialog(profileConfig: profileConfig),
    );

    if (selectedFields == null || selectedFields.isEmpty) return;

    setState(() => _isGeneratingPdf = true);
    try {
      final response = await UserAdminService.getFullUserDetail(userId);
      if (response['success'] == true && response['data'] != null) {
        final userDetailMap = response['data'] as Map<String, dynamic>;
        final pdfGenerator = UserPdfGenerator(
          userData: userDetailMap,
          fieldsToInclude: selectedFields,
          profileConfig: profileConfig,
        );
        await pdfGenerator.generateAndShowPdf();
      } else {
        throw Exception(response['message'] ?? 'Failed to get user details.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error generating document: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsBar(),
              const SizedBox(height: 16),
              _buildFilterCard(),
              const SizedBox(height: 24),
              Text(
                "All Members",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildUserList(),
            ],
          ),
        ),
        if (_isGeneratingPdf)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Generating Document...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(children: [
            Expanded(child: _StatCard.loading()),
            const SizedBox(width: 16),
            Expanded(child: _StatCard.loading()),
          ]);
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data?['success'] != true) {
          return const Text('Could not load stats.');
        }

        final stats = snapshot.data!['data'] as Map<String, dynamic>;

        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: Row(
            children: [
              Expanded(
                  child: _StatCard(
                      title: 'Total Members',
                      value: stats['totalMembers'].toString(),
                      icon: Iconsax.profile_2user,
                      color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: _StatCard(
                      title: 'Total Admins',
                      value: stats['totalAdmins'].toString(),
                      icon: Iconsax.user_octagon,
                      color: Colors.purple)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filters", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  labelText: 'Search by Name or Email',
                  prefixIcon: Icon(Iconsax.search_normal),
                  border: OutlineInputBorder()),
              onSubmitted: (_) => _loadData(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('Filter by Role'),
                    items: roleOptions
                        .map((role) =>
                            DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    hint: const Text('Filter by Class'),
                    items: spiritualClassOptions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child:
                                Text(c, style: GoogleFonts.notoSansEthiopic())))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClass = value),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedRole = null;
                      _selectedClass = null;
                    });
                    _loadData();
                  },
                  child: const Text('Clear Filters'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Iconsax.filter_search),
                  label: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data?['success'] != true) {
          return const Center(child: Text('Could not load users.'));
        }

        final users = (snapshot.data!['data'] as List<dynamic>?) ?? [];

        if (users.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No users found for this filter.'),
          ));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final imageUrl = user['profile_image_url'];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(
                          '${ApiService.baseUrl.replaceAll('/api', '')}/$imageUrl')
                      : null,
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Text((user['full_name'] ?? '?')[0])
                      : null,
                ),
                title: Text(user['full_name'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
                trailing:
                    const Icon(Iconsax.document_download, color: primaryColor),
                onTap: () => _showPrintableDocument(user['id']),
              ),
            );
          },
        );
      },
    );
  }
}

class _PdfFieldSelectorDialog extends StatefulWidget {
  final ProfileConfigProvider profileConfig;
  const _PdfFieldSelectorDialog({required this.profileConfig});
  @override
  State<_PdfFieldSelectorDialog> createState() =>
      _PdfFieldSelectorDialogState();
}

class _PdfFieldSelectorDialogState extends State<_PdfFieldSelectorDialog> {
  static const Map<String, List<String>> _sectionKeys = {
    'የግል መረጃ': [
      'full_name',
      'christian_name',
      'mother_name',
      'gender',
      'dob',
      'phone_number',
      'email'
    ],
    'መንፈሳዊ መረጃ': [
      'spiritual_class',
      'confession_father_name',
      'member_level',
      'service_status',
      'service_assignment'
    ],
    'ያለፈ የአገልግሎት ታሪክ': [
      'previous_department',
      'previous_responsibility',
      'previous_service_level'
    ],
    'የቤተሰብ / የወላጅ መረጃ': ['parent_name', 'parent_phone_number'],
  };
  static const Map<String, String> _builtInLabels = {
    'full_name': 'ሙሉ ስም',
    'christian_name': 'የክርስትና ስም',
    'mother_name': 'የእናት ስም',
    'gender': 'ጾታ',
    'dob': 'የትውልድ ዘመን',
    'phone_number': 'ስልክ ቁጥር',
    'email': 'ኢሜይል',
    'spiritual_class': 'የትምህርት ክፍል',
    'confession_father_name': 'የንስሐ አባት ስም',
    'member_level': 'የአባልነት ደረጃ',
    'service_status': 'የአገልግሎት ሁኔታ',
    'service_assignment': 'የአገልግሎት ምድብ',
    'previous_department': 'ያገለገሉበት ክፍል',
    'previous_responsibility': 'ኃላፊነት',
    'previous_service_level': 'የአገልግሎት ደረጃ',
    'parent_name': 'የወላጅ ስም',
    'parent_phone_number': 'የወላጅ ስልክ',
  };
  late Set<String> _selectedFields;

  @override
  void initState() {
    super.initState();
    _selectedFields = {};
    _sectionKeys.forEach((_, keys) {
      for (var key in keys) {
        if (widget.profileConfig.isWidgetVisible(key)) {
          _selectedFields.add(key);
        }
      }
    });
    for (var field in widget.profileConfig.customFields) {
      _selectedFields.add('custom_${field['id']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sectionWidgets = _sectionKeys.entries.map((section) {
      final List<Widget> sectionCheckboxes = section.value
          .where((key) => widget.profileConfig.isWidgetVisible(key))
          .map((fieldKey) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(_builtInLabels[fieldKey] ?? fieldKey,
              style: GoogleFonts.notoSansEthiopic()),
          value: _selectedFields.contains(fieldKey),
          onChanged: (isSelected) {
            setState(() {
              if (isSelected == true)
                _selectedFields.add(fieldKey);
              else
                _selectedFields.remove(fieldKey);
            });
          },
        );
      }).toList();
      if (sectionCheckboxes.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16),
            child: Text(section.key,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...sectionCheckboxes,
        ],
      );
    }).toList();

    sectionWidgets.add(_buildDynamicCustomFields());

    return AlertDialog(
      title: const Text('Select Fields to Print'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: sectionWidgets,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_selectedFields),
            child: const Text('Generate PDF')),
      ],
    );
  }

  Widget _buildDynamicCustomFields() {
    final customFields = widget.profileConfig.customFields;
    if (customFields.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16),
          child: Text('ተጨማሪ መረጃ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...customFields.map((field) {
          final fieldKey = 'custom_${field['id']}';
          return CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(field['name'], style: GoogleFonts.notoSansEthiopic()),
            value: _selectedFields.contains(fieldKey),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true)
                  _selectedFields.add(fieldKey);
                else
                  _selectedFields.remove(fieldKey);
              });
            },
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  factory _StatCard.loading() => const _StatCard(
        title: 'Loading...',
        value: '-',
        icon: Iconsax.clock,
        color: Colors.grey,
        isLoading: true,
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  if (isLoading)
                    Container(
                        width: 40, height: 20, color: Colors.grey.shade200)
                  else
                    Text(value,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
