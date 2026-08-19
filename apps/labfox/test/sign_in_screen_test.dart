import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/app/app.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives sign-in through the real widget tree so routing and validation are
/// exercised together.
class _StubAuthRepository implements AuthRepository {
  Account? _active;

  @override
  Account? currentAccount() => _active;

  @override
  Future<Account> signInWithToken({
    required String instanceUrl,
    required String token,
  }) async {
    if (token != 'glpat-valid') {
      throw const GitLabAuthException('rejected', statusCode: 401);
    }
    _active = Account(
      instanceUrl: instanceUrl,
      user: const User(id: 1, username: 'jungwon', name: 'Jungwon'),
    );
    return _active!;
  }

  @override
  Future<Account> signInWithOAuth({
    required String instanceUrl,
    required String clientId,
  }) async {
    if (clientId != 'good-client') {
      throw const GitLabAuthException('denied', statusCode: 401);
    }
    _active = Account(
      instanceUrl: instanceUrl,
      user: const User(id: 1, username: 'jungwon', name: 'Jungwon'),
      authMethod: AuthMethod.oauth,
      oauthClientId: clientId,
    );
    return _active!;
  }

  @override
  Future<String?> refreshOAuthAccessToken(Account account) async => null;

  @override
  Future<void> signOut([Account? account]) async => _active = null;

  @override
  List<Account> accounts() => _active == null ? const [] : [_active!];

  @override
  Future<void> switchTo(Account account) async => _active = account;

  @override
  Future<String?> tokenFor(Account account) async => 'glpat-valid';
}

Future<void> _pump(WidgetTester tester, AuthRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const LabFoxApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on the sign-in screen when signed out', (tester) async {
    await _pump(tester, _StubAuthRepository());

    expect(find.text('Connect a GitLab account'), findsOneWidget);
  });

  testWidgets('rejects an empty token without calling the repository', (
    tester,
  ) async {
    await _pump(tester, _StubAuthRepository());

    await tester.enterText(
      find.byType(TextFormField).first,
      'https://gitlab.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a Personal Access Token.'), findsOneWidget);
    expect(find.text('Connect a GitLab account'), findsOneWidget);
  });

  testWidgets('shows a token-specific error when the instance rejects it', (
    tester,
  ) async {
    await _pump(tester, _StubAuthRepository());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://gitlab.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('token was rejected'), findsOneWidget);
  });

  testWidgets('a valid token lands on the home screen', (tester) async {
    await _pump(tester, _StubAuthRepository());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://gitlab.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'glpat-valid');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Signed in as jungwon'), findsOneWidget);
  });

  testWidgets('OAuth without a client id asks for one', (tester) async {
    await _pump(tester, _StubAuthRepository());

    // gitlab.com with no built-in client id (none is set in tests) and no
    // entered id cannot start OAuth.
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Sign in with GitLab'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Enter an OAuth client ID for this instance.'),
      findsOneWidget,
    );
  });

  testWidgets('OAuth with a client id lands on the home screen', (
    tester,
  ) async {
    await _pump(tester, _StubAuthRepository());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://gitlab.com',
    );
    // The third field is the OAuth client id.
    await tester.enterText(find.byType(TextFormField).at(2), 'good-client');
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Sign in with GitLab'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Signed in as jungwon'), findsOneWidget);
  });
}
