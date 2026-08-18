import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// The application name, shown in the task switcher and app bar
  ///
  /// In en, this message translates to:
  /// **'LabFox'**
  String get appTitle;

  /// Title of the home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Shown on the home screen with the signed-in user's username
  ///
  /// In en, this message translates to:
  /// **'Signed in as {username}'**
  String homeSignedInAs(String username);

  /// Placeholder on the home screen before feature work lands
  ///
  /// In en, this message translates to:
  /// **'Your issues, merge requests and pipelines will appear here.'**
  String get homeEmptyWork;

  /// Label for the sign-out action
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Heading on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Connect a GitLab account'**
  String get signInTitle;

  /// Label for the instance URL field
  ///
  /// In en, this message translates to:
  /// **'GitLab instance URL'**
  String get signInInstanceLabel;

  /// Validation when the instance URL is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your GitLab instance URL.'**
  String get signInInstanceRequired;

  /// Validation when the instance URL is not a valid https URL
  ///
  /// In en, this message translates to:
  /// **'Enter a valid https URL, for example https://gitlab.com.'**
  String get signInInstanceInvalid;

  /// Label for the token field
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token'**
  String get signInTokenLabel;

  /// Helper text under the token field
  ///
  /// In en, this message translates to:
  /// **'Needs the api and read_user scopes.'**
  String get signInTokenHelp;

  /// Tooltip for the token visibility toggle
  ///
  /// In en, this message translates to:
  /// **'Show or hide the token'**
  String get signInTokenToggle;

  /// Validation when the token is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a Personal Access Token.'**
  String get signInTokenRequired;

  /// Label for the sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSubmit;

  /// Shown when the instance returns 401
  ///
  /// In en, this message translates to:
  /// **'The token was rejected. Check that it is correct and has not expired.'**
  String get signInErrorToken;

  /// Shown when the instance returns 403
  ///
  /// In en, this message translates to:
  /// **'The token is missing a required scope. It needs api and read_user.'**
  String get signInErrorScope;

  /// Shown when the instance cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Could not reach that instance. Check the URL, your network, and whether the certificate is trusted.'**
  String get signInErrorUnreachable;

  /// Fallback sign-in error
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInErrorGeneric;

  /// Section heading on the home screen
  ///
  /// In en, this message translates to:
  /// **'My work'**
  String get homeMyWork;

  /// Home entry that opens the projects list
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get homeProjects;

  /// Title of the projects list screen
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// Shown when the projects list is empty
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any projects yet.'**
  String get projectsEmpty;

  /// Shown when the projects list fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load your projects.'**
  String get projectsError;

  /// Label for a retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Fallback title for the project overview screen
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectOverviewTitle;

  /// Shown when the project overview fails
  ///
  /// In en, this message translates to:
  /// **'Could not load this project.'**
  String get projectOverviewError;

  /// Shown when a project has no README
  ///
  /// In en, this message translates to:
  /// **'This project has no README.'**
  String get projectOverviewNoReadme;
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
      <String>['en', 'hi', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
