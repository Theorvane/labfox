import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

/// GitLab's pipelines list returns `source` — why the pipeline ran — and the
/// model was dropping it.
///
/// It answers a question the other fields cannot. Two pipelines on `master`
/// with the same status look identical until you know one was `scheduled` and
/// the other came from a `push`; gitlab.com shows it as a tag beside the ref
/// for exactly that reason. It arrives in the list response already, so
/// surfacing it costs no extra request.
void main() {
  group('source', () {
    test('is read from the API response', () {
      final pipeline = Pipeline.fromJson(const {
        'id': 2783405198,
        'status': 'running',
        'ref': 'master',
        'source': 'schedule',
      });

      expect(pipeline.source, 'schedule');
    });

    test('is null when the instance does not send it', () {
      // Older instances and some endpoints omit it. Null must not become an
      // empty tag in the UI.
      final pipeline = Pipeline.fromJson(const {'id': 1, 'status': 'success'});

      expect(pipeline.source, isNull);
    });

    test('reads as a label rather than an API token', () {
      // GitLab sends snake_case values like `merge_request_event`; showing
      // that verbatim beside human text reads as a leaked internal.
      expect(
        const Pipeline(
          id: 1,
          status: 'running',
          source: 'merge_request_event',
        ).sourceLabel,
        'merge request',
      );
      expect(
        const Pipeline(
          id: 1,
          status: 'running',
          source: 'schedule',
        ).sourceLabel,
        'scheduled',
      );
      expect(
        const Pipeline(id: 1, status: 'running', source: 'push').sourceLabel,
        'push',
      );
    });

    test('an unknown source still reads cleanly', () {
      // GitLab adds sources over time; an unmapped one should degrade to
      // readable text, never to a blank or to raw snake_case.
      expect(
        const Pipeline(
          id: 1,
          status: 'running',
          source: 'external_pull_request_event',
        ).sourceLabel,
        'external pull request',
      );
      expect(const Pipeline(id: 1, status: 'running').sourceLabel, isNull);
    });
  });
}
