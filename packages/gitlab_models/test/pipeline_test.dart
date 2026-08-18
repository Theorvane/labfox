import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Pipeline', () {
    test('parses id, status, ref, and sha', () {
      final p = Pipeline.fromJson(const {
        'id': 944,
        'status': 'failed',
        'ref': 'main',
        'sha': 'abc123def',
        'created_at': '2026-08-18T02:00:00.000Z',
      });

      expect(p.id, 944);
      expect(p.status, 'failed');
      expect(p.ref, 'main');
      expect(p.shortSha, 'abc123de');
      expect(p.ciStatus, CiStatus.failed);
    });
  });

  group('Job', () {
    test('parses name, stage, and status', () {
      final j = Job.fromJson(const {
        'id': 7001,
        'name': 'unit-test',
        'stage': 'test',
        'status': 'success',
      });

      expect(j.name, 'unit-test');
      expect(j.stage, 'test');
      expect(j.ciStatus, CiStatus.success);
    });

    test('exposes which actions its status allows', () {
      Job withStatus(String s) => Job(id: 1, name: 'x', status: s);

      // Finished jobs can be retried, not cancelled.
      expect(withStatus('failed').canRetry, isTrue);
      expect(withStatus('success').canRetry, isTrue);
      expect(withStatus('canceled').canRetry, isTrue);
      expect(withStatus('failed').canCancel, isFalse);

      // Active jobs can be cancelled, not retried.
      expect(withStatus('running').canCancel, isTrue);
      expect(withStatus('pending').canCancel, isTrue);
      expect(withStatus('running').canRetry, isFalse);

      // A manual job can be played.
      expect(withStatus('manual').canPlay, isTrue);
      expect(withStatus('failed').canPlay, isFalse);
    });
  });

  group('CiStatus.parse', () {
    test('maps known GitLab statuses', () {
      expect(CiStatus.parse('success'), CiStatus.success);
      expect(CiStatus.parse('failed'), CiStatus.failed);
      expect(CiStatus.parse('running'), CiStatus.running);
      expect(CiStatus.parse('pending'), CiStatus.pending);
      expect(CiStatus.parse('canceled'), CiStatus.canceled);
      expect(CiStatus.parse('skipped'), CiStatus.skipped);
      expect(CiStatus.parse('manual'), CiStatus.manual);
      expect(CiStatus.parse('created'), CiStatus.created);
    });

    test('maps an unknown status to other, not a crash', () {
      expect(CiStatus.parse('waiting_for_resource'), CiStatus.other);
    });
  });
}
