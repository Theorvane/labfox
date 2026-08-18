# References

LabFox는 기존 앱을 fork하지 않는다. 아래 저장소들은 **읽고 분석하는 대상**이지 코드를 가져오는 대상이 아니다.

```
GitHub Mobile        → UX / 정보 구조
      ↓
OctoLab              → GitLab 기능 구현
      ↓
LabCoat              → 보조 구현 참고
      ↓
GH4A / OpenHub       → GitHub 클라이언트 구조
      ↓
LabNex / GitNex      → 기능 아이디어
```

막히면 이 순서대로 본다. 그리고 **API 정확성은 항상 GitLab 공식 문서가 이긴다.**

---

## 1. GitLab 클라이언트

### OctoLab — GitLab Android Client
https://github.com/secninjaz/OctoLab · Apache-2.0

가장 먼저 볼 후보. GitLab.com과 self-hosted를 모두 지원한다.

참고: Project · Issue · Merge Request · Diff · Pipeline · Repository Browser ·
Self-hosted 처리 · Multi Account · Authentication · Error Handling

### LabCoat — GitLab Client
https://gitlab.com/Commit451/LabCoat · Apache-2.0

**원본 프로젝트는 GitLab에 있다.** GitHub 미러가 아니라 위 URL을 본다.
Kotlin 기반. OctoLab의 구현이 애매할 때 비교하는 보조 레퍼런스.

참고: GitLab API 클라이언트 구조 · Authentication · GitLab 객체 모델링 ·
Project navigation · Issue / MR 처리

### LabNex — GitLab Android Client
https://github.com/labnex/LabNex · **GPL 계열 — 코드 재사용 금지**

현재도 배포 중인 GitLab 클라이언트. Project / Issue / MR 관리 구현을 비교해 보기 좋다.

> ⚠️ GPL 계열이다. LabFox가 오픈소스라도 **코드를 가져올 수 없다.**
> copyleft가 전파되어 LabFox 전체가 GPL이 되고, Apache-2.0 라이선스가 무효가 되며
> App Store 유료 배포도 막힌다. 구조와 UX만 참고한다.

---

## 2. GitHub 클라이언트 (Git hosting client 구조 참고)

GitHub Mobile 공식 앱은 소스가 공개돼 있지 않다. 대신 아래를 본다.

### GH4A / OctoDroid — GitHub Android Client
https://github.com/slapperwan/gh4a

참고: Repository Browser · Issue · Pull Request · Commit · Code Viewer ·
User Profile · Navigation

### OpenHub — GitHub Android Client
https://gitlab.com/open-nexor/openhub

비교적 현대적인 GitHub Android 클라이언트. UI/구조 참고.

### GitNex — Forgejo / Gitea Android Client
https://codeberg.org/gitnex/GitNex

GitLab용은 아니지만 **self-hosted Git 서비스**의 저장소/Issue/PR UX를 참고하기 좋다.
인스턴스 등록 흐름과 self-hosted 예외 처리 아이디어에 유용하다.

---

## 3. UX 레퍼런스 — GitHub Mobile

- 소개 https://github.com/mobile
- 공식 문서 https://docs.github.com/en/get-started/using-github/github-mobile

LabFox의 가장 중요한 UX 레퍼런스. Notification 관리, Issue/PR 리뷰,
Repository 탐색, Search 등 **모바일에서 처리 가치가 높은 작업**에 집중한 설계를 참고한다.

**참고할 것** — Home · Inbox · Repository · Issue · Pull Request · Diff Review ·
Profile · Search · Navigation · Mobile Information Density

**복제하지 않을 것** — GitHub 로고 · 아이콘 · 일러스트 · UI Asset ·
동일 Layout · 브랜드 요소

UX 패턴만 참고하고 LabFox Design System으로 재구현한다.

---

## 4. GitLab 공식 문서 (Source of Truth)

| 주제 | 링크 |
|---|---|
| API Overview | https://docs.gitlab.com/api/ |
| REST API | https://docs.gitlab.com/api/rest/ |
| GraphQL | https://docs.gitlab.com/api/graphql/ |
| OAuth 2.0 | https://docs.gitlab.com/api/oauth2/ |
| Personal Access Token | https://docs.gitlab.com/user/profile/personal_access_tokens/ |

참고 저장소 구현과 공식 문서가 다르면 **공식 문서를 따른다.**

---

## 5. Flutter 공식 문서

| 주제 | 링크 |
|---|---|
| Supported Platforms | https://docs.flutter.dev/reference/supported-platforms |
| Desktop | https://docs.flutter.dev/platform-integration/desktop |
| Platform Integration | https://docs.flutter.dev/platform-integration |
| Windows | https://docs.flutter.dev/platform-integration/windows/building |
| iOS | https://docs.flutter.dev/platform-integration/ios/setup |

---

## 참고 시 원칙

```
코드 직접 복사 X

API 호출 방식 분석
    ↓
DTO / Endpoint 분석
    ↓
Flutter 재구현
```

- **라이선스를 먼저 확인한다.** LabFox는 Apache-2.0 오픈소스 + 유료 앱 배포(open core)다.
  GPL / LGPL / AGPL 코드는 재사용할 수 없다 (`AGENTS.md` §8).
- Apache-2.0(OctoLab, LabCoat)이라도 LabFox의 Flutter 코드와 UI는 새로 작성한다.
  Apache-2.0 코드를 실제로 가져다 쓴다면 NOTICE 파일에 출처를 남겨야 한다.
- 참고한 구현을 그대로 옮기지 말고, GitLab 공식 문서로 한 번 검증한 뒤 작성한다.

### 라이선스 요약

| 저장소 | 라이선스 | 코드 재사용 |
|---|---|---|
| OctoLab | Apache-2.0 | 가능 (단, 새로 작성 원칙 + NOTICE 표기) |
| LabCoat | Apache-2.0 | 가능 (동일) |
| LabNex | GPL 계열 | **불가** — 구조·UX만 |
| GH4A · OpenHub · GitNex | 각자 확인 필요 | 열기 전에 확인 |

GH4A / OpenHub / GitNex는 라이선스를 확인하지 않았다. 코드를 참고하기 전에 저장소에서 직접 확인한다.
