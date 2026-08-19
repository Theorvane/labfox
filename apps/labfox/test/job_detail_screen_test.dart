import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/jobs/presentation/controllers/job_controllers.dart';
import 'package:labfox/features/jobs/presentation/job_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Job job,
  required String trace,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobDetailProvider.overrideWith((ref, arg) async => job),
        jobTraceProvider.overrideWith((ref, arg) async => trace),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JobDetailScreen(projectId: 1, jobId: 7001),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the job status header and renders the log', (
    tester,
  ) async {
    await _pump(
      tester,
      job: const Job(
        id: 7001,
        name: 'unit-test',
        status: 'failed',
        stage: 'test',
      ),
      trace: 'Running\n\x1b[31mAssertionError\x1b[0m\nBUILD FAILED',
    );

    // The status header spells out the state and names the stage.
    expect(find.text('Failed'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    // The job name reads as the header title (and the app bar).
    expect(find.text('unit-test'), findsWidgets);
    // The log renders through AnsiLogView.
    expect(find.byType(AnsiLogView), findsOneWidget);
  });

  testWidgets('shows an empty-log message when there is no output', (
    tester,
  ) async {
    await _pump(
      tester,
      job: const Job(id: 1, name: 'noop', status: 'success'),
      trace: '',
    );
    expect(find.byType(AnsiLogView), findsNothing);
    expect(find.textContaining('no log output'), findsOneWidget);
  });
}
