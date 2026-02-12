// lib/screens/admin/admin_member_development_screen.dart (Refactored)

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/services/development_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

// --- Amharic Localization Strings for Development Screen ---
abstract class AmharicStringsDevelopment {
  static const String memberProfile = 'የአባል ገጽ';
  static const String developmentPlanFor = 'የዕድገት ዕቅድ ለ:';
  static const String activeIssues = 'ያልተጠናቀቁ ጉዳዮች';
  static const String skills = 'ችሎታዎች';
  static const String completed = 'ተጠናቀቀ';
  static const String all = 'ሁሉም';
  static const String discipline = 'ዲሲፕሊን';
  static const String background = 'መነሻ መረጃ';
  static const String habits = 'ልማዶች';
  static const String addNote = 'ማስታወሻ ጨምር';
  static const String noItemsFound = 'ምንም ማስታወሻ አልተገኘም';
  static const String issue = 'ጉዳይ';
  static const String plan = 'እቅድ';
  static const String edit = 'አስተካክል';
  static const String completedStatus = 'ተጠናቋል';
  static const String markAsDone = 'ተከናውኗል ምልክት አድርግ';
  static const String noteUpdatedSuccess = 'ማስታወሻው በተሳካ ሁኔታ ተስተካክሏል።';
  static const String noteAddedSuccess = 'ማስታወሻው በተሳካ ሁኔታ ተመዝግቧል።';
  static const String failedToUpdateStatus = 'ሁኔታውን ማዘመን አልተቻለም።';
  static const String statusUpdatedSuccess = 'ሁኔታው በተሳካ ሁኔታ ተዘምኗል።';
  static const String confirmDeletion = 'መሰረዝን ያረጋግጡ';
  static const String deleteConfirmation = 'ይህንን ማስታወሻ በቋሚነት መሰረዝ ይፈልጋሉ?';
  static const String cancel = 'ይቅር';
  static const String delete = 'ሰርዝ';
  static const String failedToDelete = 'መሰረዝ አልተቻለም።';
  static const String noteDeletedSuccess = 'ማስታወሻው በተሳካ ሁኔታ ተሰርዟል።';
  static const String editNote = 'የዕድገት ማስታወሻ አስተካክል';
  static const String addNewNote = 'አዲስ የዕድገት ማስታወሻ ጨምር';
  static const String selectCategory = 'ምድብ ይምረጡ';
  static const String pleaseSelectCategory = 'እባክዎ ምድብ ይምረጡ';
  static const String pleaseDescribeIssue = 'እባክዎ ጉዳዩን ይግለጹ';
  static const String pleaseDescribePlan = 'እባክዎ እቅዱን ይግለጹ';
  static const String date = 'ቀን';
  static const String updateNote = 'ማስታወሻውን አዘምን';
  static const String saveNote = 'ማስታወሻውን አስቀምጥ';
  static const String saveBtn =
      'አስቀምጥ'; // Missing 'save' button text for the dialog's submit button
}

// --- UI Theme Constants (as before) ---
const Color kAdminPrimary = Color.fromARGB(255, 1, 37, 100);
const Color kAdminAccent = Color(0xFFFFD700);
const Color kAdminSurface = Color(0xFFF8F9FA);
const Color kAdminOnSurface = Color(0xFF212529);
const Color kAdminCard = Colors.white;

// Category Colors for Visual Cues (as before)
const Color kDisciplineColor = Color(0xFFD32F2F);
const Color kSkillColor = Color(0xFF1976D2);
const Color kBackgroundColor = Color(0xFF6A1B9A);
const Color kHabitColor = Color(0xFF388E3C);

// Data Model (Unchanged)
class DevelopmentItem {
  final int id;
  String category;
  String issue;
  String plan;
  DateTime date;
  bool isCompleted;

  DevelopmentItem({
    required this.id,
    required this.category,
    required this.issue,
    required this.plan,
    required this.date,
    this.isCompleted = false,
  });

  factory DevelopmentItem.fromJson(Map<String, dynamic> json) {
    return DevelopmentItem(
      id: json['id'],
      category: json['category'],
      issue: json['issue'],
      plan: json['plan'],
      date: DateTime.parse(json['date']),
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }
}

class AdminMemberDevelopmentScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminMemberDevelopmentScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminMemberDevelopmentScreen> createState() =>
      _AdminMemberDevelopmentScreenState();
}

class _AdminMemberDevelopmentScreenState
    extends State<AdminMemberDevelopmentScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<DevelopmentItem> _items = [];

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get accentColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get cardColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);

  // Map English category name to Amharic for UI display
  final Map<String, String> _categoryTranslations = {
    'All': AmharicStringsDevelopment.all,
    'Discipline': AmharicStringsDevelopment.discipline,
    'Skills': AmharicStringsDevelopment.skills,
    'Background': AmharicStringsDevelopment.background,
    'Habits': AmharicStringsDevelopment.habits,
  };

  @override
  void initState() {
    super.initState();
    _fetchDevelopmentNotes();
  }

  // --- API CALLS ---
  Future<void> _fetchDevelopmentNotes() async {
    setState(() => _isLoading = true);
    final result = await DevelopmentService.getDevelopmentNotes(
        widget.user['id'].toString());
    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data'];
        setState(() {
          _items = data.map((item) => DevelopmentItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        _showSnackbar(result['message'] ?? 'መረጃ መጫን አልተሳካም።',
            isError: true); // Translated error message
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleStatus(DevelopmentItem item) async {
    final originalStatus = item.isCompleted;
    setState(() => item.isCompleted = !originalStatus);

    final result = await DevelopmentService.updateNoteStatus(
      noteId: item.id.toString(),
      isCompleted: item.isCompleted,
    );

    if (mounted && !result['success']) {
      setState(() => item.isCompleted = originalStatus); // Revert on failure
      _showSnackbar(
          result['message'] ?? AmharicStringsDevelopment.failedToUpdateStatus,
          isError: true);
    } else if (mounted) {
      _showSnackbar(AmharicStringsDevelopment.statusUpdatedSuccess,
          isError: false);
    }
  }

  // --- UI HELPERS ---
  void _showSnackbar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.notoSansEthiopic()),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Discipline':
        return kDisciplineColor;
      case 'Skills':
        return kSkillColor;
      case 'Background':
        return kBackgroundColor;
      case 'Habits':
        return kHabitColor;
      default:
        return Colors.grey;
    }
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bgColor = themeProvider.getBackgroundColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleTextColor = themeProvider.getSubtleTextColor(context);

    final filteredItems = _selectedFilter == 'All'
        ? _items
        : _items.where((item) => item.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(primaryColor, surfaceColor, textColor),
          SliverToBoxAdapter(
              child: _buildSummaryMetrics(
                  surfaceColor, textColor, subtleTextColor)),
          SliverToBoxAdapter(
              child: _buildFilterChips(surfaceColor, textColor, primaryColor)),
          if (_isLoading)
            _buildLoadingShimmer(surfaceColor)
          else
            _buildDevelopmentList(filteredItems, surfaceColor, textColor,
                subtleTextColor, primaryColor),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'member-dev-fab-${widget.user['id']}',
        onPressed: () => _showAddOrEditItemModal(),
        backgroundColor: primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          AmharicStringsDevelopment.addNote,
          style: GoogleFonts.notoSansEthiopic(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildSliverAppBar(
      Color primaryColor, Color surfaceColor, Color textColor) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: primaryColor,
      elevation: 0,
      leading: BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          widget.user['full_name'] ?? AmharicStringsDevelopment.memberProfile,
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: -20,
              child: Icon(
                Iconsax.user_octagon,
                size: 180,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AmharicStringsDevelopment.developmentPlanFor,
                    style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Hero(
                    tag: 'user_name_${widget.user['id']}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.user['full_name'] ?? 'N/A',
                        style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics(
      Color surfaceColor, Color textColor, Color subtleTextColor) {
    final activeCount = _items.where((i) => !i.isCompleted).length.toString();
    final skillsCount =
        _items.where((i) => i.category == 'Skills').length.toString();
    final completedCount = _items.where((i) => i.isCompleted).length.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildMetricItem(Iconsax.activity,
                AmharicStringsDevelopment.activeIssues, activeCount,
                color: Colors.orange, textColor: textColor),
          ),
          Expanded(
            child: _buildMetricItem(
                Iconsax.star_1, AmharicStringsDevelopment.skills, skillsCount,
                color: kSkillColor, textColor: textColor),
          ),
          Expanded(
            child: _buildMetricItem(Iconsax.task_square,
                AmharicStringsDevelopment.completed, completedCount,
                color: kHabitColor, textColor: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value,
      {required Color color, required Color textColor}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
      Color surfaceColor, Color textColor, Color primaryColor) {
    final filters = ['All', 'Discipline', 'Skills', 'Background', 'Habits'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters.map((filter) {
            bool isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ChoiceChip(
                  label: Text(_categoryTranslations[filter] ?? filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: surfaceColor,
                  selectedColor: primaryColor,
                  labelStyle: GoogleFonts.notoSansEthiopic(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? primaryColor
                          : textColor.withValues(alpha: 0.1),
                    ),
                  ),
                  elevation: isSelected ? 4 : 0,
                  pressElevation: 8,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(Color surfaceColor) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: surfaceColor,
            highlightColor: surfaceColor.withValues(alpha: 0.5),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 140,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildDevelopmentList(List<DevelopmentItem> items, Color surfaceColor,
      Color textColor, Color subtleTextColor, Color primaryColor) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.folder_open, size: 64, color: subtleTextColor),
              const SizedBox(height: 16),
              Text(
                AmharicStringsDevelopment.noItemsFound,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18,
                  color: subtleTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: 100 * index),
              child: _buildTrackingItemCard(items[index], surfaceColor,
                  textColor, subtleTextColor, primaryColor),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildTrackingItemCard(DevelopmentItem item, Color surfaceColor,
      Color textColor, Color subtleTextColor, Color primaryColor) {
    final color = _getCategoryColor(item.category);
    final bool isCompleted = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              _categoryTranslations[item.category] ??
                                  item.category,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                          ),
                          Text(
                            EthiopianDate.fromGregorian(item.date).toString(),
                            style: GoogleFonts.notoSansEthiopic(
                                color: subtleTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          Iconsax.warning_2,
                          AmharicStringsDevelopment.issue,
                          item.issue,
                          textColor),
                      const SizedBox(height: 12),
                      _buildInfoRow(Iconsax.clipboard_text,
                          AmharicStringsDevelopment.plan, item.plan, textColor),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _showAddOrEditItemModal(item: item),
                            icon: const Icon(Iconsax.edit,
                                size: 16, color: Colors.blue),
                            label: Text(
                              AmharicStringsDevelopment.edit,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleStatus(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? kHabitColor.withValues(alpha: 0.1)
                                    : textColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Iconsax.tick_circle5
                                        : Iconsax.close_circle,
                                    color: isCompleted
                                        ? kHabitColor
                                        : subtleTextColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isCompleted
                                        ? AmharicStringsDevelopment
                                            .completedStatus
                                        : AmharicStringsDevelopment.markAsDone,
                                    style: GoogleFonts.notoSansEthiopic(
                                      color:
                                          isCompleted ? kHabitColor : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String title, String content, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: textColor.withValues(alpha: 0.3), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 14, color: textColor, height: 1.4),
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- ADD/EDIT MODAL ---
  void _showAddOrEditItemModal({DevelopmentItem? item}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final isEditing = item != null;

    final formKey = GlobalKey<FormState>();
    String? category = isEditing ? item.category : null;
    final issueController =
        TextEditingController(text: isEditing ? item.issue : '');
    final planController =
        TextEditingController(text: isEditing ? item.plan : '');
    DateTime selectedDate = isEditing ? item.date : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isEditing
                          ? AmharicStringsDevelopment.editNote
                          : AmharicStringsDevelopment.addNewNote,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: surfaceColor,
                      style: GoogleFonts.notoSansEthiopic(color: textColor),
                      decoration: _buildInputDecoration(
                          AmharicStringsDevelopment.selectCategory,
                          Iconsax.category,
                          textColor,
                          primaryColor),
                      items: ['Discipline', 'Skills', 'Background', 'Habits']
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(_categoryTranslations[cat] ?? cat),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => category = value),
                      validator: (value) => value == null
                          ? AmharicStringsDevelopment.pleaseSelectCategory
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: issueController,
                      style: GoogleFonts.notoSansEthiopic(color: textColor),
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                          AmharicStringsDevelopment.issue,
                          Iconsax.warning_2,
                          textColor,
                          primaryColor),
                      validator: (value) => (value?.isEmpty ?? true)
                          ? AmharicStringsDevelopment.pleaseDescribeIssue
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: planController,
                      style: GoogleFonts.notoSansEthiopic(color: textColor),
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                          AmharicStringsDevelopment.plan,
                          Iconsax.clipboard_text,
                          textColor,
                          primaryColor),
                      validator: (value) => (value?.isEmpty ?? true)
                          ? AmharicStringsDevelopment.pleaseDescribePlan
                          : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDialog<EthiopianDate>(
                          context: context,
                          builder: (context) => EthiopianDatePickerDialog(
                            initialDate:
                                EthiopianDate.fromGregorian(selectedDate),
                          ),
                        );
                        if (pickedDate != null) {
                          setModalState(
                              () => selectedDate = pickedDate.toGregorian());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: textColor.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.calendar,
                                color: primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              EthiopianDate.fromGregorian(selectedDate)
                                  .toString(),
                              style: GoogleFonts.notoSansEthiopic(
                                  color: textColor),
                            ),
                            const Spacer(),
                            Icon(Iconsax.arrow_right_3,
                                color: textColor.withValues(alpha: 0.3),
                                size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        if (isEditing)
                          IconButton(
                            onPressed: () => _handleDelete(item),
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            tooltip: AmharicStringsDevelopment.delete,
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _handleSave(
                            formKey: formKey,
                            isEditing: isEditing,
                            item: item,
                            category: category,
                            issueController: issueController,
                            planController: planController,
                            selectedDate: selectedDate,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            isEditing
                                ? AmharicStringsDevelopment.updateNote
                                : AmharicStringsDevelopment.saveNote,
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String label, IconData icon, Color textColor, Color primaryColor) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.notoSansEthiopic(color: textColor.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: primaryColor, size: 20),
      filled: true,
      fillColor: textColor.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: textColor.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Future<void> _handleSave({
    required GlobalKey<FormState> formKey,
    required bool isEditing,
    DevelopmentItem? item,
    required String? category,
    required TextEditingController issueController,
    required TextEditingController planController,
    required DateTime selectedDate,
  }) async {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'category': category,
      'issue': issueController.text,
      'plan': planController.text,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
    };

    final result = isEditing
        ? await DevelopmentService.updateDevelopmentNote(
            noteId: item!.id.toString(), data: data)
        : await DevelopmentService.createDevelopmentNote(
            userId: widget.user['id'].toString(), data: data);

    if (mounted) {
      if (result['success']) {
        _showSnackbar(
            isEditing
                ? AmharicStringsDevelopment.noteUpdatedSuccess
                : AmharicStringsDevelopment.noteAddedSuccess,
            isError: false);
        Navigator.pop(context);
        _fetchDevelopmentNotes();
      } else {
        _showSnackbar(result['message'] ?? 'Error occurred', isError: true);
      }
    }
  }

  Future<void> _handleDelete(DevelopmentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AmharicStringsDevelopment.confirmDeletion,
            style: GoogleFonts.notoSansEthiopic()),
        content: Text(AmharicStringsDevelopment.deleteConfirmation,
            style: GoogleFonts.notoSansEthiopic()),
        actions: [
          TextButton(
            child: Text(AmharicStringsDevelopment.cancel,
                style: GoogleFonts.notoSansEthiopic()),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(AmharicStringsDevelopment.delete,
                style: GoogleFonts.notoSansEthiopic(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result =
          await DevelopmentService.deleteDevelopmentNote(item.id.toString());
      if (mounted) {
        if (result['success']) {
          _showSnackbar(AmharicStringsDevelopment.noteDeletedSuccess,
              isError: false);
          Navigator.pop(context);
          _fetchDevelopmentNotes();
        } else {
          _showSnackbar(
              result['message'] ?? AmharicStringsDevelopment.failedToDelete,
              isError: true);
        }
      }
    }
  }
}
