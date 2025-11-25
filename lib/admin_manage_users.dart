// // lib/admin_only/admin_manage_users.dart

// import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:developer' as developer;

// // --- UI Theme Constants ---
// const Color kAdminBackgroundColor = Color.fromARGB(255, 1, 37, 100);
// const Color kAdminCardColor = Color.fromARGB(255, 4, 48, 122);
// const Color kAdminPrimaryAccent = Color(0xFFFFD700);
// const Color kAdminSecondaryText = Color(0xFFB0C4DE);

// class UnifiedAdminScreen extends StatefulWidget {
//   const UnifiedAdminScreen({super.key});

//   @override
//   State<UnifiedAdminScreen> createState() => _UnifiedAdminScreenState();
// }

// class _UnifiedAdminScreenState extends State<UnifiedAdminScreen> {
//   bool _isLoading = true;
//   String? _loadingError;

//   String? _selectedUserId;
//   Map<String, dynamic>? _selectedUserData;

//   final _searchController = TextEditingController();
//   List<Map<String, dynamic>> _allUsers = [];
//   List<Map<String, dynamic>> _filteredUsers = [];

//   bool _isActionInProgress = false;

//   // --- Controllers for Form Fields ---
//   final _fullNameController = TextEditingController();
//   String? _roleValue;

//   // --- Dropdown Options (Constants) ---
//   static const List<String> _roleOptions = ['user', 'admin', 'superior_admin'];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserList();
//     _searchController.addListener(_filterUsers);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _fullNameController.dispose();
//     super.dispose();
//   }

//   // --- API-Connected Functions ---

//   Future<void> _fetchUserList() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _loadingError = null;
//     });

//     final result = await AdminService.getAllUsers();

//     if (!mounted) return;

//     if (result['success']) {
//       setState(() {
//         _allUsers = List<Map<String, dynamic>>.from(result['data']);
//         _filteredUsers = _allUsers;
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _loadingError = result['message'];
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (_selectedUserData == null || _selectedUserId == null) return;
//     setState(() => _isActionInProgress = true);

//     final updatedData = {
//       'full_name': _fullNameController.text.trim(),
//       'role': _roleValue,
//     };

//     final result = await AdminService.updateUser(_selectedUserId!, updatedData);

//     if (mounted) {
//       if (result['success']) {
//         _showSnackbar('User updated successfully.', isError: false);
//         _clearSelection();
//         await _fetchUserList(); // Refresh list to show changes
//       } else {
//         _showSnackbar(result['message'], isError: true);
//       }
//       setState(() => _isActionInProgress = false);
//     }
//   }

//   // --- UI Helper Functions ---

//   void _filterUsers() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredUsers = _allUsers.where((user) {
//         final name = user['full_name']?.toString().toLowerCase() ?? '';
//         final email = user['email']?.toString().toLowerCase() ?? '';
//         return name.contains(query) || email.contains(query);
//       }).toList();
//     });
//   }

//   void _selectUserForEditing(Map<String, dynamic> user) {
//     setState(() {
//       _selectedUserId = user['id'];
//       _selectedUserData = Map<String, dynamic>.from(user);
//       _populateFormWithUserData(_selectedUserData!);
//     });
//   }

//   void _clearSelection() {
//     setState(() {
//       _selectedUserId = null;
//       _selectedUserData = null;
//     });
//   }

//   void _populateFormWithUserData(Map<String, dynamic> user) {
//     _fullNameController.text = user['full_name'] ?? '';
//     _roleValue = _roleOptions.contains(user['role']) ? user['role'] : 'user';
//   }

//   void _showSnackbar(String message, {bool isError = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.redAccent : Colors.green,
//       ));
//     }
//   }

//   // --- Build Methods ---

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kAdminBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kAdminBackgroundColor,
//         elevation: 0,
//         leading: _selectedUserId != null
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new),
//                 onPressed: _clearSelection)
//             : null,
//         title: Text(
//             _selectedUserId == null
//                 ? 'Manage Users'
//                 : (_selectedUserData?['full_name'] ?? 'Edit User'),
//             style: GoogleFonts.notoSansEthiopic()),
//         actions: [
//           if (_selectedUserId == null)
//             IconButton(
//                 icon: const Icon(Icons.refresh),
//                 onPressed: _isLoading ? null : _fetchUserList),
//         ],
//       ),
//       body: Stack(
//         children: [
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: _selectedUserId == null
//                 ? _buildUserList()
//                 : _buildUserEditorForm(),
//           ),
//           if (_isActionInProgress)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                   child: CircularProgressIndicator(color: kAdminPrimaryAccent)),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserList() {
//     if (_isLoading) {
//       return const Center(
//           child: CircularProgressIndicator(color: kAdminPrimaryAccent));
//     }
//     if (_loadingError != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             "Error: $_loadingError\nPlease try again.",
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.redAccent),
//           ),
//         ),
//       );
//     }

//     return Column(
//       key: const ValueKey('user-list-view'),
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             controller: _searchController,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: 'Search users by name or email...',
//               hintStyle: TextStyle(color: kAdminSecondaryText.withOpacity(0.7)),
//               prefixIcon: const Icon(Icons.search, color: kAdminSecondaryText),
//               filled: true,
//               fillColor: kAdminCardColor,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none),
//             ),
//           ),
//         ),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _fetchUserList,
//             child: _filteredUsers.isEmpty
//                 ? const Center(
//                     child: Text("No users found.",
//                         style: TextStyle(color: kAdminSecondaryText)))
//                 : ListView.builder(
//                     itemCount: _filteredUsers.length,
//                     itemBuilder: (context, index) {
//                       final user = _filteredUsers[index];
//                       final role = user['role'] ?? 'user';
//                       final imageUrl = user['profile_image_url'];
//                       final hasImage = imageUrl != null && imageUrl.isNotEmpty;
//                       return Card(
//                         color: kAdminCardColor,
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 6),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundImage:
//                                 hasImage ? NetworkImage(imageUrl) : null,
//                             child: !hasImage
//                                 ? Text(user['full_name']?[0] ?? '?')
//                                 : null,
//                           ),
//                           title: Text(user['full_name'] ?? 'No Name',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                           subtitle: Text(user['email'] ?? 'No Email',
//                               style:
//                                   const TextStyle(color: kAdminSecondaryText)),
//                           trailing: Chip(
//                             label: Text(role,
//                                 style: const TextStyle(
//                                     fontSize: 10, color: Colors.black87)),
//                             backgroundColor: role == 'superior_admin'
//                                 ? Colors.red.shade300
//                                 : role == 'admin'
//                                     ? Colors.orange.shade300
//                                     : Colors.blue.shade300,
//                           ),
//                           onTap: () => _selectUserForEditing(user),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserEditorForm() {
//     if (_selectedUserData == null) {
//       return const SizedBox.shrink(key: ValueKey('empty-editor'));
//     }

//     return Scaffold(
//       backgroundColor: Colors.transparent, // Important for the parent Stack
//       // Use a transparent app bar to avoid layout shifts
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false, // Back button is handled by parent
//         toolbarHeight: 0,
//       ),
//       body: SingleChildScrollView(
//         key: ValueKey(_selectedUserId),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTextField(_fullNameController, 'Full Name'),
//             const SizedBox(height: 16),
//             _buildDropdown(_roleValue, _roleOptions,
//                 (val) => setState(() => _roleValue = val), 'User Role'),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _isActionInProgress ? null : _saveChanges,
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kAdminPrimaryAccent,
//                   foregroundColor: kAdminBackgroundColor,
//                   minimumSize: const Size(double.infinity, 50)),
//               child: const Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label,
//       {TextInputType? keyboardType}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: kAdminSecondaryText),
//           filled: true,
//           fillColor: kAdminCardColor,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//         ),
//         keyboardType: keyboardType,
//       ),
//     );
//   }

//   Widget _buildDropdown(String? value, List<String> items,
//       ValueChanged<String?> onChanged, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         items: items
//             .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//             .toList(),
//         onChanged: onChanged,
//         style: const TextStyle(color: Colors.white),
//         dropdownColor: kAdminCardColor,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: kAdminSecondaryText),
//           filled: true,
//           fillColor: kAdminCardColor,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none),
//         ),
//       ),
//     );
//   }
// }
