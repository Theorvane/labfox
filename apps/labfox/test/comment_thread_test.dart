import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/comments/presentation/widgets/comment_thread.dart';
import 'package:labfox/l10n/app_localizations.dart';

/// A controller stub that records posts and can be told to reject them.
class _StubComments extends CommentsController {
  _StubComments(this._initial, {this.rejectWith});

  final List<Note> _initial;
  final Object? rejectWith;
  final List<String> posted = [];

  /// When set, post() awaits this so a test can hold a post in flight and
  /// control when it completes.
  Completer<void>? gate;

  @override
  Future<List<Note>> build(CommentsRef arg) async => _initial;

  @override
  Future<void> post(String body) async {
    if (gate != null) {
      await gate!.future;
    }
    if (rejectWith != null) {
      throw rejectWith!;
    }
    posted.add(body);
    state = AsyncData([
      ..._initial,
      Note(
        id: 999,
        body: body,
        author: const User(id: 1, username: 'me', name: 'Me'),
      ),
    ]);
  }
}

Future<_StubComments> _pump(
  WidgetTester tester, {
  List<Note> initial = const [],
  Object? rejectWith,
}) async {
  final stub = _StubComments(initial, rejectWith: rejectWith);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [commentsControllerProvider.overrideWith(() => stub)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CommentThread(
              type: NoteableType.issue,
              projectId: 1,
              iid: 5,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return stub;
}

Note _note(String body, {bool system = false}) => Note(
  id: body.hashCode,
  body: body,
  isSystem: system,
  author: const User(id: 1, username: 'jungwon', name: 'J'),
);

void main() {
  testWidgets('a failed post after the widget is disposed does not throw', (
    tester,
  ) async {
    final stub = _StubComments(
      const [],
      rejectWith: const GitLabForbiddenException('no'),
    );
    stub.gate = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [commentsControllerProvider.overrideWith(() => stub)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CommentThread(type: NoteableType.issue, projectId: 1, iid: 5),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'x');
    await tester.tap(find.widgetWithText(FilledButton, 'Comment'));
    await tester.pump(); // in flight, awaiting the gate

    // Navigate away: dispose CommentThread while the post is pending.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    stub.gate!.complete(); // let the in-flight post fail now
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders comments and filters out system notes', (tester) async {
    await _pump(
      tester,
      initial: [
        _note('real comment'),
        _note('changed the milestone', system: true),
      ],
    );

    // The body renders through MarkdownViewer, so assert on its data: the real
    // comment produces one viewer, the system note produces none.
    final viewers = tester.widgetList<MarkdownViewer>(
      find.byType(MarkdownViewer),
    );
    expect(viewers.map((v) => v.data), ['real comment']);
  });

  testWidgets('shows an empty message when there are no comments', (
    tester,
  ) async {
    await _pump(tester, initial: const []);
    expect(find.textContaining('No comments'), findsOneWidget);
  });

  testWidgets('posts a typed comment through the controller', (tester) async {
    final stub = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'nice work');
    await tester.tap(find.widgetWithText(FilledButton, 'Comment'));
    await tester.pumpAndSettle();

    expect(stub.posted, ['nice work']);
  });

  testWidgets('shows a permission message when posting is forbidden', (
    tester,
  ) async {
    await _pump(
      tester,
      rejectWith: const GitLabForbiddenException('no', statusCode: 403),
    );

    await tester.enterText(find.byType(TextField), 'x');
    await tester.tap(find.widgetWithText(FilledButton, 'Comment'));
    await tester.pumpAndSettle();

    expect(find.textContaining('do not have permission'), findsOneWidget);
  });
}
