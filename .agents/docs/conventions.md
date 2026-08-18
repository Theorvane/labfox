# Conventions

## 파일 / 네이밍

- 파일 `snake_case.dart`, 클래스 `PascalCase`, 멤버 `lowerCamelCase`.
- 화면 위젯은 `*_screen.dart` / `*Screen`. 재사용 위젯은 `*_tile.dart`, `*_view.dart`.
- Controller는 `*_controller.dart` / `*Controller`.
- Repository는 `*_repository.dart` / `*Repository`.
- 모델은 `packages/gitlab_models`. API DTO와 화면 모델이 다르면 DTO는 `*Dto` 접미사를 붙인다.

## Feature 폴더

```
features/merge_requests/
├── data/
│   └── merge_request_repository.dart
└── presentation/
    ├── merge_request_list_screen.dart
    ├── merge_request_detail_screen.dart
    ├── controllers/
    └── widgets/
```

`domain/` 을 억지로 만들지 않는다. 모델은 `gitlab_models`에 둔다.

## Freezed / JSON

```dart
@freezed
class MergeRequest with _$MergeRequest {
  const factory MergeRequest({
    required int id,
    required int iid,
    required String title,
    @JsonKey(name: 'source_branch') required String sourceBranch,
    @JsonKey(name: 'target_branch') required String targetBranch,
    @JsonKey(name: 'merge_status') String? mergeStatus,
  }) = _MergeRequest;

  factory MergeRequest.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestFromJson(json);
}
```

- 수동 `fromJson` 작성 금지.
- 생성 후 `dart run build_runner build --delete-conflicting-outputs`.
- `*.freezed.dart` / `*.g.dart` 직접 편집 금지.
- GitLab 응답에는 예고 없이 필드가 추가된다. 알 수 없는 필드는 무시하고, 없을 수 있는 필드는 nullable로 둔다.

## id vs iid

| | 의미 | 예 |
|---|---|---|
| `id` | GitLab 전역 식별자 | 12345 |
| `iid` | 프로젝트 내부 번호, **화면에 보이는 값** | `!142`, `#282` |

API 경로는 대부분 `/projects/:id/merge_requests/:iid` 형태다.
파라미터 이름을 `id`로 뭉개지 말고 `projectId` / `iid`로 명시한다.

## Riverpod

- 기본은 `AsyncNotifier`. 파라미터가 있으면 `family`.
- `ref.watch`는 build 안에서만. 콜백에서는 `ref.read`.
- 목록 → 상세로 이동할 때 목록 항목을 그대로 넘기지 말고, 상세 provider가 스스로 로드하게 한다
  (딥링크·창 복원에서 동일하게 동작해야 한다).
- 쓰기 후에는 관련 provider를 `invalidate`한다.

## 에러 처리

Repository에서 도메인 예외로 변환한다.

| HTTP | 처리 |
|---|---|
| 401 | 토큰 만료/무효 → 재인증 유도 |
| 403 | 권한 없음 → 기능 비활성 안내 |
| 404 | 리소스 없음 또는 비공개 → 구분해 안내 |
| 429 | Rate limit → `Retry-After` 존중 |
| 5xx | 인스턴스 오류 → 재시도 제공 |

Self-hosted 인스턴스는 사설 인증서 / 프록시 / 네트워크 미도달 케이스가 흔하다.
연결 실패와 인증 실패를 반드시 구분해 메시지를 낸다.

## 커밋 전

```
dart format .
flutter analyze
flutter test
```
