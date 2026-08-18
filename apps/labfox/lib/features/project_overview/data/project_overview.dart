import 'package:gitlab_models/gitlab_models.dart';

/// The project plus its README, loaded together for the overview screen.
class ProjectOverview {
  const ProjectOverview({required this.project, this.readme});

  final Project project;

  /// The raw README markdown, or null when the project has none.
  final String? readme;
}
