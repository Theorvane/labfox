# .agents/

LabFox 코딩 에이전트용 자산을 모아두는 폴더.
도구별 폴더(`.claude/`, `.cursor/` 등)에 흩어놓지 않고 여기 한 곳에 둔다.

```
.agents/
├── skills/    작업 유형별 절차서 (<name>/SKILL.md)
└── docs/      상세 문서 (필요할 때만 읽는다)
```

- 공통 규칙은 저장소 루트 `AGENTS.md`.
- `CLAUDE.md`는 `AGENTS.md`를 import 하고 Claude Code 전용 내용만 갖는다.
- `.claude/skills`는 `.agents/skills`로 향하는 심볼릭 링크다. 실제 파일은 여기 있다.
  다른 도구를 추가할 때도 같은 방식으로 링크만 건다.

## 스킬 추가 방법

`.agents/skills/<kebab-case-name>/SKILL.md` 를 만들고 frontmatter를 채운다.

```markdown
---
name: skill-name
description: 언제 이 스킬을 써야 하는지 한 줄로. 에이전트가 이 문장만 보고 판단한다.
---
```

`description`은 "무엇을 하는지"가 아니라 **"언제 트리거되는지"** 를 쓴다.
