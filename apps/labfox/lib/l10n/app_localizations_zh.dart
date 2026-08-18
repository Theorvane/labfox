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
}
