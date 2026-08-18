---
name: feature-slice
description: When adding a new screen or feature under apps/labfox/lib/features. Follow the folder layout, Controller/Repository authoring, and route registration order.
---

# Adding a feature

## 0. Check first

Does this feature contribute to the core LabFox flow?

```
Notification → Issue/MR → Diff/Review → Pipeline → Job Log → Approve/Merge/Retry
```

If it falls under the 1.0 exclusion list (Wiki, Packages, Registry, Analytics, Admin, etc.), do not implement it — ask first.

## 1. Folders

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

Do not split the layers further. Do not create `domain/` or `usecases/`.

## 2. Repository

```dart
class MergeRequestRepository {
  MergeRequestRepository(this._gitlab, this._db);
  final GitLabClient _gitlab;
  final LabFoxDatabase _db;

  Future<List<MergeRequest>> list({required Object projectId}) async { ... }
}
```

- Combining cache (Drift) and network ends here. Layers above do not know the source.
- Convert `DioException` → domain exception.

## 3. Controller

```dart
@riverpod
class MergeRequestListController extends _$MergeRequestListController {
  @override
  Future<List<MergeRequest>> build(Object projectId) =>
      ref.read(mergeRequestRepositoryProvider).list(projectId: projectId);
}
```

- `AsyncNotifier` by default, `family` when there are parameters.
- **Do not create UseCase classes.** The Controller calls the Repository directly.
- After a write, `invalidate` the related providers.

## 4. Screen

- Handle all of `AsyncValue`'s data / loading / error. Do not omit loading or error.
- Treat the empty state (0 items) separately.
- When navigating from a list to a detail, pass only the identifier, not the whole object.
  The detail screen must load on its own so deep links and window restoration behave identically.
- Follow the `responsive-screen` skill for screen width branching.
- Prefer components/tokens from `packages/design_system` for widgets.

## 5. Routes

Register the go_router path in `apps/labfox/lib/app/router.dart`.

- URLs follow GitLab's structure: `/projects/:projectId/merge_requests/:iid`
- The number shown on screen is the `iid`. Do not confuse it with `id`.
- It becomes a Deep Link target, so the screen must be restorable from the path alone.

## 6. Wrap up

```
dart run build_runner build --delete-conflicting-outputs   # if there are model/riverpod generated files
dart format .
flutter analyze
flutter test
```

## Definition of done

- [ ] Confirmed the feature is within 1.0 scope
- [ ] data/ + presentation/ structure
- [ ] Controller calls the Repository directly (no UseCase)
- [ ] loading / error / empty states handled
- [ ] Route registered, restorable from the identifier alone
- [ ] Mobile / Desktop layouts checked
- [ ] analyze / test pass
