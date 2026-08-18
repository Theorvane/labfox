// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'LabFox';

  @override
  String get homeTitle => '홈';

  @override
  String homeSignedInAs(String username) {
    return '$username 님으로 로그인됨';
  }

  @override
  String get homeEmptyWork => '이슈, 병합 요청, 파이프라인이 여기에 표시됩니다.';

  @override
  String get signOut => '로그아웃';

  @override
  String get signInTitle => 'GitLab 계정 연결';

  @override
  String get signInInstanceLabel => 'GitLab 인스턴스 URL';

  @override
  String get signInInstanceRequired => 'GitLab 인스턴스 URL을 입력하세요.';

  @override
  String get signInInstanceInvalid =>
      '올바른 https URL을 입력하세요. 예: https://gitlab.com';

  @override
  String get signInTokenLabel => 'Personal Access Token';

  @override
  String get signInTokenHelp => 'api 및 read_user 스코프가 필요합니다.';

  @override
  String get signInTokenToggle => '토큰 표시 또는 숨기기';

  @override
  String get signInTokenRequired => 'Personal Access Token을 입력하세요.';

  @override
  String get signInSubmit => '로그인';

  @override
  String get signInErrorToken => '토큰이 거부되었습니다. 올바른지, 만료되지 않았는지 확인하세요.';

  @override
  String get signInErrorScope => '토큰에 필요한 스코프가 없습니다. api와 read_user가 필요합니다.';

  @override
  String get signInErrorUnreachable =>
      '해당 인스턴스에 연결할 수 없습니다. URL, 네트워크, 인증서 신뢰 여부를 확인하세요.';

  @override
  String get signInErrorGeneric => '로그인에 실패했습니다. 다시 시도하세요.';

  @override
  String get homeMyWork => '내 작업';

  @override
  String get homeProjects => '프로젝트';

  @override
  String get projectsTitle => '프로젝트';

  @override
  String get projectsEmpty => '아직 참여 중인 프로젝트가 없습니다.';

  @override
  String get projectsError => '프로젝트를 불러올 수 없습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get projectOverviewTitle => '프로젝트';

  @override
  String get projectOverviewError => '이 프로젝트를 불러올 수 없습니다.';

  @override
  String get projectOverviewNoReadme => '이 프로젝트에는 README가 없습니다.';

  @override
  String get projectOverviewRepository => '저장소';

  @override
  String get repositoryTitle => '저장소';

  @override
  String get repositoryError => '이 디렉터리를 불러올 수 없습니다.';

  @override
  String get repositoryEmpty => '이 디렉터리는 비어 있습니다.';

  @override
  String get fileError => '이 파일을 불러올 수 없습니다.';

  @override
  String get fileNotFound => '파일을 찾을 수 없습니다.';

  @override
  String get fileBinary => '바이너리 파일이라 텍스트로 표시할 수 없습니다.';

  @override
  String get projectOverviewBranches => '브랜치';

  @override
  String get projectOverviewCommits => '커밋';

  @override
  String get branchesTitle => '브랜치';

  @override
  String get branchesError => '브랜치를 불러올 수 없습니다.';

  @override
  String get branchesEmpty => '이 저장소에는 브랜치가 없습니다.';

  @override
  String get branchDefault => '기본 브랜치';

  @override
  String get commitsTitle => '커밋';

  @override
  String get commitsError => '커밋을 불러올 수 없습니다.';

  @override
  String get commitsEmpty => '이 브랜치에는 아직 커밋이 없습니다.';

  @override
  String get commitTitle => '커밋';

  @override
  String get commitError => '이 커밋을 불러올 수 없습니다.';

  @override
  String get projectOverviewIssues => '이슈';

  @override
  String get issuesTitle => '이슈';

  @override
  String get issuesFilterOpen => '열림';

  @override
  String get issuesFilterClosed => '닫힘';

  @override
  String get issuesError => '이슈를 불러올 수 없습니다.';

  @override
  String get issuesEmpty => '이슈가 없습니다.';

  @override
  String get issueError => '이 이슈를 불러올 수 없습니다.';

  @override
  String get issueStateOpen => '열림';

  @override
  String get issueStateClosed => '닫힘';

  @override
  String get issueNoDescription => '설명이 없습니다.';

  @override
  String issueOpenedBy(String username) {
    return '$username 님이 열었습니다';
  }

  @override
  String get projectOverviewMergeRequests => '병합 요청';

  @override
  String get mergeRequestsTitle => '병합 요청';

  @override
  String get mrFilterOpen => '열림';

  @override
  String get mrFilterMerged => '병합됨';

  @override
  String get mrFilterClosed => '닫힘';

  @override
  String get mergeRequestsError => '병합 요청을 불러올 수 없습니다.';

  @override
  String get mergeRequestsEmpty => '병합 요청이 없습니다.';

  @override
  String get mergeRequestError => '이 병합 요청을 불러올 수 없습니다.';

  @override
  String get mergeRequestNoDescription => '설명이 없습니다.';

  @override
  String get mrStateOpen => '열림';

  @override
  String get mrStateMerged => '병합됨';

  @override
  String get mrStateClosed => '닫힘';

  @override
  String get mrDraft => '초안';

  @override
  String get changesTitle => '변경 사항';

  @override
  String get changesError => '변경 사항을 불러올 수 없습니다.';

  @override
  String get changesEmpty => '변경 사항이 없습니다.';

  @override
  String get changesBinary => '바이너리 파일 — 표시하지 않음.';

  @override
  String get commitViewChanges => '변경 사항 보기';

  @override
  String get mrViewChanges => '변경 사항 보기';

  @override
  String get changesOmitted => 'diff가 너무 크거나 접혀 있어 표시하지 않습니다.';
}
