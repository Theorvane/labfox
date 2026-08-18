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

  @override
  String get homeMyWork => 'マイワーク';

  @override
  String get homeProjects => 'プロジェクト';

  @override
  String get projectsTitle => 'プロジェクト';

  @override
  String get projectsEmpty => 'まだどのプロジェクトにも参加していません。';

  @override
  String get projectsError => 'プロジェクトを読み込めませんでした。';

  @override
  String get retry => '再試行';

  @override
  String get projectOverviewTitle => 'プロジェクト';

  @override
  String get projectOverviewError => 'このプロジェクトを読み込めませんでした。';

  @override
  String get projectOverviewNoReadme => 'このプロジェクトには README がありません。';

  @override
  String get projectOverviewRepository => 'リポジトリ';

  @override
  String get repositoryTitle => 'リポジトリ';

  @override
  String get repositoryError => 'このディレクトリを読み込めませんでした。';

  @override
  String get repositoryEmpty => 'このディレクトリは空です。';

  @override
  String get fileError => 'このファイルを読み込めませんでした。';

  @override
  String get fileNotFound => 'ファイルが見つかりませんでした。';

  @override
  String get fileBinary => 'バイナリファイルのためテキストとして表示できません。';

  @override
  String get projectOverviewBranches => 'ブランチ';

  @override
  String get projectOverviewCommits => 'コミット';

  @override
  String get branchesTitle => 'ブランチ';

  @override
  String get branchesError => 'ブランチを読み込めませんでした。';

  @override
  String get branchesEmpty => 'このリポジトリにはブランチがありません。';

  @override
  String get branchDefault => 'デフォルトブランチ';

  @override
  String get commitsTitle => 'コミット';

  @override
  String get commitsError => 'コミットを読み込めませんでした。';

  @override
  String get commitsEmpty => 'このブランチにはまだコミットがありません。';

  @override
  String get commitTitle => 'コミット';

  @override
  String get commitError => 'このコミットを読み込めませんでした。';

  @override
  String get projectOverviewIssues => '課題';

  @override
  String get issuesTitle => '課題';

  @override
  String get issuesFilterOpen => 'オープン';

  @override
  String get issuesFilterClosed => 'クローズ';

  @override
  String get issuesError => '課題を読み込めませんでした。';

  @override
  String get issuesEmpty => '課題はありません。';

  @override
  String get issueError => 'この課題を読み込めませんでした。';

  @override
  String get issueStateOpen => 'オープン';

  @override
  String get issueStateClosed => 'クローズ';

  @override
  String get issueNoDescription => '説明はありません。';

  @override
  String issueOpenedBy(String username) {
    return '$username が作成';
  }

  @override
  String get projectOverviewMergeRequests => 'マージリクエスト';

  @override
  String get mergeRequestsTitle => 'マージリクエスト';

  @override
  String get mrFilterOpen => 'オープン';

  @override
  String get mrFilterMerged => 'マージ済み';

  @override
  String get mrFilterClosed => 'クローズ';

  @override
  String get mergeRequestsError => 'マージリクエストを読み込めませんでした。';

  @override
  String get mergeRequestsEmpty => 'マージリクエストはありません。';

  @override
  String get mergeRequestError => 'このマージリクエストを読み込めませんでした。';

  @override
  String get mergeRequestNoDescription => '説明はありません。';

  @override
  String get mrStateOpen => 'オープン';

  @override
  String get mrStateMerged => 'マージ済み';

  @override
  String get mrStateClosed => 'クローズ';

  @override
  String get mrDraft => '下書き';
}
