import 'dart:ui'; // Required for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For built-in haptic feedback
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// --- API SERVICE (This should point to your existing API service file) ---
import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

/// Service class to handle API interactions for platform links.
class PlatformLinksService {
  static Future<Map<String, dynamic>> getLinks() async {
    try {
      final response = await ApiService.get('/platform-links');
      final body = json.decode(response.body);
      return body;
    } catch (e) {
      return {'success': false, 'message': 'የኔትወርክ ስህተት: $e'};
    }
  }

  static Future<Map<String, dynamic>> createLink(
      Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/platform-links', data);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'የኔትወርክ ስህተት: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateLink(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/platform-links/$id', data);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'የኔትወርክ ስህተት: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteLink(String id) async {
    try {
      final response = await ApiService.delete('/platform-links/$id');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'የኔትወርክ ስህተት: $e'};
    }
  }
}

// --- UI Theme Constants ---
// Replaced by dynamic theme provider
const Color accentColor = Color(0xFFFFD700);
const Color subtleTextColor = Color(0xFF6C757D);

// --- Data Model for Links ---
class PlatformLink {
  String id;
  String name;
  String url;
  String iconName;
  Color color;
  bool isSocialMedia;
  int displayOrder;

  PlatformLink({
    required this.id,
    required this.name,
    required this.url,
    required this.iconName,
    required this.color,
    this.isSocialMedia = false,
    this.displayOrder = 0,
  });

  factory PlatformLink.fromJson(Map<String, dynamic> json) {
    return PlatformLink(
      id: json['id'].toString(),
      name: json['name'],
      url: json['url'],
      iconName: json['icon_name'],
      color:
          Color(int.parse(json['color'].substring(1), radix: 16) + 0xFF000000),
      isSocialMedia: json['is_social_media'] == 1,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'icon_name': iconName,
      'color':
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'is_social_media': isSocialMedia,
      'display_order': displayOrder,
    };
  }
}

// =======================================================================
// --- MAIN PLATFORM & ADMIN HUB SCREEN WIDGET ---
// =======================================================================
class AmdePlatform extends StatefulWidget {
  const AmdePlatform({super.key});

  @override
  State<AmdePlatform> createState() => _AmdePlatformState();
}

class _AmdePlatformState extends State<AmdePlatform> {
  late Future<List<PlatformLink>> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = _fetchLinks();
  }

  Future<List<PlatformLink>> _fetchLinks() async {
    final result = await PlatformLinksService.getLinks();
    if (result['success'] == true && result['data'] != null) {
      final List<dynamic> linkData = result['data'];
      return linkData.map((json) => PlatformLink.fromJson(json)).toList();
    } else {
      throw Exception(result['message'] ?? 'ሊንኮችን መጫን አልተቻለም።');
    }
  }

  void _refreshLinks() {
    setState(() {
      _linksFuture = _fetchLinks();
    });
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _handleSaveLink(PlatformLink link) async {
    final isCreating = int.tryParse(link.id) == null;
    final result = isCreating
        ? await PlatformLinksService.createLink(link.toJson())
        : await PlatformLinksService.updateLink(link.id, link.toJson());

    if (result['success'] == true) {
      _refreshLinks();
    } else {
      _showErrorSnackBar(result['message'] ?? 'ሊንኩን ማስቀመጥ አልተቻለም።');
    }
  }

  Future<void> _handleDeleteLink(PlatformLink link) async {
    final result = await PlatformLinksService.deleteLink(link.id);
    if (result['success'] == true) {
      _refreshLinks();
    } else {
      _showErrorSnackBar(result['message'] ?? 'ሊንኩን መሰረዝ አልተቻለም።');
    }
  }

  void _showManageLinkSheet({PlatformLink? existingLink}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ManageLinkSheet(
          link: existingLink,
          onSave: (newLink) {
            Navigator.pop(context);
            _handleSaveLink(newLink);
          },
        ),
      ),
    );
  }

  void _confirmDeleteLink(PlatformLink link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ማረጋገጫ'),
        content: Text('"${link.name}" የተባለውን ሊንክ ለማጥፋት እርግጠኛ ነዎት?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ይቅር')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteLink(link);
            },
            child: const Text('አዎ, አጥፋ'),
          ),
        ],
      ),
    );
  }

  void _showAdminActions(PlatformLink link) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Iconsax.edit, color: primaryColor),
              title: const Text('አርትዕ'),
              onTap: () {
                Navigator.pop(context);
                _showManageLinkSheet(existingLink: link);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('አጥፋ', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteLink(link);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: FutureBuilder<List<PlatformLink>>(
          future: _linksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('ስህተት፦ ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _refreshLinks, child: const Text('እንደገና ሞክር')),
              ]));
            }

            final links = snapshot.data ?? [];
            links.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
            final platformLinks = links.where((l) => !l.isSocialMedia).toList();
            final socialLinks = links.where((l) => l.isSocialMedia).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: accentColor),
                  pinned: true,
                  expandedHeight: screenHeight * 0.3,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeroCard(),
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    centerTitle: false,
                    title: Text(
                      'የእኛ መድረኮች',
                      style: GoogleFonts.notoSansEthiopic(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? screenWidth * 0.1 : 20,
                    vertical: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildSection(
                            title: "ዋና መድረኮች",
                            icon: Iconsax.hierarchy_2,
                            links: platformLinks,
                            isAdmin: isSuperiorAdmin),
                        const SizedBox(height: 24),
                        _buildSection(
                            title: "ማህበራዊ ሚዲያ",
                            icon: Iconsax.share,
                            links: socialLinks,
                            isAdmin: isSuperiorAdmin),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: isSuperiorAdmin
          ? FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: FloatingActionButton(
                // FIX: Added a unique heroTag to prevent conflicts
                heroTag: 'add_new_platform_link_fab',
                onPressed: () => _showManageLinkSheet(),
                backgroundColor: primaryColor,
                foregroundColor: accentColor,
                tooltip: 'አዲስ ሊንክ ጨምር',
                child: const Icon(Iconsax.add),
              ),
            )
          : null,
    );
  }

  Widget _buildHeroCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF033177)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Icon(Iconsax.safe_home,
                size: 200, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.1),
                      border: Border.all(color: accentColor, width: 2),
                    ),
                    child: Icon(Iconsax.safe_home,
                        size: isTablet ? 50 : 40, color: accentColor),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text('አቅሌስያ',
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: isTablet ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text('ማህበራዊ ድረገጽና መገልገያ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: isTablet ? 18 : 16,
                            color: accentColor.withValues(alpha: 0.9)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<PlatformLink> links,
      required bool isAdmin}) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: onSurfaceColor.withValues(alpha: 0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(icon, color: primaryColor),
                    const SizedBox(width: 12),
                    Text(title,
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                  ]),
                  const Divider(height: 24),
                  if (links.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text('ምንም ሊንኮች አልተገኙም።',
                              style: TextStyle(color: subtleTextColor))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: links.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: _buildPlatformItem(links[index], isAdmin),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformItem(PlatformLink link, bool isAdmin) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(link.url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              // FIX: Wrapped icon in a Hero widget with a unique tag
              Hero(
                tag: 'platform_icon_${link.id}',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: link.color.withValues(alpha: 0.15)),
                  child: _getIconWidget(link.iconName,
                      color: link.color, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(link.name,
                    style: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.w600, color: onSurfaceColor)),
              ),
              if (isAdmin)
                IconButton(
                  icon: Icon(Iconsax.more, color: subtleTextColor),
                  onPressed: () => _showAdminActions(link),
                  tooltip: 'አማራጮች',
                )
              else
                Icon(Iconsax.arrow_right_3, size: 16, color: subtleTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ሊንኩን መክፈት አልተቻለም: $urlString')));
      }
    }
  }

  Widget _getIconWidget(String iconName, {required Color color, double? size}) {
    switch (iconName.toLowerCase()) {
      case 'googleplay':
        return FaIcon(FontAwesomeIcons.googlePlay, color: color, size: size);
      case 'facebook':
        return FaIcon(FontAwesomeIcons.facebookF, color: color, size: size);
      case 'telegram':
        return FaIcon(FontAwesomeIcons.telegram, color: color, size: size);
      case 'youtube':
        return FaIcon(FontAwesomeIcons.youtube, color: color, size: size);
      case 'tiktok':
        return FaIcon(FontAwesomeIcons.tiktok, color: color, size: size);
      case 'instagram':
        return FaIcon(FontAwesomeIcons.instagram, color: color, size: size);
      case 'book':
        return Icon(Iconsax.book_1, color: color, size: size);
      case 'globe':
        return Icon(Iconsax.global, color: color, size: size);
      default:
        return Icon(Iconsax.link, color: color, size: size);
    }
  }
}

// =======================================================================
// --- ADMIN MODAL WIDGET for Add/Edit ---
// =======================================================================

// Optimization: Made icon and color options static to avoid rebuilding.
class _ManageLinkSheetConstants {
  static final Map<String, Widget> iconOptions = {
    'globe': const Icon(Iconsax.global),
    'googleplay': const FaIcon(FontAwesomeIcons.googlePlay),
    'book': const Icon(Iconsax.book_1),
    'telegram': const FaIcon(FontAwesomeIcons.telegram),
    'youtube': const FaIcon(FontAwesomeIcons.youtube),
    'facebook': const FaIcon(FontAwesomeIcons.facebookF),
    'tiktok': const FaIcon(FontAwesomeIcons.tiktok),
    'instagram': const FaIcon(FontAwesomeIcons.instagram),
    'link': const Icon(Iconsax.link),
  };

  static final List<Color> colorOptions = [
    const Color(0xFF1A73E8), // Google Blue
    const Color(0xFF3DDC84), // Google Play Green
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF2AABEE), // Telegram Blue
    const Color(0xFFFF0000), // YouTube Red
    const Color(0xFF1877F2), // Facebook Blue
    const Color(0xFF010101), // TikTok Black
    const Color(0xFFE4405F), // Instagram Pink
    const Color(0xFFFD7E14), // Orange
    const Color(0xFF0DCAF0), // Cyan
    const Color(0xFF6F42C1), // Indigo
  ];
}

class ManageLinkSheet extends StatefulWidget {
  final PlatformLink? link;
  final Function(PlatformLink) onSave;

  const ManageLinkSheet({super.key, this.link, required this.onSave});

  @override
  State<ManageLinkSheet> createState() => _ManageLinkSheetState();
}

class _ManageLinkSheetState extends State<ManageLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late String _selectedIconName;
  late Color _selectedColor;
  late bool _isSocialMedia;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link?.name);
    _urlController = TextEditingController(text: widget.link?.url);
    _selectedIconName = widget.link?.iconName ?? 'link';
    _selectedColor =
        widget.link?.color ?? _ManageLinkSheetConstants.colorOptions[0];
    _isSocialMedia = widget.link?.isSocialMedia ?? false;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      final newLink = PlatformLink(
        id: widget.link?.id ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // Temp ID for creation
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        iconName: _selectedIconName,
        color: _selectedColor,
        isSocialMedia: _isSocialMedia,
      );
      widget.onSave(newLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
              color:
                  Provider.of<ThemeProvider>(context).getSurfaceColor(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                  const SizedBox(height: 20),
                  Text(
                    widget.link == null ? 'አዲስ ሊንክ ጨምር' : 'ሊንክ አርትዕ',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<ThemeProvider>(context)
                            .getOnSurfaceColor(context)),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'ስም', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'ስም ማስገባት ያስፈልጋል' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                        labelText: 'ሊንክ (URL)', border: OutlineInputBorder()),
                    validator: (v) {
                      if (v!.isEmpty) return 'ሊንክ ማስገባት ያስፈልጋል';
                      if (!Uri.tryParse(v)!.isAbsolute) return 'የተሳሳተ ሊንክ ነው';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('አይከን',
                      style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  // RESPONSIVE: Changed to Wrap for better responsiveness
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        _ManageLinkSheetConstants.iconOptions.keys.map((key) {
                      final isSelected = _selectedIconName == key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIconName = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Provider.of<ThemeProvider>(context)
                                    .getPrimaryColor(context)
                                : Provider.of<ThemeProvider>(context)
                                    .getSurfaceColor(context)
                                    .withValues(alpha: 0.5),
                            border: isSelected
                                ? Border.all(color: accentColor, width: 2)
                                : null,
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                                color: isSelected
                                    ? accentColor
                                    : Colors.grey[600]),
                            child: Center(
                                child:
                                    _ManageLinkSheetConstants.iconOptions[key]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('ቀለም',
                      style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  // RESPONSIVE: Changed to a horizontally scrolling list, which is fine, but could also be a Wrap. This is okay.
                  SizedBox(
                    height: 45,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _ManageLinkSheetConstants.colorOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final color =
                            _ManageLinkSheetConstants.colorOptions[index];
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 45,
                            decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('የማህበራዊ ሚዲያ ሊንክ ነው?'),
                    value: _isSocialMedia,
                    onChanged: (val) => setState(() => _isSocialMedia = val),
                    activeThumbColor: Provider.of<ThemeProvider>(context)
                        .getPrimaryColor(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Iconsax.save_2),
                      label: const Text('አስቀምጥ'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
