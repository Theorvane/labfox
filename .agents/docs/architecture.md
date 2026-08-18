# Architecture

## Layers

```
Presentation   Widget / Screen
      ↓        watch / read
Controller     Riverpod AsyncNotifier
      ↓
Repository     cache + network composition
      ↓
GitLabClient   packages/gitlab_api (pure Dart)
      ↓ HTTPS
GitLab Instance (gitlab.com | self-hosted)
```

## Layer Responsibilities

### Presentation
- Map `AsyncValue`'s `data / loading / error` onto the screen.
- Do not make business decisions. Judgments like "can this MR be merged" belong in the Controller or the model.
- Screen-width branching happens here (see the `responsive-screen` skill).

### Controller / Notifier
- `AsyncNotifier` by default. Use `family` when parameters are needed.
- Responsible for Repository calls, optimistic updates, retries, and invalidation.
- **Do not create UseCase classes.** When logic grows, push it down into the Repository or into model methods.

### Repository
- Decides the data source (network / Drift cache) and hides it from the layers above.
- Default strategy: emit the cache first → refresh over the network → re-emit after updating the cache (stale-while-revalidate).
- When offline, serve the last synced data as-is.
- Converts `DioException` into domain exceptions (`GitLabAuthException`, `GitLabNotFoundException`, `GitLabRateLimitException`, and so on).

### GitLabClient
- `packages/gitlab_api`. No `package:flutter` dependency → unit testing must stay easy.
- Split into sub-clients per resource: `projects`, `issues`, `mergeRequests`, `discussions`, `pipelines`, `jobs`, `todos`, `search` …
- The auth token and baseUrl are injected at construction time. Never read storage from inside the client.

```dart
final gitlab = GitLabClient(baseUrl: instance.baseUrl, token: token);
final projects = await gitlab.projects.list();
final mr = await gitlab.mergeRequests.get(projectId: 123, iid: 42);
```

## Multi Account

An account is identified by `(instanceBaseUrl, userId)`.

- When the active account changes, build a new `GitLabClient` and invalidate the related providers.
- Cache tables carry an account identifier column. Data must never mix across accounts.
- Tokens use a separate secure storage key per account.

## Local DB (Drift)

Cached data: recent projects, Project / Issue / MR / User caches, Recent Searches, Favorite, Draft Comment.

- The cache is **for display only**. Never judge the result of a write operation (merge, approve, comment) from the cache alone.
- Draft Comments are preserved even when sending them over the network fails.

## Secure Storage

For PAT / OAuth Access Token / Refresh Token only. Do not put anything else in it.
`packages/secure_storage` absorbs the platform differences.
