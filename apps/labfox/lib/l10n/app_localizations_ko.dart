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
  String get signInOr => '또는';

  @override
  String get signInOAuthButton => 'GitLab으로 로그인';

  @override
  String get signInClientIdLabel => 'OAuth 클라이언트 ID';

  @override
  String get signInClientIdHelp => 'self-hosted 인스턴스에서 OAuth를 쓸 때만 필요합니다.';

  @override
  String get signInOAuthNeedsClientId => '이 인스턴스의 OAuth 클라이언트 ID를 입력하세요.';

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

  @override
  String get commentsHeading => '댓글';

  @override
  String get commentsError => '댓글을 불러올 수 없습니다.';

  @override
  String get commentsEmpty => '아직 댓글이 없습니다.';

  @override
  String get commentComposerHint => '댓글을 작성하세요…';

  @override
  String get commentComposerSubmit => '댓글 달기';

  @override
  String get commentPostForbidden =>
      '여기에 댓글을 달 권한이 없습니다. 토큰에 api 스코프가 있는지 확인하세요.';

  @override
  String get commentPostError => '댓글을 게시할 수 없습니다. 다시 시도하세요.';

  @override
  String get cancel => '취소';

  @override
  String get mrApprove => '승인';

  @override
  String get mrUnapprove => '승인 취소';

  @override
  String get mrMerge => '병합';

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
  String get mrMergeConfirmTitle => '이 병합 요청을 병합할까요?';

  @override
  String mrMergeConfirmBody(String mr) {
    return '$mr 병합은 되돌릴 수 없습니다.';
  }

  @override
  String mrApprovalsSummary(int approved, int required) {
    return '승인 $approved/$required';
  }

  @override
  String get mrNotMergeable =>
      '지금은 병합할 수 없습니다. 승인, 리베이스, 또는 통과된 파이프라인이 필요할 수 있습니다.';

  @override
  String get mrActionForbidden => '이 작업을 수행할 권한이 없습니다. 토큰 스코프와 역할을 확인하세요.';

  @override
  String get mrActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get projectOverviewPipelines => '파이프라인';

  @override
  String get pipelinesTitle => '파이프라인';

  @override
  String get pipelinesError => '파이프라인을 불러올 수 없습니다.';

  @override
  String get pipelinesEmpty => '아직 파이프라인이 없습니다.';

  @override
  String get pipelineError => '이 파이프라인을 불러올 수 없습니다.';

  @override
  String get pipelineJobsError => '잡을 불러올 수 없습니다.';

  @override
  String get pipelineNoJobs => '이 파이프라인에는 잡이 없습니다.';

  @override
  String get jobTitle => '잡';

  @override
  String get jobError => '이 잡을 불러올 수 없습니다.';

  @override
  String get jobRefresh => '새로고침';

  @override
  String get jobLogError => '로그를 불러올 수 없습니다.';

  @override
  String get jobLogEmpty => '이 잡에는 로그 출력이 없습니다.';

  @override
  String get jobActionRetry => '다시 시도';

  @override
  String get jobActionCancel => '취소';

  @override
  String get jobActionRun => '실행';

  @override
  String get jobActionForbidden => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get jobActionInvalid => '현재 잡 상태에서는 이 작업을 할 수 없습니다.';

  @override
  String get jobActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get pipelineActionRetry => '다시 시도';

  @override
  String get pipelineActionCancel => '취소';

  @override
  String get pipelineActionForbidden => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get pipelineActionInvalid => '현재 파이프라인 상태에서는 이 작업을 할 수 없습니다.';

  @override
  String get pipelineActionError => '작업을 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get accountsTitle => '계정';

  @override
  String get accountAdd => '계정 추가';

  @override
  String get accountRemove => '계정 제거';

  @override
  String get homeSwitchAccount => '계정';

  @override
  String get homeInbox => '할 일 목록';

  @override
  String get inboxTitle => '할 일 목록';

  @override
  String get inboxEmpty => '모두 처리했습니다.';

  @override
  String get inboxError => '할 일 목록을 불러오지 못했습니다.';

  @override
  String get inboxMarkAllDone => '모두 완료 처리';

  @override
  String get inboxMarkDone => '완료 처리';

  @override
  String get inboxMarkDoneError => '항목을 완료 처리하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get inboxActionAssigned => '나에게 할당됨';

  @override
  String get inboxActionMentioned => '나를 언급함';

  @override
  String get inboxActionBuildFailed => '파이프라인 실패';

  @override
  String get inboxActionMarked => '할 일 추가됨';

  @override
  String get inboxActionApprovalRequired => '승인 필요';

  @override
  String get inboxActionUnmergeable => '병합할 수 없음';

  @override
  String get inboxActionDirectlyAddressed => '나를 직접 지목함';

  @override
  String get homeSearch => '검색';

  @override
  String get searchTitle => '검색';

  @override
  String get searchHint => '프로젝트, 이슈, 병합 요청 검색';

  @override
  String get searchScopeProjects => '프로젝트';

  @override
  String get searchScopeIssues => '이슈';

  @override
  String get searchScopeMergeRequests => '병합 요청';

  @override
  String get searchInitial => '검색어를 입력하세요.';

  @override
  String get searchEmpty => '검색 결과가 없습니다.';

  @override
  String get searchError => '검색을 완료할 수 없습니다.';

  @override
  String get searchLoadMore => '더 보기';

  @override
  String get projectAddFavorite => '즐겨찾기에 추가';

  @override
  String get projectRemoveFavorite => '즐겨찾기에서 제거';

  @override
  String get homeFavorites => '즐겨찾기';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAccounts => '계정';

  @override
  String get settingsLicenses => '오픈소스 라이선스';

  @override
  String get navHome => '홈';

  @override
  String get navInbox => '받은함';

  @override
  String get navSearch => '검색';

  @override
  String get navMe => '내 정보';

  @override
  String get meTitle => '내 정보';

  @override
  String get meSettings => '설정';

  @override
  String get meAccounts => '계정 전환';

  @override
  String get homeRecents => '최근';
}
