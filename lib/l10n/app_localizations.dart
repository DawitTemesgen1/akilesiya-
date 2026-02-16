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

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get loginWithEmail;

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

  /// No description provided for @drawerProfileTemplateEditor.
  ///
  /// In en, this message translates to:
  /// **'Profile Template Editor'**
  String get drawerProfileTemplateEditor;

  /// No description provided for @drawerUserActivity.
  ///
  /// In en, this message translates to:
  /// **'User Activity'**
  String get drawerUserActivity;

  /// No description provided for @drawerAdminHub.
  ///
  /// In en, this message translates to:
  /// **'Admin Hub'**
  String get drawerAdminHub;

  /// No description provided for @drawerMemberManagementCockpit.
  ///
  /// In en, this message translates to:
  /// **'Member Management Cockpit'**
  String get drawerMemberManagementCockpit;

  /// No description provided for @drawerFamilyStatus.
  ///
  /// In en, this message translates to:
  /// **'Family Status'**
  String get drawerFamilyStatus;

  /// No description provided for @drawerAttendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get drawerAttendanceSummary;

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
  /// **'With Permission'**
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
  /// **'No comments yet'**
  String get learningNoCommentsYet;

  /// No description provided for @profileMotherName.
  ///
  /// In en, this message translates to:
  /// **'Mother Name'**
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
  /// **'Guardian Information'**
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

  /// No description provided for @commonGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get commonGuest;

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

  /// No description provided for @signupLabelParentName.
  ///
  /// In en, this message translates to:
  /// **'1. Parent/Guardian\'s Name'**
  String get signupLabelParentName;

  /// No description provided for @signupLabelParentPhone.
  ///
  /// In en, this message translates to:
  /// **'5. Parent/Guardian\'s Phone'**
  String get signupLabelParentPhone;

  /// No description provided for @signupLabelHadPrevService.
  ///
  /// In en, this message translates to:
  /// **'Had previous service?'**
  String get signupLabelHadPrevService;

  /// No description provided for @signupLabelDept.
  ///
  /// In en, this message translates to:
  /// **'Service Department'**
  String get signupLabelDept;

  /// No description provided for @signupLabelResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Service Responsibility'**
  String get signupLabelResponsibility;

  /// No description provided for @signupLabelLevel.
  ///
  /// In en, this message translates to:
  /// **'Service Level'**
  String get signupLabelLevel;

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

  /// No description provided for @signupStepAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Setup'**
  String get signupStepAccountTitle;

  /// No description provided for @signupStepAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your school and secure your account'**
  String get signupStepAccountSubtitle;

  /// No description provided for @signupStepPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get signupStepPersonalTitle;

  /// No description provided for @signupStepPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about yourself'**
  String get signupStepPersonalSubtitle;

  /// No description provided for @signupStepGuardianTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian Info'**
  String get signupStepGuardianTitle;

  /// No description provided for @signupStepGuardianSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact and parent details'**
  String get signupStepGuardianSubtitle;

  /// No description provided for @signupStepServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get signupStepServiceTitle;

  /// No description provided for @signupStepServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your previous engagement in the church'**
  String get signupStepServiceSubtitle;

  /// No description provided for @signupStepAdditionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional Info'**
  String get signupStepAdditionalTitle;

  /// No description provided for @signupStepAdditionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information required by your school'**
  String get signupStepAdditionalSubtitle;

  /// No description provided for @signupStepPledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'The Pledge'**
  String get signupStepPledgeTitle;

  /// No description provided for @signupStepPledgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read and agree to the membership pledge'**
  String get signupStepPledgeSubtitle;

  /// No description provided for @signupSchoolSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not load schools.'**
  String get signupSchoolSelectionError;

  /// No description provided for @signupEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get signupEmailAddress;

  /// No description provided for @signupInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get signupInvalidEmail;

  /// No description provided for @signupPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get signupPasswordsDoNotMatch;

  /// No description provided for @signupPreviousServiceCheck.
  ///
  /// In en, this message translates to:
  /// **'I had previous service in a Sunday School'**
  String get signupPreviousServiceCheck;

  /// No description provided for @signupOtherSpecify.
  ///
  /// In en, this message translates to:
  /// **'Please Specify'**
  String get signupOtherSpecify;

  /// No description provided for @signupNoCustomFields.
  ///
  /// In en, this message translates to:
  /// **'No additional information required by your school.'**
  String get signupNoCustomFields;

  /// No description provided for @signupSelectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select School'**
  String get signupSelectSchool;

  /// No description provided for @signupPledgeText.
  ///
  /// In en, this message translates to:
  /// **'I, {christianName}, being a follower of the true Ethiopian Orthodox Tewahedo Church faith and traditions, do hereby pledge to serve {schoolName} Sunday School with all my heart and promise to fulfill my duties to the best of my ability.'**
  String signupPledgeText(Object christianName, Object schoolName);

  /// No description provided for @deptEducation.
  ///
  /// In en, this message translates to:
  /// **'Education Department'**
  String get deptEducation;

  /// No description provided for @deptMusic.
  ///
  /// In en, this message translates to:
  /// **'Music Department'**
  String get deptMusic;

  /// No description provided for @deptArt.
  ///
  /// In en, this message translates to:
  /// **'Art & Literature'**
  String get deptArt;

  /// No description provided for @deptDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development Department'**
  String get deptDevelopment;

  /// No description provided for @deptAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit Department'**
  String get deptAudit;

  /// No description provided for @deptOffering.
  ///
  /// In en, this message translates to:
  /// **'Offering & Service'**
  String get deptOffering;

  /// No description provided for @deptMembers.
  ///
  /// In en, this message translates to:
  /// **'Members Affairs'**
  String get deptMembers;

  /// No description provided for @deptFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance Department'**
  String get deptFinance;

  /// No description provided for @deptOffice.
  ///
  /// In en, this message translates to:
  /// **'Main Office'**
  String get deptOffice;

  /// No description provided for @deptRelation.
  ///
  /// In en, this message translates to:
  /// **'Public Relations'**
  String get deptRelation;

  /// No description provided for @deptLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library Department'**
  String get deptLibrary;

  /// No description provided for @deptProperty.
  ///
  /// In en, this message translates to:
  /// **'Property Department'**
  String get deptProperty;

  /// No description provided for @deptMedia.
  ///
  /// In en, this message translates to:
  /// **'Media Department'**
  String get deptMedia;

  /// No description provided for @deptOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get deptOther;

  /// No description provided for @respCoordinator.
  ///
  /// In en, this message translates to:
  /// **'Coordinator'**
  String get respCoordinator;

  /// No description provided for @respSub.
  ///
  /// In en, this message translates to:
  /// **'Sub-Coordinator'**
  String get respSub;

  /// No description provided for @respMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get respMember;

  /// No description provided for @respChair.
  ///
  /// In en, this message translates to:
  /// **'Chairperson'**
  String get respChair;

  /// No description provided for @respViceChair.
  ///
  /// In en, this message translates to:
  /// **'Vice Chairperson'**
  String get respViceChair;

  /// No description provided for @respSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get respSecretary;

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

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @signupPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get signupPasswordLengthError;

  /// No description provided for @homepageWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get homepageWelcomeUser;

  /// No description provided for @homepageMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get homepageMember;

  /// No description provided for @homepageFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get homepageFeatured;

  /// No description provided for @homepageRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homepageRecent;

  /// No description provided for @homepageNoDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get homepageNoDataFound;

  /// No description provided for @homepageManagePosts.
  ///
  /// In en, this message translates to:
  /// **'Manage Posts'**
  String get homepageManagePosts;

  /// No description provided for @homepageEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get homepageEditProfile;

  /// No description provided for @homepageFeaturedEvent.
  ///
  /// In en, this message translates to:
  /// **'FEATURED EVENT'**
  String get homepageFeaturedEvent;

  /// No description provided for @homepageImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get homepageImportant;

  /// No description provided for @homepageErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data. Please try again.'**
  String get homepageErrorLoading;

  /// No description provided for @commentsViewAllReplies.
  ///
  /// In en, this message translates to:
  /// **'View all {count} replies'**
  String commentsViewAllReplies(int count);

  /// No description provided for @commentsCollapseReplies.
  ///
  /// In en, this message translates to:
  /// **'Collapse replies'**
  String get commentsCollapseReplies;

  /// No description provided for @commentsEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing comment...'**
  String get commentsEditing;

  /// No description provided for @commentsReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {author}...'**
  String commentsReplyingTo(String author);

  /// No description provided for @commentsWritePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commentsWritePlaceholder;

  /// No description provided for @commentsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get commentsDeleteConfirmTitle;

  /// No description provided for @commentsDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get commentsDeleteConfirmMessage;

  /// No description provided for @commentsPostError.
  ///
  /// In en, this message translates to:
  /// **'Could not post comment.'**
  String get commentsPostError;

  /// No description provided for @commentsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete comment.'**
  String get commentsDeleteError;

  /// No description provided for @privateHomepageSundaySchool.
  ///
  /// In en, this message translates to:
  /// **'Sunday School'**
  String get privateHomepageSundaySchool;

  /// No description provided for @privateHomepageCommunityUpdates.
  ///
  /// In en, this message translates to:
  /// **'Community Updates'**
  String get privateHomepageCommunityUpdates;

  /// No description provided for @privateHomepageMembersText.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get privateHomepageMembersText;

  /// No description provided for @privateHomepagePostsText.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get privateHomepagePostsText;

  /// No description provided for @privateHomepageYearsText.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get privateHomepageYearsText;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelServiceTimes.
  ///
  /// In en, this message translates to:
  /// **'Service Times'**
  String get labelServiceTimes;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// No description provided for @commentsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more comments'**
  String get commentsLoadMore;

  /// No description provided for @commentsReplyAction.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentsReplyAction;

  /// No description provided for @commentsHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get commentsHideReplies;

  /// No description provided for @privateHomepageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get privateHomepageSaveError;

  /// No description provided for @privateHomepageFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get privateHomepageFeatured;

  /// No description provided for @platformLinksLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load links.'**
  String get platformLinksLoadError;

  /// No description provided for @platformLinksSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save link.'**
  String get platformLinksSaveError;

  /// No description provided for @platformLinksDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete link.'**
  String get platformLinksDeleteError;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @platformLinksDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String platformLinksDeleteConfirm(String name);

  /// No description provided for @platformOurPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Our Platforms'**
  String get platformOurPlatforms;

  /// No description provided for @platformMainPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Main Platforms'**
  String get platformMainPlatforms;

  /// No description provided for @platformSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get platformSocialMedia;

  /// No description provided for @platformAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add New Link'**
  String get platformAddLink;

  /// No description provided for @platformEditLink.
  ///
  /// In en, this message translates to:
  /// **'Edit Link'**
  String get platformEditLink;

  /// No description provided for @platformTagline.
  ///
  /// In en, this message translates to:
  /// **'Social Website and Utility'**
  String get platformTagline;

  /// No description provided for @platformNoLinksFound.
  ///
  /// In en, this message translates to:
  /// **'No links found.'**
  String get platformNoLinksFound;

  /// No description provided for @platformLinkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String platformLinkOpenError(String url);

  /// No description provided for @platformIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get platformIconLabel;

  /// No description provided for @platformColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get platformColorLabel;

  /// No description provided for @platformIsSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Is this a social media link?'**
  String get platformIsSocialMedia;

  /// No description provided for @platformUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Link (URL)'**
  String get platformUrlLabel;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredError;

  /// No description provided for @urlRequiredError.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get urlRequiredError;

  /// No description provided for @invalidUrlError.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrlError;

  /// No description provided for @optionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsLabel;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive an OTP'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordSendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get forgotPasswordSendOtpButton;

  /// No description provided for @forgotPasswordOtpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email'**
  String get forgotPasswordOtpSentSuccess;

  /// No description provided for @forgotPasswordOtpSentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get forgotPasswordOtpSentError;

  /// No description provided for @forgotPasswordConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get forgotPasswordConnectionError;

  /// No description provided for @forgotPasswordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordResetTitle;

  /// No description provided for @forgotPasswordResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP and your new password'**
  String get forgotPasswordResetSubtitle;

  /// No description provided for @forgotPasswordOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get forgotPasswordOtpLabel;

  /// No description provided for @forgotPasswordOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP'**
  String get forgotPasswordOtpRequired;

  /// No description provided for @forgotPasswordOtpDigitsError.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get forgotPasswordOtpDigitsError;

  /// No description provided for @forgotPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get forgotPasswordNewPasswordLabel;

  /// No description provided for @forgotPasswordConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get forgotPasswordConfirmPasswordLabel;

  /// No description provided for @forgotPasswordConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get forgotPasswordConfirmPasswordRequired;

  /// No description provided for @forgotPasswordResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordResetButton;

  /// No description provided for @forgotPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get forgotPasswordResetSuccess;

  /// No description provided for @forgotPasswordResetError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get forgotPasswordResetError;

  /// No description provided for @forgotPasswordResendOtpText.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Resend'**
  String get forgotPasswordResendOtpText;

  /// No description provided for @forgotPasswordOtpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP Resent'**
  String get forgotPasswordOtpResentSuccess;

  /// No description provided for @otpSetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Password'**
  String get otpSetPasswordTitle;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get otpVerifyTitle;

  /// No description provided for @otpSetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password for your account'**
  String get otpSetPasswordSubtitle;

  /// No description provided for @otpVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, we\'ve sent a 6-digit verification code to {email}. Please enter it below to proceed.'**
  String otpVerifySubtitle(String email);

  /// No description provided for @otpCompleteRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get otpCompleteRegistration;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify and Continue'**
  String get otpVerifyButton;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit code.'**
  String get otpInvalidCode;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed.'**
  String get otpVerificationFailed;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP Resent'**
  String get otpResentSuccess;

  /// No description provided for @otpLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try logging in manually.'**
  String get otpLoginFailed;

  /// No description provided for @otpSetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set password.'**
  String get otpSetPasswordFailed;

  /// No description provided for @profileTabStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get profileTabStatus;

  /// No description provided for @profileTabPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profileTabPersonal;

  /// No description provided for @profileTabSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get profileTabSpiritual;

  /// No description provided for @profileTabEducation.
  ///
  /// In en, this message translates to:
  /// **'Education & Family'**
  String get profileTabEducation;

  /// No description provided for @profileNoName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get profileNoName;

  /// No description provided for @profileServiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Service Status'**
  String get profileServiceStatus;

  /// No description provided for @profileStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileStatusActive;

  /// No description provided for @profileStatusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On Break'**
  String get profileStatusOnBreak;

  /// No description provided for @profileStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get profileStatusInactive;

  /// No description provided for @profileStatusManagedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'This status is managed by administration.'**
  String get profileStatusManagedByAdmin;

  /// No description provided for @profileAttendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get profileAttendanceSummary;

  /// No description provided for @profilePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get profilePresent;

  /// No description provided for @profileAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get profileAbsent;

  /// No description provided for @profileOnLeave.
  ///
  /// In en, this message translates to:
  /// **'On Leave'**
  String get profileOnLeave;

  /// No description provided for @profileClickToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Click to see detailed history'**
  String get profileClickToSeeHistory;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileDob;

  /// No description provided for @profileSpiritualClass.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Education Class'**
  String get profileSpiritualClass;

  /// No description provided for @profileClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get profileClass;

  /// No description provided for @profileFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get profileFilter;

  /// No description provided for @profileYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get profileYear;

  /// No description provided for @profileGradeReport.
  ///
  /// In en, this message translates to:
  /// **'Grade Report'**
  String get profileGradeReport;

  /// No description provided for @profileNoGradesFound.
  ///
  /// In en, this message translates to:
  /// **'No grades found or user is not a student'**
  String get profileNoGradesFound;

  /// No description provided for @profileGradeList.
  ///
  /// In en, this message translates to:
  /// **'Grade List'**
  String get profileGradeList;

  /// No description provided for @profileParentName.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Name'**
  String get profileParentName;

  /// No description provided for @profileParentPhone.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Phone'**
  String get profileParentPhone;

  /// No description provided for @profileLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get profileLibrary;

  /// No description provided for @profileToRead.
  ///
  /// In en, this message translates to:
  /// **'To Read'**
  String get profileToRead;

  /// No description provided for @profileRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get profileRead;

  /// No description provided for @profileNoBooksToRead.
  ///
  /// In en, this message translates to:
  /// **'No books to read'**
  String get profileNoBooksToRead;

  /// No description provided for @profileNoBooksRead.
  ///
  /// In en, this message translates to:
  /// **'No books read yet'**
  String get profileNoBooksRead;

  /// No description provided for @profileFinishBy.
  ///
  /// In en, this message translates to:
  /// **'Finish by'**
  String get profileFinishBy;

  /// No description provided for @profileReadVerified.
  ///
  /// In en, this message translates to:
  /// **'Read & Verified'**
  String get profileReadVerified;

  /// No description provided for @profileTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get profileTotalScore;

  /// No description provided for @profileNoAssessments.
  ///
  /// In en, this message translates to:
  /// **'No assessment scores recorded'**
  String get profileNoAssessments;

  /// No description provided for @profileAssessmentType.
  ///
  /// In en, this message translates to:
  /// **'Assessment Type'**
  String get profileAssessmentType;

  /// No description provided for @profileScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get profileScore;

  /// No description provided for @profileFilterYear.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get profileFilterYear;

  /// No description provided for @profileNoGradesYet.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get profileNoGradesYet;

  /// No description provided for @profileAssessmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} assessments'**
  String profileAssessmentsCount(int count);

  /// No description provided for @profileDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String profileDaysRemaining(int count);

  /// No description provided for @profileTimeElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time elapsed'**
  String get profileTimeElapsed;

  /// No description provided for @profileManagedByAdminReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Managed by Administration (Read Only)'**
  String get profileManagedByAdminReadOnly;

  /// No description provided for @profileSpiritualClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Education Class'**
  String get profileSpiritualClassLabel;

  /// No description provided for @profileSpiritualGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade {level}'**
  String profileSpiritualGrade(Object level);

  /// No description provided for @learningNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get learningNA;

  /// No description provided for @learningToggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get learningToggleTheme;

  /// No description provided for @learningCommentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load comments'**
  String get learningCommentsLoadFailed;

  /// No description provided for @learningDeleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment?'**
  String get learningDeleteCommentTitle;

  /// No description provided for @learningDeleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get learningDeleteCommentConfirm;

  /// No description provided for @learningCommentDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete comment'**
  String get learningCommentDeleteFailed;

  /// No description provided for @learningFailedToPostComment.
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment'**
  String get learningFailedToPostComment;

  /// No description provided for @learningCommentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get learningCommentsHeader;

  /// No description provided for @learningHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get learningHideReplies;

  /// No description provided for @learningViewReplies.
  ///
  /// In en, this message translates to:
  /// **'View {count} replies'**
  String learningViewReplies(int count);

  /// No description provided for @learningEditingComment.
  ///
  /// In en, this message translates to:
  /// **'Editing comment...'**
  String get learningEditingComment;

  /// No description provided for @learningReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {author}...'**
  String learningReplyingTo(String author);

  /// No description provided for @learningCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get learningCommentHint;

  /// No description provided for @learningReplyAction.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get learningReplyAction;

  /// No description provided for @learningEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get learningEditAction;

  /// No description provided for @learningDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get learningDeleteAction;

  /// No description provided for @learningBookmarked.
  ///
  /// In en, this message translates to:
  /// **'Article bookmarked'**
  String get learningBookmarked;

  /// No description provided for @videoBy.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get videoBy;

  /// No description provided for @videoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get videoDescription;

  /// No description provided for @videoWatchOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get videoWatchOnYoutube;

  /// No description provided for @videoDesktopNote.
  ///
  /// In en, this message translates to:
  /// **'For a better experience on desktop, we recommend watching the video on YouTube.'**
  String get videoDesktopNote;

  /// No description provided for @postImportant.
  ///
  /// In en, this message translates to:
  /// **'IMPORTANT'**
  String get postImportant;

  /// No description provided for @postMySundaySchool.
  ///
  /// In en, this message translates to:
  /// **'My Sunday School'**
  String get postMySundaySchool;

  /// No description provided for @postEventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get postEventDate;

  /// No description provided for @postLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get postLikes;

  /// No description provided for @postCommentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get postCommentsCount;

  /// No description provided for @postLikedAction.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get postLikedAction;

  /// No description provided for @postLikeAction.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get postLikeAction;

  /// No description provided for @postCommentAction.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get postCommentAction;

  /// No description provided for @postShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this post: {title}\n\n{description}\n\nShared via Akilesiya App'**
  String postShareMessage(Object description, Object title);

  /// No description provided for @postViewMoreComments.
  ///
  /// In en, this message translates to:
  /// **'View more comments'**
  String get postViewMoreComments;

  /// No description provided for @postViewAllReplies.
  ///
  /// In en, this message translates to:
  /// **'View all {count} replies'**
  String postViewAllReplies(int count);

  /// No description provided for @postHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get postHideReplies;

  /// No description provided for @commentsEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commentsEditAction;

  /// No description provided for @commentsDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentsDeleteAction;

  /// No description provided for @aboutUsAppSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Universal Spiritual Application'**
  String get aboutUsAppSubTitle;

  /// No description provided for @aboutUsVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get aboutUsVisionTitle;

  /// No description provided for @aboutUsVisionSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating a wise generation built on faith and conduct'**
  String get aboutUsVisionSubTitle;

  /// No description provided for @aboutUsVisionDescription.
  ///
  /// In en, this message translates to:
  /// **'Seeing a generation created with a strong faith and conduct that makes them worthy of the Kingdom of Heaven, by respecting and enforcing the church dogma, canon and tradition handed over by the holy fathers.'**
  String get aboutUsVisionDescription;

  /// No description provided for @aboutUsStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get aboutUsStoryTitle;

  /// No description provided for @aboutUsStoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Akilesiya has been producing many children of the church in spiritual service over the past many years. This digital platform is prepared to hold ancient spiritual wisdom combined with modern technology.'**
  String get aboutUsStoryDescription;

  /// No description provided for @aboutUsValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Core Values'**
  String get aboutUsValuesTitle;

  /// No description provided for @aboutUsValueFaithTitle.
  ///
  /// In en, this message translates to:
  /// **'Faith'**
  String get aboutUsValueFaithTitle;

  /// No description provided for @aboutUsValueFaithDesc.
  ///
  /// In en, this message translates to:
  /// **'Firm faith revealed by conduct'**
  String get aboutUsValueFaithDesc;

  /// No description provided for @aboutUsValueLoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get aboutUsValueLoveTitle;

  /// No description provided for @aboutUsValueLoveDesc.
  ///
  /// In en, this message translates to:
  /// **'Bound by love of God and love of neighbor'**
  String get aboutUsValueLoveDesc;

  /// No description provided for @aboutUsValueEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get aboutUsValueEducationTitle;

  /// No description provided for @aboutUsValueEducationDesc.
  ///
  /// In en, this message translates to:
  /// **'Continuous spiritual and human growth'**
  String get aboutUsValueEducationDesc;

  /// No description provided for @aboutUsValueServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get aboutUsValueServiceTitle;

  /// No description provided for @aboutUsValueServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Serving God and the community with diligence'**
  String get aboutUsValueServiceDesc;

  /// No description provided for @aboutUsBuiltByTitle.
  ///
  /// In en, this message translates to:
  /// **'Built by Faith and Technology'**
  String get aboutUsBuiltByTitle;

  /// No description provided for @aboutUsBuiltByDesc.
  ///
  /// In en, this message translates to:
  /// **'This platform is prepared to hold ancient spiritual wisdom combined with modern technology.'**
  String get aboutUsBuiltByDesc;

  /// No description provided for @aboutUsDigitalName.
  ///
  /// In en, this message translates to:
  /// **'Akilesiya Digital'**
  String get aboutUsDigitalName;

  /// No description provided for @aboutUsJoinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Our Community'**
  String get aboutUsJoinCommunity;

  /// No description provided for @aboutUsStayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with our growing family'**
  String get aboutUsStayConnected;

  /// No description provided for @aboutUsLocation.
  ///
  /// In en, this message translates to:
  /// **'Akilesiya, Ethiopia'**
  String get aboutUsLocation;

  /// No description provided for @splashMotto.
  ///
  /// In en, this message translates to:
  /// **'The church of tomorrow is built today'**
  String get splashMotto;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Akilesiya'**
  String get appName;

  /// No description provided for @attendanceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Attendance Management'**
  String get attendanceScreenTitle;

  /// No description provided for @attendanceAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get attendanceAccessDenied;

  /// No description provided for @attendanceNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to use this section.'**
  String get attendanceNoPermission;

  /// No description provided for @attendanceTabRecord.
  ///
  /// In en, this message translates to:
  /// **'Record Attendance'**
  String get attendanceTabRecord;

  /// No description provided for @attendanceTabManageAdmins.
  ///
  /// In en, this message translates to:
  /// **'Manage Admins'**
  String get attendanceTabManageAdmins;

  /// No description provided for @attendanceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance Type'**
  String get attendanceTypeLabel;

  /// No description provided for @attendanceTypeLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning Session'**
  String get attendanceTypeLearning;

  /// No description provided for @attendanceTypeHymnLearning.
  ///
  /// In en, this message translates to:
  /// **'Hymn Learning'**
  String get attendanceTypeHymnLearning;

  /// No description provided for @attendanceTypeAwudemihiret.
  ///
  /// In en, this message translates to:
  /// **'Awude Mihiret'**
  String get attendanceTypeAwudemihiret;

  /// No description provided for @attendanceTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special Program'**
  String get attendanceTypeSpecial;

  /// No description provided for @attendanceSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get attendanceSessionLabel;

  /// No description provided for @attendanceSessionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get attendanceSessionMorning;

  /// No description provided for @attendanceSessionAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get attendanceSessionAfternoon;

  /// No description provided for @attendanceFilterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter By'**
  String get attendanceFilterBy;

  /// No description provided for @attendanceGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get attendanceGroup;

  /// No description provided for @attendanceAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get attendanceAll;

  /// No description provided for @attendanceStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get attendanceStudents;

  /// No description provided for @attendanceSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Select Option'**
  String get attendanceSelectOption;

  /// No description provided for @attendanceUnnamedStudent.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Student'**
  String get attendanceUnnamedStudent;

  /// No description provided for @attendanceLateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLateTimeLabel;

  /// No description provided for @attendanceLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students...'**
  String get attendanceLoadingStudents;

  /// No description provided for @attendanceLoadingRecords.
  ///
  /// In en, this message translates to:
  /// **'Loading records...'**
  String get attendanceLoadingRecords;

  /// No description provided for @attendanceEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get attendanceEmptyStateTitle;

  /// No description provided for @attendanceEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or add students to this school.'**
  String get attendanceEmptyStateSubtitle;

  /// No description provided for @attendanceTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'📝 Daily Topic'**
  String get attendanceTopicLabel;

  /// No description provided for @attendanceSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get attendanceSaveButton;

  /// No description provided for @attendanceReadOnlyError.
  ///
  /// In en, this message translates to:
  /// **'Read only: Cannot save attendance.'**
  String get attendanceReadOnlyError;

  /// No description provided for @attendanceErrorLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Error loading students:'**
  String get attendanceErrorLoadingStudents;

  /// No description provided for @attendanceErrorLoadingRecords.
  ///
  /// In en, this message translates to:
  /// **'Error loading records:'**
  String get attendanceErrorLoadingRecords;

  /// No description provided for @attendanceSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attendance recorded successfully! 🎉'**
  String get attendanceSaveSuccess;

  /// No description provided for @attendanceSaveOffline.
  ///
  /// In en, this message translates to:
  /// **'Attendance recorded offline. It will be sent automatically when internet is available.'**
  String get attendanceSaveOffline;

  /// No description provided for @attendanceErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving attendance:'**
  String get attendanceErrorSaving;

  /// No description provided for @attendanceSearchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search user...'**
  String get attendanceSearchUserHint;

  /// No description provided for @attendanceRolesUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Roles updated successfully.'**
  String get attendanceRolesUpdateSuccess;

  /// No description provided for @attendanceGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get attendanceGenericError;

  /// No description provided for @attendanceUserStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get attendanceUserStatusPending;

  /// No description provided for @attendanceNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get attendanceNoName;

  /// No description provided for @attendanceNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get attendanceNoEmail;

  /// No description provided for @attendanceChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change Date'**
  String get attendanceChangeDate;

  /// No description provided for @planTabDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get planTabDepartments;

  /// No description provided for @planTabAllPlans.
  ///
  /// In en, this message translates to:
  /// **'All Plans'**
  String get planTabAllPlans;

  /// No description provided for @planTabPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get planTabPermissions;

  /// No description provided for @planTabMyPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get planTabMyPlans;

  /// No description provided for @planErrorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan data.'**
  String get planErrorLoadData;

  /// No description provided for @planErrorRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh data.'**
  String get planErrorRefresh;

  /// No description provided for @planErrorDeleteDept.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete department.'**
  String get planErrorDeleteDept;

  /// No description provided for @planErrorDeletePlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete plan.'**
  String get planErrorDeletePlan;

  /// No description provided for @planErrorUpdateDoneStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update plan status.'**
  String get planErrorUpdateDoneStatus;

  /// No description provided for @planErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized to perform this action.'**
  String get planErrorUnauthorized;

  /// No description provided for @planNoDepartmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Departments Found'**
  String get planNoDepartmentsTitle;

  /// No description provided for @planNoDepartmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Departments you belong to or manage will appear here.'**
  String get planNoDepartmentsSubtitle;

  /// No description provided for @planNoPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'No Plans Found'**
  String get planNoPlansTitle;

  /// No description provided for @planNoPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms.'**
  String get planNoPlansSubtitle;

  /// No description provided for @planNoPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Permissions Found'**
  String get planNoPermissionsTitle;

  /// No description provided for @planNoPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only users with department roles are listed here.'**
  String get planNoPermissionsSubtitle;

  /// No description provided for @planDeptCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Department'**
  String get planDeptCreateTitle;

  /// No description provided for @planDeptEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get planDeptEditTitle;

  /// No description provided for @planDeptNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Department Name'**
  String get planDeptNameLabel;

  /// No description provided for @planDeptNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get planDeptNameRequired;

  /// No description provided for @planDeptDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get planDeptDescLabel;

  /// No description provided for @planDeptColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Color'**
  String get planDeptColorLabel;

  /// No description provided for @planDeptCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get planDeptCreateButton;

  /// No description provided for @planDeptSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get planDeptSaveButton;

  /// No description provided for @planAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Plan'**
  String get planAddTitle;

  /// No description provided for @planEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get planEditTitle;

  /// No description provided for @planTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get planTitleLabel;

  /// No description provided for @planTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get planTitleRequired;

  /// No description provided for @planAcademicYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get planAcademicYearLabel;

  /// No description provided for @planDeptLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get planDeptLabel;

  /// No description provided for @planSelectDeptRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get planSelectDeptRequired;

  /// No description provided for @planAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee (Optional)'**
  String get planAssigneeLabel;

  /// No description provided for @planAssigneeNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No assignee selected'**
  String get planAssigneeNotSelected;

  /// No description provided for @planChangeAssignee.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get planChangeAssignee;

  /// No description provided for @planDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get planDateLabel;

  /// No description provided for @planDateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Date not selected'**
  String get planDateNotSelected;

  /// No description provided for @planSelectDateButton.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get planSelectDateButton;

  /// No description provided for @planHighPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get planHighPriorityLabel;

  /// No description provided for @planRecurringLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring (Yearly)'**
  String get planRecurringLabel;

  /// No description provided for @planStatusDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get planStatusDoneLabel;

  /// No description provided for @planAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get planAddButton;

  /// No description provided for @planSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get planSaveButton;

  /// No description provided for @planRolloverTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan Rollover'**
  String get planRolloverTitle;

  /// No description provided for @planRolloverContent.
  ///
  /// In en, this message translates to:
  /// **'This will copy \'recurring\' plans from {source} to {dest}. Original plans will not be changed.\n\nAre you sure?'**
  String planRolloverContent(String source, String dest);

  /// No description provided for @planRolloverConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Start Rollover'**
  String get planRolloverConfirmButton;

  /// No description provided for @planRolloverProgress.
  ///
  /// In en, this message translates to:
  /// **'Performing rollover...'**
  String get planRolloverProgress;

  /// No description provided for @planRolloverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rollover completed successfully.'**
  String get planRolloverSuccess;

  /// No description provided for @planRolloverError.
  ///
  /// In en, this message translates to:
  /// **'Rollover failed.'**
  String get planRolloverError;

  /// No description provided for @planUndoRolloverTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo Rollover'**
  String get planUndoRolloverTitle;

  /// No description provided for @planUndoRolloverContent.
  ///
  /// In en, this message translates to:
  /// **'This will PERMANENTLY DELETE all plans from the year {year}.\n\nThis is for correcting a mistaken rollover. This action cannot be undone. Are you sure?'**
  String planUndoRolloverContent(String year);

  /// No description provided for @planUndoRolloverConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Undo for {year}'**
  String planUndoRolloverConfirmButton(String year);

  /// No description provided for @planUndoRolloverProgress.
  ///
  /// In en, this message translates to:
  /// **'Undoing rollover...'**
  String get planUndoRolloverProgress;

  /// No description provided for @planUndoRolloverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Undo successful!'**
  String get planUndoRolloverSuccess;

  /// No description provided for @planUndoRolloverError.
  ///
  /// In en, this message translates to:
  /// **'Undo failed.'**
  String get planUndoRolloverError;

  /// No description provided for @planDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get planDeleteConfirmTitle;

  /// No description provided for @planDeleteDeptConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{name}\'? All plans associated with this department will also be deleted.'**
  String planDeleteDeptConfirmContent(String name);

  /// No description provided for @planDeletePlanConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get planDeletePlanConfirmTitle;

  /// No description provided for @planDeletePlanConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan? This action cannot be undone.'**
  String get planDeletePlanConfirmContent;

  /// No description provided for @planDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get planDeleteConfirmButton;

  /// No description provided for @planItemAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get planItemAssignee;

  /// No description provided for @planItemDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get planItemDue;

  /// No description provided for @planItemPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get planItemPriority;

  /// No description provided for @planItemRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get planItemRecurring;

  /// No description provided for @planItemAcademicYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get planItemAcademicYear;

  /// No description provided for @planAdminManageRolesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles in this Department'**
  String get planAdminManageRolesTooltip;

  /// No description provided for @planAdminRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get planAdminRoleAdmin;

  /// No description provided for @planAdminRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get planAdminRoleManager;

  /// No description provided for @planAdminNoRoles.
  ///
  /// In en, this message translates to:
  /// **'No active roles'**
  String get planAdminNoRoles;

  /// No description provided for @planCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get planCancelButton;

  /// No description provided for @planConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get planConfirmButton;

  /// No description provided for @planSelectMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get planSelectMemberTitle;

  /// No description provided for @planNoAvailableMembers.
  ///
  /// In en, this message translates to:
  /// **'No members available to add.'**
  String get planNoAvailableMembers;

  /// No description provided for @planAddMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get planAddMemberButton;

  /// No description provided for @planYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Academic year is required'**
  String get planYearRequired;

  /// No description provided for @planYearSuffix.
  ///
  /// In en, this message translates to:
  /// **'E.C.'**
  String get planYearSuffix;

  /// No description provided for @planUndoRolloverConfirmButtonWithYear.
  ///
  /// In en, this message translates to:
  /// **'YES, DELETE {year} PLANS'**
  String planUndoRolloverConfirmButtonWithYear(String year);

  /// No description provided for @planDeleteDeptTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get planDeleteDeptTitle;

  /// No description provided for @planDeleteDeptMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{deptName}\'? All plans associated with this department will also be deleted.'**
  String planDeleteDeptMessage(Object deptName);

  /// No description provided for @planDeleteDeptConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get planDeleteDeptConfirm;

  /// No description provided for @planDeletePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get planDeletePlanTitle;

  /// No description provided for @planDeletePlanMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan? This action cannot be undone.'**
  String get planDeletePlanMessage;

  /// No description provided for @planDeletePlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get planDeletePlanConfirm;

  /// No description provided for @planNoAdminsFound.
  ///
  /// In en, this message translates to:
  /// **'No Admins or Managers Found'**
  String get planNoAdminsFound;

  /// No description provided for @planNoAdminsMessage.
  ///
  /// In en, this message translates to:
  /// **'Assign roles from the \'Manage Members\' option on any department card.'**
  String get planNoAdminsMessage;

  /// No description provided for @planAdminOfDepts.
  ///
  /// In en, this message translates to:
  /// **'Admin of {count} Dept(s)'**
  String planAdminOfDepts(Object count);

  /// No description provided for @planManagerOfDepts.
  ///
  /// In en, this message translates to:
  /// **'Manager of {count} Dept(s)'**
  String planManagerOfDepts(Object count);

  /// No description provided for @planManageRolesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles in this Department'**
  String get planManageRolesTooltip;

  /// No description provided for @planUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get planUnknownUser;

  /// No description provided for @planRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get planRoleManager;

  /// No description provided for @planRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get planRoleMember;

  /// No description provided for @planCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get planCreateButton;

  /// No description provided for @planDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get planDescLabel;

  /// No description provided for @planRolloverMessagePart1.
  ///
  /// In en, this message translates to:
  /// **'This will copy recurring plans from'**
  String get planRolloverMessagePart1;

  /// No description provided for @planRolloverMessagePart2.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get planRolloverMessagePart2;

  /// No description provided for @planRolloverMessagePart3.
  ///
  /// In en, this message translates to:
  /// **'. Original plans will not be changed. Are you sure?'**
  String get planRolloverMessagePart3;

  /// No description provided for @planRolloverInProgress.
  ///
  /// In en, this message translates to:
  /// **'Performing rollover...'**
  String get planRolloverInProgress;

  /// No description provided for @planRolloverUndoInProgress.
  ///
  /// In en, this message translates to:
  /// **'Undoing rollover...'**
  String get planRolloverUndoInProgress;

  /// No description provided for @planRolloverUndoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Undo successful!'**
  String get planRolloverUndoSuccess;

  /// No description provided for @planRolloverUndoError.
  ///
  /// In en, this message translates to:
  /// **'Undo failed.'**
  String get planRolloverUndoError;

  /// No description provided for @planUndoRolloverMessage.
  ///
  /// In en, this message translates to:
  /// **'This will PERMANENTLY DELETE all plans from the year {year}. This is for correcting a mistaken rollover. This action cannot be undone. Are you sure?'**
  String planUndoRolloverMessage(String year);

  /// No description provided for @planAdminRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Can manage members and settings'**
  String get planAdminRoleDescription;

  /// No description provided for @planManagerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Can manage plans but not settings'**
  String get planManagerRoleDescription;

  /// No description provided for @planDeptMembersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No members in this department yet.'**
  String get planDeptMembersEmpty;

  /// No description provided for @planRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get planRoleAdmin;

  /// No description provided for @planDeptMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members of {deptName}'**
  String planDeptMembersTitle(String deptName);

  /// No description provided for @planDeptMembersSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department members updated successfully'**
  String get planDeptMembersSaveSuccess;

  /// No description provided for @planDeptMembersSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update department members'**
  String get planDeptMembersSaveError;

  /// No description provided for @planSortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get planSortLatest;

  /// No description provided for @planSortDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get planSortDueDate;

  /// No description provided for @planSortStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get planSortStatus;

  /// No description provided for @planUnknownDept.
  ///
  /// In en, this message translates to:
  /// **'Unknown Dept'**
  String get planUnknownDept;

  /// No description provided for @planYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year: '**
  String get planYearLabel;

  /// No description provided for @planFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter: '**
  String get planFilterLabel;

  /// No description provided for @planSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plans...'**
  String get planSearchHint;

  /// No description provided for @planEmptyNoDepts.
  ///
  /// In en, this message translates to:
  /// **'No departments available'**
  String get planEmptyNoDepts;

  /// No description provided for @planEmptyContactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please contact your administrator'**
  String get planEmptyContactAdmin;

  /// No description provided for @planEmptyNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans found for {year}.'**
  String planEmptyNoPlans(String year);

  /// No description provided for @planEmptyAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to add a plan.'**
  String get planEmptyAddPrompt;

  /// No description provided for @planEmptyNoSearch.
  ///
  /// In en, this message translates to:
  /// **'No results for your search.'**
  String get planEmptyNoSearch;

  /// No description provided for @planEmptyClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Try clearing filters.'**
  String get planEmptyClearFilter;

  /// No description provided for @planDeptMenuManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get planDeptMenuManage;

  /// No description provided for @planDeptMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get planDeptMenuEdit;

  /// No description provided for @planDeptMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get planDeptMenuDelete;

  /// No description provided for @planDeptCardPlansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Plans'**
  String planDeptCardPlansCount(String count);

  /// No description provided for @planDeptCardPercentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent} Done'**
  String planDeptCardPercentDone(String percent);

  /// No description provided for @platformLinksSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Platform links saved successfully.'**
  String get platformLinksSaveSuccess;

  /// No description provided for @planYearEndSetupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Year End Setup'**
  String get planYearEndSetupTooltip;

  /// No description provided for @planDeptCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department created successfully.'**
  String get planDeptCreateSuccess;

  /// No description provided for @planDeptCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create department.'**
  String get planDeptCreateError;

  /// No description provided for @planDeptUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department info updated successfully.'**
  String get planDeptUpdateSuccess;

  /// No description provided for @planDeptUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update department.'**
  String get planDeptUpdateError;

  /// No description provided for @planDeptDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department and its plans deleted.'**
  String get planDeptDeleteSuccess;

  /// No description provided for @planDeptDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete department.'**
  String get planDeptDeleteError;

  /// No description provided for @planAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan added successfully for {year}.'**
  String planAddSuccess(String year);

  /// No description provided for @planAddErrorDisplay.
  ///
  /// In en, this message translates to:
  /// **'Plan created, but failed to display immediately. Refreshing...'**
  String get planAddErrorDisplay;

  /// No description provided for @planAddError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add plan.'**
  String get planAddError;

  /// No description provided for @planUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan updated successfully.'**
  String get planUpdateSuccess;

  /// No description provided for @planUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update plan.'**
  String get planUpdateError;

  /// No description provided for @planDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan deleted successfully.'**
  String get planDeleteSuccess;

  /// No description provided for @planDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete plan.'**
  String get planDeleteError;

  /// No description provided for @planStatusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status.'**
  String get planStatusUpdateError;

  /// No description provided for @planUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get planUnknown;

  /// No description provided for @profileFilterClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get profileFilterClassLabel;

  /// No description provided for @profileTotalScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get profileTotalScoreLabel;

  /// No description provided for @profileUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Title'**
  String get profileUnknownTitle;

  /// No description provided for @profileDeadlinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Deadline:'**
  String get profileDeadlinePrefix;

  /// No description provided for @profileReadConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reading Confirmed'**
  String get profileReadConfirmed;

  /// No description provided for @profileCustomFieldDefault.
  ///
  /// In en, this message translates to:
  /// **'Custom Field'**
  String get profileCustomFieldDefault;

  /// No description provided for @learningAdminHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Admin Hub'**
  String get learningAdminHubTitle;

  /// No description provided for @learningAdminManageContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Learning Content'**
  String get learningAdminManageContentTitle;

  /// No description provided for @learningAdminTabManageContent.
  ///
  /// In en, this message translates to:
  /// **'Manage Content'**
  String get learningAdminTabManageContent;

  /// No description provided for @learningAdminTabPromoteAdmins.
  ///
  /// In en, this message translates to:
  /// **'Promote Admins'**
  String get learningAdminTabPromoteAdmins;

  /// No description provided for @learningAdminFailedToLoadContent.
  ///
  /// In en, this message translates to:
  /// **'Failed to load admin content.'**
  String get learningAdminFailedToLoadContent;

  /// No description provided for @learningAdminConfirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get learningAdminConfirmDeletion;

  /// No description provided for @learningAdminDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this content? This action cannot be undone.'**
  String get learningAdminDeleteConfirmation;

  /// No description provided for @learningAdminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get learningAdminCancel;

  /// No description provided for @learningAdminDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get learningAdminDelete;

  /// No description provided for @learningAdminDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed.'**
  String get learningAdminDeleteFailed;

  /// No description provided for @learningAdminVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get learningAdminVideo;

  /// No description provided for @learningAdminArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get learningAdminArticle;

  /// No description provided for @learningAdminNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get learningAdminNoTitle;

  /// No description provided for @learningAdminCreateContent.
  ///
  /// In en, this message translates to:
  /// **'Create Content'**
  String get learningAdminCreateContent;

  /// No description provided for @learningAdminEditContent.
  ///
  /// In en, this message translates to:
  /// **'Edit Content'**
  String get learningAdminEditContent;

  /// No description provided for @learningAdminRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get learningAdminRequired;

  /// No description provided for @learningAdminPleaseWaitUpload.
  ///
  /// In en, this message translates to:
  /// **'Please wait until the image uploads.'**
  String get learningAdminPleaseWaitUpload;

  /// No description provided for @learningAdminUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed:'**
  String get learningAdminUploadFailed;

  /// No description provided for @learningAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get learningAdminTitle;

  /// No description provided for @learningAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get learningAdminDescription;

  /// No description provided for @learningAdminType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get learningAdminType;

  /// No description provided for @learningAdminYoutubeURL.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get learningAdminYoutubeURL;

  /// No description provided for @learningAdminArticleMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Article Markdown'**
  String get learningAdminArticleMarkdown;

  /// No description provided for @learningAdminCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get learningAdminCategory;

  /// No description provided for @learningAdminDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (e.g., 15:30 or 10 min read)'**
  String get learningAdminDuration;

  /// No description provided for @learningAdminDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get learningAdminDifficulty;

  /// No description provided for @learningAdminVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get learningAdminVisibility;

  /// No description provided for @learningAdminBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get learningAdminBeginner;

  /// No description provided for @learningAdminIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get learningAdminIntermediate;

  /// No description provided for @learningAdminAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get learningAdminAdvanced;

  /// No description provided for @learningAdminForMySsOnly.
  ///
  /// In en, this message translates to:
  /// **'For My Sunday School Only'**
  String get learningAdminForMySsOnly;

  /// No description provided for @learningAdminForEveryone.
  ///
  /// In en, this message translates to:
  /// **'For Everyone'**
  String get learningAdminForEveryone;

  /// No description provided for @learningAdminSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get learningAdminSave;

  /// No description provided for @learningAdminTapToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get learningAdminTapToUploadImage;

  /// No description provided for @learningAdminUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get learningAdminUploadImage;

  /// No description provided for @learningAdminNoNameProvided.
  ///
  /// In en, this message translates to:
  /// **'No name provided'**
  String get learningAdminNoNameProvided;

  /// No description provided for @learningAdminRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'\'s role updated.'**
  String get learningAdminRoleUpdated;

  /// No description provided for @learningAdminFailedToUpdateRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to update role:'**
  String get learningAdminFailedToUpdateRole;

  /// No description provided for @learningAdminNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get learningAdminNoUsersFound;

  /// No description provided for @defaultNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get defaultNoTitle;

  /// No description provided for @defaultUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get defaultUnknownAuthor;

  /// No description provided for @defaultUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get defaultUnknownError;

  /// No description provided for @defaultContentArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get defaultContentArticle;

  /// No description provided for @defaultContentCategory.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get defaultContentCategory;

  /// No description provided for @defaultContentDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get defaultContentDifficulty;

  /// No description provided for @defaultNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get defaultNA;

  /// No description provided for @signupButtonNextStep.
  ///
  /// In en, this message translates to:
  /// **'NEXT STEP'**
  String get signupButtonNextStep;

  /// No description provided for @signupButtonCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signupButtonCreateAccount;

  /// No description provided for @signupLabelSpiritualClass.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Class'**
  String get signupLabelSpiritualClass;

  /// No description provided for @academicLevelPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary School'**
  String get academicLevelPrimary;

  /// No description provided for @academicLevelHighSchool.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get academicLevelHighSchool;

  /// No description provided for @academicLevelPreparatory.
  ///
  /// In en, this message translates to:
  /// **'Preparatory'**
  String get academicLevelPreparatory;

  /// No description provided for @academicLevelCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get academicLevelCertificate;

  /// No description provided for @academicLevelDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get academicLevelDiploma;

  /// No description provided for @academicLevelDegree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get academicLevelDegree;

  /// No description provided for @academicLevelMasters.
  ///
  /// In en, this message translates to:
  /// **'Masters'**
  String get academicLevelMasters;

  /// No description provided for @academicLevelPhD.
  ///
  /// In en, this message translates to:
  /// **'PhD'**
  String get academicLevelPhD;

  /// No description provided for @academicLevelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get academicLevelOther;

  /// No description provided for @serviceLevel1.
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get serviceLevel1;

  /// No description provided for @serviceLevel2.
  ///
  /// In en, this message translates to:
  /// **'Level 2'**
  String get serviceLevel2;

  /// No description provided for @serviceLevel3.
  ///
  /// In en, this message translates to:
  /// **'Level 3'**
  String get serviceLevel3;

  /// No description provided for @errorInvalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get errorInvalidEmailAddress;

  /// No description provided for @errorConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorConnectionTitle;

  /// No description provided for @errorConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection.'**
  String get errorConnectionMessage;

  /// No description provided for @errorConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorConnectionRetry;

  /// No description provided for @errorConnectionRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get errorConnectionRetrying;

  /// No description provided for @errorConnectionAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt {attempt} of {total}'**
  String errorConnectionAttempt(String attempt, String total);
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
