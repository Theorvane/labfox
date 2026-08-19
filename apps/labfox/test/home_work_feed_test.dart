import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/home/data/home_work.dart';
import 'package:labfox/features/home/presentation/controllers/home_work_controllers.dart';
import 'package:labfox/features/home/presentation/home_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubWork extends HomeWorkController {
  _StubWork(this._value);
  final AsyncValue<HomeWork> _value;

  @override
  Future<HomeWork> build() {
    return _value.when(
      data: Future.value,
      loading: () => Completer<HomeWork>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<HomeWork> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeWorkControllerProvider.overrideWith(() => _StubWork(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeWorkFeed(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows review requests and assigned work with status pills', (
    tester,
  ) async {
    await _pump(
      tester,
      const AsyncData(
        HomeWork(
          reviewRequests: [
            MergeRequest(
              id: 1,
              iid: 9,
              title: 'please review this',
              state: 'opened',
              sourceBranch: 'a',
              targetBranch: 'main',
              projectId: 7,
            ),
          ],
          assignedMergeRequests: [
            MergeRequest(
              id: 2,
              iid: 12,
              title: 'my open change',
              state: 'opened',
              sourceBranch: 'b',
              targetBranch: 'main',
              projectId: 7,
            ),
          ],
          assignedIssues: [
            Issue(
              id: 3,
              iid: 42,
              title: 'a bug to fix',
              state: 'opened',
              projectId: 7,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('please review this'), findsOneWidget);
    expect(find.text('my open change'), findsOneWidget);
    expect(find.text('a bug to fix'), findsOneWidget);
    // Merge request rows carry the !iid, the issue row the #iid.
    expect(find.text('!9'), findsOneWidget);
    expect(find.text('!12'), findsOneWidget);
    expect(find.text('#42'), findsOneWidget);
  });

  testWidgets('shows an all-clear state when there is no work', (tester) async {
    await _pump(
      tester,
      const AsyncData(
        HomeWork(
          reviewRequests: [],
          assignedMergeRequests: [],
          assignedIssues: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkTile), findsNothing);
    expect(find.textContaining('caught up'), findsOneWidget);
  });
}
