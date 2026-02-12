// lib/admin only/member_management_cockpit.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/admin_edit_user.dart';
import 'package:amde_haymanot_abalat_guday/services/template_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';

class MemberManagementCockpit extends StatefulWidget {
  const MemberManagementCockpit({super.key});

  @override
  State<MemberManagementCockpit> createState() =>
      _MemberManagementCockpitState();
}

class _MemberManagementCockpitState extends State<MemberManagementCockpit> {
  // Stats
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String? _selectedRole;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await UserAdminService.getUserStats();
      final usersRes = await UserAdminService.getDetailedUsers(
        search: _searchQuery,
        role: _selectedRole,
        spiritualClass: _selectedClass,
      );

      if (mounted) {
        setState(() {
          if (statsRes['success'] == true) _stats = statsRes['data'];
          if (usersRes['success'] == true) _users = usersRes['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final isDark = themeProvider.isDarkMode(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, primaryColor, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: _buildStatsHeader(primaryColor, isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFilterBar(primaryColor, isDark),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                : _users.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                            child: Text("No members found matching filters.")),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMemberCard(
                              _users[index], primaryColor, isDark),
                          childCount: _users.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color primaryColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor:
          isDark ? Colors.black.withValues(alpha: 0.8) : primaryColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          "የአባላት አስተዳደር",
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.7),
                isDark ? Colors.black : primaryColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Iconsax.user_octagon,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _fetchData,
          icon: const Icon(Iconsax.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(Color primaryColor, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          "ጠቅላላ አባላት",
          _stats?['totalMembers']?.toString() ?? "0",
          Iconsax.user,
          primaryColor,
          isDark,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          "አስተዳዳሪዎች",
          _stats?['totalAdmins']?.toString() ?? "0",
          Iconsax.shield_security,
          Colors.orange,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          TextField(
            onChanged: (val) {
              setState(() => _searchQuery = val);
              // Debounce or search on enter? For now let's add a search icon
            },
            onSubmitted: (_) => _fetchData(),
            decoration: InputDecoration(
              hintText: "ፈልግ (ስም፣ ስልክ...)",
              hintStyle: GoogleFonts.notoSansEthiopic(fontSize: 14),
              prefixIcon: const Icon(Iconsax.search_normal),
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.filter_edit),
                onPressed: () => _showFilterOptions(primaryColor, isDark),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(Color primaryColor, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "አጣራ",
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // For now simple dropdowns or chips
            const Text("ሚና (Role)"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _filterChip(
                    "ሁሉም", null, _selectedRole, (val) => _selectedRole = val),
                _filterChip("አስተዳዳሪ", "admin", _selectedRole,
                    (val) => _selectedRole = val),
                _filterChip("አገልጋይ", "servant", _selectedRole,
                    (val) => _selectedRole = val),
                _filterChip("ተራ አባል", "user", _selectedRole,
                    (val) => _selectedRole = val),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child:
                    const Text("ተግብር", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value, String? current,
      Function(String?) onSelected) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.notoSansEthiopic(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => onSelected(value));
      },
    );
  }

  Widget _buildMemberCard(dynamic user, Color primaryColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'avatar_${user['id']}',
          child: CircleAvatar(
            radius: 28,
            backgroundImage: user['profile_image_url'] != null
                ? CachedNetworkImageProvider(user['profile_image_url'])
                : null,
            child: user['profile_image_url'] == null
                ? Text(user['full_name']?[0] ?? "?",
                    style: const TextStyle(fontSize: 20))
                : null,
          ),
        ),
        title: Text(
          user['full_name'] ?? "Unknown",
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Iconsax.call, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(user['email'] ?? "No Email",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            _buildRoleBadge(user['role'], isDark),
          ],
        ),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: () => _showMemberDetails(user['id'], user['full_name']),
      ),
    );
  }

  Widget _buildRoleBadge(String? role, bool isDark) {
    final roles = role?.split(',') ?? ['user'];
    return Wrap(
      spacing: 4,
      children: roles.map((r) {
        Color color = Colors.blue;
        String label = "አባል";
        if (r.contains('admin')) {
          color = Colors.red;
          label = "አስተዳዳሪ";
        } else if (r.contains('servant')) {
          color = Colors.green;
          label = "አገልጋይ";
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showMemberDetails(String userId, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberDetailSheet(userId: userId, name: name),
    ).then((_) => _fetchData());
  }
}

class MemberDetailSheet extends StatefulWidget {
  final String userId;
  final String name;

  const MemberDetailSheet(
      {super.key, required this.userId, required this.name});

  @override
  State<MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<MemberDetailSheet> {
  Map<String, dynamic>? _userDetail;
  List<dynamic> _customFields = [];
  Map<String, dynamic> _selectedCustomFieldValues = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        UserAdminService.getFullUserDetail(widget.userId),
        TemplateService.getCustomFields(),
      ]);

      final userRes = results[0];
      final fieldsRes = results[1];

      if (mounted) {
        setState(() {
          if (userRes['success'] == true) {
            _userDetail = userRes['data'];
            // Extract custom field values
            final rawCustomValues = _userDetail?['custom_field_values'];
            _selectedCustomFieldValues = {};
            if (rawCustomValues is List) {
              for (var item in rawCustomValues) {
                if (item['field_id'] == null) continue;
                final fid = item['field_id'].toString();
                final val =
                    (item['value'] ?? item['option_id'] ?? item['value_text'])
                        ?.toString();
                if (val == null) continue;

                if (_selectedCustomFieldValues.containsKey(fid)) {
                  final existing = _selectedCustomFieldValues[fid];
                  if (existing is List) {
                    if (!existing.contains(val)) existing.add(val);
                  } else if (existing != val) {
                    _selectedCustomFieldValues[fid] = [existing, val];
                  }
                } else {
                  _selectedCustomFieldValues[fid] = val;
                }
              }
            } else if (rawCustomValues is Map) {
              _selectedCustomFieldValues =
                  Map<String, dynamic>.from(rawCustomValues);
            }
          }
          if (fieldsRes['success'] == true) {
            _customFields = fieldsRes['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAdminField(Map<String, dynamic> updates) async {
    setState(() => _isSaving = true);
    try {
      final res = await UserAdminService.updateUserByAdmin(
        userId: widget.userId,
        updates: updates,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['success'] == true ? "ተሳክቷል!" : "ስህተት ተከስቷል!"),
            backgroundColor: res['success'] == true ? Colors.green : Colors.red,
          ),
        );
        if (res['success'] == true) {
          _loadUserDetail();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = themeProvider.getPrimaryColor(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_userDetail == null)
            const Center(child: Text("መረጃ ማግኘት አልተቻለም"))
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(isDark, primaryColor),
                  const SizedBox(height: 30),
                  _buildSectionTitle("የአስተዳደር መረጃ (ኤዲት ይቻላል)",
                      Iconsax.setting_2, primaryColor),
                  const SizedBox(height: 15),
                  _buildAdminControls(primaryColor, isDark),
                  const SizedBox(height: 30),
                  _buildSectionTitle(
                      "የአባል መረጃ (ለማየት ብቻ)", Iconsax.user, primaryColor),
                  const SizedBox(height: 15),
                  _buildReadOnlyInfo(isDark),
                ],
              ),
            ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color primaryColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: _userDetail!['profile_image_url'] != null
              ? CachedNetworkImageProvider(_userDetail!['profile_image_url'])
              : null,
          child: _userDetail!['profile_image_url'] == null
              ? Text(_userDetail!['full_name']?[0] ?? "?",
                  style: const TextStyle(fontSize: 24))
              : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userDetail!['full_name'] ?? "Unknown",
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                _userDetail!['email'] ?? "No Email",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminEditUserScreen(
                        userId: widget.userId,
                        userName: _userDetail!['full_name'] ?? widget.name,
                      ),
                    ),
                  ).then((didUpdate) {
                    if (didUpdate == true) {
                      _loadUserDetail();
                    }
                  });
                },
                icon: const Icon(Iconsax.edit, size: 16),
                label: Text(
                  "ሙሉ መረጃ ቀይር", // "Change Full Info"
                  style: GoogleFonts.notoSansEthiopic(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminControls(Color primaryColor, bool isDark) {
    return Column(
      children: [
        _buildAdminTile(
          "የአገልግሎት ሁኔታ",
          _userDetail!['service_status'] ?? "Inactive",
          Iconsax.activity,
          onTap: () => _updateAdminField({
            'service_status': _userDetail!['service_status'] == 'Active'
                ? 'Inactive'
                : 'Active'
          }),
          trailing: Switch(
            value: _userDetail!['service_status'] == 'Active',
            onChanged: (val) => _updateAdminField(
                {'service_status': val ? 'Active' : 'Inactive'}),
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            activeThumbColor: primaryColor,
          ),
        ),
        _buildAdminTile(
          "መታወቂያ",
          (_userDetail!['is_verified'] == 1 ||
                  _userDetail!['is_verified'] == true)
              ? "የጸደቀ"
              : "ያልጸደቀ",
          Iconsax.verify,
          onTap: (_userDetail!['is_verified'] == 1 ||
                  _userDetail!['is_verified'] == true ||
                  _isSaving)
              ? null
              : () => _verifyUser(),
          trailing: Icon(
            (_userDetail!['is_verified'] == 1 ||
                    _userDetail!['is_verified'] == true)
                ? Iconsax.verify5
                : Iconsax.verify,
            color: (_userDetail!['is_verified'] == 1 ||
                    _userDetail!['is_verified'] == true)
                ? Colors.green
                : Colors.grey,
          ),
        ),
        _buildAdminTile(
          "ሚና (Role)",
          _userDetail!['role'] ?? "user",
          Iconsax.shield,
          onTap: _isSaving ? null : () => _showRolePicker(primaryColor, isDark),
          trailing: const Icon(Iconsax.edit),
        ),
      ],
    );
  }

  Future<void> _verifyUser() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await UserAdminService.verifyUser(widget.userId);
      if (mounted) {
        final wasSuccessful = res['success'] == true;
        messenger.showSnackBar(
          SnackBar(
            content:
                Text(wasSuccessful ? "ተጠቃሚው በተሳካ ሁኔታ ጸድቋል!" : "ለማጽደቅ አልተቻለም!"),
            backgroundColor: wasSuccessful ? Colors.green : Colors.red,
          ),
        );
        if (wasSuccessful) {
          _loadUserDetail();
        }
      }
    } catch (e) {
      debugPrint("Verification error: $e");
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildAdminTile(String label, String value, IconData icon,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22),
      title: Text(label, style: GoogleFonts.notoSansEthiopic(fontSize: 14)),
      subtitle:
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: trailing,
    );
  }

  Widget _buildReadOnlyInfo(bool isDark) {
    if (_userDetail == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildInfoCategory("ጠቅላላ (General)", [
          _infoRow("ስልክ", _userDetail!['phone_number']),
          _infoRow("የትውልድ ቀን", _userDetail!['dob']),
          ..._getTabCustomFields('PERSONAL'),
        ]),
        _buildInfoCategory("መንፈሳዊ (Spiritual)", [
          _infoRow("ክርስቲያናዊ ስም", _userDetail!['christian_name']),
          _infoRow("የንስሐ አባት", _userDetail!['confession_father_name']),
          _infoRow("የመንፈሳዊ ክፍል", _userDetail!['spiritual_class']),
          ..._getTabCustomFields('SPIRITUAL'),
        ]),
        _buildInfoCategory("ትምህርት (Education)", [
          _infoRow("የትምህርት ደረጃ", _userDetail!['academic_level']),
          _infoRow("ክፍል (Kifil)", _userDetail!['kifil']),
          ..._getTabCustomFields('EDUCATION'),
        ]),
        _buildInfoCategory("ቤተሰብ (Family)", [
          _infoRow("የእናት ስም", _userDetail!['mother_name']),
          _infoRow("የአሳዳጊ ስም", _userDetail!['parent_name']),
          _infoRow("የአሳዳጊ ስልክ", _userDetail!['parent_phone_number']),
          ..._getTabCustomFields('FAMILY'),
        ]),
      ],
    );
  }

  Widget _buildInfoCategory(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _getTabCustomFields(String tabName) {
    final fields = _customFields
        .where((field) =>
            field['profile_tab']?.toString().toUpperCase() == tabName)
        .toList();

    return fields.map((field) {
      final fieldId = field['id'].toString();
      final rawValue = _selectedCustomFieldValues[fieldId];
      if (rawValue == null) return const SizedBox.shrink();

      final options = field['options'] as List<dynamic>? ?? [];
      final fieldType =
          (field['field_type'] ?? field['type'])?.toString().toUpperCase() ??
              'TEXT';

      String displayValue = "";

      if (rawValue is List) {
        final optionNames = <String>[];
        for (var vid in rawValue) {
          final opt = options
              .firstWhereOrNull((o) => o['id'].toString() == vid.toString());
          if (opt != null) optionNames.add(opt['option_value'] ?? "");
        }
        displayValue =
            optionNames.isNotEmpty ? optionNames.join(", ") : "ያልተጠቀሰ";
      } else if (options.isNotEmpty &&
          ['DROPDOWN', 'RADIO', 'VOTE'].contains(fieldType)) {
        final opt = options
            .firstWhereOrNull((o) => o['id'].toString() == rawValue.toString());
        displayValue = opt?['option_value'] ?? rawValue.toString();
      } else if (fieldType == 'TOGGLE' ||
          fieldType == 'BOOLEAN' ||
          fieldType == 'YES/NO TOGGLE') {
        displayValue = (rawValue == 'true' || rawValue == '1') ? "አዎ" : "አይ";
      } else {
        displayValue = rawValue.toString();
      }

      return _infoRow(field['name'] ?? "Unknown", displayValue);
    }).toList();
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.grey[600], fontSize: 13)),
          Text(value ?? "ያልተጠቀሰ",
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRolePicker(Color primaryColor, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ሚና ይምረጡ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                title: const Text("አስተዳዳሪ"),
                onTap: () {
                  Navigator.pop(context);
                  _updateRole("admin", true);
                }),
            ListTile(
                title: const Text("አገልጋይ"),
                onTap: () {
                  Navigator.pop(context);
                  _updateRole("servant", true);
                }),
            ListTile(
                title: const Text("ተራ አባል"),
                onTap: () {
                  Navigator.pop(context);
                  _updateRole("user", false);
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(String role, bool isAdmin) async {
    setState(() => _isSaving = true);
    try {
      await UserAdminService.updateUserRoles(
        userId: widget.userId,
        shouldBeAdmin: isAdmin,
        role: role,
      );
      _loadUserDetail();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
