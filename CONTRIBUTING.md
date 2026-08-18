# Contributing to LabFox

기여해 주셔서 감사합니다. LabFox는 **하나의 Flutter 코드베이스**로 4개 플랫폼을 지원합니다.
데스크톱에서 고친 버그가 모바일에서도 그대로 고쳐집니다. 기여는 모든 플랫폼에 영향을 줍니다.

---

## 프로젝트 모델

```
소스 코드              Apache-2.0 오픈소스 — 누구나 사용·수정·재배포 가능
데스크톱 (Win/macOS)   무료
모바일 (Android/iOS)   App Store / Play Store 유료 판매
```

기여한 코드는 Apache-2.0으로 공개되며, **유료로 판매되는 모바일 앱에도 포함됩니다.**
기여 전에 이 점을 이해하고 동의해 주세요. 동의하지 않으신다면 기여하지 말아 주세요.

"LabFox" 이름과 로고는 상표이며 Apache-2.0 라이선스에 포함되지 않습니다.
포크는 자유롭지만 다른 이름과 아이콘을 사용해야 합니다. ([TRADEMARK.md](TRADEMARK.md))

---

## 시작하기 전에

1. **[AGENTS.md](AGENTS.md)를 먼저 읽어주세요.** 아키텍처, 컨벤션, 금지 사항이 정리돼 있습니다.
   사람과 코딩 에이전트 모두에게 동일하게 적용됩니다.
2. 작업하려는 내용이 **1.0 범위**(AGENTS.md §9) 안인지 확인해 주세요.
3. 큰 변경은 코드를 쓰기 전에 Issue에서 먼저 논의해 주세요.

---

## 개발 환경

```bash
flutter --version          # stable 채널
melos bootstrap            # monorepo 의존성 설치
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 작업 흐름

```
Issue → Branch → 커밋 → Pull Request
```

> LabFox는 GitLab 클라이언트지만 **개발은 GitHub에서** 합니다.
> 앱 안의 도메인 용어는 계속 Merge Request이고, 기여 절차만 Pull Request입니다.

`main`에 직접 커밋하지 않습니다.

```bash
git switch -c feat/12-mr-diff-viewer main
```

- 브랜치: `<type>/<issue-number>-<slug>` — type은 `feat` `fix` `docs` `refactor` `test` `chore`
- 커밋: [Conventional Commits](https://www.conventionalcommits.org/)
  예) `fix(gitlab_api): handle keyset pagination in project list`
- PR 설명에 `Closes #12`로 Issue를 연결
- 상세: [`.agents/docs/workflow.md`](.agents/docs/workflow.md)

### PR 전 확인

```bash
dart format .
flutter analyze
flutter test
```

`analyze` 경고가 남아 있으면 PR을 열지 말아 주세요.

---

## 반드시 지켜야 할 것

### 라이선스

- **GPL · LGPL · AGPL 코드를 가져오지 마세요.** copyleft가 전파되면 프로젝트 전체가 GPL이 되어
  Apache-2.0이 무효가 되고 App Store 배포가 막힙니다.
- 새 의존성은 **MIT · BSD · Apache-2.0 · ISC · Zlib** 만 허용됩니다.
  추가하셨다면 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)를 갱신해 주세요.
- 다른 프로젝트의 코드를 복사하지 마세요. 참고는 자유롭지만 구현은 새로 작성합니다.
- 폰트·아이콘·이미지도 상용 이용 가능 여부를 확인해 주세요.

### 플랫폼

- **플랫폼별로 UI를 따로 만들지 마세요.** 화면 폭으로 분기합니다.
  `Platform.isAndroid`가 아니라 `LayoutBuilder` + 브레이크포인트를 씁니다.
  이것이 데스크톱 기여가 모바일에 전파되는 이유입니다.
- 데스크톱만 고쳤더라도 모바일 폭(<600)에서 깨지지 않는지 확인해 주세요.

### 보안

- 토큰(PAT / OAuth)을 로그·코드·스크린샷·커밋에 남기지 마세요.
- Issue나 PR에 로그를 붙일 때 `Authorization` 헤더와 `glpat-` 문자열을 확인해 주세요.

---

## 기여자 원산지 증명 (DCO)

모든 커밋에 `Signed-off-by` 를 포함해 주세요.

```bash
git commit -s -m "fix(gitlab_api): handle keyset pagination"
```

이는 [Developer Certificate of Origin](https://developercertificate.org/)에 동의한다는 의미이며,
**본인이 해당 코드를 기여할 권리를 가지고 있음**을 확인하는 절차입니다.
별도의 CLA 서명은 요구하지 않습니다.

---

## 리뷰

- PR은 리뷰 가능한 크기로 유지해 주세요. 1000줄이 넘으면 쪼갤 수 있는지 검토합니다.
- UI 변경은 스크린샷을 첨부해 주세요. **Mobile / Desktop 양쪽**, Light / Dark 양쪽.
- CI가 통과해야 merge됩니다.
- 리뷰가 늦어질 수 있습니다. 양해 부탁드립니다.

---

## 기여하기 좋은 것

| | |
|---|---|
| **버그 리포트** | 재현 방법이 명확하면 가장 도움이 됩니다 |
| **Self-hosted 환경 이슈** | 다양한 GitLab 버전·설정에서의 문제는 직접 재현하기 어렵습니다 |
| **데스크톱 UX** | Windows/macOS 사용 경험, 키보드 단축키, Multi-pane |
| **접근성** | 스크린 리더, 대비, 터치 타겟 |
| **번역** | 다국어 지원 |

## 기여받지 않는 것

- 1.0 범위 밖 기능 (Wiki, Packages, Registry, Analytics, Admin 등)
- GitHub 브랜드 에셋을 사용한 UI
- 아키텍처를 우회하는 변경 (Widget에서 `GitLabClient` 직접 호출 등)

---

문의: sloki9637@gmail.com
