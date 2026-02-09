// // lib/users screen/book_review.dart

// import 'dart:convert';
// import 'dart:developer';
// import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
// import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
// import 'package:amde_haymanot_abalat_guday/services/book_service.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// //==============================================================================
// // --- THEME & CONFIGURATION ---
// //==============================================================================
// const Color kPrimaryColor = Color(0xFF1B263B);
// const Color kAccentColor = Color(0xFFE0A83F);
// const Color kSurfaceColor = Color(0xFFF7F7F7);
// const Color kOnSurfaceColor = Color(0xFF0D1B2A);
// const Color kCardColor = Colors.white;
// const Color kDangerColor = Color(0xFFDC3545);

// //==============================================================================
// // --- BOOK LIBRARY SCREEN ---
// //==============================================================================

// class BookLibraryScreen extends StatefulWidget {
//   const BookLibraryScreen({super.key});
//   @override
//   State<BookLibraryScreen> createState() => _BookLibraryScreenState();
// }

// class _BookLibraryScreenState extends State<BookLibraryScreen> {
//   late Future<List<Book>> _booksFuture;
//   List<Book> _allBooks = [];
//   List<Book> _filteredBooks = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _booksFuture = _fetchBooks();
//     _searchController.addListener(_runFilter);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<Book>> _fetchBooks() async {
//     try {
//       final books = await BookService.getBooks();
//       if (mounted) {
//         setState(() {
//           _allBooks = books;
//           _filteredBooks = books;
//         });
//       }
//       return books;
//     } catch (e, stackTrace) {
//       log("--- ERROR FETCHING BOOKS ---");
//       log("Error: $e");
//       log("Stack Trace: $stackTrace");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Error: ${e.toString().replaceAll("Exception: ", "")}"),
//           backgroundColor: Colors.red,
//         ));
//       }
//       throw Exception("Failed to load books. Check debug console for details.");
//     }
//   }

//   Future<void> _handleRefresh() async {
//     setState(() {
//       _booksFuture = _fetchBooks();
//     });
//     await _booksFuture;
//   }

//   void _runFilter() {
//     final query = _searchController.text;
//     final results = query.isEmpty
//         ? _allBooks
//         : _allBooks.where((book) {
//             final titleMatch =
//                 book.title.toLowerCase().contains(query.toLowerCase());
//             final authorMatch =
//                 book.author.toLowerCase().contains(query.toLowerCase());
//             return titleMatch || authorMatch;
//           }).toList();
//     setState(() => _filteredBooks = results);
//   }

//   void _showAddBookDialog() {
//     final formKey = GlobalKey<FormState>();
//     final titleController = TextEditingController();
//     final authorController = TextEditingController();
//     final coverUrlController = TextEditingController();
//     final descriptionController = TextEditingController();
//     final ratingController = TextEditingController();
//     final genresController = TextEditingController();
//     final pullQuoteController = TextEditingController();
//     final fullReviewController = TextEditingController();
//     final perfectForController = TextEditingController();
//     bool isFeatured = false;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Add New Master Book"),
//         content: Form(
//           key: formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                     controller: titleController,
//                     decoration: const InputDecoration(labelText: "Book Title*"),
//                     validator: (v) => v!.isEmpty ? 'Required' : null),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: authorController,
//                     decoration: const InputDecoration(labelText: "Author*"),
//                     validator: (v) => v!.isEmpty ? 'Required' : null),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: coverUrlController,
//                     decoration:
//                         const InputDecoration(labelText: "Cover Image URL*"),
//                     validator: (v) => v!.isEmpty ? 'Required' : null),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: descriptionController,
//                     decoration:
//                         const InputDecoration(labelText: "Description*"),
//                     maxLines: 3,
//                     validator: (v) => v!.isEmpty ? 'Required' : null),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: ratingController,
//                     decoration:
//                         const InputDecoration(labelText: "Rating (e.g., 4.5)"),
//                     keyboardType: TextInputType.number),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: genresController,
//                     decoration: const InputDecoration(
//                         labelText: "Genres (comma-separated)")),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: pullQuoteController,
//                     decoration: const InputDecoration(labelText: "Pull Quote"),
//                     maxLines: 2),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: fullReviewController,
//                     decoration: const InputDecoration(labelText: "Full Review"),
//                     maxLines: 4),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                     controller: perfectForController,
//                     decoration: const InputDecoration(
//                         labelText: "Perfect For (comma-separated)")),
//                 StatefulBuilder(builder: (context, setDialogState) {
//                   return SwitchListTile(
//                     title: const Text("Featured (Editor's Pick)"),
//                     value: isFeatured,
//                     onChanged: (val) => setDialogState(() => isFeatured = val),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 final result = await BookService.createMasterBook({
//                   'title': titleController.text,
//                   'author': authorController.text,
//                   'cover_url': coverUrlController.text,
//                   'description': descriptionController.text,
//                   'rating': double.tryParse(ratingController.text) ?? 0.0,
//                   'genres': jsonEncode(genresController.text
//                       .split(',')
//                       .map((e) => e.trim())
//                       .where((s) => s.isNotEmpty)
//                       .toList()),
//                   'is_featured': isFeatured,
//                   'pull_quote': pullQuoteController.text,
//                   'full_review': fullReviewController.text,
//                   'perfect_for': jsonEncode(perfectForController.text
//                       .split(',')
//                       .map((e) => e.trim())
//                       .where((s) => s.isNotEmpty)
//                       .toList()),
//                 });

//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text(result['message'] ?? '...'),
//                       backgroundColor:
//                           result['success'] ? Colors.green : Colors.red));
//                   if (result['success']) {
//                     Navigator.pop(context);
//                     _handleRefresh();
//                   }
//                 }
//               }
//             },
//             child: const Text("Create Book"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = context.watch<UserProvider>();
//     final isSuperiorAdmin = userProvider.roles.contains('superior_admin');

//     return Scaffold(
//       backgroundColor: kSurfaceColor,
//       floatingActionButton: isSuperiorAdmin
//           ? FloatingActionButton(
//               heroTag: 'add-master-book-fab',
//               onPressed: _showAddBookDialog,
//               backgroundColor: kPrimaryColor,
//               child: const Icon(Iconsax.box_add, color: kAccentColor),
//               tooltip: 'Add New Book to Library',
//             )
//           : null,
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: FutureBuilder<List<Book>>(
//           future: _booksFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                   child: CircularProgressIndicator(color: kPrimaryColor));
//             }
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text("Error loading library. Check debug console.",
//                       style: GoogleFonts.poppins()));
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                   child: Text("No books have been assigned yet.",
//                       style: GoogleFonts.poppins()));
//             }

//             return CustomScrollView(
//               slivers: [
//                 SliverAppBar(
//                   title: Text('መጽሐፍ ቤት',
//                       style: GoogleFonts.notoSansEthiopic(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                           color: Colors.white)),
//                   backgroundColor: kPrimaryColor,
//                   floating: true,
//                   pinned: true,
//                   elevation: 4,
//                 ),
//                 _buildSearchHeader(),
//                 _buildSectionHeader("የአርታኢ ምርጦች", Iconsax.crown_1),
//                 _buildFeaturedCarousel(),
//                 _buildSectionHeader("ሁሉንም ያስሱ", Iconsax.category),
//                 _buildBookGrid(),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchHeader() {
//     return SliverToBoxAdapter(
//       child: FadeInDown(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: TextField(
//             controller: _searchController,
//             style: const TextStyle(color: kOnSurfaceColor),
//             onChanged: (q) => _runFilter(),
//             decoration: InputDecoration(
//               hintText: 'መጽሐፍ ወይም ደራሲ ይፈልጉ...',
//               hintStyle:
//                   GoogleFonts.notoSansEthiopic(color: Colors.grey.shade600),
//               prefixIcon: Container(
//                   margin: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       color: kAccentColor.withValues(alpha: 0.1),
//                       shape: BoxShape.circle),
//                   child:
//                       const Icon(Iconsax.search_normal, color: kAccentColor)),
//               filled: true,
//               fillColor: kCardColor,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none),
//               contentPadding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return SliverToBoxAdapter(
//       child: FadeInLeft(
//         delay: const Duration(milliseconds: 200),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             children: [
//               Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       color: kAccentColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Icon(icon, color: kAccentColor, size: 24)),
//               const SizedBox(width: 12),
//               Text(title,
//                   style: GoogleFonts.notoSansEthiopic(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: kOnSurfaceColor)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeaturedCarousel() {
//     final featuredBooks = _allBooks.where((b) => b.isFeatured).toList();
//     if (featuredBooks.isEmpty)
//       return const SliverToBoxAdapter(child: SizedBox.shrink());
//     return SliverToBoxAdapter(
//       child: SizedBox(
//         height: 280,
//         child: _FeaturedCarousel(featuredBooks: featuredBooks),
//       ),
//     );
//   }

//   Widget _buildBookGrid() {
//     if (_filteredBooks.isEmpty) {
//       return SliverFillRemaining(
//         child: Center(
//           child: FadeIn(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Iconsax.search_zoom_out,
//                     size: 64, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 Text('ከፍለጋዎ ጋር የሚዛመድ መጽሐፍ የለም',
//                     style: GoogleFonts.notoSansEthiopic(
//                         color: Colors.grey.shade600, fontSize: 16)),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return SliverPadding(
//       padding: const EdgeInsets.all(16),
//       sliver: SliverGrid(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 20,
//             crossAxisSpacing: 20,
//             childAspectRatio: 0.75),
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             final book = _filteredBooks[index];
//             return FadeInUp(
//                 from: 20,
//                 delay: Duration(milliseconds: index * 50),
//                 child: _BookGridItem(book: book));
//           },
//           childCount: _filteredBooks.length,
//         ),
//       ),
//     );
//   }
// }

// //==============================================================================
// // --- BOOK DETAIL SCREEN & ITS COMPONENTS ---
// //==============================================================================
// // The rest of the file (BookDetailScreen and its helpers) remains unchanged from the correct previous version.
// // ... (All code from BookDetailScreen downwards is included here)
// class BookDetailScreen extends StatefulWidget {
//   final Book book;
//   final String heroTag;
//   const BookDetailScreen(
//       {super.key, required this.book, required this.heroTag});

//   @override
//   State<BookDetailScreen> createState() => _BookDetailScreenState();
// }

// class _BookDetailScreenState extends State<BookDetailScreen> {
//   late Book _book;
//   final TextEditingController _commentController = TextEditingController();
//   bool _isLoadingComments = true;
//   bool _isSubmittingComment = false;

//   @override
//   void initState() {
//     super.initState();
//     _book = widget.book;
//     _fetchComments();
//   }

//   Future<void> _fetchComments() async {
//     setState(() => _isLoadingComments = true);
//     try {
//       final comments = await BookService.getComments(widget.book.id);
//       if (mounted) setState(() => _book.comments = comments);
//     } catch (e) {
//       debugPrint("Error fetching comments: $e");
//     } finally {
//       if (mounted) setState(() => _isLoadingComments = false);
//     }
//   }

//   Future<void> _updateReadStatus(bool isRead) async {
//     try {
//       await BookService.updateAssignmentStatus(
//           assignmentId: _book.assignmentId, isRead: isRead);
//       if (mounted) {
//         setState(() => _book.isRead = isRead);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content:
//                 Text(isRead ? "Marked as Completed" : "Marked as In Progress"),
//             backgroundColor: Colors.green));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text("Failed to update status."),
//             backgroundColor: Colors.red));
//       }
//     }
//   }

//   Future<void> _toggleLike() async {
//     final originalIsLiked = _book.isLiked;
//     final originalLikes = _book.likes;
//     setState(() {
//       _book.isLiked = !_book.isLiked;
//       _book.likes += _book.isLiked ? 1 : -1;
//     });
//     try {
//       final result =
//           await BookService.toggleLikeStatus(assignmentId: _book.assignmentId);
//       if (mounted) {
//         setState(() {
//           _book.isLiked = result['isLiked'];
//           _book.likes = int.tryParse(result['likes']?.toString() ?? '0') ?? 0;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _book.isLiked = originalIsLiked;
//           _book.likes = originalLikes;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text("Failed to update like status."),
//             backgroundColor: Colors.red));
//       }
//     }
//   }

//   Future<void> _addComment() async {
//     if (_commentController.text.trim().isEmpty || _isSubmittingComment) return;
//     final text = _commentController.text.trim();
//     setState(() => _isSubmittingComment = true);
//     try {
//       final savedComment =
//           await BookService.addComment(bookId: widget.book.id, text: text);
//       if (mounted) {
//         setState(() {
//           _book.comments.insert(0, savedComment);
//           _commentController.clear();
//           FocusScope.of(context).unfocus();
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text("Failed to post comment."),
//             backgroundColor: Colors.red));
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmittingComment = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kSurfaceColor,
//       body: CustomScrollView(
//         slivers: [
//           _BookDetailHeader(
//               book: _book,
//               heroTag: widget.heroTag,
//               onLikePressed: _toggleLike,
//               onReadChanged: _updateReadStatus),
//           SliverToBoxAdapter(
//               child: FadeInUp(
//                   delay: const Duration(milliseconds: 300),
//                   child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _CuratedReviewWidget(book: _book),
//                             const SizedBox(height: 32),
//                             _ActionButtons(book: _book),
//                             const SizedBox(height: 32),
//                             _CommentsSection(
//                                 commentController: _commentController,
//                                 onAddComment: _addComment,
//                                 isLoading: _isLoadingComments,
//                                 isSubmitting: _isSubmittingComment,
//                                 book: _book,
//                                 onCommentUpdated: _fetchComments),
//                             const SizedBox(height: 32),
//                             _DetailSectionHeader(title: 'ስለ መጽሐፉ'),
//                             const SizedBox(height: 12),
//                             Text(_book.description,
//                                 style: GoogleFonts.notoSansEthiopic(
//                                     fontSize: 15,
//                                     height: 1.7,
//                                     color: kOnSurfaceColor.withValues(alpha: 0.8)))
//                           ])))),
//         ],
//       ),
//     );
//   }
// }

// class _FeaturedCarousel extends StatefulWidget {
//   final List<Book> featuredBooks;
//   const _FeaturedCarousel({required this.featuredBooks});

//   @override
//   State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
// }

// class _FeaturedCarouselState extends State<_FeaturedCarousel> {
//   final PageController _pageController = PageController(viewportFraction: 0.85);
//   double _currentPageValue = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       if (_pageController.hasClients) {
//         setState(() => _currentPageValue = _pageController.page!);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.featuredBooks.isEmpty) {
//       return const SizedBox(
//           height: 280,
//           child: Center(child: Text("No featured books available.")));
//     }
//     return PageView.builder(
//       controller: _pageController,
//       itemCount: widget.featuredBooks.length,
//       itemBuilder: (context, index) {
//         final scale = 1 - (_currentPageValue - index).abs() * 0.2;
//         return Transform.scale(
//           scale: scale.clamp(0.85, 1.0),
//           child: _BookGridItem(
//               book: widget.featuredBooks[index], isFeatured: true),
//         );
//       },
//     );
//   }
// }

// class _BookGridItem extends StatelessWidget {
//   final Book book;
//   final bool isFeatured;
//   const _BookGridItem({required this.book, this.isFeatured = false});

//   @override
//   Widget build(BuildContext context) {
//     final heroTag = isFeatured ? 'featured_${book.id}' : book.id;
//     return InkWell(
//       onTap: () => Navigator.push(
//           context,
//           PageRouteBuilder(
//               transitionDuration: const Duration(milliseconds: 500),
//               pageBuilder: (_, __, ___) =>
//                   BookDetailScreen(book: book, heroTag: heroTag),
//               transitionsBuilder:
//                   (context, animation, secondaryAnimation, child) =>
//                       FadeTransition(opacity: animation, child: child))),
//       child: Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: kCardColor,
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.08),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4))
//             ]),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//                 flex: 3,
//                 child: Hero(
//                     tag: heroTag,
//                     child: Stack(children: [
//                       ClipRRect(
//                           borderRadius:
//                               const BorderRadius.vertical(top: Radius.circular(16)),
//                           child: Image.network(book.coverUrl,
//                               width: double.infinity,
//                               height: double.infinity,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stack) => Container(
//                                     color: Colors.black12,
//                                     alignment: Alignment.center,
//                                     child: const Icon(Iconsax.gallery_slash,
//                                         color: Colors.black45),
//                                   ))),
//                           Positioned(
//                               top: 8,
//                               right: 8,
//                               child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(
//                                       color: Colors.black.withValues(alpha: 0.7),
//                                       borderRadius: BorderRadius.circular(12)),
//                                   child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Icon(Iconsax.star1,
//                                             color: kAccentColor, size: 12),
//                                         const SizedBox(width: 4),
//                                         Text(book.rating.toString(),
//                                             style: GoogleFonts.poppins(
//                                                 color: Colors.white,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold))
//                                       ]))),
//                           if (book.isRead)
//                             Positioned(
//                                 bottom: 8,
//                                 left: 8,
//                                 child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                         color: Colors.green.withValues(alpha: 0.8),
//                                         borderRadius:
//                                             BorderRadius.circular(12)),
//                                     child: const Icon(Iconsax.tick_circle,
//                                         color: Colors.white, size: 16)))
//                         ])))),
//             Expanded(
//                 flex: 2,
//                 child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(book.title,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: GoogleFonts.notoSansEthiopic(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                         color: kOnSurfaceColor)),
//                                 const SizedBox(height: 4),
//                                 Text(book.author,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: GoogleFonts.poppins(
//                                         color: Colors.grey.shade600,
//                                         fontSize: 12))
//                               ]),
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(children: [
//                                   Icon(Iconsax.heart,
//                                       color: book.isLiked
//                                           ? Colors.red
//                                           : Colors.grey.shade400,
//                                       size: 16),
//                                   const SizedBox(width: 4),
//                                   Text('${book.likes}',
//                                       style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade600))
//                                 ]),
//                                 _buildAvailabilityIndicator(book.availability)
//                               ])
//                         ]))),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailabilityIndicator(BookAvailability availability) {
//     Color color;
//     IconData icon;
//     switch (availability) {
//       case BookAvailability.siteLibrary:
//         color = Colors.green;
//         icon = Iconsax.book;
//         break;
//       case BookAvailability.online:
//         color = Colors.blue;
//         icon = Iconsax.global;
//         break;
//       case BookAvailability.unavailable:
//         color = Colors.grey;
//         icon = Iconsax.close_circle;
//         break;
//     }
//     return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(8)),
//         child: Icon(icon, color: color, size: 12));
//   }
// }

// class _BookDetailHeader extends StatelessWidget {
//   final Book book;
//   final String heroTag;
//   final VoidCallback onLikePressed;
//   final Function(bool) onReadChanged;
//   const _BookDetailHeader(
//       {required this.book,
//       required this.heroTag,
//       required this.onLikePressed,
//       required this.onReadChanged});

//   String _getAvailabilityText(BuildContext context, BookAvailability availability) {
//     final l = AppLocalizations.of(context);
//     switch (availability) {
//       case BookAvailability.siteLibrary:
//         return l?.bookAvailabilitySiteLibrary ?? 'Available in Library';
//       case BookAvailability.online:
//         return l?.bookAvailabilityOnline ?? 'Available Online';
//       default:
//         return l?.bookAvailabilityUnavailable ?? 'Currently Unavailable';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//         expandedHeight: MediaQuery.of(context).size.height * 0.55,
//         pinned: true,
//         stretch: true,
//         backgroundColor: kPrimaryColor,
//         flexibleSpace: FlexibleSpaceBar(
//             background: Stack(fit: StackFit.expand, children: [
//           Hero(
//               tag: heroTag,
//               child: Image.network(book.coverUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (c, e, s) =>
//                       const Icon(Iconsax.gallery_slash, color: Colors.white))),
//           const DecoratedBox(
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [
//                         Colors.black54,
//                         Colors.transparent,
//                         Colors.black87
//                       ],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       stops: [0.0, 0.5, 1.0]))),
//           Positioned(
//               bottom: 20,
//               left: 24,
//               right: 24,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(book.title,
//                         style: GoogleFonts.notoSansEthiopic(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white)),
//                     const SizedBox(height: 8),
//                     Text('${AppLocalizations.of(context)?.bookByPrefix ?? 'by'} ${book.author}',
//                         style: GoogleFonts.poppins(
//                             fontSize: 16, color: Colors.white70)),
//                     const SizedBox(height: 16),
//                     Row(children: [
//                       Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                               color: Colors.green.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.green)),
//                           child: Text(_getAvailabilityText(context, book.availability),
//                               style: GoogleFonts.notoSansEthiopic(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500))),
//                       const SizedBox(width: 12),
//                       Row(children: [
//                         const Icon(Iconsax.star1,
//                             color: kAccentColor, size: 16),
//                         const SizedBox(width: 4),
//                         Text(book.rating.toString(),
//                             style: GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold))
//                       ])
//                     ]),
//                     const SizedBox(height: 16),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           if (book.deadline != null)
//                             Chip(
//                                 avatar: Icon(Iconsax.calendar_1,
//                                     color: kAccentColor.withValues(alpha: 0.8),
//                                     size: 16),
//                                 label: Text(
//                                     "Due: ${DateFormat.yMMMd().format(book.deadline!)}",
//                                     style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 12)),
//                                 backgroundColor: Colors.white.withValues(alpha: 0.1),
//                                 side: BorderSide(
//                                     color: kAccentColor.withValues(alpha: 0.5))),
//                           ChoiceChip(
//                               label: Text(
//                                   book.isRead ? "Completed" : "Mark as Read",
//                                   style:
//                                       GoogleFonts.poppins(color: Colors.white)),
//                               selected: book.isRead,
//                               onSelected: onReadChanged,
//                               selectedColor: Colors.green,
//                               backgroundColor: Colors.white.withValues(alpha: 0.2),
//                               labelStyle: GoogleFonts.poppins(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                               avatar: Icon(
//                                   book.isRead
//                                       ? Iconsax.tick_circle
//                                       : Iconsax.tag,
//                                   color: Colors.white,
//                                   size: 16))
//                         ])
//                   ]))
//         ])),
//         actions: [
//           IconButton(
//               icon: Icon(book.isLiked ? Iconsax.heart5 : Iconsax.heart,
//                   color: book.isLiked ? Colors.red : Colors.white),
//               onPressed: onLikePressed)
//         ]);
//   }
// }

// class _CuratedReviewWidget extends StatelessWidget {
//   final Book book;
//   const _CuratedReviewWidget({required this.book});
//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       _DetailSectionHeader(title: "ይህን መጽሐፍ የሚወዱት ለምንድን ነው?"),
//       const SizedBox(height: 16),
//       Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//               color: kAccentColor.withValues(alpha: 0.05),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: kAccentColor.withValues(alpha: 0.1))),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Icon(Iconsax.quote_down, color: kAccentColor, size: 24),
//             const SizedBox(height: 8),
//             Text(book.pullQuote,
//                 style: GoogleFonts.lora(
//                     fontSize: 16,
//                     fontStyle: FontStyle.italic,
//                     color: kOnSurfaceColor,
//                     height: 1.5))
//           ])),
//       const SizedBox(height: 16),
//       Text(book.fullReview,
//           style: GoogleFonts.poppins(
//               fontSize: 15,
//               height: 1.7,
//               color: kOnSurfaceColor.withValues(alpha: 0.8))),
//       const SizedBox(height: 24),
//       Text("ለሚወዷቸው አንባቢዎች ተስማሚ፦",
//           style: GoogleFonts.notoSansEthiopic(
//               fontWeight: FontWeight.bold, color: kOnSurfaceColor)),
//       const SizedBox(height: 12),
//       Wrap(
//           spacing: 8.0,
//           runSpacing: 8.0,
//           children: book.perfectFor
//               .map((tag) => Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                       color: kAccentColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(tag,
//                       style: GoogleFonts.poppins(
//                           color: kOnSurfaceColor,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500))))
//               .toList())
//     ]);
//   }
// }

// class _ActionButtons extends StatelessWidget {
//   final Book book;
//   const _ActionButtons({required this.book});
//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//           child: ElevatedButton.icon(
//               icon: const Icon(Iconsax.book_1),
//               label: Text('አሁን ያንብቡ'),
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kPrimaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12))))),
//       const SizedBox(width: 12),
//       Expanded(
//           child: OutlinedButton.icon(
//               icon: const Icon(Iconsax.book_saved),
//               label: Text('መጽሐፍ ይበደሩ'),
//               onPressed: () {},
//               style: OutlinedButton.styleFrom(
//                   foregroundColor: kPrimaryColor,
//                   side: const BorderSide(color: kPrimaryColor),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)))))
//     ]);
//   }
// }

// class _CommentsSection extends StatelessWidget {
//   final Book book;
//   final TextEditingController commentController;
//   final VoidCallback onAddComment;
//   final bool isLoading;
//   final bool isSubmitting;
//   final VoidCallback onCommentUpdated;

//   const _CommentsSection({
//     required this.book,
//     required this.commentController,
//     required this.onAddComment,
//     required this.isLoading,
//     required this.isSubmitting,
//     required this.onCommentUpdated,
//   });

//   void _showCommentOptions(
//       BuildContext context, Comment comment, String currentUserId) {
//     if (comment.userId != currentUserId &&
//         !Provider.of<UserProvider>(context, listen: false)
//             .roles
//             .contains('superior_admin')) {
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) => Wrap(
//         children: <Widget>[
//           ListTile(
//             leading: const Icon(Iconsax.edit, color: kPrimaryColor),
//             title: const Text('Edit Comment'),
//             onTap: () {
//               Navigator.pop(ctx);
//               _showEditCommentDialog(context, comment);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Iconsax.trash, color: kDangerColor),
//             title: const Text('Delete Comment',
//                 style: TextStyle(color: kDangerColor)),
//             onTap: () async {
//               Navigator.pop(ctx);
//               final confirmed = await showDialog<bool>(
//                 context: context,
//                 builder: (alertCtx) => AlertDialog(
//                   title: const Text('Confirm Deletion'),
//                   content: const Text(
//                       'Are you sure you want to delete this comment?'),
//                   actions: [
//                     TextButton(
//                         onPressed: () => Navigator.pop(alertCtx, false),
//                         child: const Text('Cancel')),
//                     TextButton(
//                         onPressed: () => Navigator.pop(alertCtx, true),
//                         child: const Text('Delete',
//                             style: TextStyle(color: kDangerColor))),
//                   ],
//                 ),
//               );
//               if (confirmed == true) {
//                 final result = await BookService.deleteComment(comment.id);
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(result['message'] ?? '...')));
//                   if (result['success']) {
//                     onCommentUpdated();
//                   }
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditCommentDialog(BuildContext context, Comment comment) {
//     final editController = TextEditingController(text: comment.text);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Edit Comment'),
//         content: TextField(
//           controller: editController,
//           autofocus: true,
//           maxLines: 4,
//           style: const TextStyle(color: kOnSurfaceColor),
//           decoration: const InputDecoration(border: OutlineInputBorder()),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               final result = await BookService.updateComment(
//                   commentId: comment.id, text: editController.text);
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(result['message'] ?? '...')));
//                 if (result['success']) {
//                   Navigator.pop(ctx);
//                   onCommentUpdated();
//                 }
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId =
//         Provider.of<UserProvider>(context, listen: false).userProfile?['id'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _DetailSectionHeader(title: 'አስተያየቶች'),
//         const SizedBox(height: 16),
//         Container(
//           decoration: BoxDecoration(
//               color: kCardColor,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4))
//               ]),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: commentController,
//                   maxLines: 3,
//                   style: const TextStyle(color: kOnSurfaceColor),
//                   decoration: InputDecoration(
//                       hintText: 'አስተያየት ይጨምሩ...',
//                       hintStyle: GoogleFonts.notoSansEthiopic(),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none),
//                       filled: true,
//                       fillColor: kSurfaceColor),
//                 ),
//                 const SizedBox(height: 12),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton.icon(
//                     icon: isSubmitting
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2))
//                         : const Icon(Iconsax.send_2, size: 16),
//                     label: const Text('ለጥፍ'),
//                     onPressed: isSubmitting ? null : onAddComment,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: kAccentColor,
//                         foregroundColor: kPrimaryColor),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         if (isLoading)
//           const Center(
//               child: Padding(
//                   padding: EdgeInsets.all(32.0),
//                   child: CircularProgressIndicator(color: kPrimaryColor)))
//         else if (book.comments.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(32),
//             child: Column(children: [
//               Icon(Iconsax.messages, size: 48, color: Colors.grey.shade400),
//               const SizedBox(height: 12),
//               Text('እስካሁን ምንም አስተያየት የለም።',
//                   textAlign: TextAlign.center,
//                   style:
//                       GoogleFonts.notoSansEthiopic(color: Colors.grey.shade600))
//             ]),
//           )
//         else
//           ListView.separated(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             itemCount: book.comments.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final comment = book.comments[index];
//               final imageUrl = comment.profileImageUrl;
//               String? fullImageUrl;
//               if (imageUrl != null && imageUrl.isNotEmpty) {
//                 final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
//                 fullImageUrl = '$baseUrl/uploads/$imageUrl';
//               }
//               return InkWell(
//                 onLongPress: () =>
//                     _showCommentOptions(context, comment, currentUserId),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                       color: kCardColor,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.grey.shade200)),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: kAccentColor.withValues(alpha: 0.1),
//                         backgroundImage: fullImageUrl != null
//                             ? NetworkImage(fullImageUrl)
//                             : null,
//                         child: fullImageUrl == null
//                             ? Text(
//                                 comment.userName.isNotEmpty
//                                     ? comment.userName[0]
//                                     : '?',
//                                 style: const TextStyle(
//                                     color: kAccentColor,
//                                     fontWeight: FontWeight.bold),
//                               )
//                             : null,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(comment.userName,
//                                       style: GoogleFonts.poppins(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14)),
//                                   Text(_formatTime(comment.timestamp),
//                                       style: GoogleFonts.poppins(
//                                           color: Colors.grey.shade500,
//                                           fontSize: 12))
//                                 ]),
//                             const SizedBox(height: 4),
//                             Text(comment.text,
//                                 style: GoogleFonts.notoSansEthiopic(
//                                     fontSize: 14, height: 1.4)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }

//   String _formatTime(DateTime timestamp) {
//     final difference = DateTime.now().difference(timestamp);
//     if (difference.inMinutes < 1) return 'Just now';
//     if (difference.inHours < 1) return '${difference.inMinutes}m ago';
//     if (difference.inHours < 24) return '${difference.inHours}h ago';
//     return DateFormat.yMMMd().format(timestamp);
//   }
// }

// class _DetailSectionHeader extends StatelessWidget {
//   final String title;
//   const _DetailSectionHeader({required this.title});
//   @override
//   Widget build(BuildContext context) {
//     return Text(title,
//         style: GoogleFonts.notoSansEthiopic(
//             fontSize: 20, fontWeight: FontWeight.bold, color: kOnSurfaceColor));
//   }
// }
