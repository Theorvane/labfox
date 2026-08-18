import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

Future<void> _pump(WidgetTester tester, FileDiff file) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: DiffViewer(file: file)),
      ),
    ),
  );
}

FileDiff _diff(String diff) => FileDiff(
  oldPath: 'a.dart',
  newPath: 'a.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff: diff,
);

void main() {
  testWidgets('renders added, removed, and context lines', (tester) async {
    await _pump(tester, _diff('@@ -1,2 +1,2 @@\n keep\n-old\n+new\n'));

    expect(find.textContaining('keep'), findsOneWidget);
    expect(find.textContaining('old'), findsOneWidget);
    expect(find.textContaining('new'), findsOneWidget);
    // The hunk header is shown.
    expect(find.textContaining('@@ -1,2 +1,2 @@'), findsOneWidget);
  });

  testWidgets('shows a placeholder for a binary file', (tester) async {
    // A binary file has an empty diff and is not a rename.
    final binary = FileDiff(
      oldPath: 'logo.png',
      newPath: 'logo.png',
      isNew: false,
      isDeleted: false,
      isRenamed: false,
      diff: '',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiffViewer(file: binary, binaryLabel: 'Binary file, not shown'),
        ),
      ),
    );
    expect(find.text('Binary file, not shown'), findsOneWidget);
  });
}
