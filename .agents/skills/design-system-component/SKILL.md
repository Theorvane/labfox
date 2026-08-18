---
name: design-system-component
description: packages/design_system 에 공용 위젯이나 디자인 토큰을 추가/수정할 때. 여러 feature에서 재사용되는 UI를 만들 경우 사용한다.
---

# Design System 컴포넌트

## 어디에 둘 것인가

| 위치 | 기준 |
|---|---|
| `packages/design_system` | 2개 이상 feature에서 쓰이거나, 쓰일 것이 분명한 UI |
| `features/<f>/presentation/widgets/` | 해당 feature에서만 쓰는 UI |

애매하면 feature 안에 두고, 두 번째 사용처가 생길 때 승격한다. 미리 일반화하지 않는다.

## 구성

```
packages/design_system/lib/
├── src/
│   ├── tokens/       color, spacing, radius, typography
│   ├── theme/        light / dark ThemeData
│   └── components/
└── design_system.dart
```

**기본 컴포넌트** — Button, Surface, Card, Divider, Avatar, Badge, Label,
State Indicator, Markdown, Code, Diff

**GitLab 전용 컴포넌트** — ProjectTile, IssueTile, MergeRequestTile, PipelineTile,
JobTile, GitLabAvatar, GitLabLabel, DiffViewer, CodeViewer, MarkdownViewer

## 규칙

- 색·간격·타이포는 **토큰만** 쓴다. `Color(0xFF...)`, `EdgeInsets.all(13)` 같은 매직값 금지.
- Light / Dark 양쪽에서 확인한다. 한쪽만 보고 끝내지 않는다.
- 컴포넌트는 Riverpod provider를 직접 읽지 않는다. 데이터는 파라미터로 받는다
  (재사용성과 프리뷰/테스트를 위해).
- 네트워크 호출을 하지 않는다.
- `GitLabLabel`은 GitLab이 내려주는 임의 색상(hex)을 받는다.
  배경색에 따라 전경색 대비를 계산해 가독성을 보장한다.
- 밀도는 GitHub Mobile 수준의 개발자 친화적 정보 밀도를 목표로 하되,
  **GitHub의 아이콘·일러스트·브랜드 에셋은 사용하지 않는다.** LabFox 고유 디자인으로 만든다.

## 반응형

컴포넌트 자체는 주어진 제약(`LayoutBuilder` / 부모 폭)에 반응한다.
화면 전체 레이아웃 분기는 컴포넌트가 아니라 화면의 책임이다 (`responsive-screen` 스킬).

`DiffViewer`는 예외로 unified / split 두 모드를 지원한다. 모드는 파라미터로 받고,
어느 모드를 쓸지는 호출하는 화면이 결정한다.

## 접근성

- 터치 타겟 최소 44dp.
- 아이콘 전용 버튼에 semantic label을 붙인다.
- 상태를 색으로만 표현하지 않는다 (pipeline passed/failed 에 아이콘·텍스트 병행).

## 완료 조건

- [ ] 토큰만 사용, 매직값 없음
- [ ] Light / Dark 확인
- [ ] provider 의존 없음, 데이터는 파라미터
- [ ] `design_system.dart`에서 export
- [ ] analyze 통과
