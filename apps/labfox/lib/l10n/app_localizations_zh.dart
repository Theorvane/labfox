// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => '主页';

  @override
  String homeSignedInAs(String username) {
    return '已登录为 $username';
  }

  @override
  String get homeEmptyWork => '您的议题、合并请求和流水线将显示在这里。';

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
  String get signOut => '退出登录';

  @override
  String get signInTitle => '连接 GitLab 账户';

  @override
  String get signInInstanceLabel => 'GitLab 实例 URL';

  @override
  String get signInInstanceRequired => '请输入您的 GitLab 实例 URL。';

  @override
  String get signInInstanceInvalid => '请输入有效的 https URL，例如 https://gitlab.com';

  @override
  String get signInTokenLabel => '个人访问令牌';

  @override
  String get signInTokenHelp => '需要 api 和 read_user 权限范围。';

  @override
  String get signInTokenToggle => '显示或隐藏令牌';

  @override
  String get signInTokenRequired => '请输入个人访问令牌。';

  @override
  String get signInSubmit => '登录';

  @override
  String get signInOr => '或';

  @override
  String get signInOAuthButton => '使用 GitLab 登录';

  @override
  String get signInClientIdLabel => 'OAuth 客户端 ID';

  @override
  String get signInClientIdHelp => '仅在自托管实例上使用 OAuth 时需要。';

  @override
  String get signInOAuthNeedsClientId => '请输入该实例的 OAuth 客户端 ID。';

  @override
  String get signInErrorToken => '令牌被拒绝。请检查它是否正确且未过期。';

  @override
  String get signInErrorScope => '令牌缺少必需的权限范围。需要 api 和 read_user。';

  @override
  String get signInErrorUnreachable => '无法连接到该实例。请检查 URL、网络以及证书是否受信任。';

  @override
  String get signInErrorGeneric => '登录失败。请重试。';

  @override
  String get homeMyWork => '我的工作';

  @override
  String get homeProjects => '项目';

  @override
  String get projectsTitle => '项目';

  @override
  String get projectsEmpty => '您还不是任何项目的成员。';

  @override
  String get projectsError => '无法加载您的项目。';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get retry => '重试';

  @override
  String get projectOverviewTitle => '项目';

  @override
  String get projectOverviewError => '无法加载此项目。';

  @override
  String get projectOverviewNoReadme => '此项目没有 README。';

  @override
  String get projectOverviewRepository => '仓库';

  @override
  String get repositoryTitle => '仓库';

  @override
  String get repositoryError => '无法加载此目录。';

  @override
  String get repositoryEmpty => '此目录为空。';

  @override
  String get fileError => '无法加载此文件。';

  @override
  String get fileNotFound => '未找到此文件。';

  @override
  String get fileBinary => '这是二进制文件，无法作为文本显示。';

  @override
  String get projectOverviewBranches => '分支';

  @override
  String get projectOverviewCommits => '提交';

  @override
  String get branchesTitle => '分支';

  @override
  String get branchesError => '无法加载分支。';

  @override
  String get branchesEmpty => '此仓库没有分支。';

  @override
  String get branchDefault => '默认分支';

  @override
  String get commitsTitle => '提交';

  @override
  String get commitsError => '无法加载提交。';

  @override
  String get commitsEmpty => '此分支还没有提交。';

  @override
  String get commitTitle => '提交';

  @override
  String get commitError => '无法加载此提交。';

  @override
  String get projectOverviewIssues => '议题';

  @override
  String get issuesTitle => '议题';

  @override
  String get issuesFilterOpen => '打开';

  @override
  String get issuesFilterClosed => '已关闭';

  @override
  String get issuesError => '无法加载议题。';

  @override
  String get issuesEmpty => '这里没有议题。';

  @override
  String get issueError => '无法加载此议题。';

  @override
  String get issueStateOpen => '打开';

  @override
  String get issueStateClosed => '已关闭';

  @override
  String get issueNoDescription => '未提供描述。';

  @override
  String issueOpenedBy(String username) {
    return '由 $username 创建';
  }

  @override
  String get projectOverviewMergeRequests => '合并请求';

  @override
  String get mergeRequestsTitle => '合并请求';

  @override
  String get mrFilterOpen => '打开';

  @override
  String get mrFilterMerged => '已合并';

  @override
  String get mrFilterClosed => '已关闭';

  @override
  String get mergeRequestsError => '无法加载合并请求。';

  @override
  String get mergeRequestsEmpty => '这里没有合并请求。';

  @override
  String get mergeRequestError => '无法加载此合并请求。';

  @override
  String get mergeRequestNoDescription => '未提供描述。';

  @override
  String get mrStateOpen => '打开';

  @override
  String get mrStateMerged => '已合并';

  @override
  String get mrStateClosed => '已关闭';

  @override
  String get mrDraft => '草稿';

  @override
  String get changesTitle => '变更';

  @override
  String get changesError => '无法加载变更。';

  @override
  String get changesEmpty => '没有变更。';

  @override
  String get changesBinary => '二进制文件 — 不显示。';

  @override
  String get commitViewChanges => '查看变更';

  @override
  String get mrViewChanges => '查看变更';

  @override
  String get changesOmitted => 'diff 太大或已折叠，未显示。';

  @override
  String get commentsHeading => '评论';

  @override
  String get commentsError => '无法加载评论。';

  @override
  String get commentsEmpty => '还没有评论。';

  @override
  String get commentComposerHint => '写评论…';

  @override
  String get commentComposerSubmit => '评论';

  @override
  String get commentPostForbidden => '您没有权限在此评论。请检查您的令牌是否具有 api 权限范围。';

  @override
  String get commentPostError => '无法发布您的评论。请重试。';

  @override
  String get cancel => '取消';

  @override
  String get mrApprove => '批准';

  @override
  String get mrUnapprove => '撤销批准';

  @override
  String get mrMerge => '合并';

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
  String get mrMergeConfirmTitle => '要合并此合并请求吗？';

  @override
  String mrMergeConfirmBody(String mr) {
    return '合并 $mr 无法撤销。';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '$approved/$required 项批准';
  }

  @override
  String get mrNotMergeable => '目前无法合并。可能需要批准、变基或通过的流水线。';

  @override
  String get mrActionForbidden => '您没有执行此操作的权限。请检查您的令牌范围和角色。';

  @override
  String get mrActionError => '操作无法完成。请重试。';

  @override
  String get projectOverviewPipelines => '流水线';

  @override
  String get pipelinesTitle => '流水线';

  @override
  String get pipelinesError => '无法加载流水线。';

  @override
  String get pipelinesEmpty => '还没有流水线。';

  @override
  String get pipelineError => '无法加载此流水线。';

  @override
  String get pipelineJobsError => '无法加载作业。';

  @override
  String get pipelineNoJobs => '此流水线没有作业。';

  @override
  String get jobTitle => '作业';

  @override
  String get jobError => '无法加载此作业。';

  @override
  String get jobRefresh => '刷新';

  @override
  String get jobLogError => '无法加载日志。';

  @override
  String get jobLogEmpty => '此作业没有日志输出。';

  @override
  String get jobActionRetry => '重试';

  @override
  String get jobActionCancel => '取消';

  @override
  String get jobActionRun => '运行';

  @override
  String get jobActionForbidden => '您没有执行此操作的权限。';

  @override
  String get jobActionInvalid => '作业当前状态下无法执行此操作。';

  @override
  String get jobActionError => '操作无法完成。请重试。';

  @override
  String get pipelineActionRetry => '重试';

  @override
  String get pipelineActionCancel => '取消';

  @override
  String get pipelineActionForbidden => '您没有执行此操作的权限。';

  @override
  String get pipelineActionInvalid => '流水线当前状态下无法执行此操作。';

  @override
  String get pipelineActionError => '操作无法完成。请重试。';

  @override
  String get accountsTitle => '账户';

  @override
  String get accountAdd => '添加账户';

  @override
  String get accountRemove => '移除账户';

  @override
  String get homeSwitchAccount => '账户';

  @override
  String get homeInbox => '待办列表';

  @override
  String get inboxTitle => '待办列表';

  @override
  String get inboxEmpty => '全部处理完毕。';

  @override
  String get inboxError => '无法加载待办事项。';

  @override
  String get inboxMarkAllDone => '全部标记为完成';

  @override
  String get inboxMarkDone => '标记为完成';

  @override
  String get inboxMarkDoneError => '无法清除该事项，请重试。';

  @override
  String get inboxActionAssigned => '已指派给你';

  @override
  String get inboxActionMentioned => '提到了你';

  @override
  String get inboxActionBuildFailed => '流水线失败';

  @override
  String get inboxActionMarked => '添加了待办';

  @override
  String get inboxActionApprovalRequired => '需要批准';

  @override
  String get inboxActionUnmergeable => '无法合并';

  @override
  String get inboxActionDirectlyAddressed => '直接提及你';

  @override
  String get homeSearch => '搜索';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索项目、议题、合并请求';

  @override
  String get searchScopeProjects => '项目';

  @override
  String get searchScopeIssues => '议题';

  @override
  String get searchScopeMergeRequests => '合并请求';

  @override
  String get searchInitial => '输入以搜索。';

  @override
  String get searchEmpty => '未找到结果。';

  @override
  String get searchError => '搜索无法完成。';

  @override
  String get searchLoadMore => '加载更多';

  @override
  String get projectAddFavorite => '添加到收藏';

  @override
  String get projectRemoveFavorite => '从收藏中移除';

  @override
  String get homeFavorites => '收藏';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccounts => '账户';

  @override
  String get settingsLicenses => '开源许可';

  @override
  String get navHome => '主页';

  @override
  String get navInbox => '收件箱';

  @override
  String get navSearch => '搜索';

  @override
  String get navMe => '我';

  @override
  String get meTitle => '我';

  @override
  String get meSettings => '设置';

  @override
  String get meAccounts => '切换账户';

  @override
  String get homeRecents => '最近';
}
