# AGENTS.md — LabFox

이 문서는 LabFox 저장소에서 작업하는 모든 코딩 에이전트의 **공통 규칙**이다.
도구별 파일(`CLAUDE.md` 등)은 이 문서를 import 하고, 도구 전용 내용만 추가한다.

---

## 1. 프로젝트

**LabFox** — GitHub Mobile 수준의 UX에 GitLab의 Merge Request / CI-CD / Self-hosted 를 결합한
Flutter 기반 Cross-platform GitLab **Workflow Client**.

지원 플랫폼: Android · iOS · Windows · macOS

핵심 사용 흐름 (모든 기능 판단의 기준):

```
알림 확인 → Issue / MR 확인 → Diff 확인 및 Review → Pipeline 상태 → Job Log → Approve / Merge / Retry
```

GitLab 웹의 모든 기능을 옮기지 않는다. **개발자가 자주 쓰는 작업을 빠르게 처리**하는 것이 목표다.
기능 추가 요청을 받으면 위 흐름에 기여하는지 먼저 판단한다.

### 라이선스 / 배포 모델

LabFox는 **open core** 모델이다.

```
소스 코드              Apache-2.0 오픈소스 (GitHub: labfox-app/labfox)
데스크톱 (Win/macOS)   무료
모바일 (Android/iOS)   App Store / Play Store 유료 판매
```

의도한 개선 사이클:

```
데스크톱 사용자 / 외부 기여자
        │  MR 기여
        ▼
   공유 Flutter 코드베이스
        │  동일 feature · 동일 로직
        ▼
    모바일 앱도 함께 개선
```

**이 모델이 성립하는 전제가 곧 아키텍처 제약이다.**
플랫폼별로 코드를 나누면 데스크톱 기여가 모바일에 전파되지 않는다.
따라서 §10의 "플랫폼별 UI를 따로 만들지 않는다"는 취향이 아니라 **비즈니스 요구사항**이다.

| 파일 | 내용 |
|---|---|
| `LICENSE` | Apache License 2.0 전문 |
| `NOTICE` | 저작권 고지, attribution, 제3자 상표 고지 |
| `TRADEMARK.md` | 상표 정책 — "LabFox" 이름·로고는 라이선스에서 제외 |
| `THIRD_PARTY_NOTICES.md` | 의존성 라이선스 허용/금지 목록, 인앱 고지 |
| `CONTRIBUTING.md` | 외부 기여 절차 |

- **"LabFox" 이름과 로고는 상표이며 라이선스에 포함되지 않는다** (Apache-2.0 §6).
  코드는 자유롭게 쓸 수 있지만 같은 이름으로 스토어에 올릴 수는 없다. 이것이 유료 모델을 지탱한다.
- 외부 기여를 받으므로 **저작권이 분산된다.** 나중에 라이선스를 닫는 것은 사실상 불가능하다.
- 코드나 문서에서 GitLab / GitHub를 제휴·공식 관계처럼 표현하지 않는다.

---

## 2. 저장소 구조

Monorepo. API 레이어를 앱에서 분리한다.

```
labfox/
├── apps/
│   └── labfox/              Flutter 애플리케이션
├── packages/
│   ├── gitlab_api/          GitLab REST / GraphQL 클라이언트 (Flutter 비의존, 순수 Dart)
│   ├── gitlab_models/       DTO / Entity (freezed + json_serializable)
│   ├── design_system/       LabFox Design System (위젯, 테마, 토큰)
│   └── secure_storage/      플랫폼 Secure Storage 래퍼
├── .agents/                 에이전트용 스킬 및 상세 문서
├── AGENTS.md                ← 이 문서
└── CLAUDE.md                AGENTS.md import + Claude Code 전용
```

앱 내부는 **Feature First**:

```
apps/labfox/lib/
├── app/          app.dart, router.dart, theme.dart
├── core/         auth/ network/ storage/ utils/
├── features/     home/ inbox/ projects/ repository/ issues/
│                 merge_requests/ pipelines/ search/ profile/
└── main.dart
```

각 feature 폴더는 `data/` `presentation/` 정도만 둔다. 계층을 더 쪼개지 않는다.

---

## 3. 아키텍처

```
UI (Widget)
  ↓
Controller / Notifier (Riverpod AsyncNotifier)
  ↓
Repository
  ↓
GitLabClient (packages/gitlab_api)
  ↓
GitLab Instance
```

규칙:

- **Clean Architecture 과적용 금지.** API CRUD 중심 앱이다.
- **UseCase 클래스를 만들지 않는다.** Controller가 Repository를 직접 호출한다.
- Widget이 `GitLabClient`나 `Dio`를 직접 만지지 않는다. 반드시 Controller 경유.
- `packages/gitlab_api`는 `package:flutter`를 import 하지 않는다. 순수 Dart 유지.
- Repository는 캐시(Drift) ↔ 네트워크(GitLabClient) 조합 책임을 갖는다. Controller는 출처를 모른다.

상세: `.agents/docs/architecture.md`

---

## 4. 기술 스택

| 영역 | 선택 |
|---|---|
| Framework | Flutter / Dart |
| State | Riverpod (`AsyncNotifier` 기본) |
| Network | Dio |
| Routing | go_router |
| Model | freezed + json_serializable |
| Local DB | Drift + SQLite |
| Secret | flutter_secure_storage |

임의로 다른 상태관리/네트워크 라이브러리를 도입하지 않는다. 필요하면 먼저 제안하고 승인받는다.

---

## 5. 코딩 컨벤션

- 파일명 `snake_case.dart`, 클래스 `PascalCase`, 멤버 `lowerCamelCase`.
- 모델은 전부 `freezed` + `json_serializable`. 수동 `fromJson` 작성 금지.
- 코드 생성: `dart run build_runner build --delete-conflicting-outputs`.
  생성물(`*.freezed.dart`, `*.g.dart`)은 직접 편집하지 않는다.
- GitLab API가 주는 필드명은 snake_case다. `@JsonKey(name: 'merge_status')` 로 매핑하고
  Dart 쪽 이름은 camelCase로 둔다.
- MR/Issue 식별자는 **`iid`(project 내 번호)와 `id`(전역)를 반드시 구분**한다.
  화면에 보이는 `!142`, `#282`는 `iid`다. 파라미터 이름을 `id`로 뭉개지 말 것.
- 문자열 하드코딩보다 `design_system`의 토큰/컴포넌트를 우선 사용한다.
- 주석과 커밋 메시지는 한국어/영어 모두 허용하되 한 파일 안에서는 통일한다.

상세: `.agents/docs/conventions.md`

---

## 6. GitLab API 규칙

- **공식 문서가 최종 Source of Truth.** 참고 오픈소스 구현과 다르면 공식 문서를 따른다.
  https://docs.gitlab.com/api/
- 기본은 **REST(`/api/v4`)**. 한 화면에서 여러 리소스를 모아야 유리한 경우에만 GraphQL을 선택 사용.
- Self-hosted 대응: baseUrl은 항상 사용자 입력 인스턴스 URL에서 파생한다.
  `https://git.company.com` → `https://git.company.com/api/v4`. **`gitlab.com`을 하드코딩하지 않는다.**
- Pagination은 응답 헤더(`X-Next-Page`, `X-Total-Pages`) 또는 keyset 기반으로 처리한다.
  페이지 수를 임의 가정하지 않는다.
- 401 / 403 / 404 / 429 / 5xx 를 구분해 도메인 예외로 변환한 뒤 UI에 올린다. raw `DioException` 누출 금지.

새 엔드포인트를 추가할 때는 `.agents/skills/gitlab-api-endpoint/SKILL.md` 를 따른다.

---

## 7. 보안

다음은 **절대 평문 저장/로그 출력 금지**:

- Personal Access Token
- OAuth Access Token / Refresh Token

- 토큰은 `packages/secure_storage` 경유로만 읽고 쓴다. Drift/SharedPreferences에 넣지 않는다.
- 로그/에러 리포트에 Authorization 헤더가 실리지 않도록 Dio interceptor에서 마스킹한다.
- 테스트/예제 코드에 실제 토큰을 넣지 않는다. `glpat-xxxxxxxxxxxx` 형태의 더미만 사용.

---

## 8. 하지 말 것

- 참고 저장소의 **코드를 복사하지 않는다.**
  API 호출 방식 · DTO · 엔드포인트 구성만 분석하고 Flutter로 새로 구현한다.
  공개 저장소이므로 출처가 불분명한 코드는 곧바로 드러난다.
- **copyleft 라이선스 코드를 어떤 형태로도 가져오지 않는다** (GPL · LGPL · AGPL).
  LabNex 등이 여기 해당한다. 오픈소스라도 마찬가지다 — 한 줄이라도 들어가면
  copyleft가 전파되어 Apache-2.0이 무효가 되고, 소스를 받은 사람이 무료로
  재배포할 권리를 갖게 되며, App Store 배포도 막힌다. 구조와 UX만 참고한다.
- **새 의존성을 추가하기 전에 라이선스를 확인한다.**
  허용: MIT · BSD · Apache-2.0 · ISC · Zlib
  금지: GPL · LGPL · AGPL · SSPL · BUSL · Commons Clause · 라이선스 미표기
  LGPL은 Flutter가 정적 링크를 하므로 동적 링크 예외를 쓸 수 없다.
- 의존성을 추가했으면 **`THIRD_PARTY_NOTICES.md`를 갱신한다.**
  permissive 라이선스도 저작권 고지와 라이선스 전문 첨부가 의무다. 선택 사항이 아니다.
- 폰트·아이콘·이미지 에셋도 라이선스 확인 대상이다. **상용 이용 가능 여부**를 먼저 본다.
- GitHub 로고 / 아이콘 / 일러스트 / UI 에셋 / 브랜드 요소를 가져오지 않는다.
  **UX 패턴만** 참고하고 LabFox Design System으로 재구현한다.
- 1.0 범위 밖 기능을 임의 구현하지 않는다 (아래 9번).
- 플랫폼별로 UI를 따로 만들지 않는다. 하나의 feature를 반응형으로 분기한다.

---

## 9. 1.0 범위

**포함** — Account(GitLab.com / Self-hosted / PAT / OAuth / Multi Account),
Project(Projects, Favorites, Repository, Files, Branches, Commits),
Collaboration(Issues, Comments, MR, Discussions, Diff, Approval, Merge),
CI-CD(Pipelines, Jobs, Job Logs, Retry, Cancel, Manual Job),
Productivity(To-do Inbox, Search, Recent, Favorites).

**제외** — Wiki, Packages, Container Registry, Infrastructure, Kubernetes,
Security Dashboard, Analytics, Admin Area, Runner Administration, AI 기능.

개발 단계(M0~M4)와 최초 Vertical Slice: `.agents/docs/roadmap.md`

---

## 10. 반응형

동일 feature 코드를 폭 기준으로 분기한다.

| 폭 | 모드 | 레이아웃 |
|---|---|---|
| < 600 | Mobile | Bottom Navigation, 단일 pane, push 네비게이션 |
| 600–1000 | Tablet / Compact Desktop | Navigation Rail, 2 pane |
| > 1000 | Desktop | Navigation Rail + Multi-pane, Command Palette, Split Diff |

`Platform.isX`가 아니라 **화면 폭**으로 판단한다 (태블릿·창 크기 변경 대응).
작성 방법: `.agents/skills/responsive-screen/SKILL.md`

---

## 11. 작업 흐름 — Issue → Branch → PR

origin은 **GitHub** (`labfox-app/labfox`)다. CLI는 `gh`.

> ⚠️ **용어 혼동 주의.** LabFox는 *GitLab 클라이언트*지만 *GitHub에서 개발*한다.
> - 앱이 다루는 도메인 → **Merge Request**, `iid`, `/api/v4` (GitLab)
> - 개발 절차 → **Pull Request**, `gh` (GitHub)
>
> 코드와 UI의 용어는 계속 GitLab 기준이다. 바꾸지 않는다.

모든 작업은 아래 순서를 따른다. `main`에 직접 커밋하지 않는다.

```
Issue → Branch → 커밋 → Push → PR → Review → Merge
```

### 1) Issue

```
gh issue create --title "MR Diff Viewer 구현" --body "..."
```

- 제목은 **무엇을 하는지** 한 줄로. "수정", "개선" 같은 모호한 제목 금지.
- 1.0 범위(§9) 밖이면 Issue를 만들기 전에 확인받는다.
- **하나의 Issue = 하나의 PR**이 되도록 쪼갠다.

### 2) Branch

```
<type>/<issue-number>-<slug>

feat/12-mr-diff-viewer
fix/28-self-hosted-cert-error
```

type: `feat` · `fix` · `docs` · `refactor` · `test` · `chore`

```
git switch -c feat/12-mr-diff-viewer main
```

`main`에서 분기한다. 다른 작업 브랜치 위에 쌓지 않는다.

### 3) Commit

Conventional Commits + **DCO 서명**(`-s`). scope는 package 또는 feature 이름.

```
git commit -s -m "feat(merge_requests): add unified diff viewer"
```

- 하나의 커밋은 하나의 논리적 변경.
- 생성물(`*.g.dart`, `*.freezed.dart`)은 소스 변경과 같은 커밋에 넣는다.
- 본문에는 **왜** 바꿨는지 쓴다. 무엇을 바꿨는지는 diff가 말해준다.

### 4) Push 전 품질 게이트

```
dart format .
flutter analyze
flutter test
```

`analyze` 경고를 남긴 채 PR을 올리지 않는다. 실패하면 실패했다고 보고한다.

### 5) PR

```
gh pr create --fill --base main
```

- 설명에 **`Closes #12`** 를 넣어 Issue와 연결한다.
- 템플릿: `.github/PULL_REQUEST_TEMPLATE.md`
- CI가 통과해야 merge한다.

### 커밋 / 푸시 / PR 권한

- **커밋·브랜치 생성·push·PR 생성은 진행해도 된다.** 매번 확인받지 않는다.
- **단, `main`에 직접 push하지 않는다.** force push도 하지 않는다.
- **merge는 메인테이너가 한다.** 에이전트가 PR을 merge하지 않는다.
- Issue/PR을 close하거나 삭제하는 것은 요청받았을 때만 한다.

### 그 외

1. 변경 전에 해당 feature의 기존 패턴을 먼저 읽는다. 새 패턴을 만들기보다 맞춘다.
2. 모델 변경 시 `build_runner`를 돌린다.
3. 스캐폴딩이 아직 없는 영역을 건드릴 때는 임의로 만들지 말고 범위를 먼저 확인한다.

> 현재 저장소는 초기 상태로, `apps/` · `packages/` 스캐폴딩이 아직 생성되지 않았다.
> Flutter 명령은 M0 완료 이후를 기준으로 한다.

상세: `.agents/docs/workflow.md`

---

## 12. 참고 우선순위

```
GitHub Mobile        → UX / 정보 구조
      ↓
OctoLab              → GitLab 기능 구현 (최우선 코드 레퍼런스)
      ↓
LabCoat              → 보조 구현 참고
      ↓
GH4A / OpenHub       → GitHub 클라이언트 구조
      ↓
LabNex / GitNex      → 기능 아이디어 (GPL 주의)
```

단, **API 정확성은 항상 GitLab 공식 문서가 이긴다.**
참고 구현과 공식 문서가 다르면 공식 문서를 따른다.

저장소 URL · 라이선스 · 항목별로 무엇을 볼지: `.agents/docs/references.md`

## 13. `.agents/`

에이전트용 스킬과 상세 문서는 `.agents/` 아래에 둔다 (`.claude/` 아님).

```
.agents/
├── skills/    작업 유형별 절차 (SKILL.md)
└── docs/      architecture / conventions / api-reference / roadmap
```
