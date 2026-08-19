import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubJobs extends PipelineJobsController {
  _StubJobs(this._value);
  final List<Job> _value;

  @override
  Future<List<Job>> build(PipelineRef arg) async => _value;
}

Future<void> _pump(
  WidgetTester tester, {
  required Pipeline pipeline,
  List<Job> jobs = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineDetailProvider.overrideWith((ref, arg) async => pipeline),
        pipelineJobsControllerProvider.overrideWith(() => _StubJobs(jobs)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PipelineDetailScreen(projectId: 1, pipelineId: 944),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('header shows the ref, a status pill and the pipeline number', (
    tester,
  ) async {
    await _pump(
      tester,
      pipeline: const Pipeline(
        id: 944,
        status: 'failed',
        ref: 'main',
        sha: 'abcdef1234567890',
      ),
    );

    // The branch ref reads as the header title.
    expect(find.text('main'), findsOneWidget);
    // The status pill spells out the state.
    expect(find.text('Failed'), findsOneWidget);
    // The pipeline number appears (app bar and header meta).
    expect(find.textContaining('#944'), findsWidgets);
    // The short SHA is shown, not the full 40-char one.
    expect(find.text('abcdef12'), findsOneWidget);
  });

  testWidgets('jobs render grouped by stage with a status pill each', (
    tester,
  ) async {
    await _pump(
      tester,
      pipeline: const Pipeline(id: 944, status: 'running', ref: 'main'),
      jobs: const [
        Job(id: 1, name: 'compile', status: 'success', stage: 'build'),
        Job(id: 2, name: 'unit', status: 'running', stage: 'test'),
      ],
    );

    expect(find.text('compile'), findsOneWidget);
    expect(find.text('unit'), findsOneWidget);
    // Each job carries its own status pill.
    expect(find.text('Success'), findsOneWidget);
    // 'Running' appears on the pipeline header pill and the job pill.
    expect(find.text('Running'), findsWidgets);
    // Stage names head their groups.
    expect(find.text('build'), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
  });
}
