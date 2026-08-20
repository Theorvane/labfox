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
  String get homeReviewRequests => 'Review requests';

  @override
  String get homeAssignedMergeRequests => 'Assigned merge requests';

  @override
  String get homeAssignedIssues => 'Assigned issues';

  @override
  String get homeWorkAllClear => 'You\'re all caught up.';

  @override
  String get homeWorkError => 'Couldn\'t load your work.';

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
  String get signInOr => 'または';

  @override
  String get signInOAuthButton => 'GitLab でサインイン';

  @override
  String get signInClientIdLabel => 'OAuth クライアント ID';

  @override
  String get signInClientIdHelp => 'self-hosted インスタンスで OAuth を使う場合のみ必要です。';

  @override
  String get signInOAuthNeedsClientId => 'このインスタンスの OAuth クライアント ID を入力してください。';

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
  String get shareLink => 'Share';

  @override
  String get mrBlockerConflicts => 'Conflicts';

  @override
  String get mrBlockerChecksFailed => 'Checks failed';

  @override
  String get mrBlockerCiRunning => 'CI running';

  @override
  String get mrBlockerNeedsApproval => 'Needs approval';

  @override
  String get mrBlockerUnresolved => 'Unresolved threads';

  @override
  String get retry => '再試行';

  @override
  String get newIssueTitle => 'New issue';

  @override
  String get newIssueTitleLabel => 'Title';

  @override
  String get newIssueTitleRequired => 'Enter a title.';

  @override
  String get newIssueDescriptionLabel => 'Description (optional)';

  @override
  String get newIssueSubmit => 'Create issue';

  @override
  String get newIssueError => 'Could not create the issue. Please try again.';

  @override
  String get newIssueButton => 'New issue';

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

  @override
  String get changesTitle => '変更';

  @override
  String get changesError => '変更を読み込めませんでした。';

  @override
  String get changesEmpty => '変更はありません。';

  @override
  String get changesBinary => 'バイナリファイル — 表示しません。';

  @override
  String get commitViewChanges => '変更を表示';

  @override
  String get mrViewChanges => '変更を表示';

  @override
  String get changesOmitted => 'diff が大きすぎるか折りたたまれているため表示しません。';

  @override
  String get commentsHeading => 'コメント';

  @override
  String get commentsError => 'コメントを読み込めませんでした。';

  @override
  String get commentsEmpty => 'まだコメントはありません。';

  @override
  String get commentComposerHint => 'コメントを入力…';

  @override
  String get commentComposerSubmit => 'コメント';

  @override
  String get commentPostForbidden =>
      'ここにコメントする権限がありません。トークンに api スコープがあるか確認してください。';

  @override
  String get commentPostError => 'コメントを投稿できませんでした。もう一度お試しください。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get mrApprove => '承認';

  @override
  String get mrUnapprove => '承認を取り消す';

  @override
  String get mrMerge => 'マージ';

  @override
  String get mrMergeMethodTitle => 'Merge method';

  @override
  String get mrMergeCommit => 'Merge commit';

  @override
  String get mrMergeSquash => 'Squash and merge';

  @override
  String get mrReadyToMerge => 'Ready to merge';

  @override
  String get mrCannotMergeNow => 'Cannot be merged yet';

  @override
  String get mrMergeConfirmTitle => 'このマージリクエストをマージしますか？';

  @override
  String mrMergeConfirmBody(String mr) {
    return '$mr のマージは取り消せません。';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '承認 $approved/$required';
  }

  @override
  String get mrNotMergeable => '現在マージできません。承認、リベース、またはパイプラインの成功が必要な場合があります。';

  @override
  String get mrActionForbidden => 'この操作の権限がありません。トークンのスコープとロールを確認してください。';

  @override
  String get mrActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get projectOverviewPipelines => 'パイプライン';

  @override
  String get pipelinesTitle => 'パイプライン';

  @override
  String get pipelinesError => 'パイプラインを読み込めませんでした。';

  @override
  String get pipelinesEmpty => 'まだパイプラインはありません。';

  @override
  String get pipelineError => 'このパイプラインを読み込めませんでした。';

  @override
  String get pipelineJobsError => 'ジョブを読み込めませんでした。';

  @override
  String get pipelineNoJobs => 'このパイプラインにはジョブがありません。';

  @override
  String get jobTitle => 'ジョブ';

  @override
  String get jobError => 'このジョブを読み込めませんでした。';

  @override
  String get jobRefresh => '更新';

  @override
  String get jobLogError => 'ログを読み込めませんでした。';

  @override
  String get jobLogEmpty => 'このジョブにはログ出力がありません。';

  @override
  String get jobActionRetry => '再試行';

  @override
  String get jobActionCancel => 'キャンセル';

  @override
  String get jobActionRun => '実行';

  @override
  String get jobActionForbidden => 'この操作の権限がありません。';

  @override
  String get jobActionInvalid => '現在のジョブの状態ではこの操作はできません。';

  @override
  String get jobActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get pipelineActionRetry => '再試行';

  @override
  String get pipelineActionCancel => 'キャンセル';

  @override
  String get pipelineActionForbidden => 'この操作の権限がありません。';

  @override
  String get pipelineActionInvalid => '現在のパイプラインの状態ではこの操作はできません。';

  @override
  String get pipelineActionError => '操作を完了できませんでした。もう一度お試しください。';

  @override
  String get accountsTitle => 'アカウント';

  @override
  String get accountAdd => 'アカウントを追加';

  @override
  String get accountRemove => 'アカウントを削除';

  @override
  String get homeSwitchAccount => 'アカウント';

  @override
  String get homeInbox => 'To Do リスト';

  @override
  String get inboxTitle => 'To Do リスト';

  @override
  String get inboxEmpty => 'すべて完了しました。';

  @override
  String get inboxError => 'To Do を読み込めませんでした。';

  @override
  String get inboxMarkAllDone => 'すべて完了にする';

  @override
  String get inboxMarkDone => '完了にする';

  @override
  String get inboxMarkDoneError => '項目を完了にできませんでした。もう一度お試しください。';

  @override
  String get inboxActionAssigned => 'あなたに割り当て';

  @override
  String get inboxActionMentioned => 'あなたにメンション';

  @override
  String get inboxActionBuildFailed => 'パイプライン失敗';

  @override
  String get inboxActionMarked => 'To Do を追加';

  @override
  String get inboxActionApprovalRequired => '承認が必要';

  @override
  String get inboxActionUnmergeable => 'マージできません';

  @override
  String get inboxActionDirectlyAddressed => 'あなたを直接指定';

  @override
  String get homeSearch => '検索';

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'プロジェクト・イシュー・マージリクエストを検索';

  @override
  String get searchScopeProjects => 'プロジェクト';

  @override
  String get searchScopeIssues => 'イシュー';

  @override
  String get searchScopeMergeRequests => 'マージリクエスト';

  @override
  String get searchInitial => '検索語を入力してください。';

  @override
  String get searchEmpty => '結果が見つかりませんでした。';

  @override
  String get searchError => '検索を完了できませんでした。';

  @override
  String get searchLoadMore => 'さらに読み込む';

  @override
  String get projectAddFavorite => 'お気に入りに追加';

  @override
  String get projectRemoveFavorite => 'お気に入りから削除';

  @override
  String get homeFavorites => 'お気に入り';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccounts => 'アカウント';

  @override
  String get settingsLicenses => 'オープンソースライセンス';

  @override
  String get navHome => 'ホーム';

  @override
  String get navInbox => '受信箱';

  @override
  String get navSearch => '検索';

  @override
  String get navMe => 'マイページ';

  @override
  String get meTitle => 'マイページ';

  @override
  String get meSettings => '設定';

  @override
  String get meAccounts => 'アカウント切り替え';

  @override
  String get homeRecents => '最近';
}
