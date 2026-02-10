import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Amde Haymanot'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @startWelcome.
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get startWelcome;

  /// No description provided for @startDescription.
  ///
  /// In en, this message translates to:
  /// **'In the name of the Father, the Son, and the Holy Spirit, One God, Amen. The Amde Haymanot Sunday School of the Ethiopian Orthodox Tewahedo Church, St. Mary\'s Cathedral in Jimma Diocese.'**
  String get startDescription;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcome;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account to continue'**
  String get loginPrompt;

  /// No description provided for @loginSchoolName.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get loginSchoolName;

  /// No description provided for @loginSchoolNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Amde Haymanot'**
  String get loginSchoolNameHint;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @signupCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a New Account'**
  String get signupCreateAccount;

  /// No description provided for @signupSchoolID.
  ///
  /// In en, this message translates to:
  /// **'School ID'**
  String get signupSchoolID;

  /// No description provided for @signupFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signupFullName;

  /// No description provided for @signupEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmail;

  /// No description provided for @signupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPassword;

  /// No description provided for @signupConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupConfirmPassword;

  /// No description provided for @errorRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequiredField;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get homePageTitle;

  /// No description provided for @chatPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatPageTitle;

  /// No description provided for @profilePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// No description provided for @learningPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningPageTitle;

  /// No description provided for @managementPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get managementPageTitle;

  /// No description provided for @postScopeAllSchools.
  ///
  /// In en, this message translates to:
  /// **'All Sunday Schools'**
  String get postScopeAllSchools;

  /// No description provided for @postScopeMySchoolOnly.
  ///
  /// In en, this message translates to:
  /// **'My Sunday School Only'**
  String get postScopeMySchoolOnly;

  /// No description provided for @postScopeSelection.
  ///
  /// In en, this message translates to:
  /// **'Who should see this post?'**
  String get postScopeSelection;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsCurrentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get settingsCurrentLanguage;

  /// No description provided for @settingsLanguageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get settingsLanguageAmharic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirmation;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settingsConfirm;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get settingsUserInfo;

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @drawerMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get drawerMainMenu;

  /// No description provided for @drawerSystemAdmin.
  ///
  /// In en, this message translates to:
  /// **'System Admin'**
  String get drawerSystemAdmin;

  /// No description provided for @drawerSystemDashboard.
  ///
  /// In en, this message translates to:
  /// **'System Dashboard'**
  String get drawerSystemDashboard;

  /// No description provided for @drawerSchoolsManagement.
  ///
  /// In en, this message translates to:
  /// **'Schools Management'**
  String get drawerSchoolsManagement;

  /// No description provided for @drawerUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get drawerUserManagement;

  /// No description provided for @drawerPlatformAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Platform Analytics'**
  String get drawerPlatformAnalytics;

  /// No description provided for @drawerSystemAudit.
  ///
  /// In en, this message translates to:
  /// **'System Audit'**
  String get drawerSystemAudit;

  /// No description provided for @drawerSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get drawerSystemSettings;

  /// No description provided for @drawerAdminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get drawerAdminTools;

  /// No description provided for @drawerAttendanceManagement.
  ///
  /// In en, this message translates to:
  /// **'Attendance Management'**
  String get drawerAttendanceManagement;

  /// No description provided for @drawerAcademicManagement.
  ///
  /// In en, this message translates to:
  /// **'Academic Management'**
  String get drawerAcademicManagement;

  /// No description provided for @drawerLibraryManagement.
  ///
  /// In en, this message translates to:
  /// **'Library Management'**
  String get drawerLibraryManagement;

  /// No description provided for @drawerPlanManagement.
  ///
  /// In en, this message translates to:
  /// **'Plan Management'**
  String get drawerPlanManagement;

  /// No description provided for @drawerMemberDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Member Development'**
  String get drawerMemberDevelopment;

  /// No description provided for @drawerUserList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get drawerUserList;

  /// No description provided for @drawerSuperiorLeadership.
  ///
  /// In en, this message translates to:
  /// **'Superior Leadership'**
  String get drawerSuperiorLeadership;

  /// No description provided for @drawerMemberAccountAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Member Account Adjustment'**
  String get drawerMemberAccountAdjustment;

  /// No description provided for @drawerManageFamilyLinks.
  ///
  /// In en, this message translates to:
  /// **'Manage Family Links'**
  String get drawerManageFamilyLinks;

  /// No description provided for @drawerAuditReport.
  ///
  /// In en, this message translates to:
  /// **'Audit Report'**
  String get drawerAuditReport;

  /// No description provided for @drawerNewSchoolRegistration.
  ///
  /// In en, this message translates to:
  /// **'New School Registration'**
  String get drawerNewSchoolRegistration;

  /// No description provided for @drawerApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get drawerApplication;

  /// No description provided for @drawerAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get drawerAboutUs;

  /// No description provided for @drawerSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get drawerSocialMedia;

  /// No description provided for @drawerRestartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get drawerRestartApp;

  /// No description provided for @drawerPermissionsAndScreens.
  ///
  /// In en, this message translates to:
  /// **'Permissions & Screens'**
  String get drawerPermissionsAndScreens;

  /// No description provided for @sysAdminTotalSchools.
  ///
  /// In en, this message translates to:
  /// **'Total Schools'**
  String get sysAdminTotalSchools;

  /// No description provided for @sysAdminActiveSchools.
  ///
  /// In en, this message translates to:
  /// **'Active Schools'**
  String get sysAdminActiveSchools;

  /// No description provided for @sysAdminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get sysAdminTotalUsers;

  /// No description provided for @sysAdminActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get sysAdminActiveUsers;

  /// No description provided for @sysAdminQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get sysAdminQuickActions;

  /// No description provided for @sysAdminToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'System Admin Tools'**
  String get sysAdminToolsLabel;

  /// No description provided for @sysAdminOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overall platform status and statistics'**
  String get sysAdminOverviewSubtitle;

  /// No description provided for @sysAdminRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get sysAdminRecentActivity;

  /// No description provided for @sysAdminUnknownSchool.
  ///
  /// In en, this message translates to:
  /// **'Unknown School'**
  String get sysAdminUnknownSchool;

  /// No description provided for @attendanceStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendanceStatusPresent;

  /// No description provided for @attendanceStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceStatusAbsent;

  /// No description provided for @attendanceStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceStatusLate;

  /// No description provided for @attendanceStatusPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get attendanceStatusPermission;

  /// No description provided for @attendanceStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get attendanceStatusUnknown;

  /// No description provided for @attendanceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistoryTitle;

  /// No description provided for @attendanceErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get attendanceErrorPrefix;

  /// No description provided for @attendanceNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found for this user.'**
  String get attendanceNoRecords;

  /// No description provided for @attendanceDetailTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get attendanceDetailTypeLabel;

  /// No description provided for @attendanceDetailSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get attendanceDetailSessionLabel;

  /// No description provided for @attendanceDetailArrivalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get attendanceDetailArrivalTimeLabel;

  /// No description provided for @attendanceDetailTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get attendanceDetailTopicLabel;

  /// No description provided for @attendanceDetailNoTopic.
  ///
  /// In en, this message translates to:
  /// **'No topic recorded.'**
  String get attendanceDetailNoTopic;

  /// No description provided for @attendanceColumnIndex.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get attendanceColumnIndex;

  /// No description provided for @attendanceColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get attendanceColumnName;

  /// No description provided for @attendanceColumnPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendanceColumnPresent;

  /// No description provided for @attendanceColumnAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceColumnAbsent;

  /// No description provided for @attendanceColumnLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceColumnLate;

  /// No description provided for @attendanceColumnPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent %'**
  String get attendanceColumnPercent;

  /// No description provided for @privateHomeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Home! 🏡'**
  String get privateHomeWelcome;

  /// No description provided for @privateHomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your spiritual family. New updates, events, and blessings await.'**
  String get privateHomeMessage;

  /// No description provided for @privateHomeNewUpdates.
  ///
  /// In en, this message translates to:
  /// **'New Updates'**
  String get privateHomeNewUpdates;

  /// No description provided for @privateHomeCommunityFeed.
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get privateHomeCommunityFeed;

  /// No description provided for @profileLabelChristianName.
  ///
  /// In en, this message translates to:
  /// **'Christian Name'**
  String get profileLabelChristianName;

  /// No description provided for @profileLabelMothersName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get profileLabelMothersName;

  /// No description provided for @profileLabelGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileLabelGender;

  /// No description provided for @profileLabelAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileLabelAge;

  /// No description provided for @profileLabelDOB.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileLabelDOB;

  /// No description provided for @profileLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileLabelPhone;

  /// No description provided for @profileLabelConfessionFather.
  ///
  /// In en, this message translates to:
  /// **'Confession Father'**
  String get profileLabelConfessionFather;

  /// No description provided for @profileLabelSpiritualClass.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Class'**
  String get profileLabelSpiritualClass;

  /// No description provided for @profileLabelKifil.
  ///
  /// In en, this message translates to:
  /// **'Kifil'**
  String get profileLabelKifil;

  /// No description provided for @profileLabelAcademicLevel.
  ///
  /// In en, this message translates to:
  /// **'Academic Level'**
  String get profileLabelAcademicLevel;

  /// No description provided for @profileLabelParentName.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Name'**
  String get profileLabelParentName;

  /// No description provided for @profileLabelParentPhone.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Phone'**
  String get profileLabelParentPhone;

  /// No description provided for @planManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Management'**
  String get planManagementTitle;

  /// No description provided for @planManagementTabDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get planManagementTabDepartments;

  /// No description provided for @planManagementTabAllPlans.
  ///
  /// In en, this message translates to:
  /// **'All Plans'**
  String get planManagementTabAllPlans;

  /// No description provided for @planManagementTabPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get planManagementTabPermissions;

  /// No description provided for @homepageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the list'**
  String get homepageLoadError;

  /// No description provided for @homepageRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get homepageRetry;

  /// No description provided for @homepageSundaySchoolUnion.
  ///
  /// In en, this message translates to:
  /// **'Sunday School Union'**
  String get homepageSundaySchoolUnion;

  /// No description provided for @homepageUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get homepageUpcomingEvents;

  /// No description provided for @homepageNewUpdates.
  ///
  /// In en, this message translates to:
  /// **'New Updates'**
  String get homepageNewUpdates;

  /// No description provided for @homepageNoUpdatesYet.
  ///
  /// In en, this message translates to:
  /// **'No new updates yet.'**
  String get homepageNoUpdatesYet;

  /// No description provided for @homepageComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get homepageComments;

  /// No description provided for @homepageNoCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get homepageNoCommentsYet;

  /// No description provided for @homepageAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add your comment...'**
  String get homepageAddComment;

  /// No description provided for @homepageFailedToPostComment.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment.'**
  String get homepageFailedToPostComment;

  /// No description provided for @homepageManagePublicPosts.
  ///
  /// In en, this message translates to:
  /// **'Manage Public Posts'**
  String get homepageManagePublicPosts;

  /// No description provided for @homepageEventAt.
  ///
  /// In en, this message translates to:
  /// **'Event at: '**
  String get homepageEventAt;

  /// No description provided for @homepageNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get homepageNoTitle;

  /// No description provided for @homepageUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get homepageUnknownAuthor;

  /// No description provided for @learningContentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load content.'**
  String get learningContentLoadError;

  /// No description provided for @learningNoContentYet.
  ///
  /// In en, this message translates to:
  /// **'No learning content yet.'**
  String get learningNoContentYet;

  /// No description provided for @learningAddCommentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add comment...'**
  String get learningAddCommentPlaceholder;

  /// No description provided for @learningNoCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Share your thoughts!'**
  String get learningNoCommentsYet;

  /// No description provided for @profileMotherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get profileMotherName;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileFemale;

  /// No description provided for @profileConfessionFather.
  ///
  /// In en, this message translates to:
  /// **'Confession Father\'s Name'**
  String get profileConfessionFather;

  /// No description provided for @profileAcademicLevel.
  ///
  /// In en, this message translates to:
  /// **'Academic Level'**
  String get profileAcademicLevel;

  /// No description provided for @profileKifil.
  ///
  /// In en, this message translates to:
  /// **'Kifil'**
  String get profileKifil;

  /// No description provided for @profileGuardianInfo.
  ///
  /// In en, this message translates to:
  /// **'Guardian\'s Information'**
  String get profileGuardianInfo;

  /// No description provided for @profileGuardianName.
  ///
  /// In en, this message translates to:
  /// **'Guardian\'s Name'**
  String get profileGuardianName;

  /// No description provided for @profileGuardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Guardian\'s Phone'**
  String get profileGuardianPhone;

  /// No description provided for @loginLoadSchoolsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schools. Check connection.'**
  String get loginLoadSchoolsError;

  /// No description provided for @contentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load page content.'**
  String get contentLoadError;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorPrefix;

  /// No description provided for @exceptionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Exception: '**
  String get exceptionPrefix;

  /// No description provided for @dateInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format'**
  String get dateInvalidFormat;

  /// No description provided for @dateParseError.
  ///
  /// In en, this message translates to:
  /// **'Error parsing date'**
  String get dateParseError;

  /// No description provided for @refreshSignalReceived.
  ///
  /// In en, this message translates to:
  /// **'Refresh signal received! Reloading data.'**
  String get refreshSignalReceived;

  /// No description provided for @failedToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get failedToLoadFeed;

  /// No description provided for @newUpdatesSuffix.
  ///
  /// In en, this message translates to:
  /// **' New Updates'**
  String get newUpdatesSuffix;

  /// No description provided for @commentsSuffix.
  ///
  /// In en, this message translates to:
  /// **' Comments'**
  String get commentsSuffix;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Title'**
  String get bookTitle;

  /// No description provided for @bookAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get bookAuthor;

  /// No description provided for @bookCoverImageURL.
  ///
  /// In en, this message translates to:
  /// **'Cover Image URL'**
  String get bookCoverImageURL;

  /// No description provided for @bookDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get bookDescription;

  /// No description provided for @bookRating.
  ///
  /// In en, this message translates to:
  /// **'Rating (e.g., 4.5)'**
  String get bookRating;

  /// No description provided for @bookGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres (comma-separated)'**
  String get bookGenres;

  /// No description provided for @bookPullQuote.
  ///
  /// In en, this message translates to:
  /// **'Pull Quote'**
  String get bookPullQuote;

  /// No description provided for @bookFullReview.
  ///
  /// In en, this message translates to:
  /// **'Full Review'**
  String get bookFullReview;

  /// No description provided for @addNewMasterBook.
  ///
  /// In en, this message translates to:
  /// **'Add New Master Book'**
  String get addNewMasterBook;

  /// No description provided for @unknownSchool.
  ///
  /// In en, this message translates to:
  /// **'Unknown School'**
  String get unknownSchool;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get unknownUser;

  /// No description provided for @socialMediaOpened.
  ///
  /// In en, this message translates to:
  /// **'Opening social media'**
  String get socialMediaOpened;

  /// No description provided for @attendancePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendancePresent;

  /// No description provided for @attendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLate;

  /// No description provided for @attendancePermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get attendancePermission;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTitle;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @fieldTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get fieldTooShort;

  /// No description provided for @fieldTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get fieldTooLong;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @filterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterButton;

  /// No description provided for @sortButton.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortButton;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @tomorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @likeButton.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeButton;

  /// No description provided for @commentButton.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentButton;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'View Less'**
  String get viewLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLess;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get chooseFile;

  /// No description provided for @noFileChosen.
  ///
  /// In en, this message translates to:
  /// **'No file chosen'**
  String get noFileChosen;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @confirmDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get confirmDeletePost;

  /// No description provided for @privateHomepageAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get privateHomepageAnonymous;

  /// No description provided for @privateHomepageNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get privateHomepageNoTitle;

  /// No description provided for @privateHomepageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get privateHomepageUnknown;

  /// No description provided for @privateHomepageFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get privateHomepageFailedToLoad;

  /// No description provided for @privateHomepageNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Be the first to share!'**
  String get privateHomepageNoPosts;

  /// No description provided for @privateHomepageLoadingCommunity.
  ///
  /// In en, this message translates to:
  /// **'Loading community'**
  String get privateHomepageLoadingCommunity;

  /// No description provided for @privateHomepageCommunityFeed.
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get privateHomepageCommunityFeed;

  /// No description provided for @privateHomepageWelcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Home! 🏡'**
  String get privateHomepageWelcomeHome;

  /// No description provided for @privateHomepageWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your spiritual family. New updates, events, and blessings await you.'**
  String get privateHomepageWelcomeMessage;

  /// No description provided for @privateHomepageNewUpdates.
  ///
  /// In en, this message translates to:
  /// **'New Updates'**
  String get privateHomepageNewUpdates;

  /// No description provided for @privateHomepageUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get privateHomepageUpcomingEvents;

  /// No description provided for @privateHomepageActiveMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get privateHomepageActiveMembers;

  /// No description provided for @privateHomepagePrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'Prayer Requests'**
  String get privateHomepagePrayerRequests;

  /// No description provided for @privateHomepageAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get privateHomepageAnnouncements;

  /// No description provided for @privateHomepageEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get privateHomepageEditDetails;

  /// No description provided for @privateHomepageManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get privateHomepageManageMembers;

  /// No description provided for @privateHomepageFeaturedUpdates.
  ///
  /// In en, this message translates to:
  /// **'🌟 Featured Updates'**
  String get privateHomepageFeaturedUpdates;

  /// No description provided for @privateHomepageManagePosts.
  ///
  /// In en, this message translates to:
  /// **'Manage Posts'**
  String get privateHomepageManagePosts;

  /// No description provided for @dateInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date'**
  String get dateInvalidDate;

  /// No description provided for @dateSelectDate.
  ///
  /// In en, this message translates to:
  /// **'📅 Select Date'**
  String get dateSelectDate;

  /// No description provided for @dateEthiopianCalendar.
  ///
  /// In en, this message translates to:
  /// **'E.C.'**
  String get dateEthiopianCalendar;

  /// No description provided for @dateJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get dateJustNow;

  /// No description provided for @dateHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get dateHoursAgo;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateInvalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Ethiopian Date Format'**
  String get dateInvalidDateFormat;

  /// No description provided for @dateErrorParsing.
  ///
  /// In en, this message translates to:
  /// **'Error parsing Ethiopian date string'**
  String get dateErrorParsing;

  /// No description provided for @postTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get postTypeEvent;

  /// No description provided for @postTypeAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get postTypeAnnouncement;

  /// No description provided for @postTypeNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get postTypeNews;

  /// No description provided for @postTypePrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get postTypePrayer;

  /// No description provided for @privateHomepageEditSSDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Sunday School Details'**
  String get privateHomepageEditSSDetails;

  /// No description provided for @privateHomepageSSName.
  ///
  /// In en, this message translates to:
  /// **'Sunday School Name'**
  String get privateHomepageSSName;

  /// No description provided for @privateHomepageMemberCount.
  ///
  /// In en, this message translates to:
  /// **'Member Count'**
  String get privateHomepageMemberCount;

  /// No description provided for @validationNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validationNameCannotBeEmpty;

  /// No description provided for @validationCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get validationCannotBeEmpty;

  /// No description provided for @validationMustBeValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be valid number'**
  String get validationMustBeValidNumber;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commonComments;

  /// No description provided for @commonNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get commonNoComments;

  /// No description provided for @commonWriteComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commonWriteComment;

  /// No description provided for @commonFailedToPostComment.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment.'**
  String get commonFailedToPostComment;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeMessage;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @helpButton.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpButton;

  /// No description provided for @supportButton.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportButton;

  /// No description provided for @feedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackButton;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Amde Haymanot. All rights reserved.'**
  String get copyrightText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @monthMeskerem.
  ///
  /// In en, this message translates to:
  /// **'Meskerem'**
  String get monthMeskerem;

  /// No description provided for @monthTikimt.
  ///
  /// In en, this message translates to:
  /// **'Tikimt'**
  String get monthTikimt;

  /// No description provided for @monthHidar.
  ///
  /// In en, this message translates to:
  /// **'Hidar'**
  String get monthHidar;

  /// No description provided for @monthTahsas.
  ///
  /// In en, this message translates to:
  /// **'Tahsas'**
  String get monthTahsas;

  /// No description provided for @monthTir.
  ///
  /// In en, this message translates to:
  /// **'Tir'**
  String get monthTir;

  /// No description provided for @monthYekatit.
  ///
  /// In en, this message translates to:
  /// **'Yekatit'**
  String get monthYekatit;

  /// No description provided for @monthMegabit.
  ///
  /// In en, this message translates to:
  /// **'Megabit'**
  String get monthMegabit;

  /// No description provided for @monthMiyazya.
  ///
  /// In en, this message translates to:
  /// **'Miyazya'**
  String get monthMiyazya;

  /// No description provided for @monthGinbot.
  ///
  /// In en, this message translates to:
  /// **'Ginbot'**
  String get monthGinbot;

  /// No description provided for @monthSene.
  ///
  /// In en, this message translates to:
  /// **'Sene'**
  String get monthSene;

  /// No description provided for @monthHamle.
  ///
  /// In en, this message translates to:
  /// **'Hamle'**
  String get monthHamle;

  /// No description provided for @monthNehase.
  ///
  /// In en, this message translates to:
  /// **'Nehase'**
  String get monthNehase;

  /// No description provided for @monthPagume.
  ///
  /// In en, this message translates to:
  /// **'Pagume'**
  String get monthPagume;

  /// No description provided for @dateHoursAgoSuffix.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get dateHoursAgoSuffix;

  /// No description provided for @loginSelectSchoolError.
  ///
  /// In en, this message translates to:
  /// **'Please select a school.'**
  String get loginSelectSchoolError;

  /// No description provided for @loginFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Login failed: '**
  String get loginFailedPrefix;

  /// No description provided for @loginPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordLengthError;

  /// No description provided for @loginLoadingSchools.
  ///
  /// In en, this message translates to:
  /// **'Loading Schools...'**
  String get loginLoadingSchools;

  /// No description provided for @loginNoSchoolsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schools available'**
  String get loginNoSchoolsAvailable;

  /// No description provided for @loginNoSchoolsFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find any schools.'**
  String get loginNoSchoolsFound;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retryButton;

  /// No description provided for @learningCenter.
  ///
  /// In en, this message translates to:
  /// **'Learning Center'**
  String get learningCenter;

  /// No description provided for @learningManageContent.
  ///
  /// In en, this message translates to:
  /// **'Manage Content'**
  String get learningManageContent;

  /// No description provided for @learningSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get learningSearch;

  /// No description provided for @learningFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get learningFilter;

  /// No description provided for @learningNoContent.
  ///
  /// In en, this message translates to:
  /// **'No learning content yet.'**
  String get learningNoContent;

  /// No description provided for @learningAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get learningAnonymous;

  /// No description provided for @learningUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get learningUnknownAuthor;

  /// No description provided for @learningNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get learningNoTitle;

  /// No description provided for @learningCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get learningCategoryGeneral;

  /// No description provided for @learningDifficultyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get learningDifficultyBeginner;

  /// No description provided for @learningDifficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get learningDifficultyIntermediate;

  /// No description provided for @learningDifficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get learningDifficultyAdvanced;

  /// No description provided for @learningFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load content.'**
  String get learningFailedToLoad;

  /// No description provided for @learningLikeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update like.'**
  String get learningLikeUpdateFailed;

  /// No description provided for @learningBookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to bookmarks'**
  String get learningBookmarkAdded;

  /// No description provided for @learningBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from bookmarks'**
  String get learningBookmarkRemoved;

  /// No description provided for @learningBookmarkUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update bookmark.'**
  String get learningBookmarkUpdateFailed;

  /// No description provided for @learningCommentPostFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment.'**
  String get learningCommentPostFailed;

  /// No description provided for @learningNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Share your thoughts!'**
  String get learningNoComments;

  /// No description provided for @learningAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add comment...'**
  String get learningAddComment;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit My Profile'**
  String get profileEditTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileChristianName.
  ///
  /// In en, this message translates to:
  /// **'Christian Name'**
  String get profileChristianName;

  /// No description provided for @profileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileGenderFemale;

  /// No description provided for @profileSpiritualAcademic.
  ///
  /// In en, this message translates to:
  /// **'Spiritual & Academic'**
  String get profileSpiritualAcademic;

  /// No description provided for @profileAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get profileAdditionalInfo;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get profileNotSet;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get profileSelectDob;

  /// No description provided for @signupStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get signupStepAccount;

  /// No description provided for @signupStepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get signupStepPersonal;

  /// No description provided for @signupStepGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get signupStepGuardian;

  /// No description provided for @signupStepService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get signupStepService;

  /// No description provided for @signupStepAgreement.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get signupStepAgreement;

  /// No description provided for @signupAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'First, select your school and create your login credentials.'**
  String get signupAccountDesc;

  /// No description provided for @signupPersonalDesc.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your personal details as per the registration form.'**
  String get signupPersonalDesc;

  /// No description provided for @signupGuardianDesc.
  ///
  /// In en, this message translates to:
  /// **'If you are under 18, please provide guardian information.'**
  String get signupGuardianDesc;

  /// No description provided for @signupServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Please provide your past service history, if any.'**
  String get signupServiceDesc;

  /// No description provided for @signupErrorAccountFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields in the Account step.'**
  String get signupErrorAccountFields;

  /// No description provided for @signupErrorPersonalFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields in the Personal step.'**
  String get signupErrorPersonalFields;

  /// No description provided for @signupErrorAgreeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the pledge to complete registration.'**
  String get signupErrorAgreeRequired;

  /// No description provided for @signupErrorSchoolNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find the selected school. Please try again.'**
  String get signupErrorSchoolNotFound;

  /// No description provided for @signupErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get signupErrorUnknown;

  /// No description provided for @signupErrorSchoolsLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load schools.'**
  String get signupErrorSchoolsLoad;

  /// No description provided for @signupErrorSelectSchool.
  ///
  /// In en, this message translates to:
  /// **'Please select your school'**
  String get signupErrorSelectSchool;

  /// No description provided for @signupButtonBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get signupButtonBack;

  /// No description provided for @signupButtonNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get signupButtonNext;

  /// No description provided for @signupButtonFinish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get signupButtonFinish;

  /// No description provided for @signupLabelFullName.
  ///
  /// In en, this message translates to:
  /// **'1. Full Name (with Grandfather)*'**
  String get signupLabelFullName;

  /// No description provided for @signupLabelChristianName.
  ///
  /// In en, this message translates to:
  /// **'2. Christian Name'**
  String get signupLabelChristianName;

  /// No description provided for @signupLabelConfessionFather.
  ///
  /// In en, this message translates to:
  /// **'3. Confession Father\'s Name'**
  String get signupLabelConfessionFather;

  /// No description provided for @signupLabelMotherName.
  ///
  /// In en, this message translates to:
  /// **'4. Mother\'s Name'**
  String get signupLabelMotherName;

  /// No description provided for @signupLabelGender.
  ///
  /// In en, this message translates to:
  /// **'5. Gender'**
  String get signupLabelGender;

  /// No description provided for @signupLabelAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get signupLabelAge;

  /// No description provided for @signupLabelAcademicLevel.
  ///
  /// In en, this message translates to:
  /// **'6. Academic Level'**
  String get signupLabelAcademicLevel;

  /// No description provided for @signupLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'8. Phone Number'**
  String get signupLabelPhone;

  /// No description provided for @signupLabelDob.
  ///
  /// In en, this message translates to:
  /// **'10. Date of Birth (Ethiopian)'**
  String get signupLabelDob;

  /// No description provided for @signupLabelGuardianName.
  ///
  /// In en, this message translates to:
  /// **'1. Parent/Guardian\'s Name'**
  String get signupLabelGuardianName;

  /// No description provided for @signupLabelGuardianPhone.
  ///
  /// In en, this message translates to:
  /// **'5. Parent/Guardian\'s Phone'**
  String get signupLabelGuardianPhone;

  /// No description provided for @signupLabelHadPrevService.
  ///
  /// In en, this message translates to:
  /// **'Had previous service?'**
  String get signupLabelHadPrevService;

  /// No description provided for @signupLabelServiceDept.
  ///
  /// In en, this message translates to:
  /// **'Service Department'**
  String get signupLabelServiceDept;

  /// No description provided for @signupLabelServiceResp.
  ///
  /// In en, this message translates to:
  /// **'Service Responsibility'**
  String get signupLabelServiceResp;

  /// No description provided for @signupLabelServiceLevel.
  ///
  /// In en, this message translates to:
  /// **'Service Level'**
  String get signupLabelServiceLevel;

  /// No description provided for @signupErrorSelectDept.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get signupErrorSelectDept;

  /// No description provided for @signupErrorSelectResp.
  ///
  /// In en, this message translates to:
  /// **'Please select a responsibility'**
  String get signupErrorSelectResp;

  /// No description provided for @signupErrorSelectLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select a level'**
  String get signupErrorSelectLevel;

  /// No description provided for @signupLabelOtherDept.
  ///
  /// In en, this message translates to:
  /// **'Please specify other department'**
  String get signupLabelOtherDept;

  /// No description provided for @signupPledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership Pledge'**
  String get signupPledgeTitle;

  /// No description provided for @signupPledgeAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the pledge.'**
  String get signupPledgeAgree;

  /// No description provided for @settingsLanguageToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get settingsLanguageToggleTooltip;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
