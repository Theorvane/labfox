---
name: gitlab-api-endpoint
description: packages/gitlab_api 에 GitLab REST 엔드포인트를 추가하거나 수정할 때. 새 리소스 호출, DTO 추가, 페이지네이션이나 에러 처리 변경이 필요한 경우 사용한다.
---

# GitLab 엔드포인트 추가

## 1. 공식 문서 확인 (건너뛰지 않는다)

https://docs.gitlab.com/api/ 에서 실제 경로 · 파라미터 · 응답 형태를 확인한다.
참고 저장소(OctoLab, LabCoat)의 구현과 다르면 **공식 문서를 따른다**.
기억이나 추측으로 경로를 쓰지 않는다.

확인할 것:
- 경로에 쓰이는 게 `id`인지 `iid`인지
- 필수/선택 쿼리 파라미터
- 페이지네이션 방식 (offset / keyset)
- 응답이 JSON인지 plain text인지 (job trace는 text다)

## 2. 배치

리소스 그룹별 폴더에 넣는다.

```
packages/gitlab_api/lib/src/<resource>/
├── <resource>_api.dart      서브 클라이언트
└── (필요시) 요청 파라미터 클래스
```

`GitLabClient`에 접근자를 노출한다: `gitlab.mergeRequests.get(...)`

## 3. 작성 규칙

```dart
Future<MergeRequest> get({
  required Object projectId,   // int 또는 "group/project" (URL 인코딩)
  required int iid,
}) async {
  final res = await _dio.get('/projects/${_enc(projectId)}/merge_requests/$iid');
  return MergeRequest.fromJson(res.data as Map<String, dynamic>);
}
```

- `packages/flutter`를 import 하지 않는다. 순수 Dart 유지.
- projectId는 숫자 ID와 `group/project` 경로 둘 다 받는다. 경로형은 **URL 인코딩 필수**.
- baseUrl은 주입받은 값을 쓴다. `gitlab.com` 하드코딩 금지.
- 토큰은 Dio interceptor에서 붙인다. 메서드마다 헤더를 만들지 않는다.

## 4. 모델

`packages/gitlab_models`에 freezed + json_serializable로 추가한다.
snake_case 필드는 `@JsonKey(name: ...)`로 매핑하고, 없을 수 있는 필드는 nullable로 둔다.

```
dart run build_runner build --delete-conflicting-outputs
```

## 5. 페이지네이션

목록 엔드포인트는 페이지 메타데이터를 함께 반환한다.

```dart
Future<Paginated<Project>> list({int page = 1, int perPage = 20});
```

응답 헤더 `X-Next-Page` / `X-Total-Pages`를 읽어 담는다.
헤더가 없을 수 있으므로(대규모 컬렉션) 총 개수를 전제한 API를 만들지 않는다.

## 6. 에러

raw `DioException`을 밖으로 내보내지 않는다.
401 / 403 / 404 / 429 / 5xx 를 도메인 예외로 변환한다 (`.agents/docs/conventions.md` 참고).
연결 실패(self-hosted 미도달, 인증서 오류)와 인증 실패를 구분한다.

## 7. 테스트

`gitlab_api`는 Flutter 비의존이므로 순수 Dart 테스트로 검증한다.
실제 응답 JSON 샘플을 fixture로 두고 파싱 테스트를 붙인다. 실제 토큰은 넣지 않는다.

## 완료 조건

- [ ] 공식 문서로 경로/파라미터 확인
- [ ] 서브 클라이언트 메서드 추가 + `GitLabClient` 노출
- [ ] freezed 모델 + build_runner 실행
- [ ] 페이지네이션/에러 처리
- [ ] 파싱 테스트
- [ ] `dart format .` / `flutter analyze` 통과
