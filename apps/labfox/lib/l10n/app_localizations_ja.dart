// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => 'ホーム';

  @override
  String homeSignedInAs(String username) {
    return '$username としてサインイン中';
  }

  @override
  String get homeEmptyWork => '課題、マージリクエスト、パイプラインがここに表示されます。';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signInTitle => 'GitLab アカウントを接続';

  @override
  String get signInInstanceLabel => 'GitLab インスタンス URL';

  @override
  String get signInInstanceRequired => 'GitLab インスタンスの URL を入力してください。';

  @override
  String get signInInstanceInvalid =>
      '有効な https URL を入力してください。例: https://gitlab.com';

  @override
  String get signInTokenLabel => 'パーソナルアクセストークン';

  @override
  String get signInTokenHelp => 'api と read_user のスコープが必要です。';

  @override
  String get signInTokenToggle => 'トークンの表示 / 非表示';

  @override
  String get signInTokenRequired => 'パーソナルアクセストークンを入力してください。';

  @override
  String get signInSubmit => 'サインイン';

  @override
  String get signInErrorToken => 'トークンが拒否されました。正しいか、有効期限が切れていないか確認してください。';

  @override
  String get signInErrorScope => 'トークンに必要なスコープがありません。api と read_user が必要です。';

  @override
  String get signInErrorUnreachable =>
      'そのインスタンスに接続できませんでした。URL、ネットワーク、証明書の信頼を確認してください。';

  @override
  String get signInErrorGeneric => 'サインインに失敗しました。もう一度お試しください。';
}
