---
name: responsive-screen
description: 화면을 Mobile / Tablet / Desktop 으로 분기하거나 Desktop 전용 UI(Multi-pane, Command Palette, 단축키)를 다룰 때 사용한다.
---

# 반응형 화면

## 원칙

플랫폼별로 화면을 따로 만들지 않는다. **하나의 feature 코드**를 폭 기준으로 분기한다.
Feature와 비즈니스 로직은 전부 공유하고, 달라지는 것은 배치뿐이다.

## 브레이크포인트

| 폭 | 모드 | 레이아웃 |
|---|---|---|
| < 600 | Mobile | Bottom Navigation (`Home · Inbox · Search · Me`), 단일 pane, push 네비게이션 |
| 600–1000 | Tablet / Compact Desktop | Navigation Rail, 2 pane |
| > 1000 | Desktop | Navigation Rail + Multi-pane, Command Palette, Split Diff |

## `Platform.isX`를 쓰지 않는다

판단 기준은 **화면 폭**이다.

```dart
// X
if (Platform.isAndroid) { ... }

// O
LayoutBuilder(
  builder: (context, constraints) => constraints.maxWidth < 600
      ? _MobileLayout()
      : _WideLayout(),
)
```

이유: 태블릿, 폴더블, 데스크톱 창 크기 변경, 분할 화면에서 모두 올바르게 동작해야 한다.
`Platform.isX`는 파일 시스템 접근이나 플랫폼 통합처럼 **실제로 OS가 다른 경우**에만 쓴다.

## 네비게이션 흐름

```
Mobile    Projects → Project → MR → Diff        (push)
Desktop   Projects │ Merge Requests │ Diff       (동시 표시)
```

Desktop에서 pane 간 선택 상태는 provider로 관리한다.
Mobile 라우팅과 Desktop pane 선택이 **같은 상태를 공유**해야 창 크기가 바뀔 때 자연스럽게 이어진다.

## Desktop 전용

폭이 넓을 때만 붙인다. Mobile 코드 경로에 넣지 않는다.

- Navigation Rail
- Multi-pane
- Keyboard Shortcuts
- Right Click Menu
- Drag & Drop
- Command Palette (`⌘K` / `Ctrl+K`)
- Multi Window
- Split Diff (`DiffViewer`의 split 모드)

Command Palette 결과는 Project / Issue / MR 을 한 목록에 섞어 보여주고,
`Search` 화면과 같은 검색 경로를 재사용한다.

## 확인

작업 후 최소한 두 폭에서 확인한다.

- 좁은 폭 (< 600) — overflow, 잘림, bottom nav 가림 여부
- 넓은 폭 (> 1000) — 텍스트가 과도하게 늘어지지 않는지 (본문 최대 폭 제한)

창 크기를 실시간으로 바꿔가며 레이아웃이 깨지거나 상태가 초기화되지 않는지 본다.

## 완료 조건

- [ ] `Platform.isX`로 레이아웃을 나누지 않았다
- [ ] Mobile / Desktop 레이아웃이 같은 Controller/Repository를 공유한다
- [ ] 좁은 폭·넓은 폭 양쪽 확인
- [ ] 창 크기 변경 시 상태가 유지된다
