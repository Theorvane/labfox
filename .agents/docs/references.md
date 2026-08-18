# References

LabFox does not fork existing apps. The repositories below are **subjects to read and analyze**, not sources to pull code from.

```
GitHub Mobile        → UX / information architecture
      ↓
OctoLab              → GitLab feature implementation
      ↓
LabCoat              → secondary implementation reference
      ↓
GH4A / OpenHub       → GitHub client structure
      ↓
LabNex / GitNex      → feature ideas
```

When stuck, consult them in this order. And **for API accuracy, the official GitLab documentation always wins.**

---

## 1. GitLab Clients

### OctoLab — GitLab Android Client
https://github.com/secninjaz/OctoLab · Apache-2.0

The first candidate to look at. Supports both GitLab.com and self-hosted.

Reference: Project · Issue · Merge Request · Diff · Pipeline · Repository Browser ·
Self-hosted handling · Multi Account · Authentication · Error Handling

### LabCoat — GitLab Client
https://gitlab.com/Commit451/LabCoat · Apache-2.0

**The original project lives on GitLab.** Use the URL above, not the GitHub mirror.
Kotlin-based. A secondary reference for comparison when OctoLab's implementation is unclear.

Reference: GitLab API client structure · Authentication · GitLab object modeling ·
Project navigation · Issue / MR handling

### LabNex — GitLab Android Client
https://github.com/labnex/LabNex · **GPL family — code reuse forbidden**

A GitLab client still under active distribution. Good for comparing Project / Issue / MR management implementations.

> ⚠️ This is GPL family. Even though LabFox is open source, **you cannot take code from it.**
> The copyleft would propagate, turning all of LabFox into GPL, voiding the Apache-2.0 license
> and blocking paid App Store distribution. Reference structure and UX only.

---

## 2. GitHub Clients (Git hosting client structure reference)

The official GitHub Mobile app is not open source. Look at these instead.

### GH4A / OctoDroid — GitHub Android Client
https://github.com/slapperwan/gh4a

Reference: Repository Browser · Issue · Pull Request · Commit · Code Viewer ·
User Profile · Navigation

### OpenHub — GitHub Android Client
https://gitlab.com/open-nexor/openhub

A relatively modern GitHub Android client. Reference for UI/structure.

### GitNex — Forgejo / Gitea Android Client
https://codeberg.org/gitnex/GitNex

Not GitLab-specific, but a good reference for repository/Issue/PR UX on **self-hosted Git services**.
Useful for instance registration flows and self-hosted edge-case handling ideas.

---

## 3. UX Reference — GitHub Mobile

- Overview https://github.com/mobile
- Official docs https://docs.github.com/en/get-started/using-github/github-mobile

LabFox's most important UX reference. Study how it focuses on **tasks worth doing on mobile** —
notification management, Issue/PR review, repository browsing, search.

**Do reference** — Home · Inbox · Repository · Issue · Pull Request · Diff Review ·
Profile · Search · Navigation · Mobile Information Density

**Do not copy** — GitHub logo · icons · illustrations · UI assets ·
identical layouts · brand elements

Reference the UX patterns only, and rebuild them with the LabFox Design System.

---

## 4. GitLab Official Documentation (Source of Truth)

| Topic | Link |
|---|---|
| API Overview | https://docs.gitlab.com/api/ |
| REST API | https://docs.gitlab.com/api/rest/ |
| GraphQL | https://docs.gitlab.com/api/graphql/ |
| OAuth 2.0 | https://docs.gitlab.com/api/oauth2/ |
| Personal Access Token | https://docs.gitlab.com/user/profile/personal_access_tokens/ |

When a reference repository's implementation disagrees with the official docs, **follow the official docs.**

---

## 5. Flutter Official Documentation

| Topic | Link |
|---|---|
| Supported Platforms | https://docs.flutter.dev/reference/supported-platforms |
| Desktop | https://docs.flutter.dev/platform-integration/desktop |
| Platform Integration | https://docs.flutter.dev/platform-integration |
| Windows | https://docs.flutter.dev/platform-integration/windows/building |
| iOS | https://docs.flutter.dev/platform-integration/ios/setup |

---

## Principles When Referencing

```
No direct code copying

Analyze the API call approach
    ↓
Analyze DTOs / endpoints
    ↓
Reimplement in Flutter
```

- **Check the license first.** LabFox is Apache-2.0 open source + paid app distribution (open core).
  GPL / LGPL / AGPL code cannot be reused (`AGENTS.md` §8).
- Even for Apache-2.0 (OctoLab, LabCoat), write LabFox's Flutter code and UI from scratch.
  If you do actually take Apache-2.0 code, you must record the attribution in the NOTICE file.
- Don't transplant a referenced implementation as-is; verify it against the official GitLab docs first, then write it.

### License Summary

| Repository | License | Code reuse |
|---|---|---|
| OctoLab | Apache-2.0 | Allowed (but write-from-scratch principle + NOTICE attribution) |
| LabCoat | Apache-2.0 | Allowed (same) |
| LabNex | GPL family | **Not allowed** — structure/UX only |
| GH4A · OpenHub · GitNex | Must be checked individually | Check before opening |

The licenses of GH4A / OpenHub / GitNex have not been verified. Check them directly in the repository before referencing any code.
