import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubMR extends MergeRequestController {
  _StubMR(this._value);
  final AsyncValue<MergeRequest> _value;

  @override
  Future<MergeRequest> build(MergeRequestRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<MergeRequest>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<MergeRequest> value) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mergeRequestControllerProvider.overrideWith(() => _StubMR(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MergeRequestDetailScreen(projectId: 1, iid: 142),
      ),
    ),
  );
  await tester.pump();
}

MergeRequest _mr({String state = 'opened', List<Label> labels = const []}) =>
    MergeRequest(
      id: 55123,
      iid: 142,
      title: 'Add OAuth authentication',
      state: state,
      sourceBranch: 'feature/oauth',
      targetBranch: 'develop',
      description: 'Adds the OAuth flow.',
      labels: labels,
    );

void main() {
  testWidgets('renders branches, state, labels, and description', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _mr(
          labels: const [Label(name: 'backend', color: '#0e8a16')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add OAuth authentication'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    // '!142' appears in the app bar and the header.
    expect(find.textContaining('!142'), findsWidgets);
    // Source and target branches render in the branch chip.
    expect(find.text('feature/oauth'), findsOneWidget);
    expect(find.text('develop'), findsOneWidget);
    expect(find.byType(GitLabLabel), findsOneWidget);
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('a merged MR shows the Merged state, not closed', (tester) async {
    await _pump(tester, AsyncData(_mr(state: 'merged')));
    await tester.pumpAndSettle();

    expect(find.text('Merged'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
  });
}
