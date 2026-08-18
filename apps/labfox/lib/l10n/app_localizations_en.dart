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
  String get homeMyWork => 'My work';

  @override
  String get homeProjects => 'Projects';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsEmpty => 'You are not a member of any projects yet.';

  @override
  String get projectsError => 'Could not load your projects.';

  @override
  String get retry => 'Retry';

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
  String get projectOverviewBranches => 'Branches';

  @override
  String get projectOverviewCommits => 'Commits';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get branchesError => 'Could not load branches.';

  @override
  String get branchesEmpty => 'This repository has no branches.';

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
}
