import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/inbox/data/inbox_repository.dart';
import 'package:labfox/features/inbox/presentation/controllers/inbox_controllers.dart';
import 'package:labfox/features/inbox/presentation/inbox_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Todo _todo(int id, String title, {String state = 'pending'}) => Todo(
  id: id,
  state: state,
  actionName: 'assigned',
  targetType: 'Issue',
  body: title,
  project: const Project(id: 7, name: 'p', pathWithNamespace: 'g/p'),
  target: TodoTarget(iid: id, title: title),
);

class _FakeRepo extends InboxRepository {
  _FakeRepo(this.todos, {this.doneTodos = const []})
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'glpat-x'));

  List<Todo> todos;
  List<Todo> doneTodos;
  bool fail = false;
  final List<String> stateCalls = [];
  final List<int> doneCalls = [];
  bool markedAll = false;

  @override
  Future<List<Todo>> list({
    required TodoState state,
    TodoType? type,
    TodoAction? action,
  }) async {
    stateCalls.add(
      '${state.value}/${type?.value ?? '-'}/${action?.value ?? '-'}',
    );
    return state == TodoState.pending ? todos : doneTodos;
  }

  @override
  Future<void> markDone(int id) async {
    if (fail) throw StateError('boom');
    doneCalls.add(id);
  }

  @override
  Future<void> markAllDone() async {
    if (fail) throw StateError('boom');
    markedAll = true;
  }
}

Future<void> _pump(WidgetTester tester, _FakeRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [inboxRepositoryProvider.overrideWith((ref) async => repo)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: InboxScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('InboxController', () {
    test('marking a todo done removes it optimistically', () async {
      final repo = _FakeRepo([_todo(1, 'a'), _todo(2, 'b')]);
      final container = ProviderContainer(
        overrides: [inboxRepositoryProvider.overrideWith((ref) async => repo)],
      );
      addTearDown(container.dispose);

      await container.read(inboxControllerProvider(const InboxQuery()).future);
      await container
          .read(inboxControllerProvider(const InboxQuery()).notifier)
          .markDone(1);

      final ids = container
          .read(inboxControllerProvider(const InboxQuery()))
          .value!
          .map((t) => t.id)
          .toList();
      expect(ids, [2]);
      expect(repo.doneCalls, [1]);
    });

    test('a failed mark-done rolls the row back', () async {
      final repo = _FakeRepo([_todo(1, 'a')])..fail = true;
      final container = ProviderContainer(
        overrides: [inboxRepositoryProvider.overrideWith((ref) async => repo)],
      );
      addTearDown(container.dispose);

      await container.read(inboxControllerProvider(const InboxQuery()).future);
      await expectLater(
        container
            .read(inboxControllerProvider(const InboxQuery()).notifier)
            .markDone(1),
        throwsA(isA<StateError>()),
      );

      final ids = container
          .read(inboxControllerProvider(const InboxQuery()))
          .value!
          .map((t) => t.id)
          .toList();
      expect(ids, [1]);
    });
  });

  group('InboxScreen', () {
    testWidgets('lists pending todos', (tester) async {
      await _pump(tester, _FakeRepo([_todo(1, 'Fix login'), _todo(2, 'Ship')]));
      expect(find.text('Fix login'), findsOneWidget);
      expect(find.text('Ship'), findsOneWidget);
      // Project context stays distinct from the target number so both scan
      // predictably in a dense mobile list.
      expect(find.text('g/p'), findsNWidgets(2));
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('shows an empty state when there is nothing to do', (
      tester,
    ) async {
      await _pump(tester, _FakeRepo([]));
      expect(find.text("You're all caught up."), findsOneWidget);
    });

    testWidgets('the check button clears a row', (tester) async {
      final repo = _FakeRepo([_todo(1, 'Fix login')]);
      await _pump(tester, repo);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.text('Fix login'), findsNothing);
      expect(repo.doneCalls, [1]);
    });

    testWidgets('a failed clear restores the row and warns', (tester) async {
      final repo = _FakeRepo([_todo(1, 'Fix login')])..fail = true;
      await _pump(tester, repo);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.text('Fix login'), findsOneWidget);
      expect(
        find.text('The item could not be cleared. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('the Done filter lists cleared todos read-only', (
      tester,
    ) async {
      final repo = _FakeRepo(
        [_todo(1, 'Fix login')],
        doneTodos: [_todo(9, 'Old review', state: 'done')],
      );
      await _pump(tester, repo);

      await tester.tap(find.byType(FilterMenuChip<TodoState>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();

      expect(repo.stateCalls, ['pending/-/-', 'done/-/-']);
      expect(find.text('Old review'), findsOneWidget);
      expect(find.text('Fix login'), findsNothing);
      // Done items cannot be cleared again: no per-row check, no swipe, no
      // mark-all-done.
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('the type filter narrows the list', (tester) async {
      final repo = _FakeRepo([_todo(1, 'Fix login')]);
      await _pump(tester, repo);

      await tester.tap(find.byType(FilterMenuChip<TodoType?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Issues').last);
      await tester.pumpAndSettle();

      expect(repo.stateCalls, ['pending/-/-', 'pending/Issue/-']);
    });

    testWidgets('the reason filter narrows the list', (tester) async {
      // Three chips need more width than the default test surface.
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repo = _FakeRepo([_todo(1, 'Fix login')]);
      await _pump(tester, repo);

      await tester.tap(find.byType(FilterMenuChip<TodoAction?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mentioned you').last);
      await tester.pumpAndSettle();

      expect(repo.stateCalls, ['pending/-/-', 'pending/-/mentioned']);
    });

    testWidgets('switching back to Pending restores the actions', (
      tester,
    ) async {
      final repo = _FakeRepo([_todo(1, 'Fix login')]);
      await _pump(tester, repo);

      await tester.tap(find.byType(FilterMenuChip<TodoState>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilterMenuChip<TodoState>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pending').last);
      await tester.pumpAndSettle();

      expect(find.text('Fix login'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
