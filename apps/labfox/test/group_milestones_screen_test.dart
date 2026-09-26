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

class _GroupList extends GroupMilestoneListController {
  @override
  Future<Paginated<GitLabMilestone>> build(GroupMilestoneListRef arg) async =>
      Paginated(
        items: [
          GitLabMilestone(
            id: arg.state == 'active' ? 12 : 13,
            iid: arg.state == 'active' ? 3 : 4,
            groupId: arg.groupId,
            title: arg.state == 'active' ? '10.0' : '9.0',
            state: arg.state,
          ),
        ],
      );
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/groups/7/milestones',
    routes: [
      GoRoute(
        path: '/groups/:id/milestones',
        builder: (_, state) => MilestonesScreen.group(
          groupId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/groups/:id/milestones/:milestoneId',
        builder: (_, state) => MilestoneDetailScreen.group(
          groupId: int.parse(state.pathParameters['id']!),
          milestoneId: int.parse(state.pathParameters['milestoneId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupMilestoneListControllerProvider.overrideWith(_GroupList.new),
        groupMilestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 12,
            iid: 3,
            groupId: 7,
            title: '10.0',
            state: 'active',
            description: '## Group plan',
          ),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('filters and opens a group milestone by global ID on mobile', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('10.0'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('9.0'), findsOneWidget);
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.0'));
    await tester.pumpAndSettle();
    final detail = tester.widget<MilestoneDetailScreen>(
      find.byType(MilestoneDetailScreen),
    );
    expect(detail.groupId, 7);
    expect(detail.milestoneId, 12);
    expect(find.text('Group plan'), findsOneWidget);
  });

  testWidgets('fits a wide group milestone list', (tester) async {
    await _pump(tester, const Size(1200, 800));
    expect(find.text('10.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
