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
}
