import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';

void main() {
  testWidgets('falls back to the name initial without an avatar url', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(
            user: User(id: 1, username: 'ari', name: 'Ari'),
          ),
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
  });
}
