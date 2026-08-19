# Architecture

## Layers

```
Presentation   Widget / Screen
      ↓        watch / read
Controller     Riverpod AsyncNotifier
      ↓
Repository     network (local cache planned post-1.0)
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
- Decides the data source and hides it from the layers above.
- Converts `DioException` into domain exceptions (`GitLabAuthException`, `GitLabNotFoundException`, `GitLabRateLimitException`, and so on).
- **Today repositories are network-only.** The local cache described under
  "Local DB (Drift)" below is a **planned post-1.0 layer, not yet implemented**;
  until it lands, a repository simply calls `GitLabClient` and returns the
  result. When the cache arrives, the intended strategy is stale-while-revalidate
  (emit cache → refresh over network → re-emit), serving the last synced data
  when offline. Do not write code that assumes a cache exists yet.

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
- Tokens use a separate secure storage key per account.
- Local, per-account data that already exists (recents, favorites) is namespaced
  by account id so it never mixes across accounts; the planned cache tables will
  carry an account identifier column for the same reason.

## Local DB (Drift) — planned, post-1.0

> **Status: not implemented.** There is no `drift` dependency yet and
> repositories are network-only. This section is the intended design for when
> the cache lands after 1.0, not a description of current behaviour.

Recents and favorites currently persist through `shared_preferences`
(`core/storage`), not Drift.

Intended cached data: recent projects, Project / Issue / MR / User caches,
Recent Searches, Favorite, Draft Comment.

- The cache will be **for display only**. Never judge the result of a write operation (merge, approve, comment) from the cache alone.
- Draft Comments will be preserved even when sending them over the network fails.

## Secure Storage

For PAT / OAuth Access Token / Refresh Token only. Do not put anything else in it.
`packages/secure_storage` absorbs the platform differences.
