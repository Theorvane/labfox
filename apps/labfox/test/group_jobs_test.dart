import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

void main() {
  group('groupJobsByStage', () {
    test('restores execution order from GitLab newest-first jobs', () {
      final jobs = [
        const Job(id: 30, name: 'release', status: 'created', stage: 'deploy'),
        const Job(
          id: 21,
          name: 'integration',
          status: 'success',
          stage: 'test',
        ),
        const Job(id: 20, name: 'unit', status: 'failed', stage: 'test'),
        const Job(id: 10, name: 'compile', status: 'success', stage: 'build'),
      ];

      final grouped = groupJobsByStage(jobs);

      expect(grouped.keys.toList(), ['build', 'test', 'deploy']);
      expect(grouped['test']!.map((j) => j.name), ['unit', 'integration']);
    });

    test('a job without a stage groups under an empty key', () {
      final grouped = groupJobsByStage([
        const Job(id: 1, name: 'x', status: 'success'),
      ]);
      expect(grouped.keys, ['']);
    });
  });
}
