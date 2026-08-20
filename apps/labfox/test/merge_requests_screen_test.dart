import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/merge_requests_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubMRs extends MergeRequestsController {
  _StubMRs(this._byState);
  final Map<MergeRequestState, AsyncValue<List<MergeRequest>>> _byState;

  @override
  Future<List<MergeRequest>> build(MergeRequestsQuery arg) {
    final value = _byState[arg.state] ?? const AsyncData(<MergeRequest>[]);
    return value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<List<MergeRequest>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Map<MergeRequestState, AsyncValue<List<MergeRequest>>> byState,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mergeRequestsControllerProvider.overrideWith(() => _StubMRs(byState)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MergeRequestsScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

MergeRequest _mr(int iid, String title, {String state = 'opened'}) =>
    MergeRequest(
      id: iid * 100,
      iid: iid,
      title: title,
      state: state,
      sourceBranch: 'feature/x',
      targetBranch: 'develop',
    );

void main() {
  testWidgets('shows a merge-blocker chip from detailed_merge_status', (
    tester,
  ) async {
    await _pump(tester, {
      MergeRequestState.opened: const AsyncData([
        MergeRequest(
          id: 1,
          iid: 7,
          title: 'blocked',
          state: 'opened',
          sourceBranch: 'a',
          targetBranch: 'main',
          detailedMergeStatus: 'conflict',
        ),
      ]),
    });
    await tester.pumpAndSettle();

    expect(find.text('Conflicts'), findsOneWidget);
  });

  testWidgets('lists open MRs with their iid and state', (tester) async {
    await _pump(tester, {
      MergeRequestState.opened: AsyncData([_mr(142, 'Add OAuth')]),
    });
    await tester.pumpAndSettle();

    expect(find.text('Add OAuth'), findsOneWidget);
    expect(find.textContaining('!142'), findsOneWidget);
    // 'Open' appears both as the filter and the row's status pill.
    expect(find.text('Open'), findsWidgets);
  });

  testWidgets('switching to Merged loads merged MRs', (tester) async {
    await _pump(tester, {
      MergeRequestState.opened: AsyncData([_mr(1, 'open mr')]),
      MergeRequestState.merged: AsyncData([
        _mr(2, 'merged mr', state: 'merged'),
      ]),
    });
    await tester.pumpAndSettle();
    expect(find.text('open mr'), findsOneWidget);

    await tester.tap(find.text('Merged'));
    await tester.pumpAndSettle();

    expect(find.text('merged mr'), findsOneWidget);
    expect(find.text('open mr'), findsNothing);
  });

  testWidgets('marks a draft with a Draft pill', (tester) async {
    final draft = _mr(5, 'wip').copyWith(draft: true);
    await _pump(tester, {
      MergeRequestState.opened: AsyncData([draft]),
    });
    await tester.pumpAndSettle();
    expect(find.text('wip'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });
}
