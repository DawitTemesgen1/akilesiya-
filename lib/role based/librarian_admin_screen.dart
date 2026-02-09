import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import '../services/librarian_admin_service.dart';

// --- ሞዴሎች ---
class LibraryRoleUser {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  bool isLibrarian;
  bool isLibraryAdmin;

  LibraryRoleUser({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    required this.isLibrarian,
    required this.isLibraryAdmin,
  });

  factory LibraryRoleUser.fromJson(Map<String, dynamic> json) {
    return LibraryRoleUser(
      id: json['id'],
      fullName: json['fullName'] ?? 'ስም የለም', // ተተርጉሟል
      profileImageUrl: json['profileImageUrl'],
      isLibrarian: json['isLibrarian'] ?? false,
      isLibraryAdmin: json['isLibraryAdmin'] ?? false,
    );
  }
}

// --- ዋናው የማያ ገጽ መግብር ---
class LibrarianAdminScreen extends StatefulWidget {
  const LibrarianAdminScreen({super.key});

  @override
  State<LibrarianAdminScreen> createState() => _LibrarianAdminScreenState();
}

class _LibrarianAdminScreenState extends State<LibrarianAdminScreen> {
  late Future<List<LibraryRoleUser>> _usersFuture;
  final Map<String, bool> _loadingStates = {}; // ለእያንዳንዱ ተጠቃሚ የመጫኛ ሁኔታን ለመከታተል

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);
  Color get accentColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<LibraryRoleUser>> _fetchUsers() async {
    final result = await LibrarianAdminService.getUsersWithLibraryRoles();
    if (mounted && result['success']) {
      return (result['data'] as List)
          .map((userData) => LibraryRoleUser.fromJson(userData))
          .toList();
    } else {
      throw Exception(result['message'] ?? 'ተጠቃሚዎችን ማምጣት አልተቻለም።'); // ተተርጉሟል
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  Future<void> _updateUserRoles(LibraryRoleUser user) async {
    setState(() => _loadingStates[user.id] = true);

    final result = await LibrarianAdminService.updateUserLibraryRoles(
      userId: user.id,
      isLibrarian: user.isLibrarian,
      isLibraryAdmin: user.isLibraryAdmin,
    );

    if (mounted) {
      _showSnackbar(result['message'] ?? 'ተፈጽሟል።', // ተተርጉሟል
          isError: !result['success']);
    }

    setState(() => _loadingStates[user.id] = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          'የቤተ-መጽሐፍት አስተዳዳሪዎችን ያቀናብሩ', // ተተርጉሟል
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: onSurfaceColor),
        ),
        backgroundColor: primaryColor,
        elevation: 1,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: FutureBuilder<List<LibraryRoleUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'ስህተት፦ ${snapshot.error}', // ተተርጉሟል
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ምንም ተጠቃሚዎች አልተገኙም።')); // ተተርጉሟል
          }

          final users = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () {
              setState(() {
                _usersFuture = _fetchUsers();
              });
              return _usersFuture;
            },
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isLoading = _loadingStates[user.id] ?? false;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  color: surfaceColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.profileImageUrl != null &&
                                      user.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(
                                      '${ApiService.baseUrl}/${user.profileImageUrl!}')
                                  : null,
                              child: user.profileImageUrl == null ||
                                      user.profileImageUrl!.isEmpty
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0]
                                          : '?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: onSurfaceColor),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user.fullName,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: onSurfaceColor),
                              ),
                            ),
                            if (isLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                          ],
                        ),
                        const Divider(height: 20),
                        SwitchListTile(
                          title: Text('የቤተ-መጽሐፍት ባለሙያ', // ተተርጉሟል
                              style: TextStyle(color: onSurfaceColor)),
                          subtitle:
                              Text('የንባብ ታሪክ እና ስታቲስቲክስ ማየት ይችላል።', // ተተርጉሟል
                                  style: TextStyle(color: subtleTextColor)),
                          secondary: Icon(Iconsax.book, color: accentColor),
                          value: user.isLibrarian,
                          activeThumbColor: accentColor,
                          onChanged: isLoading
                              ? null
                              : (newValue) {
                                  setState(() => user.isLibrarian = newValue);
                                  _updateUserRoles(user);
                                },
                        ),
                        SwitchListTile(
                          title: Text('የቤተ-መጽሐፍት አስተዳዳሪ', // ተተርጉሟል
                              style: TextStyle(color: onSurfaceColor)),
                          subtitle: Text('ለአንባቢዎች መጽሐፍትን መመደብ ይችላል።', // ተተርጉሟል
                              style: TextStyle(color: subtleTextColor)),
                          secondary: Icon(Iconsax.user_add, color: accentColor),
                          value: user.isLibraryAdmin,
                          activeThumbColor: accentColor,
                          onChanged: isLoading
                              ? null
                              : (newValue) {
                                  setState(
                                      () => user.isLibraryAdmin = newValue);
                                  _updateUserRoles(user);
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
