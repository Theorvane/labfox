# Conventions

## Files / Naming

- Files `snake_case.dart`, classes `PascalCase`, members `lowerCamelCase`.
- Screen widgets are `*_screen.dart` / `*Screen`. Reusable widgets are `*_tile.dart`, `*_view.dart`.
- Controllers are `*_controller.dart` / `*Controller`.
- Repositories are `*_repository.dart` / `*Repository`.
- Models live in `packages/gitlab_models`. When the API DTO differs from the screen model, suffix the DTO with `*Dto`.

## Feature Folders

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

Do not force a `domain/` folder. Models belong in `gitlab_models`.

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

- Do not hand-write `fromJson`.
- After adding one, run `dart run build_runner build --delete-conflicting-outputs`.
- Do not edit `*.freezed.dart` / `*.g.dart` directly.
- GitLab responses gain fields without warning. Ignore unknown fields, and make fields that may be absent nullable.

## id vs iid

| | Meaning | Example |
|---|---|---|
| `id` | GitLab-wide identifier | 12345 |
| `iid` | Number internal to the project, **the value shown on screen** | `!142`, `#282` |

Most API paths take the form `/projects/:id/merge_requests/:iid`.
Do not lump parameter names together as `id`; spell them out as `projectId` / `iid`.

## Riverpod

- `AsyncNotifier` by default. Use `family` when there are parameters.
- `ref.watch` only inside build. Use `ref.read` in callbacks.
- When navigating from list to detail, do not pass the list item straight through; let the detail provider load it itself
  (deep links and window restoration have to behave the same way).
- After a write, `invalidate` the related providers.

## Error Handling

Convert to domain exceptions in the Repository.

| HTTP | Handling |
|---|---|
| 401 | Token expired/invalid → prompt re-authentication |
| 403 | Not permitted → tell the user the feature is unavailable |
| 404 | Resource missing or private → distinguish the two in the message |
| 429 | Rate limit → respect `Retry-After` |
| 5xx | Instance error → offer a retry |

Self-hosted instances commonly hit private certificates, proxies, and unreachable networks.
Always distinguish connection failures from authentication failures in the message.

## Before Committing

```
dart format .
flutter analyze
flutter test
```
