# Architecture

## 레이어

```
Presentation   Widget / Screen
      ↓        watch / read
Controller     Riverpod AsyncNotifier
      ↓
Repository     캐시 + 네트워크 조합
      ↓
GitLabClient   packages/gitlab_api (순수 Dart)
      ↓ HTTPS
GitLab Instance (gitlab.com | self-hosted)
```

## 각 레이어 책임

### Presentation
- `AsyncValue`의 `data / loading / error`를 화면에 매핑한다.
- 비즈니스 판단을 하지 않는다. "MR을 merge할 수 있는가" 같은 판단은 Controller/모델에 둔다.
- 화면 폭 분기는 여기서 한다 (`responsive-screen` 스킬 참고).

### Controller / Notifier
- `AsyncNotifier` 기본. 파라미터가 필요하면 `family`.
- Repository 호출, 낙관적 업데이트, 재시도, invalidate 책임.
- **UseCase 클래스를 만들지 않는다.** 로직이 커지면 Repository나 모델 메서드로 내린다.

### Repository
- 데이터 출처(네트워크 / Drift 캐시)를 결정하고 상위에 숨긴다.
- 기본 전략: 캐시를 먼저 방출 → 네트워크 갱신 → 캐시 갱신 후 재방출 (stale-while-revalidate).
- 오프라인일 때는 마지막 동기화 데이터를 그대로 준다.
- `DioException`을 도메인 예외(`GitLabAuthException`, `GitLabNotFoundException`, `GitLabRateLimitException` 등)로 변환한다.

### GitLabClient
- `packages/gitlab_api`. `package:flutter` 의존 금지 → 단위 테스트가 쉬워야 한다.
- 리소스별 서브 클라이언트로 나눈다: `projects`, `issues`, `mergeRequests`, `discussions`, `pipelines`, `jobs`, `todos`, `search` …
- 인증 토큰과 baseUrl은 생성 시 주입받는다. 내부에서 저장소를 읽지 않는다.

```dart
final gitlab = GitLabClient(baseUrl: instance.baseUrl, token: token);
final projects = await gitlab.projects.list();
final mr = await gitlab.mergeRequests.get(projectId: 123, iid: 42);
```

## Multi Account

계정은 `(instanceBaseUrl, userId)` 로 식별한다.

- 활성 계정이 바뀌면 `GitLabClient`를 새로 만들고 관련 provider를 invalidate 한다.
- 캐시 테이블에는 계정 식별자 컬럼을 둔다. 계정 간 데이터가 섞이면 안 된다.
- 토큰은 계정별로 secure storage 키를 분리한다.

## Local DB (Drift)

캐시 대상: 최근 프로젝트, Project / Issue / MR / User 캐시, Recent Searches, Favorite, Draft Comment.

- 캐시는 **표시용**이다. 쓰기 작업(merge, approve, comment)의 결과를 캐시만 보고 판단하지 않는다.
- Draft Comment는 네트워크 전송 실패 시에도 보존한다.

## Secure Storage

PAT / OAuth Access Token / Refresh Token 전용. 그 외 데이터는 넣지 않는다.
`packages/secure_storage`가 플랫폼 차이를 흡수한다.
