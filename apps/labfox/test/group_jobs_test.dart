import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

void main() {
  group('groupJobsByStage', () {
    test('groups jobs by stage, preserving first-seen stage order', () {
      final jobs = [
        const Job(id: 1, name: 'compile', status: 'success', stage: 'build'),
        const Job(id: 2, name: 'unit', status: 'failed', stage: 'test'),
        const Job(id: 3, name: 'lint', status: 'success', stage: 'test'),
        const Job(id: 4, name: 'docker', status: 'success', stage: 'build'),
      ];

      final grouped = groupJobsByStage(jobs);

      // build appears before test; both keep their jobs.
      expect(grouped.keys.toList(), ['build', 'test']);
      expect(grouped['build']!.map((j) => j.name), ['compile', 'docker']);
      expect(grouped['test']!.map((j) => j.name), ['unit', 'lint']);
    });

    test('a job without a stage groups under an empty key', () {
      final grouped = groupJobsByStage([
        const Job(id: 1, name: 'x', status: 'success'),
      ]);
      expect(grouped.keys, ['']);
    });
  });
}
