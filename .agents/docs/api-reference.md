# GitLab API Reference

**공식 문서가 최종 Source of Truth.** 참고 구현(OctoLab, LabCoat)과 다르면 공식 문서를 따른다.

| 주제 | 링크 |
|---|---|
| API Overview | https://docs.gitlab.com/api/ |
| REST API | https://docs.gitlab.com/api/rest/ |
| REST Authentication | https://docs.gitlab.com/api/rest/authentication/ |
| GraphQL | https://docs.gitlab.com/api/graphql/ |
| OAuth 2.0 | https://docs.gitlab.com/api/oauth2/ |
| Personal Access Token | https://docs.gitlab.com/user/profile/personal_access_tokens/ |

## Base URL

```
사용자 입력   https://git.company.com
    ↓
REST          https://git.company.com/api/v4
GraphQL       https://git.company.com/api/graphql
```

`gitlab.com`은 기본값일 뿐이며 하드코딩하지 않는다. GitLab.com과 self-hosted를 동등하게 다룬다.

## 인증

- **PAT** — 개발 초기 기본. `PRIVATE-TOKEN: <token>` 또는 `Authorization: Bearer <token>`.
- **OAuth 2.0** — 정식 제품 기본. Access / Refresh Token을 secure storage에 보관하고 만료 시 갱신.

토큰은 로그에 남기지 않는다 (`AGENTS.md` §7).

## 리소스 매핑

`packages/gitlab_api/lib/src/` 하위 폴더 = 리소스 그룹.

| 서브 클라이언트 | 주요 경로 |
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

경로와 파라미터는 사용 시점에 공식 문서로 확인한다. 위 표는 폴더 구성을 위한 요약이다.

## Pagination

- offset: `page`, `per_page` + 응답 헤더 `X-Next-Page`, `X-Total-Pages`, `X-Total`.
- keyset: 대규모 컬렉션에서 권장. `Link` 헤더의 `rel="next"` 를 따라간다.
- 전체 개수를 항상 주지는 않는다. 총 페이지 수를 가정한 UI를 만들지 않는다.

## Job Log

`/projects/:id/jobs/:job_id/trace`는 **ANSI escape가 포함된 plain text**를 준다.
JSON이 아니다. ANSI 색상 렌더링, 라인 wrap, 증분 로딩을 고려해 파싱한다.

## Diff

MR 변경사항은 `/projects/:id/merge_requests/:iid/changes` (또는 `/diffs`).
큰 diff는 잘려 오거나 `overflow` 플래그가 붙는다. 잘림을 UI에 표시한다.

## REST vs GraphQL

기본은 REST. 한 화면에서 여러 리소스를 한 번에 가져오는 편이 명확히 유리할 때만
(예: MR 상세 + 승인 상태 + 파이프라인 + 토론) GraphQL을 선택적으로 쓴다.
두 방식을 같은 화면에서 혼용해 상태가 갈라지지 않게 한다.

## 용어 매핑 (GitHub → LabFox)

| GitHub | LabFox / GitLab |
|---|---|
| Repository | Project |
| Pull Request | Merge Request |
| Actions | Pipeline / Job |
| Notifications | To-do / Inbox |
| Code Review | MR Review |
| Organization | Group |

## 참고 구현 / UX 레퍼런스

저장소 목록과 라이선스 주의사항은 `.agents/docs/references.md` 참고.
어떤 구현과 공식 문서가 다르면 **공식 문서를 따른다.**
