import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_actions.dart';
import 'package:labfox/l10n/app_localizations.dart';

/// Records which action ran and can be told to reject with an exception.
class _StubActions extends MrActionsController {
  _StubActions({this.rejectMerge});

  final Object? rejectMerge;
  final List<String> ran = [];

  @override
  Future<void> build(MergeRequestRef arg) async {}

  @override
  Future<void> approve() async => ran.add('approve');

  @override
  Future<void> unapprove() async => ran.add('unapprove');

  @override
  Future<void> merge() async {
    ran.add('merge');
    if (rejectMerge != null) {
      throw rejectMerge!;
    }
  }
}

MergeRequest _mr() => const MergeRequest(
  id: 1,
  iid: 142,
  title: 'Add OAuth',
  state: 'opened',
  sourceBranch: 'a',
  targetBranch: 'b',
);

Future<_StubActions> _pump(WidgetTester tester, {Object? rejectMerge}) async {
  final stub = _StubActions(rejectMerge: rejectMerge);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mrActionsControllerProvider.overrideWith(() => stub),
        // No approvals endpoint in the test; treat as unavailable.
        mrApprovalsProvider.overrideWith((ref, arg) async => null),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MrActions(mr: _mr(), projectId: 1)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return stub;
}

void main() {
  testWidgets('approve runs the approve action', (tester) async {
    final stub = await _pump(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Approve'));
    await tester.pumpAndSettle();
    expect(stub.ran, ['approve']);
  });

  testWidgets('merge is guarded by a confirmation dialog', (tester) async {
    final stub = await _pump(tester);

    // Tapping merge opens the dialog but does not merge yet.
    await tester.tap(find.text('Merge'));
    await tester.pumpAndSettle();
    expect(find.text('Merge this merge request?'), findsOneWidget);
    expect(stub.ran, isEmpty);

    // Cancel: still no merge.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stub.ran, isEmpty);
  });

  testWidgets('confirming the dialog merges', (tester) async {
    final stub = await _pump(tester);
    await tester.tap(find.text('Merge'));
    await tester.pumpAndSettle();
    // The dialog's Merge button confirms (the second 'Merge' in the tree).
    await tester.tap(find.text('Merge').last);
    await tester.pumpAndSettle();
    expect(stub.ran, ['merge']);
  });

  testWidgets('a not-mergeable result shows a message', (tester) async {
    await _pump(
      tester,
      rejectMerge: const GitLabNotMergeableException('no', statusCode: 405),
    );
    await tester.tap(find.text('Merge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merge').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot be merged right now'), findsOneWidget);
  });
}
