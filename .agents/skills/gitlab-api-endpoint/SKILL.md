---
name: gitlab-api-endpoint
description: When adding or modifying a GitLab REST endpoint in packages/gitlab_api. Use it when you need to call a new resource, add a DTO, or change pagination or error handling.
---

# Adding a GitLab endpoint

## 1. Check the official docs (do not skip)

Confirm the real path, parameters, and response shape at https://docs.gitlab.com/api/.
If the reference repositories (OctoLab, LabCoat) disagree with them, **follow the official docs**.
Never write a path from memory or guesswork.

Things to confirm:
- Whether the path uses `id` or `iid`
- Required/optional query parameters
- Pagination style (offset / keyset)
- Whether the response is JSON or plain text (job trace is text)

## 2. Placement

Put it in the folder for its resource group.

```
packages/gitlab_api/lib/src/<resource>/
├── <resource>_api.dart      sub-client
└── (if needed) request parameter classes
```

Expose an accessor on `GitLabClient`: `gitlab.mergeRequests.get(...)`

## 3. Authoring rules

```dart
Future<MergeRequest> get({
  required Object projectId,   // int or "group/project" (URL-encoded)
  required int iid,
}) async {
  final res = await _dio.get('/projects/${_enc(projectId)}/merge_requests/$iid');
  return MergeRequest.fromJson(res.data as Map<String, dynamic>);
}
```

- Do not import `packages/flutter`. Keep it pure Dart.
- projectId accepts both a numeric ID and a `group/project` path. Path form **must be URL-encoded**.
- Use the injected baseUrl. Never hardcode `gitlab.com`.
- The token is attached by a Dio interceptor. Do not build headers per method.

## 4. Models

Add them to `packages/gitlab_models` with freezed + json_serializable.
Map snake_case fields with `@JsonKey(name: ...)`, and make possibly-absent fields nullable.

```
dart run build_runner build --delete-conflicting-outputs
```

## 5. Pagination

List endpoints return page metadata alongside the data.

```dart
Future<Paginated<Project>> list({int page = 1, int perPage = 20});
```

Read the `X-Next-Page` / `X-Total-Pages` response headers and carry them through.
Those headers may be missing (large collections), so do not design an API that assumes a total count.

## 6. Errors

Do not let a raw `DioException` escape.
Convert 401 / 403 / 404 / 429 / 5xx into domain exceptions (see `.agents/docs/conventions.md`).
Distinguish connection failures (unreachable self-hosted instance, certificate errors) from authentication failures.

## 7. Tests

`gitlab_api` does not depend on Flutter, so verify it with pure Dart tests.
Keep real response JSON samples as fixtures and add parsing tests against them. Never include real tokens.

## Definition of done

- [ ] Path/parameters confirmed against the official docs
- [ ] Sub-client method added + exposed on `GitLabClient`
- [ ] freezed model + build_runner run
- [ ] Pagination/error handling
- [ ] Parsing test
- [ ] `dart format .` / `flutter analyze` pass
