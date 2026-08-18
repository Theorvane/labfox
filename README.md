<p align="center">
  <img src="brand/generated/icon-128.png" width="96" height="96" alt="LabFox">
</p>

# LabFox

**A Flutter-based cross-platform GitLab workflow client that pairs GitHub Mobile-grade UX
with GitLab's Merge Requests, CI/CD, and self-hosted support.**

<p>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-blue.svg"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS-lightgrey.svg">
</p>

> 🚧 Early development. There is no runnable build yet.

---

## What we're building

LabFox does not try to port every feature of GitLab's web UI.
The goal is to **make the work developers do every day fast.**

```
Check notifications
   ↓
Open the Issue / Merge Request
   ↓
Read the diff and review
   ↓
Check pipeline status
   ↓
Check job logs
   ↓
Approve / Merge / Retry
```

Where the GitLab web UI splits its menus by feature, LabFox reorganizes them **around the task at hand.**

```
Home
├── My Issues
├── Merge Requests
├── Review Requests
├── Pipelines
├── Projects
└── To-do
```

## What sets it apart

| | |
|---|---|
| **GitHub Mobile-grade UX** | Information density and flow designed for development work on the go |
| **GitLab CI/CD** | Pipelines, job logs, retries, and manual jobs — all from your phone |
| **Self-hosted / Multi Account** | GitLab.com and your company's instance are equal citizens |
| **Four platforms** | Android · iOS · Windows · macOS |

## Tech stack

Flutter · Dart · Riverpod · Dio · go_router · Drift/SQLite · flutter_secure_storage

```
UI → Controller (Riverpod) → Repository → GitLab API Client → GitLab
```

Monorepo layout:

```
labfox/
├── apps/labfox/          Flutter application
└── packages/
    ├── gitlab_api/       GitLab REST / GraphQL client (pure Dart)
    ├── gitlab_models/    DTO / Entity
    ├── design_system/    LabFox Design System
    └── secure_storage/   Platform secure storage wrapper
```

## Roadmap

| | |
|---|---|
| **M0** Foundation | Scaffolding, routing, theming, responsive layout, API client skeleton |
| **M1** Repository | PAT login, Projects, Repository Browser, File Viewer |
| **M2** Collaboration | Issues, Merge Requests, Diff, Discussion, Approve, Merge |
| **M3** CI/CD | Pipeline, Jobs, Job Log, Retry, Cancel, Manual Job |
| **M4** Product | OAuth, Self-hosted, Multi Account, Inbox, Search, Offline |

Details: [`.agents/docs/roadmap.md`](.agents/docs/roadmap.md)

## Contributing

**Contributions are welcome.** Read [CONTRIBUTING.md](CONTRIBUTING.md) before you start.

One Flutter codebase powers all four platforms, so
**a bug you fix on desktop is fixed on mobile too.**

```
Desktop contribution → shared codebase → every platform improves
```

This repository is developed together with coding agents.
The working rules live in [`AGENTS.md`](AGENTS.md), and they apply to human contributors just the same.

Work flows **Issue → Branch → Pull Request**. Nothing is committed directly to `main`.

```
gh issue create --title "..."
git switch -c feat/12-mr-diff-viewer dev
git commit -s -m "feat(scope): ..."
gh pr create --fill --base dev
```

- Branches: `<type>/<issue-number>-<slug>` (`feat` `fix` `docs` `refactor` `test` `chore`)
- Commits: [Conventional Commits](https://www.conventionalcommits.org/) with a DCO sign-off (`git commit -s`)
- Link the issue from the PR description with `Closes #N`
- Details: [`.agents/docs/workflow.md`](.agents/docs/workflow.md)

### Docs

- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution process, DCO, license rules
- [`AGENTS.md`](AGENTS.md) — architecture, conventions, what's off-limits, 1.0 scope
- [`.agents/docs/`](.agents/docs/) — detailed docs (architecture · conventions · api-reference · references · roadmap)
- [`.agents/docs/workflow.md`](.agents/docs/workflow.md) — the Issue → Branch → PR process
- [`.agents/skills/`](.agents/skills/) — playbooks for each type of task

## License

The source code is released under the **Apache License 2.0**. → [LICENSE](LICENSE)

```
Source code            Apache-2.0 open source — anyone may use, modify, redistribute
Desktop (Win/macOS)    Free
Mobile (Android/iOS)   Sold on the App Store / Play Store
```

Desktop is free, and mobile app sales keep development going.
Because LabFox shares a single Flutter codebase, **improvements contributed on desktop
land in the mobile apps as well.**

Third-party dependency licenses: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## Trademark

**The "LabFox" name and logo are not covered by the Apache-2.0 license.**
Section 6 of the Apache License 2.0 explicitly withholds trademark rights.

You are free to use, modify, and redistribute the code. However, **shipping a modified version
under the "LabFox" name or logo requires prior permission.** Forks must use a different name and icon.

Full details: [TRADEMARK.md](TRADEMARK.md)

## Notice

LabFox is an **unofficial third-party client** and is not affiliated with, endorsed by,
or certified by GitLab Inc. or GitHub, Inc.
"GitLab" is a trademark of GitLab Inc.; "GitHub" is a trademark of GitHub, Inc.
