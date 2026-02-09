// lib/screens/family/family_view_screen.dart (or your file path)

import 'package:amde_haymanot_abalat_guday/role%20based/family_detail.dart';
import 'package:amde_haymanot_abalat_guday/services/family_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';

// Import the detail screen to navigate to it

import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// --- UI Theme Constants ---
// Replaced by ThemeProvider
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFDC3545);

// --- Model ---
class LinkedStudent {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final String? spiritualClass;
  final double overallGrade;
  final double attendancePercentage;
  final bool isSelectedForService;

  LinkedStudent({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    this.spiritualClass,
    required this.overallGrade,
    required this.attendancePercentage,
    required this.isSelectedForService,
  });

  // ======================= THE FIX =======================
  // This factory now safely handles numbers that arrive as strings.
  factory LinkedStudent.fromJson(Map<String, dynamic> json) {
    return LinkedStudent(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? 'No Name',
      profileImageUrl: json['profile_image_url'],
      spiritualClass: json['spiritual_class'],
      // Use double.tryParse to handle both "88.5" and 88.5 safely.
      overallGrade:
          double.tryParse(json['overallGrade']?.toString() ?? '0.0') ?? 0.0,
      attendancePercentage:
          double.tryParse(json['attendancePercentage']?.toString() ?? '0.0') ??
              0.0,
      isSelectedForService: json['isSelectedForService'] == 1 ||
          json['isSelectedForService'] == true,
    );
  }
  // =======================================================
}

// #########################################################################
// SCREEN: FamilyViewScreen (Fully connected)
// #########################################################################

class FamilyViewScreen extends StatefulWidget {
  const FamilyViewScreen({super.key});

  @override
  State<FamilyViewScreen> createState() => _FamilyViewScreenState();
}

class _FamilyViewScreenState extends State<FamilyViewScreen> {
  late Future<List<LinkedStudent>> _linkedStudentsFuture;

  Future<List<LinkedStudent>> _fetchLinkedStudents() async {
    final result = await FamilyService.getLinkedStudents();
    if (mounted && result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => LinkedStudent.fromJson(json)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to load linked students');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _linkedStudentsFuture = _fetchLinkedStudents();
    });
    await _linkedStudentsFuture;
  }

  @override
  void initState() {
    super.initState();
    _linkedStudentsFuture = _fetchLinkedStudents();
    super.initState();
    _linkedStudentsFuture = _fetchLinkedStudents();
  }

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("የቤተሰብ ክትትል",
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold, color: onSurfaceColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        backgroundColor: surfaceColor,
        color: primaryColor,
        child: FutureBuilder<List<LinkedStudent>>(
          future: _linkedStudentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingShimmer();
            }
            if (snapshot.hasError) {
              return _ErrorDisplay(
                  error: snapshot.error.toString(), onRetry: _handleRefresh);
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _EmptyState(onRefresh: _handleRefresh);
            }

            final students = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  from: 30,
                  delay: Duration(milliseconds: 150 * index),
                  duration: const Duration(milliseconds: 500),
                  child: _StudentDashboardCard(student: students[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StudentDashboardCard extends StatelessWidget {
  final LinkedStudent student;
  const _StudentDashboardCard({required this.student});

  Color _getGradeColor(double grade) {
    if (grade >= 85) return successColor;
    if (grade >= 50) return warningColor;
    return dangerColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyMemberDetailScreen(
                studentId: student.id, studentName: student.fullName),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: Provider.of<ThemeProvider>(context).getSurfaceColor(context),
        shadowColor: Provider.of<ThemeProvider>(context)
            .getPrimaryColor(context)
            .withValues(alpha: 0.1),
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Provider.of<ThemeProvider>(context)
                        .getPrimaryColor(context),
                    child: CircleAvatar(
                      radius: 29,
                      backgroundImage: student.profileImageUrl != null
                          ? NetworkImage(student.profileImageUrl!)
                          : null,
                      child: student.profileImageUrl == null
                          ? Text(
                              student.fullName.isNotEmpty
                                  ? student.fullName[0]
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.fullName,
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context)
                                    .getOnSurfaceColor(context))),
                        const SizedBox(height: 4),
                        Text('መንፈሳዊ ክፍል: ${student.spiritualClass ?? "N/A"}',
                            style: GoogleFonts.notoSansEthiopic(
                                color: Provider.of<ThemeProvider>(context)
                                    .getSubtleTextColor(context),
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildGradeIndicator(student.overallGrade, context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttendanceIndicator(
                            student.attendancePercentage, context),
                        _buildServiceStatus(
                            student.isSelectedForService, context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeIndicator(double grade, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Overall Grade',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Provider.of<ThemeProvider>(context)
                    .getOnSurfaceColor(context))),
        Text('${grade.toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _getGradeColor(grade))),
      ]),
      const SizedBox(height: 8),
      LinearPercentIndicator(
          percent: grade / 100,
          lineHeight: 10,
          barRadius: const Radius.circular(5),
          progressColor: _getGradeColor(grade),
          backgroundColor: _getGradeColor(grade).withValues(alpha: 0.2),
          animation: true),
    ]);
  }

  Widget _buildAttendanceIndicator(double percentage, BuildContext context) {
    return Column(children: [
      CircularPercentIndicator(
          radius: 35.0,
          lineWidth: 8.0,
          percent: percentage / 100,
          center: Text('${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Provider.of<ThemeProvider>(context)
                      .getOnSurfaceColor(context))),
          progressColor:
              Provider.of<ThemeProvider>(context).getPrimaryColor(context),
          backgroundColor: Provider.of<ThemeProvider>(context)
              .getPrimaryColor(context)
              .withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true),
      const SizedBox(height: 8),
      Text('Attendance',
          style: GoogleFonts.poppins(
              color: Provider.of<ThemeProvider>(context)
                  .getSubtleTextColor(context))),
    ]);
  }

  Widget _buildServiceStatus(bool isSelected, BuildContext context) {
    return Column(children: [
      Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (isSelected ? successColor : warningColor).withValues(alpha: 0.1)),
          child: Icon(
              isSelected ? Iconsax.calendar_tick : Iconsax.calendar_remove,
              color: isSelected ? successColor : warningColor,
              size: 35)),
      const SizedBox(height: 8),
      Text(isSelected ? 'On Service' : 'Not on Duty',
          style: GoogleFonts.poppins(
              color: Provider.of<ThemeProvider>(context)
                  .getSubtleTextColor(context))),
    ]);
  }
}

// --- Helper Widgets for Loading, Error, and Empty States ---

class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: List.generate(
          3,
          (index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 230,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context)
                        .getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorDisplay({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, color: dangerColor, size: 60),
            const SizedBox(height: 16),
            Text("Something Went Wrong",
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(context)
                        .getOnSurfaceColor(context))),
            const SizedBox(height: 8),
            Text(error.replaceAll("Exception: ", ""),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Provider.of<ThemeProvider>(context)
                        .getSubtleTextColor(context),
                    fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Provider.of<ThemeProvider>(context)
                    .getPrimaryColor(context),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.user_search,
                      color: kSubtleTextColor, size: 60),
                  const SizedBox(height: 16),
                  Text("No Linked Students",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Provider.of<ThemeProvider>(context)
                              .getOnSurfaceColor(context))),
                  const SizedBox(height: 8),
                  Text(
                    "You don't have any students linked to your account yet. Please contact a school administrator to get set up.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Provider.of<ThemeProvider>(context)
                            .getSubtleTextColor(context),
                        fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                      onPressed: onRefresh, child: const Text("Refresh")),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
