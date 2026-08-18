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
}
