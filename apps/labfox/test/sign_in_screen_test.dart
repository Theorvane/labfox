import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/app/app.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:labfox/core/auth/oauth_config.dart';
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

Future<void> _pump(
  WidgetTester tester,
  AuthRepository repo, {
  bool browserAuthorization = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(repo),
        browserAuthorizationProvider.overrideWithValue(browserAuthorization),
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
    // The screen says whose account it is asking for. Real users need it to
    // understand why an instance URL is being asked for at all, and App Review
    // has twice read this screen as a login that creates a LabFox account.
    expect(
      find.textContaining('LabFox has no account of its own'),
      findsOneWidget,
    );
  });

  // App Store Review Guideline 4.8 asks an app that offers a third-party login
  // service to offer another one beside it. LabFox has no account for such a
  // service to establish, and the guideline exempts a client whose users sign
  // in to their own third-party account — but review rejected the app three
  // times over the browser button regardless, twice after being told why.
  //
  // On Apple's platforms the button is therefore not offered at all. What is
  // left is a token the user issued to themselves on their own server, which
  // is not a login service under any reading. Everywhere else the button stays.
  testWidgets('offers no browser authorization where it is not available', (
    tester,
  ) async {
    await _pump(tester, _StubAuthRepository(), browserAuthorization: false);

    expect(find.text('Authorize with your instance'), findsNothing);
    expect(find.text('OAuth client ID'), findsNothing);
    expect(find.text('or'), findsNothing);
    // The token is still there, and is the whole screen.
    expect(find.text('Personal Access Token'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
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

    // 'Home' now appears in both the app bar and the navigation shell.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('My work'), findsOneWidget);
  });

  testWidgets('OAuth without a client id asks for one', (tester) async {
    await _pump(tester, _StubAuthRepository());

    // gitlab.com with no built-in client id (none is set in tests) and no
    // entered id cannot start OAuth.
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Authorize with your instance'),
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
      find.widgetWithText(OutlinedButton, 'Authorize with your instance'),
    );
    await tester.pumpAndSettle();

    // 'Home' now appears in both the app bar and the navigation shell.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('My work'), findsOneWidget);
  });
}
