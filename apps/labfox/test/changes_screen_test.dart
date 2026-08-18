import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/diff/presentation/changes_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

/// A simple provider the test can drive, standing in for the commit/MR diff
/// providers the real screens pass.
final _testDiffProvider = FutureProvider<List<FileDiff>>((ref) async {
  return _completer.future;
});
late Completer<List<FileDiff>> _completer;

Future<void> _pump(WidgetTester tester) async {
  _completer = Completer<List<FileDiff>>();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangesScreen(title: 'abc123', provider: _testDiffProvider),
      ),
    ),
  );
  await tester.pump();
}

FileDiff _diff(String path, String diff, {bool isNew = false}) => FileDiff(
  oldPath: path,
  newPath: path,
  isNew: isNew,
  isDeleted: false,
  isRenamed: false,
  diff: diff,
);

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders each changed file with its diff', (tester) async {
    await _pump(tester);
    _completer.complete([
      _diff('lib/a.dart', '@@ -1 +1 @@\n-old\n+new\n'),
      _diff('lib/b.dart', '@@ -1 +1 @@\n-x\n+y\n', isNew: true),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('lib/a.dart'), findsOneWidget);
    expect(find.text('lib/b.dart'), findsOneWidget);
    expect(find.byType(DiffViewer), findsNWidgets(2));
    expect(find.textContaining('new'), findsWidgets);
  });

  testWidgets('shows an empty message when nothing changed', (tester) async {
    await _pump(tester);
    _completer.complete(const []);
    await tester.pumpAndSettle();
    expect(find.textContaining('No changes'), findsOneWidget);
  });
}
