class HeroTags {
  // App Bar
  static String appBarProfile(String userId) => 'app_bar_profile_$userId';
  
  // Navigation
  static String bottomNav(String userId) => 'bottom_nav_$userId';
  static String navRail(String userId) => 'nav_rail_$userId';
  
  // Main Content
  static String mainContent(String userId, String page) => 'main_content_${userId}_$page';
  
  // User specific
  static String userAvatar(String userId) => 'user_avatar_$userId';
  static String userCard(String userId) => 'user_card_$userId';
  
  // Post specific
  static String postImage(String postId) => 'post_image_$postId';
  static String postCard(String postId) => 'post_card_$postId';
}
