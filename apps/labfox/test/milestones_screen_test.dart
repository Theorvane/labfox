import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';
import 'package:labfox/features/milestones/presentation/milestone_detail_screen.dart';
import 'package:labfox/features/milestones/presentation/milestones_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends MilestoneListController {
  @override
  Future<Paginated<GitLabMilestone>> build(MilestoneListRef arg) async =>
      Paginated(
        items: [
          GitLabMilestone(
            id: arg.state == 'active' ? 12 : 13,
            iid: arg.state == 'active' ? 3 : 4,
            title: arg.state == 'active' ? '10.0' : '9.0',
            state: arg.state,
          ),
        ],
      );
}

Future<void> _pump(
  WidgetTester tester, {
  Size? size,
  bool dark = false,
  String initialLocation = '/projects/7/milestones',
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/projects/:id/milestones',
        builder: (_, state) =>
            MilestonesScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id/milestones/:milestoneId',
        builder: (_, state) => MilestoneDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          milestoneId: int.parse(state.pathParameters['milestoneId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        milestoneListControllerProvider.overrideWith(_List.new),
        milestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 12,
            iid: 3,
            title: '10.0',
            state: 'active',
            description: '## Planned work',
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('filters active and closed milestones', (tester) async {
    await _pump(tester);
    expect(find.text('10.0'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('9.0'), findsOneWidget);
    expect(find.text('10.0'), findsNothing);
  });

  testWidgets('opens project milestone by global ID', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('10.0'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MilestoneDetailScreen>(find.byType(MilestoneDetailScreen))
          .milestoneId,
      12,
    );
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('fits a narrow dark screen', (tester) async {
    await _pump(tester, size: const Size(390, 844), dark: true);
    expect(find.text('10.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('places description beside metadata on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(1200, 800),
      initialLocation: '/projects/7/milestones/12',
    );
    expect(
      tester.getTopLeft(find.byType(MarkdownViewer)).dx,
      greaterThan(tester.getTopLeft(find.text('Active')).dx + 150),
    );
  });
}
