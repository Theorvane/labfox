import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/repository/presentation/controllers/file_controller.dart';
import 'package:labfox/features/repository/presentation/file_viewer_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubFile extends FileController {
  _StubFile(this._value);
  final AsyncValue<RepositoryFile?> _value;

  @override
  Future<RepositoryFile?> build(FileRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<RepositoryFile?>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<RepositoryFile?> value,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [fileControllerProvider.overrideWith(() => _StubFile(value))],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FileViewerScreen(
          projectId: 1,
          ref: 'main',
          path: 'lib/main.dart',
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders text file contents', (tester) async {
    final file = RepositoryFile.fromBytes(
      Uint8List.fromList('final x = 1;'.codeUnits),
    );
    await _pump(tester, AsyncData(file));
    await tester.pumpAndSettle();
    expect(find.text('final x = 1;'), findsOneWidget);
  });

  testWidgets('shows a placeholder for a binary file, not garbage', (
    tester,
  ) async {
    final file = RepositoryFile.fromBytes(
      Uint8List.fromList([0x89, 0x50, 0x00, 0x01]),
    );
    await _pump(tester, AsyncData(file));
    await tester.pumpAndSettle();
    expect(find.textContaining('binary file'), findsOneWidget);
  });

  testWidgets('shows not-found when the file is absent', (tester) async {
    await _pump(tester, const AsyncData(null));
    await tester.pumpAndSettle();
    expect(find.textContaining('not found'), findsOneWidget);
  });
}
