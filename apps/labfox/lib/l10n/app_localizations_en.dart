// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'Home';

  @override
  String homeSignedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get homeEmptyWork =>
      'Your issues, merge requests and pipelines will appear here.';

  @override
  String get homeReviewRequests => 'Review requests';

  @override
  String get homeAssignedMergeRequests => 'Assigned merge requests';

  @override
  String get homeAssignedIssues => 'Assigned issues';

  @override
  String get homeWorkAllClear => 'You\'re all caught up.';

  @override
  String get homeWorkError => 'Couldn\'t load your work.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Connect a GitLab account';

  @override
  String get signInInstanceLabel => 'GitLab instance URL';

  @override
  String get signInInstanceRequired => 'Enter your GitLab instance URL.';

  @override
  String get signInInstanceInvalid =>
      'Enter a valid https URL, for example https://gitlab.com.';

  @override
  String get signInTokenLabel => 'Personal Access Token';

  @override
  String get signInTokenHelp => 'Needs the api and read_user scopes.';

  @override
  String get signInTokenToggle => 'Show or hide the token';

  @override
  String get signInTokenRequired => 'Enter a Personal Access Token.';

  @override
  String get signInSubmit => 'Sign in';

  @override
  String get signInOr => 'or';

  @override
  String get signInOAuthButton => 'Sign in with GitLab';

  @override
  String get signInClientIdLabel => 'OAuth client ID';

  @override
  String get signInClientIdHelp => 'Only for OAuth on a self-hosted instance.';

  @override
  String get signInOAuthNeedsClientId =>
      'Enter an OAuth client ID for this instance.';

  @override
  String get signInErrorToken =>
      'The token was rejected. Check that it is correct and has not expired.';

  @override
  String get signInErrorScope =>
      'The token is missing a required scope. It needs api and read_user.';

  @override
  String get signInErrorUnreachable =>
      'Could not reach that instance. Check the URL, your network, and whether the certificate is trusted.';

  @override
  String get signInErrorGeneric => 'Sign-in failed. Please try again.';

  @override
  String get scopeAssigned => 'Assigned';

  @override
  String get scopeCreated => 'Created';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeFavoritesEmpty => 'Star projects to pin them here.';

  @override
  String get homeMyWork => 'My work';

  @override
  String get homeProjects => 'Projects';

  @override
  String get homeGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsEmpty => 'You are not a member of any groups yet.';

  @override
  String get groupsError => 'Could not load your groups.';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsEmpty => 'You are not a member of any projects yet.';

  @override
  String get projectsError => 'Could not load your projects.';

  @override
  String get shareLink => 'Share';

  @override
  String get mrClose => 'Close';

  @override
  String get mrReopen => 'Reopen';

  @override
  String get mrRebase => 'Rebase';

  @override
  String get mrMarkDraft => 'Mark as draft';

  @override
  String get mrMarkReady => 'Mark as ready';

  @override
  String get mrBlockerConflicts => 'Conflicts';

  @override
  String get mrBlockerChecksFailed => 'Checks failed';

  @override
  String get mrBlockerCiRunning => 'CI running';

  @override
  String get mrBlockerNeedsApproval => 'Needs approval';

  @override
  String get mrBlockerUnresolved => 'Unresolved threads';

  @override
  String get retry => 'Retry';

  @override
  String get newIssueTitle => 'New issue';

  @override
  String get newIssueTitleLabel => 'Title';

  @override
  String get newIssueTitleRequired => 'Enter a title.';

  @override
  String get newIssueDescriptionLabel => 'Description (optional)';

  @override
  String get newIssueSubmit => 'Create issue';

  @override
  String get newIssueError => 'Could not create the issue. Please try again.';

  @override
  String get newIssueButton => 'New issue';

  @override
  String get issueClose => 'Close issue';

  @override
  String get issueReopen => 'Reopen issue';

  @override
  String get issueStateError => 'Could not update the issue. Please try again.';

  @override
  String get newMrTitle => 'New merge request';

  @override
  String get newMrSourceLabel => 'Source branch';

  @override
  String get newMrTargetLabel => 'Target branch';

  @override
  String get newMrTitleLabel => 'Title';

  @override
  String get newMrDescriptionLabel => 'Description (optional)';

  @override
  String get newMrBranchRequired => 'Enter a branch.';

  @override
  String get newMrTitleRequired => 'Enter a title.';

  @override
  String get newMrSubmit => 'Create merge request';

  @override
  String get newMrError =>
      'Could not create the merge request. Please try again.';

  @override
  String get newMrButton => 'New merge request';

  @override
  String get projectOverviewTitle => 'Project';

  @override
  String get projectOverviewError => 'Could not load this project.';

  @override
  String get projectOverviewNoReadme => 'This project has no README.';

  @override
  String get projectOverviewRepository => 'Repository';

  @override
  String get repositoryTitle => 'Repository';

  @override
  String get repositoryError => 'Could not load this directory.';

  @override
  String get repositoryEmpty => 'This directory is empty.';

  @override
  String get fileError => 'Could not load this file.';

  @override
  String get fileNotFound => 'This file was not found.';

  @override
  String get fileBinary => 'This is a binary file and cannot be shown as text.';

  @override
  String get fileCopy => 'Copy contents';

  @override
  String get fileCopied => 'Contents copied';

  @override
  String get projectOverviewBranches => 'Branches';

  @override
  String get projectOverviewCommits => 'Commits';

  @override
  String get projectOverviewCode => 'Code';

  @override
  String get projectOverviewBrowseCode => 'Browse code';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get branchesError => 'Could not load branches.';

  @override
  String get branchesEmpty => 'This repository has no branches.';

  @override
  String get newBranchTitle => 'New branch';

  @override
  String get newBranchNameLabel => 'Branch name';

  @override
  String get newBranchFromLabel => 'Create from';

  @override
  String get newBranchNameRequired => 'Enter a branch name.';

  @override
  String get newBranchFromRequired => 'Enter a source branch or ref.';

  @override
  String get newBranchCreate => 'Create branch';

  @override
  String get newBranchError => 'Could not create the branch. Please try again.';

  @override
  String get newBranchButton => 'New branch';

  @override
  String get branchDefault => 'Default branch';

  @override
  String get commitsTitle => 'Commits';

  @override
  String get commitsError => 'Could not load commits.';

  @override
  String get commitsEmpty => 'No commits on this branch yet.';

  @override
  String get commitTitle => 'Commit';

  @override
  String get commitError => 'Could not load this commit.';

  @override
  String get projectOverviewIssues => 'Issues';

  @override
  String get issuesTitle => 'Issues';

  @override
  String get issuesFilterOpen => 'Open';

  @override
  String get issuesFilterClosed => 'Closed';

  @override
  String get issuesError => 'Could not load issues.';

  @override
  String get issuesEmpty => 'No issues here.';

  @override
  String get issueError => 'Could not load this issue.';

  @override
  String get issueStateOpen => 'Open';

  @override
  String get issueStateClosed => 'Closed';

  @override
  String get issueNoDescription => 'No description provided.';

  @override
  String issueOpenedBy(String username) {
    return 'opened by $username';
  }

  @override
  String get projectOverviewMergeRequests => 'Merge requests';

  @override
  String get mergeRequestsTitle => 'Merge requests';

  @override
  String get mrFilterOpen => 'Open';

  @override
  String get mrFilterMerged => 'Merged';

  @override
  String get mrFilterClosed => 'Closed';

  @override
  String get mergeRequestsError => 'Could not load merge requests.';

  @override
  String get mergeRequestsEmpty => 'No merge requests here.';

  @override
  String get mergeRequestError => 'Could not load this merge request.';

  @override
  String get mergeRequestNoDescription => 'No description provided.';

  @override
  String get mrStateOpen => 'Open';

  @override
  String get mrStateMerged => 'Merged';

  @override
  String get mrStateClosed => 'Closed';

  @override
  String get mrDraft => 'Draft';

  @override
  String get changesTitle => 'Changes';

  @override
  String get changesError => 'Could not load the changes.';

  @override
  String get changesEmpty => 'No changes.';

  @override
  String get changesBinary => 'Binary file — not shown.';

  @override
  String get commitViewChanges => 'View changes';

  @override
  String get mrViewChanges => 'View changes';

  @override
  String get changesOmitted =>
      'Diff not shown because it is too large or collapsed.';

  @override
  String get commentsHeading => 'Comments';

  @override
  String get commentsError => 'Could not load comments.';

  @override
  String get commentsEmpty => 'No comments yet.';

  @override
  String get commentComposerHint => 'Write a comment…';

  @override
  String get commentComposerSubmit => 'Comment';

  @override
  String get commentPostForbidden =>
      'You do not have permission to comment here. Check that your token has the api scope.';

  @override
  String get commentPostError =>
      'Could not post your comment. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get mrApprove => 'Approve';

  @override
  String get mrUnapprove => 'Revoke approval';

  @override
  String get mrMerge => 'Merge';

  @override
  String get mrMergeMethodTitle => 'Merge method';

  @override
  String get mrMergeCommit => 'Merge commit';

  @override
  String get mrMergeSquash => 'Squash and merge';

  @override
  String get mrReadyToMerge => 'Ready to merge';

  @override
  String get mrCannotMergeNow => 'Cannot be merged yet';

  @override
  String get mrMergeConfirmTitle => 'Merge this merge request?';

  @override
  String mrMergeConfirmBody(String mr) {
    return 'Merging $mr cannot be undone.';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '$approved of $required approvals';
  }

  @override
  String get mrNotMergeable =>
      'This merge request cannot be merged right now. It may need approval, a rebase, or a passing pipeline.';

  @override
  String get mrActionForbidden =>
      'You do not have permission for this action. Check your token scope and role.';

  @override
  String get mrActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get projectOverviewPipelines => 'Pipelines';

  @override
  String get pipelinesTitle => 'Pipelines';

  @override
  String get pipelinesError => 'Could not load pipelines.';

  @override
  String get pipelinesEmpty => 'No pipelines yet.';

  @override
  String get pipelineError => 'Could not load this pipeline.';

  @override
  String get pipelineJobsError => 'Could not load jobs.';

  @override
  String get pipelineNoJobs => 'This pipeline has no jobs.';

  @override
  String get jobTitle => 'Job';

  @override
  String get jobError => 'Could not load this job.';

  @override
  String get jobRefresh => 'Refresh';

  @override
  String get jobLogError => 'Could not load the log.';

  @override
  String get jobLogEmpty => 'This job has no log output.';

  @override
  String get jobActionRetry => 'Retry';

  @override
  String get jobActionCancel => 'Cancel';

  @override
  String get jobActionRun => 'Run';

  @override
  String get jobActionForbidden =>
      'You do not have permission for this action.';

  @override
  String get jobActionInvalid =>
      'This action is not available for the job\'s current state.';

  @override
  String get jobActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get pipelineActionRetry => 'Retry';

  @override
  String get pipelineActionCancel => 'Cancel';

  @override
  String get pipelineActionForbidden =>
      'You do not have permission for this action.';

  @override
  String get pipelineActionInvalid =>
      'This action is not available for the pipeline\'s current state.';

  @override
  String get pipelineActionError =>
      'The action could not be completed. Please try again.';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountAdd => 'Add account';

  @override
  String get accountRemove => 'Remove account';

  @override
  String get homeSwitchAccount => 'Accounts';

  @override
  String get homeInbox => 'To-do list';

  @override
  String get inboxTitle => 'To-do list';

  @override
  String get inboxEmpty => 'You\'re all caught up.';

  @override
  String get inboxDoneEmpty => 'Nothing marked done yet.';

  @override
  String get inboxFilterPending => 'Pending';

  @override
  String get inboxFilterDone => 'Done';

  @override
  String get inboxFilterAllTypes => 'All types';

  @override
  String get inboxTypeIssues => 'Issues';

  @override
  String get inboxTypeMergeRequests => 'Merge requests';

  @override
  String get inboxFilterAllReasons => 'All reasons';

  @override
  String get inboxError => 'Your to-do items could not be loaded.';

  @override
  String get inboxMarkAllDone => 'Mark all as done';

  @override
  String get inboxMarkDone => 'Mark done';

  @override
  String get inboxMarkDoneError =>
      'The item could not be cleared. Please try again.';

  @override
  String get inboxActionAssigned => 'Assigned to you';

  @override
  String get inboxActionMentioned => 'Mentioned you';

  @override
  String get inboxActionBuildFailed => 'Pipeline failed';

  @override
  String get inboxActionMarked => 'Added a to-do';

  @override
  String get inboxActionApprovalRequired => 'Approval required';

  @override
  String get inboxActionUnmergeable => 'Cannot be merged';

  @override
  String get inboxActionDirectlyAddressed => 'Directly addressed you';

  @override
  String get homeSearch => 'Search';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search projects, issues, merge requests';

  @override
  String get searchScopeProjects => 'Projects';

  @override
  String get searchScopeIssues => 'Issues';

  @override
  String get searchScopeMergeRequests => 'Merge requests';

  @override
  String get searchInitial => 'Type to search.';

  @override
  String get searchEmpty => 'No results found.';

  @override
  String get searchError => 'The search could not be completed.';

  @override
  String get searchLoadMore => 'Load more';

  @override
  String get listSearchHint => 'Search by title';

  @override
  String get listSearchClose => 'Close search';

  @override
  String get projectAddFavorite => 'Add to favorites';

  @override
  String get projectRemoveFavorite => 'Remove from favorites';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of service';

  @override
  String get settingsWebsite => 'Website';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsBackgroundChecks => 'Background to-do checks';

  @override
  String get settingsBackgroundChecksHelp =>
      'LabFox checks your to-do list in the background and notifies you about new items. Android checks about every 15 minutes; iOS decides when, so this is a background check rather than instant push.';

  @override
  String get paywallNotifications =>
      'Background to-do checks are part of the subscription. The to-do inbox and manual refresh stay free.';

  @override
  String get settingsNotificationsDenied =>
      'LabFox cannot show notifications until you allow them in system settings.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get meShareProfile => 'Share profile';

  @override
  String get settingsLicenses => 'Open source licenses';

  @override
  String get paywallTitle => 'A subscription unlocks this';

  @override
  String get paywallSubscribe => 'See the subscription';

  @override
  String get paywallNotNow => 'Not now';

  @override
  String get paywallMergeRequestActions =>
      'Approving and merging are part of the subscription. Reading merge requests, diffs, and discussions stays free.';

  @override
  String get paywallPipelineActions =>
      'Retrying, cancelling, and running manual jobs are part of the subscription. Watching pipelines and reading job logs stays free.';

  @override
  String get paywallAccounts =>
      'One account is free. Connecting more instances is part of the subscription.';

  @override
  String paywallFavorites(int count) {
    return 'Free keeps $count favorites. The subscription removes the limit.';
  }

  @override
  String get subscriptionTitle => 'LabFox subscription';

  @override
  String get subscriptionActive => 'Subscribed';

  @override
  String get subscriptionInactive => 'Not subscribed';

  @override
  String get subscriptionPitch =>
      'Approve and merge, retry pipelines, and connect more than one account.';

  @override
  String get subscriptionBenefitAccounts =>
      'Connect multiple accounts and self-hosted instances';

  @override
  String get subscriptionBenefitActions =>
      'Approve, merge, retry, cancel, and run manual jobs';

  @override
  String get subscriptionBenefitNotifications =>
      'Background checks that notify you about new to-do items';

  @override
  String get subscriptionBenefitFavorites =>
      'Unlimited favorites, instead of the free limit of three';

  @override
  String subscriptionSubscribe(String price) {
    return 'Subscribe for $price';
  }

  @override
  String get subscriptionRestore => 'Restore purchases';

  @override
  String get subscriptionUnavailable =>
      'The store is not available right now. Try again later.';

  @override
  String get subscriptionError =>
      'That did not go through. Nothing was charged.';

  @override
  String get subscriptionRestored => 'Your subscription is active.';

  @override
  String get subscriptionNothingToRestore =>
      'No subscription found for this store account.';

  @override
  String get navHome => 'Home';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navSearch => 'Search';

  @override
  String get navMe => 'Me';

  @override
  String get meTitle => 'Me';

  @override
  String get meSettings => 'Settings';

  @override
  String get meAccounts => 'Switch account';

  @override
  String get homeRecents => 'Recent';
}
