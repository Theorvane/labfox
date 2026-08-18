# CLAUDE.md

@AGENTS.md

위 `AGENTS.md`가 이 저장소의 공통 규칙이며 **Source of Truth**다.
규칙을 바꿔야 하면 `AGENTS.md`를 수정한다. 이 파일에는 Claude Code 전용 내용만 둔다.

---

## 스킬

프로젝트 스킬은 `.claude/skills/`가 아니라 **`.agents/skills/`** 에 보관한다.
`.claude/skills`는 `.agents/skills`를 가리키는 심볼릭 링크이며, 실제 파일은 모두 `.agents/` 아래에 있다.
스킬을 추가할 때는 `.agents/skills/<name>/SKILL.md`로 만든다.

| Skill | 사용 시점 |
|---|---|
| `gitlab-api-endpoint` | `packages/gitlab_api`에 GitLab 엔드포인트를 추가/수정할 때 |
| `feature-slice` | `apps/labfox/lib/features/`에 새 화면/기능을 추가할 때 |
| `design-system-component` | `packages/design_system`에 공용 위젯을 추가할 때 |
| `responsive-screen` | 화면을 Mobile / Tablet / Desktop로 분기할 때 |

## 참고 문서

세부 규칙은 필요할 때만 읽는다 (기본 컨텍스트에 올리지 않는다).

- `.agents/docs/architecture.md` — 레이어별 책임, 데이터 흐름, 캐시 전략
- `.agents/docs/conventions.md` — 네이밍, 파일 배치, freezed/Riverpod 작성 규칙
- `.agents/docs/api-reference.md` — GitLab 엔드포인트 매핑, 인증, 페이지네이션, 용어 대응
- `.agents/docs/roadmap.md` — M0~M4, Vertical Slice, 1.0 범위
- `.agents/docs/workflow.md` — Issue → Branch → PR 절차, gh 명령, 권한 경계
- `.agents/docs/references.md` — 참고 저장소/문서 링크, 참고 우선순위, 라이선스 주의사항

## 작업 흐름

origin은 **GitHub** (`labfox-app/labfox`)다. CLI는 **`gh`**.

```
Issue → Branch → 커밋(-s) → Push → PR → Merge(사용자)
```

⚠️ LabFox는 GitLab 클라이언트지만 개발은 GitHub에서 한다.
**앱 도메인 용어는 Merge Request, 개발 절차는 Pull Request.** 섞지 않는다.

확인 없이 진행해도 되는 것: Issue 생성, 브랜치 생성, 커밋, push, PR 생성.
하지 않는 것: `main` 직접 push, force push, **PR merge**, Issue/PR/브랜치 삭제.

절차와 명령: `.agents/docs/workflow.md` · 요약: `AGENTS.md` §11

## 서브에이전트

**Agent 도구 사용이 허용돼 있다.** 매번 확인받지 않아도 된다.

적합한 작업:

- 참고 저장소(OctoLab, LabCoat 등) 조사 — 읽기 전용이고 양이 많다
- GitLab API 문서 여러 엔드포인트 동시 확인
- 서로 독립적인 feature slice 구현
- 넓은 범위의 코드 탐색 (`Explore`)
- PR 리뷰 / 코드 점검

지킬 것:

- 위임 프롬프트에 **`AGENTS.md`를 읽고 따르라**고 명시한다.
  특히 라이선스 규칙(§8), `id`/`iid` 구분, 1.0 범위(§9).
- 같은 파일을 건드리는 작업은 병렬로 돌리지 않는다. `isolation: "worktree"`로 격리하거나 순차 진행.
- 서브에이전트에게 push·merge를 맡기지 않는다.
- 결과를 그대로 신뢰하지 않는다. **API 경로와 라이선스는 직접 확인한다.**
- 독립적인 작업은 한 메시지에서 동시에 띄운다.

## 작업 습관

- 코드를 쓰기 전에 같은 계층의 기존 파일을 먼저 읽고 패턴을 맞춘다.
- 새 의존성 추가는 먼저 제안하고 승인받는다 (`AGENTS.md` §4).
- 모델을 건드렸으면 `build_runner` 실행까지 포함해야 작업 완료다.
- 완료 보고 시 `flutter analyze` / `flutter test` 결과를 그대로 전달한다. 실패는 실패로 보고한다.
