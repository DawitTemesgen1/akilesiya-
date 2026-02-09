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
    final filteredItems = _selectedFilter == 'All'
        ? _items
        : _items.where((item) => item.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: kAdminSurface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSummaryMetrics()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          if (_isLoading)
            SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: accentColor)))
          else
            _buildDevelopmentList(filteredItems),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // The hero tag was a likely source of the multiple heroes issue in other screens,
        // but adding a tag here is correct if this FAB is part of a Hero transition.
        heroTag:
            'member-dev-fab-${widget.user['id']}', // Use user ID for uniqueness

        onPressed: () => _showAddOrEditItemModal(),
        backgroundColor: accentColor,
        icon: Icon(Iconsax.add, color: Colors.white),
        label: Text(
          AmharicStringsDevelopment.addNote, // Translated
          style: GoogleFonts.notoSansEthiopic(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: primaryColor,
      elevation: 2,
      // Responsive: FlexibleSpaceBar is inherently responsive
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Title on the app bar collapses nicely
        title: Text(
          widget.user['full_name'] ?? AmharicStringsDevelopment.memberProfile,
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -50,
                right: -50,
                child: Icon(Iconsax.user_octagon,
                    size: 200, color: accentColor.withValues(alpha: 0.1)),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AmharicStringsDevelopment
                          .developmentPlanFor, // Translated
                      style: GoogleFonts.notoSansEthiopic(color: accentColor),
                    ),
                    Hero(
                      tag: 'user_name_${widget.user['id']}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.user['full_name'] ?? 'N/A',
                          style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    final activeCount = _items.where((i) => !i.isCompleted).length.toString();
    final skillsCount =
        _items.where((i) => i.category == 'Skills').length.toString();
    final completedCount = _items.where((i) => i.isCompleted).length.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: kAdminCard,
      // Responsive: Use layout builder for complex cross-platform layouts if needed, but Row is fine for 3 items.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildMetricItem(
                Iconsax.activity,
                AmharicStringsDevelopment.activeIssues, // Translated
                activeCount,
                Colors.orange),
          ),
          Expanded(
            child: _buildMetricItem(
                Iconsax.star_1,
                AmharicStringsDevelopment.skills, // Translated
                skillsCount,
                kSkillColor),
          ),
          Expanded(
            child: _buildMetricItem(
                Iconsax.task_square,
                AmharicStringsDevelopment.completed, // Translated
                completedCount,
                kHabitColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: onSurfaceColor),
        ),
        Text(
          label, // Translated label
          style: GoogleFonts.notoSansEthiopic(
              fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Discipline', 'Skills', 'Background', 'Habits'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: SizedBox(
        height: 40,
        // Responsive: Horizontal ListView allows scrolling on small screens
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters.map((filter) {
            bool isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(_categoryTranslations[filter] ??
                    filter), // Translated label
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedFilter = filter);
                },
                backgroundColor: surfaceColor,
                selectedColor: accentColor,
                labelStyle: GoogleFonts.notoSansEthiopic(
                    color: isSelected ? Colors.white : onSurfaceColor,
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: isSelected ? accentColor : Colors.grey.shade300),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDevelopmentList(List<DevelopmentItem> items) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.folder_open, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                AmharicStringsDevelopment.noItemsFound, // Translated
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      // Ensure enough padding for the FAB
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeInUp(
              from: 20,
              delay: Duration(milliseconds: index * 50),
              child: _buildTrackingItemCard(items[index]),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildTrackingItemCard(DevelopmentItem item) {
    final color = _getCategoryColor(item.category);
    final lightColor = color.withValues(alpha: 0.1);
    final bool isCompleted = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kAdminCard,
        borderRadius: BorderRadius.circular(12),
        // Use color theme for border
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _categoryTranslations[item.category] ??
                        item.category, // Translated category
                    style: GoogleFonts.notoSansEthiopic(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                // Ethiopian Date format for clean display
                Text(
                  EthiopianDate.fromGregorian(item.date).toString(),
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                Iconsax.warning_2,
                '${AmharicStringsDevelopment.issue} / ${AmharicStringsDevelopment.issue}', // Translated
                item.issue),
            const Divider(height: 24, thickness: 0.5),
            _buildInfoRow(
                Iconsax.clipboard_text,
                '${AmharicStringsDevelopment.plan} / ${AmharicStringsDevelopment.plan}', // Translated
                item.plan),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddOrEditItemModal(item: item),
                  icon: Icon(Iconsax.edit, size: 16, color: accentColor),
                  label: Text(
                      '${AmharicStringsDevelopment.edit} / ${AmharicStringsDevelopment.edit}', // Translated
                      style: GoogleFonts.notoSansEthiopic(color: accentColor)),
                ),
                GestureDetector(
                  onTap: () => _toggleStatus(item),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? kHabitColor.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Iconsax.tick_square
                              : Iconsax.close_square,
                          color:
                              isCompleted ? kHabitColor : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted
                              ? AmharicStringsDevelopment
                                  .completedStatus // Translated
                              : AmharicStringsDevelopment
                                  .markAsDone, // Translated
                          style: GoogleFonts.notoSansEthiopic(
                            color: isCompleted
                                ? kHabitColor
                                : Colors.grey.shade800,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, // Translated header
                style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 14, color: onSurfaceColor, height: 1.5),
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- ADD/EDIT MODAL (Translated and Cleaned) ---
  void _showAddOrEditItemModal({DevelopmentItem? item}) {
    final formKey = GlobalKey<FormState>();
    final isEditing = item != null;

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
        builder: (BuildContext context, StateSetter setModalState) {
          Future<void> handleSave() async {
            if (!formKey.currentState!.validate()) return;

            final data = {
              'category': category,
              'issue': issueController.text,
              'plan': planController.text,
              'date': DateFormat('yyyy-MM-dd').format(selectedDate),
            };

            final result = isEditing
                ? await DevelopmentService.updateDevelopmentNote(
                    noteId: item.id.toString(), data: data)
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
                _showSnackbar(
                    result['message'] ?? 'ስህተት ተከስቷል።', // Translated error
                    isError: true);
              }
            }
          }

          Future<void> handleDelete() async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                    AmharicStringsDevelopment.confirmDeletion, // Translated
                    style: GoogleFonts.notoSansEthiopic()),
                content: Text(
                    AmharicStringsDevelopment.deleteConfirmation, // Translated
                    style: GoogleFonts.notoSansEthiopic()),
                actions: [
                  TextButton(
                      child:
                          Text(AmharicStringsDevelopment.cancel, // Translated
                              style: GoogleFonts.notoSansEthiopic()),
                      onPressed: () => Navigator.of(ctx).pop(false)),
                  TextButton(
                      child: Text(
                          AmharicStringsDevelopment.delete, // Translated
                          style:
                              GoogleFonts.notoSansEthiopic(color: Colors.red)),
                      onPressed: () => Navigator.of(ctx).pop(true)),
                ],
              ),
            );

            if (confirmed == true && item != null) {
              final result = await DevelopmentService.deleteDevelopmentNote(
                  item.id.toString());
              if (mounted) {
                if (result['success']) {
                  _showSnackbar(
                      AmharicStringsDevelopment
                          .noteDeletedSuccess, // Translated
                      isError: false);
                  Navigator.of(context).pop(); // Close the modal
                  _fetchDevelopmentNotes();
                } else {
                  _showSnackbar(
                      result['message'] ??
                          AmharicStringsDevelopment
                              .failedToDelete, // Translated
                      isError: true);
                }
              }
            }
          }

          return Padding(
            // Responsive: Padding for keyboard
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, left: 24, right: 24, bottom: 24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                // Responsive: SingleChildScrollView to ensure fields are visible
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 24),
                      Text(
                        isEditing
                            ? AmharicStringsDevelopment.editNote
                            : AmharicStringsDevelopment
                                .addNewNote, // Translated
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        hint: Text(
                            AmharicStringsDevelopment
                                .selectCategory, // Translated
                            style: GoogleFonts.notoSansEthiopic()),
                        items: ['Discipline', 'Skills', 'Background', 'Habits']
                            .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                    _categoryTranslations[cat] ??
                                        cat, // Translated options
                                    style: GoogleFonts.notoSansEthiopic())))
                            .toList(),
                        onChanged: (value) =>
                            setModalState(() => category = value),
                        validator: (value) => value == null
                            ? AmharicStringsDevelopment
                                .pleaseSelectCategory // Translated validation
                            : null,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12)),
                        style:
                            GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: issueController,
                        decoration: InputDecoration(
                            labelText:
                                '${AmharicStringsDevelopment.issue} / ${AmharicStringsDevelopment.issue}', // Translated label
                            labelStyle: GoogleFonts.notoSansEthiopic(),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12)),
                        maxLines: 3,
                        validator: (value) => (value?.isEmpty ?? true)
                            ? AmharicStringsDevelopment
                                .pleaseDescribeIssue // Translated validation
                            : null,
                        style: GoogleFonts.notoSansEthiopic(
                            color: kAdminOnSurface),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: planController,
                        decoration: InputDecoration(
                            labelText:
                                '${AmharicStringsDevelopment.plan} / ${AmharicStringsDevelopment.plan}', // Translated label
                            labelStyle: GoogleFonts.notoSansEthiopic(),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: kAdminPrimary, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12)),
                        maxLines: 3,
                        validator: (value) => (value?.isEmpty ?? true)
                            ? AmharicStringsDevelopment
                                .pleaseDescribePlan // Translated validation
                            : null,
                        style: GoogleFonts.notoSansEthiopic(
                            color: kAdminOnSurface),
                      ),
                      const SizedBox(height: 16),
                      // Ethiopian Date Picker Integration (Translated)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                            '${AmharicStringsDevelopment.date}: ${EthiopianDate.fromGregorian(selectedDate)}', // Translated
                            style: GoogleFonts.notoSansEthiopic(
                                color: kAdminOnSurface)),
                        trailing:
                            const Icon(Iconsax.calendar, color: kAdminPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
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
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (isEditing)
                            IconButton(
                              icon: const Icon(Iconsax.trash,
                                  color: kDisciplineColor),
                              onPressed: handleDelete,
                              tooltip: AmharicStringsDevelopment
                                  .delete, // Translated tooltip
                            ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: handleSave,
                            icon: const Icon(Iconsax.save_2,
                                color: kAdminPrimary),
                            label: Text(
                              isEditing
                                  ? AmharicStringsDevelopment.updateNote
                                  : AmharicStringsDevelopment
                                      .saveNote, // Translated
                              style: GoogleFonts.notoSansEthiopic(
                                  fontWeight: FontWeight.bold,
                                  color: kAdminPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAdminAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize:
                                  const Size(150, 48), // Responsive size
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
