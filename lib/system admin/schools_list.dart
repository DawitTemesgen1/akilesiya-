import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/create_school.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/school_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SchoolsListScreen extends StatefulWidget {
  const SchoolsListScreen({super.key});

  @override
  State<SchoolsListScreen> createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  List<dynamic> _schools = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredSchools = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getSchools();
    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _schools = result['data']['schools'];
          _filteredSchools = _schools;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredSchools = _schools
          .where((school) =>
              school['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              school['email']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'Sunday Schools',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            primaryColor.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.1),
                          ]
                        : [
                            primaryColor.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.5),
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Iconsax.refresh, color: primaryColor),
                onPressed: _loadSchools,
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: _buildSearchBar(context, isDark),
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'All Registered Schools (${_filteredSchools.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Schools List
          _isLoading
              ? SliverToBoxAdapter(child: _buildShimmerList(isDark))
              : _filteredSchools.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.teacher,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'ምንም ትምህርት ቤት አልተገኘም',
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return FadeInUp(
                              duration:
                                  Duration(milliseconds: 400 + (index * 50)),
                              child: _buildSchoolCard(
                                  _filteredSchools[index], isDark),
                            );
                          },
                          childCount: _filteredSchools.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateSchoolScreen()),
        ).then((_) => _loadSchools()),
        backgroundColor: primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          'አዲስ ትምህርት ቤት',
          style: GoogleFonts.notoSansEthiopic(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search schools by name or email...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Iconsax.search_normal,
              color: Theme.of(context).primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSchoolCard(Map<String, dynamic> school, bool isDark) {
    final statusColor =
        (school['is_active'] == 1 || school['is_active'] == true)
            ? Colors.green
            : Colors.red;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolDetailScreen(schoolId: school['id']),
            ),
          ).then((_) => _loadSchools()),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Functional School Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: primaryColor.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: school['logo_url'] != null &&
                            school['logo_url'].toString().isNotEmpty
                        ? Image.network(
                            school['logo_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildLogoPlaceholder(school['name']),
                          )
                        : _buildLogoPlaceholder(school['name']),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school['name'] ?? 'Untitled School',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        school['email'] ?? 'No email provided',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (school['is_active'] == 1 ||
                                          school['is_active'] == true)
                                      ? 'Active'
                                      : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Iconsax.user, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${school['member_count'] ?? 0} Members',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, size: 20, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String? name) {
    return Center(
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: List.generate(
          5,
          (index) => Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[900]! : Colors.grey[200]!,
            highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
