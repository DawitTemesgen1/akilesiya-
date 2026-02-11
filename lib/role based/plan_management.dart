// lib/role based/plan_management.dart
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/plan_service.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// --- DATA MODELS ---
class DepartmentMember {
  final String userId;
  final String name;
  final String? avatarUrl;
  String role;
  DepartmentMember(
      {required this.userId,
      required this.name,
      this.avatarUrl,
      required this.role});
}

class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role;
  User(
      {required this.id,
      required this.name,
      this.avatarUrl,
      required this.role});
  factory User.fromJson(Map<String, dynamic> json) {
    final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    return User(
      id: json['id'].toString(), // Robustify: ID can be int or string
      name: json['full_name'] ?? 'Unknown',
      avatarUrl: json['profile_image_url'] != null &&
              json['profile_image_url'].isNotEmpty
          ? '$baseUrl/uploads/${json['profile_image_url']}'
          : null,
      role: json['role'] ?? 'user',
    );
  }
}

Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  if (hexCode.length == 6) {
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  return Colors.grey;
}

class Department {
  final int id;
  String name;
  String? description;
  Color color;
  List<DepartmentMember> members;
  Department(
      {required this.id,
      required this.name,
      this.description,
      required this.color,
      this.members = const []});
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: _colorFromHex(json['color'] ?? '#808080'),
      members: (json['members'] as List<dynamic>?)
              ?.map((memberJson) => DepartmentMember(
                  userId: memberJson['userId'],
                  name: memberJson['name'] ?? 'Unknown',
                  avatarUrl: memberJson['avatarUrl'],
                  role: memberJson['role']))
              .toList() ??
          [],
    );
  }
}

class PlanItem {
  final int id;
  String title;
  String? description;
  DateTime? planDate;
  String? assigneeId;
  int departmentId;
  bool isDone;
  bool isHighPriority;
  bool isRecurring;
  int academicYear;
  final DateTime createdAt;
  PlanItem(
      {required this.id,
      required this.title,
      this.description,
      this.planDate,
      this.assigneeId,
      required this.departmentId,
      this.isDone = false,
      this.isHighPriority = false,
      this.isRecurring = false,
      required this.academicYear,
      required this.createdAt});
  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      planDate:
          json['plan_date'] != null ? DateTime.parse(json['plan_date']) : null,
      assigneeId: json['assignee_id']?.toString(), // Handle as string
      departmentId: json['department_id'] is int
          ? json['department_id']
          : int.parse(json['department_id'].toString()),
      isDone: json['is_done'] == 1 || json['is_done'] == true,
      isHighPriority:
          json['is_high_priority'] == 1 || json['is_high_priority'] == true,
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      academicYear: json['academic_year'] is int
          ? json['academic_year']
          : int.parse(json['academic_year'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum PlanSortOrder { byDate, byDueDate, byStatus }
// --- END OF DATA MODELS ---

class PlanControlScreen extends StatefulWidget {
  const PlanControlScreen({super.key});
  @override
  State<PlanControlScreen> createState() => _PlanControlScreenState();
}

class _PlanControlScreenState extends State<PlanControlScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  // Theme Colors (assigned in build to be safe)
  late Color primaryColor;
  late Color accentColor;
  late Color cardColor;
  late Color onSurfaceColor;

  late TabController _tabController;

  List<User> _allUsers = [];
  List<Department> _allowedDepartments = [];
  List<PlanItem> _plans = [];

  int? _selectedDepartmentIdForFilter;
  String _searchQuery = '';
  PlanSortOrder _sortOrder = PlanSortOrder.byDate;
  late int _selectedYear;
  final List<int> _yearOptions =
      List.generate(5, (i) => DateTime.now().year + 2 - i);

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;

    // Initialize TabController with a default length (updated later if needed)
    // We start with 2 (Standard User). If Superior Admin, we'll need to update or handle it.
    // To be safe and simple, we'll initialize it in `didChangeDependencies` or just check roles here?
    // Actually, accessing Provider in initState with listen:false is safe.
    // Let's defer strict length setting to initialization or use a safe default.
    // Better strategy: Initialize with expected length based on current role state if possible,
    // or handle dynamic length by disposing and re-initializing if roles change (rare).
    // For now, let's look at how we determine `isSuperiorAdmin`.
    // We can't easily change tab controller length.
    // Let's assume standard behavior: we will initialize it after checking roles or just use a builder.
    // Wait, `isSuperiorAdmin` relies on `UserProvider`.
    // Let's initialize `_tabController` in `didChangeDependencies` or `_initializeData`.
    // Actually, `TabController` needs `vsync`.
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Defer data load to next frame to allow context access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {}); // Rebuild to update FAB visibility
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper functions
  int _getEthiopianYear(int gregorianYear) {
    return EthiopianDate.fromGregorian(DateTime(gregorianYear, 12, 1)).year;
  }

  String _getUserRoleForDepartment(int departmentId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userProfile?['id'];

    try {
      final department =
          _allowedDepartments.firstWhere((d) => d.id == departmentId);
      final member = department.members.firstWhere(
          (m) => m.userId == currentUserId,
          orElse: () => DepartmentMember(userId: '', name: '', role: ''));
      return member.role;
    } catch (e) {
      return ''; // User is not a member of this department
    }
  }

  // API and Data Handling
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    // Self-healing: Ensure superior_admin has plan_admin role for backend compatibility
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // FIX: Force refresh profile to ensure roles are in sync with backend
      print(
          'DEBUG PlanControlScreen: Refreshing user profile to sync roles...');
      await userProvider.refreshProfile();

      if (userProvider.roles.contains('superior_admin') &&
          !userProvider.roles.contains('plan_admin')) {
        print(
            'DEBUG PlanControlScreen: Auto-assigning missing plan_admin role to superior_admin...');
        final userId = userProvider.userProfile?['id'];

        if (userId != null) {
          await UserAdminService.updateUserRoles(
              userId: userId, shouldBeAdmin: true, role: 'plan_admin');
          await userProvider.fetchUserProfile(); // Refresh local roles
          print('DEBUG PlanControlScreen: Successfully added plan_admin role.');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Permissions updated. Reloading...'),
                backgroundColor: Colors.green));
          }
        }
      }
    } catch (e) {
      print(
          'DEBUG PlanControlScreen: Failed to auto-assign plan_admin role: $e');
      // Continue anyway, as maybe backend is fixed or user has access via another means
    }

    // ======================= FIX 1 =======================
    // Determine the most privileged role to send to backend context
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Re-init TabController if role changes tab count requirements
    final bool isSuperiorAdmin =
        userProvider.roles.contains('superior_admin') ||
            userProvider.roles.contains('system_admin');
    final int requiredTabs = isSuperiorAdmin ? 3 : 2;
    if (_tabController.length != requiredTabs) {
      _tabController.removeListener(_handleTabSelection);
      _tabController.dispose();
      _tabController = TabController(length: requiredTabs, vsync: this);
      _tabController.addListener(_handleTabSelection);
      // Trigger rebuild to update TabBar with new controller
      if (mounted) setState(() {});
    }

    String? effectiveRole;

    // BACKEND FIXED: Now we can prioritize the highest role
    if (userProvider.roles.contains('superior_admin')) {
      effectiveRole = 'superior_admin';
    } else if (userProvider.roles.contains('system_admin')) {
      effectiveRole = 'system_admin';
    } else if (userProvider.roles.contains('plan_admin')) {
      effectiveRole = 'plan_admin';
    }

    // Corrected the method name from getDashboardData to getPlanData
    final result =
        await PlanService.getPlanData(year: _selectedYear, role: effectiveRole);
    // =======================================================
    if (mounted && result['success']) {
      final data = result['data'];
      setState(() {
        _allUsers =
            (data['users'] as List).map((u) => User.fromJson(u)).toList();
        _allowedDepartments = (data['departments'] as List)
            .map((d) => Department.fromJson(d))
            .toList();
        _plans =
            (data['plans'] as List).map((p) => PlanItem.fromJson(p)).toList();
        _isLoading = false;
      });
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to load data.');
      setState(() => _isLoading = false);
    }
  }

  // This function seems to be a duplicate or for another purpose,
  // but I'm correcting it to prevent the compile error.
  // Refreshing all data is generally safer.
  Future<void> _refreshPlans() async {
    setState(() => _isLoading = true);
    // ======================= FIX 2 =======================
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? effectiveRole;
    if (userProvider.roles.contains('superior_admin')) {
      effectiveRole = 'superior_admin';
    } else if (userProvider.roles.contains('system_admin')) {
      effectiveRole = 'system_admin';
    } else if (userProvider.roles.contains('plan_admin')) {
      effectiveRole = 'plan_admin';
    }

    // Corrected the method name from getPlansForYear to getPlanData
    final result =
        await PlanService.getPlanData(year: _selectedYear, role: effectiveRole);
    // =======================================================
    if (mounted && result['success']) {
      final data = result['data'];
      setState(() {
        _plans =
            (data['plans'] as List).map((p) => PlanItem.fromJson(p)).toList();
        _isLoading = false;
      });
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to refresh plans.');
      setState(() => _isLoading = false);
    }
  }

  List<PlanItem> get _filteredAndSortedPlans {
    List<PlanItem> processedPlans = List.from(_plans);
    if (_selectedDepartmentIdForFilter != null) {
      processedPlans
          .retainWhere((p) => p.departmentId == _selectedDepartmentIdForFilter);
    }
    if (_searchQuery.isNotEmpty) {
      processedPlans.retainWhere((p) =>
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false));
    }
    processedPlans.sort((a, b) {
      if (a.isHighPriority && !b.isHighPriority) return -1;
      if (!a.isHighPriority && b.isHighPriority) return 1;
      switch (_sortOrder) {
        case PlanSortOrder.byDueDate:
          if (a.planDate == null && b.planDate == null) {
            return b.createdAt.compareTo(a.createdAt);
          }
          if (a.planDate == null) return 1;
          if (b.planDate == null) return -1;
          return a.planDate!.compareTo(b.planDate!);
        case PlanSortOrder.byStatus:
          if (a.isDone == b.isDone) return b.createdAt.compareTo(a.createdAt);
          return a.isDone ? 1 : -1;
        case PlanSortOrder.byDate:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return processedPlans;
  }

  // Department CRUD
  Future<void> _createDepartment(
      String name, String? description, Color color) async {
    final result = await PlanService.createDepartment(
        name: name, description: description, color: color);
    if (mounted && result['success']) {
      final newDeptData = result['data'] as Map<String, dynamic>;
      setState(() => _allowedDepartments.add(Department.fromJson(newDeptData)));
      _showSuccessSnackbar('Department created successfully.');
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to create department.');
    }
  }

  Future<void> _updateDepartment(
      Department dept, String name, String? description, Color color) async {
    final result = await PlanService.updateDepartment(
        departmentId: dept.id.toString(),
        name: name,
        description: description,
        color: color);
    if (mounted && result['success']) {
      setState(() {
        final index = _allowedDepartments.indexWhere((d) => d.id == dept.id);
        if (index != -1) {
          _allowedDepartments[index] = Department.fromJson(result['data']);
        }
      });
      _showSuccessSnackbar('Department info updated successfully.');
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to update department.');
    }
  }

  Future<void> _deleteDepartment(int deptId) async {
    final result = await PlanService.deleteDepartment(deptId.toString());
    if (mounted && result['success']) {
      setState(() {
        _allowedDepartments.removeWhere((d) => d.id == deptId);
        _plans.removeWhere((p) => p.departmentId == deptId);
      });
      _showSuccessSnackbar('Department and its plans deleted.');
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to delete department.');
    }
  }

  // Plan CRUD
  Future<void> _addPlan(int departmentId, String? assigneeId, DateTime? date,
      bool isHighPriority, bool isRecurring, int academicYear) async {
    final result = await PlanService.createPlan(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        planDate: date,
        departmentId: departmentId.toString(),
        assigneeId: assigneeId,
        isHighPriority: isHighPriority,
        isRecurring: isRecurring,
        academicYear: academicYear);
    if (mounted && result['success']) {
      print('DEBUG: _addPlan result data: ${result['data']}');
      try {
        final newPlan = PlanItem.fromJson(result['data']);
        if (newPlan.academicYear == _selectedYear) {
          setState(() => _plans.insert(0, newPlan));
        }
        _showSuccessSnackbar(
            'Plan added successfully for ${newPlan.academicYear}.');
      } catch (e) {
        print('CRITICAL ERROR parsing new plan: $e');
        // Don't crash, just show error and maybe refresh
        _showErrorSnackbar(
            'Plan created, but failed to display immediately. Refreshing...');
        _initializeData();
      }
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to add plan.');
    }
  }

  Future<void> _updatePlan(
      PlanItem plan,
      int departmentId,
      String? assigneeId,
      DateTime? date,
      bool isDone,
      bool isHighPriority,
      bool isRecurring) async {
    final result = await PlanService.updatePlan(
        planId: plan.id.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        planDate: date,
        assigneeId: assigneeId,
        departmentId: departmentId.toString(),
        isDone: isDone,
        isHighPriority: isHighPriority,
        isRecurring: isRecurring,
        academicYear: plan.academicYear);
    if (mounted && result['success']) {
      final updatedPlan = PlanItem.fromJson(result['data']);
      setState(() {
        final index = _plans.indexWhere((p) => p.id == updatedPlan.id);
        if (index != -1) _plans[index] = updatedPlan;
      });
      _showSuccessSnackbar('Plan updated successfully.');
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to update plan.');
    }
  }

  Future<void> _deletePlan(int planId) async {
    final result = await PlanService.deletePlan(planId.toString());
    if (mounted && result['success']) {
      setState(() => _plans.removeWhere((plan) => plan.id == planId));
      _showSuccessSnackbar("Plan deleted successfully.");
    } else if (mounted) {
      _showErrorSnackbar(result['message'] ?? 'Failed to delete plan.');
    }
  }

  Future<void> _togglePlanStatus(PlanItem plan, bool isDone) async {
    final originalStatus = plan.isDone;
    setState(() => plan.isDone = isDone);
    final result =
        await PlanService.togglePlanStatus(plan.id.toString(), isDone);
    if (mounted && !result['success']) {
      setState(() => plan.isDone = originalStatus);
      _showErrorSnackbar(result['message'] ?? 'Failed to update status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe Theme Access
    final themeProvider = Provider.of<ThemeProvider>(context);
    primaryColor = themeProvider.getBackgroundColor(context);
    accentColor = themeProvider.getPrimaryColor(context);
    cardColor = themeProvider.getSurfaceColor(context);
    onSurfaceColor = themeProvider.getOnSurfaceColor(context);

    final userProvider = context.watch<UserProvider>();

    // DEBUG: Log roles for Plan Failure Diagnosis
    print('DEBUG PlanControlScreen: User roles = ${userProvider.roles}');

    final bool isSuperiorAdmin =
        userProvider.roles.contains('superior_admin') ||
            userProvider.roles.contains('system_admin');

    print('DEBUG PlanControlScreen: isSuperiorAdmin = $isSuperiorAdmin');

    // Ensure controller matches role (in case build happens before initData finishes re-sync)
    // Be careful not to dispose/init during build. We rely on _initializeData to correct it.
    // If mismatch, we might show fewer tabs temporarily or error.
    // Ideally we'd key the Scaffold or Controller, but for now we trust _initializeData.

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: _buildAppBar(isSuperiorAdmin),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDepartmentGrid(isSuperiorAdmin),
                _buildPlanList(isSuperiorAdmin),
                if (isSuperiorAdmin && _tabController.length >= 3)
                  _buildAdminManagementTab(),
              ],
            ),
      floatingActionButton:
          _buildFloatingActionButton(isSuperiorAdmin), // Contex removed
    );
  }

  // --- WIDGET BUILDERS ---

  AppBar _buildAppBar(bool isSuperiorAdmin) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      title: Text('እቅድ ቁጥጥር',
          style: GoogleFonts.notoSansEthiopic(
              fontWeight: FontWeight.w600, color: onSurfaceColor)),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: onSurfaceColor,
          onPressed: () => context.pop()),
      actions: [
        if (isSuperiorAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_backup_restore_rounded),
            tooltip: "Year End Setup",
            color: cardColor,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rollover',
                child: Text("Perform Annual Rollover",
                    style: GoogleFonts.notoSansEthiopic(color: onSurfaceColor)),
              ),
              PopupMenuItem(
                value: 'undo',
                child: Text("Undo Rollover",
                    style: GoogleFonts.notoSansEthiopic(color: Colors.orange)),
              ),
            ],
            onSelected: (value) {
              if (value == 'rollover') {
                _showRolloverDialog();
              } else if (value == 'undo') {
                _showUndoRolloverDialog();
              }
            },
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: accentColor,
        indicatorWeight: 3,
        labelColor: accentColor,
        labelStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w600),
        unselectedLabelColor: onSurfaceColor.withValues(alpha: 0.7),
        tabs: [
          const Tab(icon: Icon(Icons.dashboard_rounded), text: "ክፍላት"),
          const Tab(icon: Icon(Icons.list_alt_rounded), text: "ሁሉም እቅዶች"),
          if (isSuperiorAdmin && _tabController.length >= 3)
            const Tab(
                icon: Icon(Icons.admin_panel_settings), text: "Permissions"),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isSuperiorAdmin) {
    // No context needed, we use _tabController directly
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: _tabController.index == 0
            ? (isSuperiorAdmin
                ? FloatingActionButton.extended(
                    key: const ValueKey('add_dept'),
                    onPressed: () => _showAddOrEditDepartmentDialog(),
                    backgroundColor: accentColor,
                    foregroundColor: primaryColor,
                    icon: const Icon(Icons.add),
                    label: Text("አዲስ ክፍል",
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold)),
                    tooltip: 'Add Department',
                  )
                : null)
            : (_tabController.index == 1
                ? FloatingActionButton.extended(
                    key: const ValueKey('add_plan'),
                    onPressed: _allowedDepartments.isNotEmpty
                        ? () => _showAddOrEditPlanDialog()
                        : null,
                    backgroundColor: _allowedDepartments.isNotEmpty
                        ? accentColor
                        : Colors.grey.shade700,
                    foregroundColor: primaryColor,
                    icon: const Icon(Icons.add),
                    label: Text("አዲስ እቅድ",
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold)),
                    tooltip: _allowedDepartments.isNotEmpty
                        ? 'አዲስ እቅድ ያክሉ'
                        : 'እቅድ ለመጨመር የተፈቀደ ክፍል የለም',
                  )
                : const SizedBox.shrink()));
  }

  Widget _buildDepartmentGrid(bool isSuperiorAdmin) {
    if (_allowedDepartments.isEmpty) {
      return _buildEmptyState(
          "No Departments Assigned",
          "Contact a superior admin to be assigned to a department.",
          Icons.grid_view_rounded);
    }
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: accentColor,
      backgroundColor: primaryColor,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0),
        itemCount: _allowedDepartments.length,
        itemBuilder: (context, index) {
          final department = _allowedDepartments[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildDepartmentCard(department, isSuperiorAdmin, context),
          );
        },
      ),
    );
  }

  Widget _buildDepartmentCard(
      Department department, bool isSuperiorAdmin, BuildContext context) {
    final plansForDept =
        _plans.where((p) => p.departmentId == department.id).toList();
    final completedCount = plansForDept.where((p) => p.isDone).length;
    final totalCount = plansForDept.length;
    final completionPercentage =
        totalCount > 0 ? completedCount / totalCount : 0.0;
    final userRoleInDept = _getUserRoleForDepartment(department.id);
    final canManageDept = isSuperiorAdmin || userRoleInDept == 'admin';

    return Card(
      elevation: 4,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: department.color, width: 2)),
      child: InkWell(
        onTap: () {
          setState(() => _selectedDepartmentIdForFilter = department.id);
          _tabController.animateTo(1);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.business_rounded,
                      color: department.color, size: 32),
                  if (canManageDept)
                    _buildDepartmentMenu(department, isSuperiorAdmin),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(department.name,
                      style: GoogleFonts.notoSansEthiopic(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('$totalCount እቅዶች',
                      style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  if (totalCount > 0) ...[
                    LinearProgressIndicator(
                      value: completionPercentage,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: department.color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${(completionPercentage * 100).toStringAsFixed(0)}% ተጠናቋል',
                        style: GoogleFonts.notoSansEthiopic(
                            color: department.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<String> _buildDepartmentMenu(
      Department department, bool isSuperiorAdmin) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'manage') _showManageMembersSheet(department);
        if (value == 'edit') {
          _showAddOrEditDepartmentDialog(department: department);
        }
        if (value == 'delete') _confirmDeleteDepartment(department);
      },
      icon: const Icon(Icons.more_vert, color: Colors.white70),
      color: cardColor,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'manage',
          child: ListTile(
            leading: const Icon(Icons.group_add_outlined, color: Colors.white),
            title: Text("Manage Members & Roles",
                style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.white),
            title: Text("አስተካክል",
                style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
          ),
        ),
        if (isSuperiorAdmin) const PopupMenuDivider(),
        if (isSuperiorAdmin)
          PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
              title: Text("ሰርዝ",
                  style:
                      GoogleFonts.notoSansEthiopic(color: Colors.red.shade400)),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanList(bool isSuperiorAdmin) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
          child: Row(
            children: [
              Text("Year:",
                  style: GoogleFonts.notoSansEthiopic(color: Colors.white70)),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: _selectedYear,
                items: _yearOptions
                    .map((gregorianYear) => DropdownMenuItem(
                          value: gregorianYear,
                          child: Text(
                              '${_getEthiopianYear(gregorianYear)} ዓ.ም.',
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (newYear) {
                  if (newYear != null) {
                    setState(() => _selectedYear = newYear);
                    _initializeData();
                  }
                },
                dropdownColor: cardColor,
                iconEnabledColor: accentColor,
                underline: Container(),
              ),
              const Spacer(),
            ],
          ),
        ),
        _buildSearchAndSortBar(),
        if (_selectedDepartmentIdForFilter != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Chip(
              label: Text(
                  "ማጣሪያ: ${_allowedDepartments.firstWhere((d) => d.id == _selectedDepartmentIdForFilter, orElse: () => Department(id: 0, name: '', color: Colors.grey)).name}",
                  style: GoogleFonts.notoSansEthiopic(
                      color: primaryColor, fontWeight: FontWeight.bold)),
              backgroundColor: accentColor,
              onDeleted: () => setState(() {
                _selectedDepartmentIdForFilter = null;
                _searchQuery = '';
              }),
            ),
          ),
        Expanded(
          child: _plans.isEmpty && !_isLoading
              ? _buildEmptyState(
                  "No plans found for ${_getEthiopianYear(_selectedYear)} ዓ.ም.",
                  "Add a new plan to get started.",
                  Icons.assignment_outlined)
              : _filteredAndSortedPlans.isEmpty
                  ? _buildEmptyState(
                      "No plans match your search.",
                      "Try a different search term or clear the filter.",
                      Icons.search_off_rounded)
                  : RefreshIndicator(
                      onRefresh: _initializeData,
                      color: accentColor,
                      backgroundColor: primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredAndSortedPlans.length,
                        itemBuilder: (context, index) => _buildPlanItem(
                            _filteredAndSortedPlans[index], isSuperiorAdmin),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.notoSansEthiopic(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'እቅዶችን ፈልግ...',
                hintStyle: GoogleFonts.notoSansEthiopic(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<PlanSortOrder>(
            onSelected: (order) => setState(() => _sortOrder = order),
            icon: const Icon(Icons.sort, color: Colors.white),
            color: cardColor,
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: PlanSortOrder.byDate,
                  child: Text('በቅርብ ጊዜ',
                      style:
                          GoogleFonts.notoSansEthiopic(color: Colors.white))),
              PopupMenuItem(
                  value: PlanSortOrder.byDueDate,
                  child: Text('በመድረሻ ቀን',
                      style:
                          GoogleFonts.notoSansEthiopic(color: Colors.white))),
              PopupMenuItem(
                  value: PlanSortOrder.byStatus,
                  child: Text('በሁኔታ',
                      style:
                          GoogleFonts.notoSansEthiopic(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(PlanItem plan, bool isSuperiorAdmin) {
    final department = _allowedDepartments.firstWhere(
        (d) => d.id == plan.departmentId,
        orElse: () => Department(id: 0, name: 'ያልታወቀ', color: Colors.grey));
    final assignee = plan.assigneeId != null
        ? _allUsers.firstWhere((u) => u.id == plan.assigneeId,
            orElse: () =>
                User(id: '', name: '?', avatarUrl: null, role: 'user'))
        : null;

    final userRoleInDept = _getUserRoleForDepartment(plan.departmentId);
    final canEditPlan = isSuperiorAdmin || userRoleInDept == 'admin';

    return Dismissible(
      key: Key(plan.id.toString()),
      direction:
          isSuperiorAdmin ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete_forever, color: Colors.white)),
      confirmDismiss: (direction) => _confirmDeletePlan(),
      onDismissed: (direction) => _deletePlan(plan.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: department.color.withValues(alpha: 0.5), width: 1)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              canEditPlan ? () => _showAddOrEditPlanDialog(plan: plan) : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plan.isHighPriority) ...[
                      Icon(Icons.local_fire_department,
                          color: Colors.orange.shade400, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                        child: Text(plan.title,
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: plan.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: plan.isDone
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white))),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Checkbox(
                          value: plan.isDone,
                          onChanged: canEditPlan
                              ? (isDone) =>
                                  _togglePlanStatus(plan, isDone ?? false)
                              : null,
                          activeColor: Colors.green,
                          checkColor: primaryColor,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5))),
                    ),
                  ],
                ),
                if (plan.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(plan.description!,
                      style: GoogleFonts.notoSansEthiopic(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                        avatar: Icon(Icons.business,
                            size: 16, color: department.color),
                        label: Text(department.name,
                            style: GoogleFonts.notoSansEthiopic(
                                color: Colors.white)),
                        backgroundColor:
                            department.color.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4)),
                    if (assignee != null)
                      Chip(
                          avatar: CircleAvatar(
                              radius: 10,
                              backgroundImage: assignee.avatarUrl != null
                                  ? NetworkImage(assignee.avatarUrl!)
                                  : null),
                          label: Text(assignee.name,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: accentColor)),
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4)),
                    if (plan.planDate != null)
                      Chip(
                          avatar: Icon(Icons.calendar_today_outlined,
                              size: 16, color: accentColor),
                          label: Text(
                              EthiopianDate.fromGregorian(plan.planDate!)
                                  .toString(),
                              style: GoogleFonts.notoSansEthiopic(
                                  color: accentColor)),
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminManagementTab() {
    // 1. Process data to group permissions by user.
    final Map<String, List<Map<String, dynamic>>> permissionsMap = {};
    for (var department in _allowedDepartments) {
      for (var member in department.members) {
        if (member.role == 'admin' || member.role == 'manager') {
          permissionsMap.putIfAbsent(member.userId, () => []);
          permissionsMap[member.userId]!.add({
            'departmentName': department.name,
            'departmentColor': department.color,
            'departmentId': department.id, // Store ID for navigation
            'role': member.role,
          });
        }
      }
    }

    final adminUserIds = permissionsMap.keys.toList();

    if (adminUserIds.isEmpty) {
      return _buildEmptyState(
          "No Admins or Managers Found",
          "Assign roles from the 'Manage Members' option on any department card.",
          Icons.no_accounts);
    }

    // 2. Build the list view based on the processed data.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adminUserIds.length,
      itemBuilder: (context, index) {
        final userId = adminUserIds[index];
        final user = _allUsers.firstWhere((u) => u.id == userId,
            orElse: () => User(
                id: '', name: 'Unknown User', role: 'user', avatarUrl: null));
        final permissions = permissionsMap[userId]!;

        // Create a summary for the subtitle
        final adminCount =
            permissions.where((p) => p['role'] == 'admin').length;
        final managerCount =
            permissions.where((p) => p['role'] == 'manager').length;
        String summary = '';
        if (adminCount > 0) summary += "Admin of $adminCount Dept(s)";
        if (managerCount > 0) {
          if (summary.isNotEmpty) summary += " • ";
          summary += "Manager of $managerCount Dept(s)";
        }

        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                  : null,
            ),
            title: Text(user.name,
                style: GoogleFonts.notoSansEthiopic(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(summary,
                style:
                    GoogleFonts.notoSans(color: Colors.white70, fontSize: 12)),
            children: permissions.map((permission) {
              final department = _allowedDepartments
                  .firstWhere((d) => d.id == permission['departmentId']);
              return ListTile(
                leading: Icon(Icons.circle,
                    color: permission['departmentColor'], size: 12),
                title: Text(permission['departmentName'],
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
                subtitle: Text(
                  permission['role'].toString().capitalize(),
                  style: GoogleFonts.notoSans(
                      color: permission['role'] == 'admin'
                          ? accentColor
                          : Colors.blueAccent,
                      fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.manage_accounts_outlined,
                      color: Colors.white70),
                  tooltip: 'Manage Roles in this Department',
                  onPressed: () {
                    _showManageMembersSheet(department);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // --- DIALOGS AND SHEETS ---

  void _showManageMembersSheet(Department department) {
    List<DepartmentMember> tempMembers = department.members
        .map((m) => DepartmentMember(
            userId: m.userId,
            name: m.name,
            avatarUrl: m.avatarUrl,
            role: m.role))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final availableUsers = _allUsers
                .where((u) => !tempMembers.any((m) => m.userId == u.id))
                .toList();

            void addMember(User user) =>
                setModalState(() => tempMembers.add(DepartmentMember(
                    userId: user.id,
                    name: user.name,
                    avatarUrl: user.avatarUrl,
                    role: 'member')));
            void removeMember(DepartmentMember member) => setModalState(() =>
                tempMembers.removeWhere((m) => m.userId == member.userId));
            void changeRole(DepartmentMember member, String newRole) =>
                setModalState(() => member.role = newRole);

            Future<void> saveChanges() async {
              final memberPayload = tempMembers
                  .map((m) => {'userId': m.userId, 'role': m.role})
                  .toList();
              final result = await PlanService.updateDepartmentMembers(
                  departmentId: department.id, members: memberPayload);
              if (mounted) {
                if (result['success']) {
                  _showSuccessSnackbar("Members updated successfully.");
                  Navigator.pop(context);
                  _initializeData();
                } else {
                  _showErrorSnackbar(
                      result['message'] ?? 'Failed to save members.');
                }
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, controller) => Container(
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('${department.name} - Manage Roles',
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    Expanded(
                      child: tempMembers.isEmpty
                          ? Center(
                              child: Text("No members in this department.",
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: Colors.white70)))
                          : ListView.builder(
                              controller: controller,
                              itemCount: tempMembers.length,
                              itemBuilder: (context, index) {
                                final member = tempMembers[index];
                                final user = _allUsers.firstWhere(
                                    (u) => u.id == member.userId,
                                    orElse: () => User(
                                        id: '',
                                        name: 'Unknown',
                                        avatarUrl: null,
                                        role: 'user'));
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? Text(user.name.isNotEmpty
                                            ? user.name[0]
                                            : '?')
                                        : null,
                                  ),
                                  title: Text(user.name,
                                      style: GoogleFonts.notoSansEthiopic(
                                          color: Colors.white)),
                                  subtitle: PopupMenuButton<String>(
                                    color: const Color(0xFF2c3e50),
                                    onSelected: (newRole) =>
                                        changeRole(member, newRole),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(member.role.capitalize(),
                                            style: GoogleFonts.notoSans(
                                                fontWeight: FontWeight.bold,
                                                color: member.role == 'admin'
                                                    ? accentColor
                                                    : (member.role == 'manager'
                                                        ? Colors.blueAccent
                                                        : Colors.white70))),
                                        const Icon(Icons.arrow_drop_down,
                                            color: Colors.white70)
                                      ],
                                    ),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'admin',
                                          child: Text('Admin (Read/Write)',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                      const PopupMenuItem(
                                          value: 'manager',
                                          child: Text('Manager (Read-Only)',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                      const PopupMenuItem(
                                          value: 'member',
                                          child: Text('Member',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    ],
                                  ),
                                  trailing: IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.redAccent),
                                      onPressed: () => removeMember(member)),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      accentColor.withValues(alpha: 0.8),
                                  foregroundColor: primaryColor,
                                  minimumSize: const Size(double.infinity, 50)),
                              onPressed: () async {
                                final newUser =
                                    await _showAddMemberDialog(availableUsers);
                                if (newUser != null) {
                                  addMember(newUser);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: Text('አዲስ አባል',
                                  style: GoogleFonts.notoSansEthiopic(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                              ),
                              onPressed: saveChanges,
                              child: Text('አስቀምጥ',
                                  style: GoogleFonts.notoSansEthiopic(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddOrEditDepartmentDialog({Department? department}) async {
    final isEditing = department != null;
    final nameController =
        TextEditingController(text: isEditing ? department.name : '');
    final descController =
        TextEditingController(text: isEditing ? department.description : '');
    final List<Color> colorOptions = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    Color selectedColor = isEditing ? department.color : colorOptions[0];
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(isEditing ? 'ክፍል ያርትዑ' : 'አዲስ ክፍል ይፍጠሩ',
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                      controller: nameController,
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      decoration: _getDialogInputDecoration('የክፍል ስም'),
                      validator: (v) => v!.isEmpty ? 'ስም ያስገቡ' : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: descController,
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      decoration: _getDialogInputDecoration('ዝርዝር (አማራጭ)'),
                      maxLines: 2),
                  const SizedBox(height: 16),
                  Text("ቀለም ይምረጡ",
                      style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: colorOptions
                        .map((color) => InkWell(
                              onTap: () =>
                                  setDialogState(() => selectedColor = color),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 18,
                                child: selectedColor == color
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ይቅር',
                    style: GoogleFonts.notoSansEthiopic(color: accentColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor, foregroundColor: primaryColor),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  isEditing
                      ? await _updateDepartment(department, nameController.text,
                          descController.text, selectedColor)
                      : await _createDepartment(nameController.text,
                          descController.text, selectedColor);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'አስቀምጥ' : 'ፍጠር',
                  style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> _showAddMemberDialog(List<User> availableUsers) {
    return showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('አባል ይምረጡ',
            style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: availableUsers.isEmpty
              ? Text("ሊጨመር የሚችል አባል የለም።",
                  style: GoogleFonts.notoSansEthiopic(color: Colors.white70))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null),
                      title: Text(user.name,
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white)),
                      onTap: () {
                        Navigator.of(context).pop(user);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ይቅር',
                  style: GoogleFonts.notoSansEthiopic(color: accentColor))),
        ],
      ),
    );
  }

  Future<void> _showAddOrEditPlanDialog({PlanItem? plan}) async {
    if (_allowedDepartments.isEmpty) {
      _showErrorSnackbar("እቅድ ለመጨመር የተፈቀደልዎት ክፍል የለም።");
      return;
    }

    final isEditing = plan != null;
    _titleController.text = isEditing ? plan.title : '';
    _descriptionController.text = isEditing ? plan.description ?? '' : '';

    int? selectedDeptId = isEditing
        ? plan.departmentId
        : (_selectedDepartmentIdForFilter ?? _allowedDepartments.first.id);
    String? selectedAssigneeId = isEditing ? plan.assigneeId : null;
    DateTime? selectedDate = isEditing ? plan.planDate : null;
    bool isDone = isEditing ? plan.isDone : false;
    bool isHighPriority = isEditing ? plan.isHighPriority : false;
    bool isRecurring = isEditing ? plan.isRecurring : false;
    int selectedAcademicYear = isEditing ? plan.academicYear : _selectedYear;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedAssignee = selectedAssigneeId != null
              ? _allUsers.firstWhere((u) => u.id == selectedAssigneeId,
                  orElse: () => User(
                      id: '', name: 'Unknown', avatarUrl: null, role: 'user'))
              : null;
          final availableUsers = List.of(_allUsers);

          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text(isEditing ? 'እቅድ ያርትዑ' : 'አዲስ እቅድ ያክሉ',
                style: GoogleFonts.notoSansEthiopic(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        controller: _titleController,
                        style:
                            GoogleFonts.notoSansEthiopic(color: Colors.white),
                        decoration: _getDialogInputDecoration('ርዕስ'),
                        validator: (v) => v!.isEmpty ? 'ርዕስ ያስገቡ' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _descriptionController,
                        style:
                            GoogleFonts.notoSansEthiopic(color: Colors.white),
                        decoration: _getDialogInputDecoration('ዝርዝር'),
                        maxLines: 3),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedAcademicYear,
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      dropdownColor: cardColor,
                      decoration: _getDialogInputDecoration('Year / ዓ.ም.'),
                      items: _yearOptions
                          .map((gregorianYear) => DropdownMenuItem(
                              value: gregorianYear,
                              child: Text(
                                  '${_getEthiopianYear(gregorianYear)} ዓ.ም.',
                                  style: GoogleFonts.notoSansEthiopic())))
                          .toList(),
                      onChanged: isEditing
                          ? null
                          : (value) => setDialogState(
                              () => selectedAcademicYear = value!),
                      validator: (value) =>
                          value == null ? 'Please select a year' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedDeptId,
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      dropdownColor: cardColor,
                      decoration: _getDialogInputDecoration('ክፍል'),
                      items: _allowedDepartments
                          .map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name,
                                  style: GoogleFonts.notoSansEthiopic())))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedDeptId = value),
                      validator: (value) =>
                          value == null ? 'እባክዎ ክፍል ይምረጡ' : null,
                    ),
                    const SizedBox(height: 16),
                    Text("ኃላፊ",
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final User? newAssignee =
                            await _showAddMemberDialog(availableUsers);
                        if (newAssignee != null) {
                          setDialogState(
                              () => selectedAssigneeId = newAssignee.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5))),
                        child: Row(
                          children: [
                            if (selectedAssignee != null) ...[
                              CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      selectedAssignee.avatarUrl != null
                                          ? NetworkImage(
                                              selectedAssignee.avatarUrl!)
                                          : null),
                              const SizedBox(width: 12),
                              Text(selectedAssignee.name,
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: Colors.white)),
                            ] else ...[
                              const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person_outline, size: 18)),
                              const SizedBox(width: 12),
                              Text('ኃላፊ አልተመረጠም',
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: Colors.white70)),
                            ],
                            const Spacer(),
                            Text('ቀይር',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: accentColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar, color: accentColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? 'ቀን አልተመረጠም'
                                      : EthiopianDate.fromGregorian(
                                              selectedDate!)
                                          .toString(),
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                if (selectedDate != null)
                                  Text(
                                    DateFormat.yMMMEd().format(selectedDate!),
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final pickedEthiopianDate =
                                  await showDialog<EthiopianDate>(
                                context: context,
                                builder: (context) => EthiopianDatePickerDialog(
                                  initialDate: selectedDate != null
                                      ? EthiopianDate.fromGregorian(
                                          selectedDate!)
                                      : EthiopianDate.now(),
                                ),
                              );
                              if (pickedEthiopianDate != null) {
                                setDialogState(() {
                                  selectedDate =
                                      pickedEthiopianDate.toGregorian();
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  accentColor.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('ቀን ምረጥ',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      title: Text('ከፍተኛ ቅድሚያ',
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white)),
                      value: isHighPriority,
                      activeThumbColor: accentColor,
                      onChanged: (val) =>
                          setDialogState(() => isHighPriority = val),
                      secondary: Icon(Icons.local_fire_department,
                          color: isHighPriority
                              ? Colors.orange.shade400
                              : Colors.white70),
                    ),
                    SwitchListTile(
                      title: Text('Recurring Plan (Annual)',
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white)),
                      value: isRecurring,
                      activeThumbColor: accentColor,
                      onChanged: (val) =>
                          setDialogState(() => isRecurring = val),
                      secondary: Icon(Icons.autorenew,
                          color: isRecurring ? accentColor : Colors.white70),
                    ),
                    if (isEditing)
                      SwitchListTile(
                        title: Text('ተግባሩ ተጠናቋል',
                            style: GoogleFonts.notoSansEthiopic(
                                color: Colors.white)),
                        value: isDone,
                        activeThumbColor: Colors.green,
                        onChanged: (val) => setDialogState(() => isDone = val),
                        secondary: Icon(Icons.check_circle_outline,
                            color: isDone ? Colors.green : Colors.white70),
                      )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ይቅር',
                      style: GoogleFonts.notoSansEthiopic(color: accentColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: primaryColor),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    isEditing
                        ? await _updatePlan(
                            plan,
                            selectedDeptId!,
                            selectedAssigneeId,
                            selectedDate,
                            isDone,
                            isHighPriority,
                            isRecurring)
                        : await _addPlan(
                            selectedDeptId!,
                            selectedAssigneeId,
                            selectedDate,
                            isHighPriority,
                            isRecurring,
                            selectedAcademicYear);
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'አስቀምጥ' : 'አክል',
                    style: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRolloverDialog() {
    int sourceYear = _selectedYear;
    int destinationYear = _selectedYear + 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Annual Plan Rollover",
            style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
        content: Text(
          "This will copy 'recurring' plans from ${_getEthiopianYear(sourceYear)} to ${_getEthiopianYear(destinationYear)}. Original plans will not be changed.\n\nAre you sure?",
          style: GoogleFonts.notoSansEthiopic(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: GoogleFonts.notoSansEthiopic(color: accentColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, foregroundColor: primaryColor),
            onPressed: () async {
              final navigator = Navigator.of(context);
              _showSuccessSnackbar("Performing rollover...");
              final result = await PlanService.performRollover(
                sourceYear: sourceYear,
                destinationYear: destinationYear,
              );
              if (mounted) {
                if (result['success']) {
                  _showSuccessSnackbar(
                      result['message'] ?? 'Rollover complete!');
                  setState(() => _selectedYear = destinationYear);
                  _initializeData();
                } else {
                  _showErrorSnackbar(result['message'] ?? 'Rollover failed.');
                }
                navigator.pop();
              }
            },
            child: Text("Confirm & Rollover",
                style:
                    GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showUndoRolloverDialog() {
    int yearToClear = _selectedYear;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Undo Rollover",
            style: GoogleFonts.notoSansEthiopic(color: Colors.orange)),
        content: Text(
          "This will PERMANENTLY DELETE all plans from the year ${_getEthiopianYear(yearToClear)}.\n\nThis is for correcting a mistaken rollover. This action cannot be undone. Are you sure?",
          style: GoogleFonts.notoSansEthiopic(color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel",
                style: GoogleFonts.notoSansEthiopic(color: accentColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, foregroundColor: primaryColor),
            child: Text("Yes, Undo for ${_getEthiopianYear(yearToClear)}",
                style:
                    GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
            onPressed: () async {
              final navigator = Navigator.of(context);
              _showSuccessSnackbar("Undoing rollover...");
              final result = await PlanService.undoRollover(
                yearToDelete: yearToClear,
              );
              if (mounted) {
                if (result['success']) {
                  _showSuccessSnackbar(result['message'] ?? 'Undo successful!');
                  _initializeData();
                } else {
                  _showErrorSnackbar(result['message'] ?? 'Undo failed.');
                }
                navigator.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDepartment(Department department) async {
    final confirmed = await _showConfirmationDialog(
        title: 'ክፍሉን ሰርዝ',
        content:
            '\'${department.name}\'ን ለመሰረዝ እርግጠኛ ነዎት? ከዚህ ክፍል ጋር የተያያዙ ሁሉም እቅዶችም ይሰረዛሉ።',
        isDestructive: true,
        confirmText: 'አዎ, ሰርዝ');
    if (confirmed == true) {
      _deleteDepartment(department.id);
    }
  }

  Future<bool> _confirmDeletePlan() async {
    return await _showConfirmationDialog(
            title: 'እቅዱን ሰርዝ',
            content: 'ይህን እቅድ ለመሰረዝ እርግጠኛ ነዎት? ይህን ድርጊት መመለስ አይቻልም።',
            isDestructive: true,
            confirmText: 'አዎ, ሰርዝ') ??
        false;
  }

  Future<bool?> _showConfirmationDialog(
      {required String title,
      required String content,
      bool isDestructive = false,
      String confirmText = 'Confirm'}) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(title,
            style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
        content: Text(
          content,
          style: GoogleFonts.notoSansEthiopic(
              color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',
                  style: GoogleFonts.notoSansEthiopic(color: accentColor))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText,
                  style: GoogleFonts.notoSansEthiopic(
                      color: isDestructive ? Colors.red : Colors.green))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  InputDecoration _getDialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.notoSansEthiopic(
          color: Colors.white.withValues(alpha: 0.7)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: accentColor)),
      errorStyle: GoogleFonts.notoSansEthiopic(),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.notoSansEthiopic(
              color: primaryColor, fontWeight: FontWeight.bold)),
      backgroundColor: accentColor,
      behavior: SnackBarBehavior.fixed,
    ));
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.fixed,
    ));
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
