import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/repository/presentation/controllers/repository_browser_controller.dart';
import 'package:labfox/features/repository/presentation/repository_browser_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubDir extends DirectoryController {
  _StubDir(this._value);
  final AsyncValue<List<RepositoryEntry>> _value;

  @override
  Future<List<RepositoryEntry>> build(DirectoryRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<List<RepositoryEntry>>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<List<RepositoryEntry>> value,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        directoryControllerProvider.overrideWith(() => _StubDir(value)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepositoryBrowserScreen(projectId: 1, ref: 'main'),
      ),
    ),
  );
  await tester.pump();
}

RepositoryEntry _dir(String name) =>
    RepositoryEntry(id: name, name: name, type: 'tree', path: name);
RepositoryEntry _file(String name) =>
    RepositoryEntry(id: name, name: name, type: 'blob', path: name);

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lists entries with folder and file icons', (tester) async {
    await _pump(tester, AsyncData([_dir('src'), _file('README.md')]));
    await tester.pumpAndSettle();

    expect(find.text('src'), findsOneWidget);
    expect(find.text('README.md'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
  });

  testWidgets('shows an empty message for an empty directory', (tester) async {
    await _pump(tester, const AsyncData(<RepositoryEntry>[]));
    await tester.pumpAndSettle();
    expect(find.textContaining('empty'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(tester, AsyncError(Exception('x'), StackTrace.current));
    await tester.pump();
    expect(
      find.textContaining('Could not load this directory'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
