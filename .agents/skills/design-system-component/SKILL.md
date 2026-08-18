---
name: design-system-component
description: When adding or modifying a shared widget or design token in packages/design_system. Use it when building UI that is reused across multiple features.
---

# Design System components

## Where it goes

| Location | Criteria |
|---|---|
| `packages/design_system` | UI used by two or more features, or clearly about to be |
| `features/<f>/presentation/widgets/` | UI used only by that feature |

When in doubt, keep it inside the feature and promote it once a second usage appears. Do not generalize ahead of time.

## Structure

```
packages/design_system/lib/
├── src/
│   ├── tokens/       color, spacing, radius, typography
│   ├── theme/        light / dark ThemeData
│   └── components/
└── design_system.dart
```

**Base components** — Button, Surface, Card, Divider, Avatar, Badge, Label,
State Indicator, Markdown, Code, Diff

**GitLab-specific components** — ProjectTile, IssueTile, MergeRequestTile, PipelineTile,
JobTile, GitLabAvatar, GitLabLabel, DiffViewer, CodeViewer, MarkdownViewer

## Rules

- Use **tokens only** for color, spacing, and typography. Magic values like `Color(0xFF...)` or `EdgeInsets.all(13)` are forbidden.
- Check both Light and Dark. Do not stop after looking at one.
- Components do not read Riverpod providers directly. Data comes in as parameters
  (for reuse and for previews/tests).
- Do not make network calls.
- `GitLabLabel` receives arbitrary colors (hex) served by GitLab.
  Compute foreground contrast against the background color to guarantee readability.
- Target a developer-friendly information density on par with GitHub Mobile, but
  **do not use GitHub's icons, illustrations, or brand assets.** Build a design unique to LabFox.

## Responsive

Components themselves respond to the constraints they are given (`LayoutBuilder` / parent width).
Branching the overall screen layout is the screen's responsibility, not the component's (`responsive-screen` skill).

`DiffViewer` is the exception: it supports both unified and split modes. The mode comes in as a parameter,
and the calling screen decides which one to use.

## Accessibility

- Minimum touch target of 44dp.
- Attach a semantic label to icon-only buttons.
- Do not convey state by color alone (pair pipeline passed/failed with an icon and text).

## Definition of done

- [ ] Tokens only, no magic values
- [ ] Light / Dark checked
- [ ] No provider dependency, data via parameters
- [ ] Exported from `design_system.dart`
- [ ] analyze passes
