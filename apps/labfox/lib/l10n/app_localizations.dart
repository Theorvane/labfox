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

  /// Home section heading for merge requests awaiting the user's review
  ///
  /// In en, this message translates to:
  /// **'Review requests'**
  String get homeReviewRequests;

  /// Home section heading for merge requests assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned merge requests'**
  String get homeAssignedMergeRequests;

  /// Home section heading for issues assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned issues'**
  String get homeAssignedIssues;

  /// Shown on the home feed when the user has no review requests or assigned work
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get homeWorkAllClear;

  /// Shown when the home work feed fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your work.'**
  String get homeWorkError;

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

  /// Divider between the token and OAuth sign-in options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// Button that starts the OAuth browser sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in with GitLab'**
  String get signInOAuthButton;

  /// Label for the OAuth client id field
  ///
  /// In en, this message translates to:
  /// **'OAuth client ID'**
  String get signInClientIdLabel;

  /// Helper text for the OAuth client id field
  ///
  /// In en, this message translates to:
  /// **'Only for OAuth on a self-hosted instance.'**
  String get signInClientIdHelp;

  /// Shown when OAuth is started without a usable client id
  ///
  /// In en, this message translates to:
  /// **'Enter an OAuth client ID for this instance.'**
  String get signInOAuthNeedsClientId;

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

  /// Tooltip for the action that shares the item's web link
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLink;

  /// Row chip when a merge request has merge conflicts
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get mrBlockerConflicts;

  /// Row chip when a merge request's required pipeline has not passed
  ///
  /// In en, this message translates to:
  /// **'Checks failed'**
  String get mrBlockerChecksFailed;

  /// Row chip when a merge request's pipeline is still running
  ///
  /// In en, this message translates to:
  /// **'CI running'**
  String get mrBlockerCiRunning;

  /// Row chip when a merge request still needs approval
  ///
  /// In en, this message translates to:
  /// **'Needs approval'**
  String get mrBlockerNeedsApproval;

  /// Row chip when a merge request has unresolved discussion threads
  ///
  /// In en, this message translates to:
  /// **'Unresolved threads'**
  String get mrBlockerUnresolved;

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

  /// Overview link that opens the repository browser
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get projectOverviewRepository;

  /// Title of the repository browser at the root
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get repositoryTitle;

  /// Shown when a directory listing fails
  ///
  /// In en, this message translates to:
  /// **'Could not load this directory.'**
  String get repositoryError;

  /// Shown for an empty directory
  ///
  /// In en, this message translates to:
  /// **'This directory is empty.'**
  String get repositoryEmpty;

  /// Shown when a file fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this file.'**
  String get fileError;

  /// Shown when a file does not exist
  ///
  /// In en, this message translates to:
  /// **'This file was not found.'**
  String get fileNotFound;

  /// Shown for a binary file
  ///
  /// In en, this message translates to:
  /// **'This is a binary file and cannot be shown as text.'**
  String get fileBinary;

  /// Overview link that opens the branches list
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get projectOverviewBranches;

  /// Overview link that opens the commits list
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get projectOverviewCommits;

  /// Title of the branches screen
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchesTitle;

  /// Shown when the branches list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load branches.'**
  String get branchesError;

  /// Shown for a repository with no branches
  ///
  /// In en, this message translates to:
  /// **'This repository has no branches.'**
  String get branchesEmpty;

  /// Label marking the default branch
  ///
  /// In en, this message translates to:
  /// **'Default branch'**
  String get branchDefault;

  /// Title of the commits screen
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get commitsTitle;

  /// Shown when the commits list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load commits.'**
  String get commitsError;

  /// Shown for a branch with no commits
  ///
  /// In en, this message translates to:
  /// **'No commits on this branch yet.'**
  String get commitsEmpty;

  /// Fallback title for the commit detail screen
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get commitTitle;

  /// Shown when a commit fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this commit.'**
  String get commitError;

  /// Overview link that opens the issues list
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get projectOverviewIssues;

  /// Title of the issues list screen
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issuesTitle;

  /// Label for the open-issues filter
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get issuesFilterOpen;

  /// Label for the closed-issues filter
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get issuesFilterClosed;

  /// Shown when the issues list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load issues.'**
  String get issuesError;

  /// Shown when the issues list is empty
  ///
  /// In en, this message translates to:
  /// **'No issues here.'**
  String get issuesEmpty;

  /// Shown when an issue fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this issue.'**
  String get issueError;

  /// Issue state badge, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get issueStateOpen;

  /// Issue state badge, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get issueStateClosed;

  /// Shown when an issue has no description
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get issueNoDescription;

  /// Attribution line on an issue
  ///
  /// In en, this message translates to:
  /// **'opened by {username}'**
  String issueOpenedBy(String username);

  /// Overview link that opens the merge requests list
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get projectOverviewMergeRequests;

  /// Title of the merge requests list screen
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get mergeRequestsTitle;

  /// Merge requests filter, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mrFilterOpen;

  /// Merge requests filter, merged
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get mrFilterMerged;

  /// Merge requests filter, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mrFilterClosed;

  /// Shown when the MR list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load merge requests.'**
  String get mergeRequestsError;

  /// Shown when the MR list is empty
  ///
  /// In en, this message translates to:
  /// **'No merge requests here.'**
  String get mergeRequestsEmpty;

  /// Shown when an MR fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this merge request.'**
  String get mergeRequestError;

  /// Shown when an MR has no description
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get mergeRequestNoDescription;

  /// MR state badge, open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mrStateOpen;

  /// MR state badge, merged
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get mrStateMerged;

  /// MR state badge, closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get mrStateClosed;

  /// Label marking a draft MR
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get mrDraft;

  /// Title of the changed-files (diff) screen
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get changesTitle;

  /// Shown when a diff fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load the changes.'**
  String get changesError;

  /// Shown when there are no file changes
  ///
  /// In en, this message translates to:
  /// **'No changes.'**
  String get changesEmpty;

  /// Shown for a binary file in a diff
  ///
  /// In en, this message translates to:
  /// **'Binary file — not shown.'**
  String get changesBinary;

  /// Button on commit detail that opens the diff
  ///
  /// In en, this message translates to:
  /// **'View changes'**
  String get commitViewChanges;

  /// Button on MR detail that opens the diff
  ///
  /// In en, this message translates to:
  /// **'View changes'**
  String get mrViewChanges;

  /// Shown for a text file whose diff GitLab omitted (too large or collapsed)
  ///
  /// In en, this message translates to:
  /// **'Diff not shown because it is too large or collapsed.'**
  String get changesOmitted;

  /// Heading above a comment thread
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsHeading;

  /// Shown when comments fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load comments.'**
  String get commentsError;

  /// Shown when there are no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get commentsEmpty;

  /// Placeholder in the comment composer
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get commentComposerHint;

  /// Button to post a comment
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentComposerSubmit;

  /// Shown when posting a comment is forbidden (403)
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to comment here. Check that your token has the api scope.'**
  String get commentPostForbidden;

  /// Generic comment post error
  ///
  /// In en, this message translates to:
  /// **'Could not post your comment. Please try again.'**
  String get commentPostError;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to approve a merge request
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get mrApprove;

  /// Button to remove approval
  ///
  /// In en, this message translates to:
  /// **'Revoke approval'**
  String get mrUnapprove;

  /// Button to merge a merge request
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mrMerge;

  /// Title of the sheet that lets the user pick how to merge
  ///
  /// In en, this message translates to:
  /// **'Merge method'**
  String get mrMergeMethodTitle;

  /// Merge method that keeps every commit and adds a merge commit
  ///
  /// In en, this message translates to:
  /// **'Merge commit'**
  String get mrMergeCommit;

  /// Merge method that squashes all commits into one
  ///
  /// In en, this message translates to:
  /// **'Squash and merge'**
  String get mrMergeSquash;

  /// Shown when GitLab reports the merge request can be merged
  ///
  /// In en, this message translates to:
  /// **'Ready to merge'**
  String get mrReadyToMerge;

  /// Shown when GitLab reports the merge request is not mergeable
  ///
  /// In en, this message translates to:
  /// **'Cannot be merged yet'**
  String get mrCannotMergeNow;

  /// Merge confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Merge this merge request?'**
  String get mrMergeConfirmTitle;

  /// Merge confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Merging {mr} cannot be undone.'**
  String mrMergeConfirmBody(String mr);

  /// Approval summary line
  ///
  /// In en, this message translates to:
  /// **'{approved} of {required} approvals'**
  String mrApprovalsSummary(int approved, int required);

  /// Shown when a merge is rejected as not mergeable
  ///
  /// In en, this message translates to:
  /// **'This merge request cannot be merged right now. It may need approval, a rebase, or a passing pipeline.'**
  String get mrNotMergeable;

  /// Shown when an approve/merge is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action. Check your token scope and role.'**
  String get mrActionForbidden;

  /// Generic MR action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get mrActionError;

  /// Overview link that opens the pipelines list
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get projectOverviewPipelines;

  /// Title of the pipelines list screen
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get pipelinesTitle;

  /// Shown when the pipelines list fails
  ///
  /// In en, this message translates to:
  /// **'Could not load pipelines.'**
  String get pipelinesError;

  /// Shown when there are no pipelines
  ///
  /// In en, this message translates to:
  /// **'No pipelines yet.'**
  String get pipelinesEmpty;

  /// Shown when a pipeline fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this pipeline.'**
  String get pipelineError;

  /// Shown when a pipeline's jobs fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load jobs.'**
  String get pipelineJobsError;

  /// Shown when a pipeline has no jobs
  ///
  /// In en, this message translates to:
  /// **'This pipeline has no jobs.'**
  String get pipelineNoJobs;

  /// Fallback title for the job detail screen
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get jobTitle;

  /// Shown when a job fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load this job.'**
  String get jobError;

  /// Tooltip for the job refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get jobRefresh;

  /// Shown when a job log fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load the log.'**
  String get jobLogError;

  /// Shown when a job has no log
  ///
  /// In en, this message translates to:
  /// **'This job has no log output.'**
  String get jobLogEmpty;

  /// Button to retry a job
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get jobActionRetry;

  /// Button to cancel a job
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get jobActionCancel;

  /// Button to run a manual job
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get jobActionRun;

  /// Shown when a job action is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get jobActionForbidden;

  /// Shown when a job action conflicts with status
  ///
  /// In en, this message translates to:
  /// **'This action is not available for the job\'s current state.'**
  String get jobActionInvalid;

  /// Generic job action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get jobActionError;

  /// Button to retry a pipeline
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pipelineActionRetry;

  /// Button to cancel a pipeline
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pipelineActionCancel;

  /// Shown when a pipeline action is forbidden
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get pipelineActionForbidden;

  /// Shown when a pipeline action conflicts with status
  ///
  /// In en, this message translates to:
  /// **'This action is not available for the pipeline\'s current state.'**
  String get pipelineActionInvalid;

  /// Generic pipeline action error
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get pipelineActionError;

  /// Title of the accounts switcher screen
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// Button to add another account
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAdd;

  /// Tooltip for removing an account
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get accountRemove;

  /// Home action that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeSwitchAccount;

  /// Home entry that opens the to-do inbox
  ///
  /// In en, this message translates to:
  /// **'To-do list'**
  String get homeInbox;

  /// Title of the to-do inbox screen
  ///
  /// In en, this message translates to:
  /// **'To-do list'**
  String get inboxTitle;

  /// Shown when the to-do inbox has no pending items
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get inboxEmpty;

  /// Shown when the to-do list fails to load
  ///
  /// In en, this message translates to:
  /// **'Your to-do items could not be loaded.'**
  String get inboxError;

  /// Action that clears every pending to-do item
  ///
  /// In en, this message translates to:
  /// **'Mark all as done'**
  String get inboxMarkAllDone;

  /// Tooltip for clearing a single to-do item
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get inboxMarkDone;

  /// Shown when marking a to-do item done fails
  ///
  /// In en, this message translates to:
  /// **'The item could not be cleared. Please try again.'**
  String get inboxMarkDoneError;

  /// To-do reason: the item was assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned to you'**
  String get inboxActionAssigned;

  /// To-do reason: the user was mentioned
  ///
  /// In en, this message translates to:
  /// **'Mentioned you'**
  String get inboxActionMentioned;

  /// To-do reason: a pipeline the user owns failed
  ///
  /// In en, this message translates to:
  /// **'Pipeline failed'**
  String get inboxActionBuildFailed;

  /// To-do reason: the user added the item to their list
  ///
  /// In en, this message translates to:
  /// **'Added a to-do'**
  String get inboxActionMarked;

  /// To-do reason: the user's approval is required
  ///
  /// In en, this message translates to:
  /// **'Approval required'**
  String get inboxActionApprovalRequired;

  /// To-do reason: the merge request cannot be merged
  ///
  /// In en, this message translates to:
  /// **'Cannot be merged'**
  String get inboxActionUnmergeable;

  /// To-do reason: the user was directly addressed
  ///
  /// In en, this message translates to:
  /// **'Directly addressed you'**
  String get inboxActionDirectlyAddressed;

  /// Home entry that opens search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearch;

  /// Title of the search screen
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Placeholder in the search field
  ///
  /// In en, this message translates to:
  /// **'Search projects, issues, merge requests'**
  String get searchHint;

  /// Search scope: projects
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get searchScopeProjects;

  /// Search scope: issues
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get searchScopeIssues;

  /// Search scope: merge requests
  ///
  /// In en, this message translates to:
  /// **'Merge requests'**
  String get searchScopeMergeRequests;

  /// Shown before the user has entered a search term
  ///
  /// In en, this message translates to:
  /// **'Type to search.'**
  String get searchInitial;

  /// Shown when a search returns nothing
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchEmpty;

  /// Shown when a search request fails
  ///
  /// In en, this message translates to:
  /// **'The search could not be completed.'**
  String get searchError;

  /// Button that loads the next page of search results
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get searchLoadMore;

  /// Tooltip for favoriting a project
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get projectAddFavorite;

  /// Tooltip for unfavoriting a project
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get projectRemoveFavorite;

  /// Home section title for favorited projects
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings entry that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsAccounts;

  /// Settings entry that opens the open-source license page
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get settingsLicenses;

  /// Bottom navigation / rail label for the home destination
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation / rail label for the inbox destination
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Bottom navigation / rail label for the search destination
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom navigation / rail label for the profile destination
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Title of the profile (Me) screen
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// Profile entry that opens settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// Profile entry that opens the account switcher
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get meAccounts;

  /// Home section title for recently opened projects
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecents;
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
