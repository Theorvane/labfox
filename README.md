# LabFox

**GitHub Mobile 수준의 UX에 GitLab의 Merge Request · CI/CD · Self-hosted를 결합한
Flutter 기반 Cross-platform GitLab Workflow Client.**

<p>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-blue.svg"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS-lightgrey.svg">
</p>

> 🚧 개발 초기 단계입니다. 아직 실행 가능한 빌드가 없습니다.

---

## 무엇을 만드는가

LabFox는 GitLab 웹의 모든 기능을 옮기지 않는다.
**개발자가 자주 사용하는 업무를 빠르게 처리하는 것**이 목표다.

```
알림 확인
   ↓
Issue / Merge Request 확인
   ↓
Diff 확인 및 Review
   ↓
Pipeline 상태 확인
   ↓
Job Log 확인
   ↓
Approve / Merge / Retry
```

웹 GitLab이 기능 중심으로 메뉴를 나눈다면, LabFox는 **사용자 작업 중심**으로 재구성한다.

```
Home
├── My Issues
├── Merge Requests
├── Review Requests
├── Pipelines
├── Projects
└── To-do
```

## 차별점

| | |
|---|---|
| **GitHub Mobile 수준의 UX** | 정보 밀도와 흐름을 모바일 개발 작업에 맞춰 설계 |
| **GitLab CI/CD** | Pipeline, Job Log, Retry, Manual Job까지 모바일에서 처리 |
| **Self-hosted / Multi Account** | GitLab.com과 사내 인스턴스를 동등하게 지원 |
| **4개 플랫폼** | Android · iOS · Windows · macOS |

## 기술 스택

Flutter · Dart · Riverpod · Dio · go_router · Drift/SQLite · flutter_secure_storage

```
UI → Controller (Riverpod) → Repository → GitLab API Client → GitLab
```

Monorepo 구성:

```
labfox/
├── apps/labfox/          Flutter 애플리케이션
└── packages/
    ├── gitlab_api/       GitLab REST / GraphQL 클라이언트 (순수 Dart)
    ├── gitlab_models/    DTO / Entity
    ├── design_system/    LabFox Design System
    └── secure_storage/   플랫폼 Secure Storage 래퍼
```

## 로드맵

| | |
|---|---|
| **M0** Foundation | 스캐폴딩, 라우팅, 테마, 반응형, API 클라이언트 골격 |
| **M1** Repository | PAT 로그인, Projects, Repository Browser, File Viewer |
| **M2** Collaboration | Issues, Merge Requests, Diff, Discussion, Approve, Merge |
| **M3** CI/CD | Pipeline, Jobs, Job Log, Retry, Cancel, Manual Job |
| **M4** Product | OAuth, Self-hosted, Multi Account, Inbox, Search, Offline |

상세: [`.agents/docs/roadmap.md`](.agents/docs/roadmap.md)

## 기여

**기여를 환영합니다.** 시작 전에 [CONTRIBUTING.md](CONTRIBUTING.md)를 읽어주세요.

하나의 Flutter 코드베이스로 4개 플랫폼을 지원하므로,
**데스크톱에서 고친 버그가 모바일에서도 그대로 고쳐집니다.**

```
데스크톱 기여 → 공유 코드베이스 → 모든 플랫폼 개선
```

이 저장소는 코딩 에이전트와 함께 개발한다.
작업 규칙은 [`AGENTS.md`](AGENTS.md)에 정리돼 있으며, 사람이 기여할 때도 동일하게 적용된다.

작업은 **Issue → Branch → Pull Request** 순서로 진행한다. `main`에 직접 커밋하지 않는다.

```
gh issue create --title "..."
git switch -c feat/12-mr-diff-viewer main
git commit -s -m "feat(scope): ..."
gh pr create --fill --base main
```

- 브랜치: `<type>/<issue-number>-<slug>` (`feat` `fix` `docs` `refactor` `test` `chore`)
- 커밋: [Conventional Commits](https://www.conventionalcommits.org/) + DCO 서명 (`git commit -s`)
- PR 설명에 `Closes #N`으로 Issue를 연결한다
- 상세: [`.agents/docs/workflow.md`](.agents/docs/workflow.md)

### 문서

- [CONTRIBUTING.md](CONTRIBUTING.md) — 기여 절차, DCO, 라이선스 규칙
- [`AGENTS.md`](AGENTS.md) — 아키텍처, 컨벤션, 금지 사항, 1.0 범위
- [`.agents/docs/`](.agents/docs/) — 상세 문서 (architecture · conventions · api-reference · references · roadmap)
- [`.agents/docs/workflow.md`](.agents/docs/workflow.md) — Issue → Branch → PR 절차
- [`.agents/skills/`](.agents/skills/) — 작업 유형별 절차서

## 라이선스

소스 코드는 **Apache License 2.0**으로 공개된다. → [LICENSE](LICENSE)

```
소스 코드              Apache-2.0 오픈소스 — 누구나 사용·수정·재배포 가능
데스크톱 (Win/macOS)   무료
모바일 (Android/iOS)   App Store / Play Store 유료 판매
```

데스크톱은 무료로 제공되고, 모바일 앱 판매가 개발을 지속시킨다.
LabFox는 하나의 Flutter 코드베이스를 공유하므로 **데스크톱에 기여한 개선이
모바일 앱에도 그대로 반영된다.**

서드파티 의존성 라이선스: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## 상표

**"LabFox" 이름과 로고는 Apache-2.0 라이선스에 포함되지 않는다.**
Apache License 2.0 Section 6은 상표에 대한 권리를 명시적으로 제외한다.

코드는 자유롭게 사용·수정·재배포할 수 있다. 다만 **수정한 버전을 "LabFox" 이름이나
로고로 배포하려면 사전 허락이 필요하다.** 포크는 다른 이름과 아이콘을 사용해야 한다.

자세한 내용: [TRADEMARK.md](TRADEMARK.md)

## 고지

LabFox는 **비공식 서드파티 클라이언트**이며 GitLab Inc. 또는 GitHub, Inc.와
제휴·후원·인증 관계가 없다.
"GitLab"은 GitLab Inc.의, "GitHub"은 GitHub, Inc.의 상표다.
