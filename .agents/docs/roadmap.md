# Roadmap

## 최초 Vertical Slice

전체 API를 먼저 구현하지 않는다. 아래 한 줄기를 먼저 끝낸다.

```
PAT Login → Home → Projects → Project → Merge Requests → MR Detail → Diff
```

여기까지 되면 API 아키텍처 · 인증 · 라우팅 · 상태관리 · UI · Markdown · Diff · 반응형이
사실상 전부 검증된다. 이후 기능은 이 뼈대를 반복 적용하는 일이다.

## 단계

### M0 — Foundation
Flutter 프로젝트 및 monorepo 스캐폴딩, Riverpod / Dio / go_router,
freezed + json_serializable, Drift, Secure Storage, Theme, 반응형 레이아웃,
`gitlab_api` 클라이언트 골격.

### M1 — Repository
PAT Login, Projects, Project Overview, Repository Browser, File Viewer,
README 렌더링, Branches, Commits.

### M2 — Collaboration
Issues, Issue Detail, Comments, Merge Requests, MR Detail, Diff, Discussion,
Approve, Merge.

### M3 — CI/CD
Pipeline, Pipeline Detail, Stages, Jobs, Job Log, Retry, Cancel, Manual Job.

### M4 — Product
OAuth, Self-hosted, Multi Account, Inbox(To-do), Search, Local Cache, Offline, Deep Links.

## 1.0 범위

**포함**

- Account — GitLab.com, Self-hosted, PAT, OAuth, Multi Account
- Project — Projects, Favorites, Repository, Files, Branches, Commits
- Collaboration — Issues, Comments, Merge Requests, Discussions, Diff, Approval, Merge
- CI/CD — Pipelines, Jobs, Job Logs, Retry, Cancel, Manual Job
- Productivity — To-do Inbox, Search, Recent, Favorites
- Platform — Android, iOS, Windows, macOS

**제외 (1.0에서 구현하지 않는다)**

Wiki · Packages · Container Registry · Infrastructure · Kubernetes ·
Security Dashboard · Analytics · Admin Area · Runner Administration

## 이후 확장

- Desktop Integration — VS Code / Cursor / Android Studio / IntelliJ / Terminal / Explorer / Finder 에서 열기
- AI — Job Log 실패 원인 분석, MR 변경사항 요약
  → **1.0 핵심 기능 완성 이후에 착수한다.**

## 정보 구조

웹 GitLab의 기능 중심 메뉴를 그대로 옮기지 않고, 사용자 작업 중심으로 재구성한다.

```
Home
├── My Issues
├── Merge Requests
├── Review Requests
├── Pipelines
├── Projects
└── To-do
```

Mobile 네비게이션: Bottom Navigation — `Home · Inbox · Search · Me`
Desktop: Navigation Rail + Multi-pane + Command Palette (⌘K / Ctrl+K)
