import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/home/data/home_work.dart';
import 'package:labfox/features/home/presentation/controllers/home_work_controllers.dart';
import 'package:labfox/features/home/presentation/home_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _EmptyWork extends HomeWorkController {
  @override
  Future<HomeWork> build() async => const HomeWork(
    reviewRequests: [],
    assignedMergeRequests: [],
    assignedIssues: [],
  );
}

void main() {
  testWidgets('home shows the My Work launcher tiles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeWorkControllerProvider.overrideWith(_EmptyWork.new),
          // Signed out keeps the project sections empty without touching prefs.
          currentAccountProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My work'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('To-do list'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}
