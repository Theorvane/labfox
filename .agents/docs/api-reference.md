# GitLab API Reference

**The official documentation is the final Source of Truth.** When a reference implementation (OctoLab, LabCoat) disagrees with it, follow the official documentation.

| Topic | Link |
|---|---|
| API Overview | https://docs.gitlab.com/api/ |
| REST API | https://docs.gitlab.com/api/rest/ |
| REST Authentication | https://docs.gitlab.com/api/rest/authentication/ |
| GraphQL | https://docs.gitlab.com/api/graphql/ |
| OAuth 2.0 | https://docs.gitlab.com/api/oauth2/ |
| Personal Access Token | https://docs.gitlab.com/user/profile/personal_access_tokens/ |

## Base URL

```
User input    https://git.company.com
    ↓
REST          https://git.company.com/api/v4
GraphQL       https://git.company.com/api/graphql
```

`gitlab.com` is nothing more than a default — do not hardcode it. Treat GitLab.com and self-hosted instances as equals.

## Authentication

- **PAT** — the default for early development. `PRIVATE-TOKEN: <token>` or `Authorization: Bearer <token>`.
- **OAuth 2.0** — the default for the shipping product. Keep the Access / Refresh Tokens in secure storage and refresh them on expiry.

Never let tokens reach the logs (`AGENTS.md` §7).

## Resource Mapping

Subfolders under `packages/gitlab_api/lib/src/` = resource groups.

| Sub-client | Main paths |
|---|---|
| `auth` | `/oauth/token` |
| `users` | `/user`, `/users/:id` |
| `groups` | `/groups`, `/groups/:id/projects` |
| `projects` | `/projects`, `/projects/:id` |
| `repositories` | `/projects/:id/repository/tree`, `/repository/files/:path` |
| `branches` | `/projects/:id/repository/branches` |
| `commits` | `/projects/:id/repository/commits` |
| `issues` | `/issues`, `/projects/:id/issues/:iid` |
| `merge_requests` | `/merge_requests`, `/projects/:id/merge_requests/:iid`, `/changes`, `/approve`, `/merge` |
| `discussions` | `/projects/:id/merge_requests/:iid/discussions` |
| `pipelines` | `/projects/:id/pipelines/:pipeline_id`, `/retry`, `/cancel` |
| `jobs` | `/projects/:id/jobs/:job_id`, `/trace`, `/play` |
| `todos` | `/todos`, `/todos/:id/mark_as_done` |
| `search` | `/search`, `/projects/:id/search` |

Verify paths and parameters against the official documentation at the point of use. The table above is a summary for laying out the folders.

## Pagination

- offset: `page`, `per_page` plus the `X-Next-Page`, `X-Total-Pages`, `X-Total` response headers.
- keyset: recommended for large collections. Follow `rel="next"` in the `Link` header.
- The total count is not always returned. Do not build UI that assumes a known total page count.

## Job Log

`/projects/:id/jobs/:job_id/trace` returns **plain text containing ANSI escapes**.
It is not JSON. Parse it with ANSI color rendering, line wrapping, and incremental loading in mind.

## Diff

MR changes come from `/projects/:id/merge_requests/:iid/changes` (or `/diffs`).
Large diffs arrive truncated or carry an `overflow` flag. Surface the truncation in the UI.

## REST vs GraphQL

REST by default. Reach for GraphQL selectively only when fetching several resources at once for a single screen is clearly better
(for example MR detail + approval state + pipelines + discussions).
Do not mix the two on the same screen and let state diverge.

## Terminology Mapping (GitHub → LabFox)

| GitHub | LabFox / GitLab |
|---|---|
| Repository | Project |
| Pull Request | Merge Request |
| Actions | Pipeline / Job |
| Notifications | To-do / Inbox |
| Code Review | MR Review |
| Organization | Group |

## Reference Implementations / UX References

See `.agents/docs/references.md` for the repository list and license caveats.
When an implementation disagrees with the official documentation, **follow the official documentation.**
