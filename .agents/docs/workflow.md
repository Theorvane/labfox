# Workflow — Issue → Branch → PR

## 호스팅

origin은 **GitHub**이다.

```
https://github.com/labfox-app/labfox.git
```

| | |
|---|---|
| CLI | **`gh`** |
| 변경 제안 | **Pull Request (PR)** |
| 템플릿 | **`.github/`** |

> ⚠️ **혼동 주의.** LabFox는 *GitLab 클라이언트*이지만 *GitHub에서 개발*한다.
> - 코드가 다루는 대상 → GitLab (Merge Request, `iid`, `/api/v4`)
> - 개발 워크플로 → GitHub (Pull Request, `gh`)
>
> 앱 도메인 용어는 계속 **Merge Request**다. 개발 절차만 PR이다.

`gitlab` remote는 이전 호스트(개인 self-hosted GitLab 인스턴스)이며 백업용으로 남아 있다.
평소 작업은 `origin`(GitHub)만 사용한다.
공개 저장소이므로 **개인 인스턴스 주소를 문서·이슈·커밋 메시지에 남기지 않는다.**

---

## 전체 흐름

```
Issue 생성
   ↓
Branch 생성 (main에서 분기)
   ↓
커밋 (Signed-off-by 포함)
   ↓
품질 게이트 (format / analyze / test)
   ↓
Push
   ↓
PR 생성 (Closes #N)
   ↓
CI 통과 + Review
   ↓
Merge  ← 메인테이너가 수행
```

`main`에 직접 커밋하거나 push하지 않는다.

---

## 1. Issue

작업 전에 Issue를 먼저 만든다.

```
gh issue create --title "MR Diff Viewer 구현" --body "..." --label feat
gh issue list
gh issue view 12
```

### 규칙

- 제목은 **무엇을 하는지** 한 줄로. "수정", "개선", "리팩토링" 단독 제목 금지.
- **하나의 Issue = 하나의 PR**이 되도록 쪼갠다.
  "M2 Collaboration 구현" 같은 마일스톤 단위 Issue를 작업 단위로 쓰지 않는다.
- 1.0 범위(`AGENTS.md` §9) 밖이면 Issue를 만들기 전에 확인받는다.
- 템플릿: `.github/ISSUE_TEMPLATE/` (`task`, `bug`)

### 라벨

| 라벨 | 용도 |
|---|---|
| `feat` `fix` `docs` `refactor` `test` `chore` | 변경 종류 |
| `M0` `M1` `M2` `M3` `M4` | 마일스톤 |
| `android` `ios` `desktop` | 플랫폼 한정 이슈 |
| `api` `ui` `design-system` | 영역 |
| `self-hosted` | self-hosted GitLab 전용 문제 |
| `good first issue` | 신규 기여자용 |

---

## 2. Branch

```
<type>/<issue-number>-<slug>
```

```
feat/12-mr-diff-viewer
fix/28-self-hosted-cert-error
docs/31-api-reference
chore/35-melos-bootstrap
```

- type: `feat` · `fix` · `docs` · `refactor` · `test` · `chore`
- 번호는 GitHub Issue 번호다.
- slug는 소문자 + 하이픈. 짧게.

```
git switch main && git pull
git switch -c feat/12-mr-diff-viewer
```

**항상 최신 `main`에서 분기한다.** 다른 작업 브랜치 위에 쌓지 않는다.
의존이 불가피하면 PR 설명에 선행 PR을 명시한다.

---

## 3. Commit

[Conventional Commits](https://www.conventionalcommits.org/) 형식. scope는 package 또는 feature 이름.

```
feat(merge_requests): add unified diff viewer
fix(gitlab_api): handle keyset pagination in project list
refactor(design_system): extract spacing tokens
docs(agents): add PR workflow
chore(deps): bump dio to 5.5.0
```

**모든 커밋에 DCO 서명을 포함한다.**

```
git commit -s -m "fix(gitlab_api): handle keyset pagination"
```

### 규칙

- 하나의 커밋 = 하나의 논리적 변경. 무관한 변경을 섞지 않는다.
- **생성물(`*.g.dart`, `*.freezed.dart`)은 소스 변경과 같은 커밋에 넣는다.**
  따로 커밋하면 어느 시점에도 빌드가 깨진다.
- 본문에는 **왜**를 쓴다. 무엇을 바꿨는지는 diff가 말해준다.
- `WIP`, `fix typo`, `asdf` 같은 커밋을 남기지 않는다. push 전에 정리한다.
- 커밋 메시지에 토큰·비밀번호·내부 URL을 넣지 않는다.

---

## 4. 품질 게이트

push 전에 반드시 통과시킨다.

```
dart run build_runner build --delete-conflicting-outputs   # 모델 변경 시
dart format .
flutter analyze
flutter test
```

- `analyze` 경고를 남긴 채 PR을 올리지 않는다.
- 실패하면 **실패했다고 보고한다.** 통과한 것처럼 넘어가지 않는다.

---

## 5. Pull Request

```
git push -u origin feat/12-mr-diff-viewer
gh pr create --fill --base main
```

Draft로 시작:

```
gh pr create --draft --fill --base main
gh pr ready 42
```

조회 / 확인:

```
gh pr list
gh pr view 42
gh pr checks
gh run list
```

### 규칙

- 설명에 **`Closes #12`** 를 넣어 Issue와 연결한다. merge 시 Issue가 자동으로 닫힌다.
- 템플릿: `.github/PULL_REQUEST_TEMPLATE.md` 체크리스트를 실제로 확인하고 체크한다.
- 제목은 커밋 제목과 같은 형식: `feat(merge_requests): add unified diff viewer`
- **CI가 통과해야 merge한다.**
- UI 변경이 있으면 스크린샷을 첨부한다. Mobile / Desktop 양쪽.
- 리뷰 코멘트는 resolve하고 merge한다.

### PR 크기

리뷰 가능한 크기로 유지한다. 1000줄이 넘어가면 쪼갤 수 있는지 먼저 검토한다.
생성 코드(`*.g.dart`)가 많아 커진 경우는 예외이며, PR 설명에 그렇다고 적는다.

---

## 6. 권한 경계

에이전트가 확인 없이 해도 되는 것:

- Issue 생성 · 조회 · 코멘트
- 브랜치 생성 · 커밋 · push
- PR 생성 (Draft 포함) · 조회 · 코멘트
- CI 상태 확인

**하지 않는 것:**

- ❌ `main`에 직접 push
- ❌ force push (`--force`, `--force-with-lease` 모두)
- ❌ **PR merge** — 메인테이너가 한다
- ❌ Issue / PR / 브랜치 삭제
- ❌ 릴리스 태그 생성
- ❌ 저장소 설정 변경 · 저장소 공개/비공개 전환

요청받으면 위 항목도 수행한다. 다만 되돌리기 어려운 작업이므로 먼저 대상을 확인하고 진행한다.

---

## 7. 병렬 작업 / 서브에이전트

여러 Issue를 동시에 진행할 때는 브랜치를 분리하고, 가능하면 git worktree를 쓴다.
같은 작업 트리에서 서로 다른 브랜치를 오가며 작업하지 않는다.

서브에이전트를 활용해도 좋은 작업:

| 작업 | 이유 |
|---|---|
| 참고 저장소 조사 (OctoLab, LabCoat 등) | 읽기 전용이고 양이 많다. 결론만 받으면 된다 |
| GitLab API 문서 확인 | 여러 엔드포인트를 병렬로 확인 |
| 독립적인 feature slice 구현 | 서로 다른 feature는 충돌하지 않는다 |
| PR 리뷰 / 코드 점검 | 독립적인 시각이 유용하다 |
| 넓은 범위의 코드 탐색 | 컨텍스트를 절약한다 |

주의:

- **서브에이전트도 `AGENTS.md`를 따른다.** 위임할 때 관련 규칙(라이선스, id/iid, 범위)을 프롬프트에 명시한다.
- 같은 파일을 동시에 수정하는 작업은 병렬로 돌리지 않는다. worktree로 격리하거나 순차 진행한다.
- 서브에이전트에게 merge·push 권한이 필요한 작업을 맡기지 않는다.
- 서브에이전트 결과를 그대로 신뢰하지 않는다. 특히 API 경로와 라이선스는 직접 확인한다.
