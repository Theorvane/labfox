---
name: feature-slice
description: apps/labfox/lib/features 아래에 새 화면이나 기능을 추가할 때. 폴더 구성, Controller/Repository 작성, 라우트 등록 순서를 따른다.
---

# Feature 추가

## 0. 먼저 확인

이 기능이 LabFox 핵심 흐름에 기여하는가?

```
알림 → Issue/MR → Diff/Review → Pipeline → Job Log → Approve/Merge/Retry
```

1.0 제외 목록(Wiki, Packages, Registry, Analytics, Admin 등)에 해당하면 구현하지 않고 먼저 확인한다.

## 1. 폴더

```
features/<feature>/
├── data/
│   └── <feature>_repository.dart
└── presentation/
    ├── <feature>_screen.dart
    ├── controllers/
    │   └── <feature>_controller.dart
    └── widgets/
```

계층을 더 쪼개지 않는다. `domain/`, `usecases/`를 만들지 않는다.

## 2. Repository

```dart
class MergeRequestRepository {
  MergeRequestRepository(this._gitlab, this._db);
  final GitLabClient _gitlab;
  final LabFoxDatabase _db;

  Future<List<MergeRequest>> list({required Object projectId}) async { ... }
}
```

- 캐시(Drift)와 네트워크 조합은 여기서 끝낸다. 상위는 출처를 모른다.
- `DioException` → 도메인 예외 변환.

## 3. Controller

```dart
@riverpod
class MergeRequestListController extends _$MergeRequestListController {
  @override
  Future<List<MergeRequest>> build(Object projectId) =>
      ref.read(mergeRequestRepositoryProvider).list(projectId: projectId);
}
```

- `AsyncNotifier` 기본, 파라미터가 있으면 `family`.
- **UseCase 클래스를 만들지 않는다.** Controller가 Repository를 직접 호출한다.
- 쓰기 작업 후 관련 provider를 `invalidate`한다.

## 4. Screen

- `AsyncValue`의 data / loading / error를 모두 처리한다. loading·error를 빠뜨리지 않는다.
- 빈 상태(0건)를 별도로 다룬다.
- 목록에서 상세로 넘어갈 때 객체를 통째로 넘기지 말고 식별자만 넘긴다.
  상세 화면이 스스로 로드해야 딥링크와 창 복원에서 동일하게 동작한다.
- 화면 폭 분기는 `responsive-screen` 스킬을 따른다.
- 위젯은 `packages/design_system`의 컴포넌트/토큰을 우선 사용한다.

## 5. 라우트

`apps/labfox/lib/app/router.dart`에 go_router 경로를 등록한다.

- URL은 GitLab 구조를 따른다: `/projects/:projectId/merge_requests/:iid`
- 화면에 보이는 번호는 `iid`다. `id`와 혼동하지 않는다.
- Deep Link 대상이 되므로 경로만으로 화면을 복원할 수 있어야 한다.

## 6. 마무리

```
dart run build_runner build --delete-conflicting-outputs   # 모델/riverpod 생성물이 있으면
dart format .
flutter analyze
flutter test
```

## 완료 조건

- [ ] 1.0 범위 내 기능인지 확인
- [ ] data/ + presentation/ 구성
- [ ] Controller가 Repository를 직접 호출 (UseCase 없음)
- [ ] loading / error / empty 상태 처리
- [ ] 라우트 등록, 식별자만으로 복원 가능
- [ ] Mobile / Desktop 레이아웃 확인
- [ ] analyze / test 통과
