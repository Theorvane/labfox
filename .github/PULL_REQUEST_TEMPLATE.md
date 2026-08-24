## Summary

<!--
What this change does and why. The diff already shows what changed — explain the reasoning.
Keep it in English. Do not paste tokens, instance hostnames, internal URLs, or confidential code.
-->

Closes #

## Validation

- [ ] `dart format .`
- [ ] `flutter analyze` reports no warnings
- [ ] `flutter test` passes
- [ ] Re-ran `dart run build_runner build --delete-conflicting-outputs` and committed the generated files (only if models changed)
- [ ] Manually validated the change in the app (describe below)

## Checklist

- [ ] This pull request targets `dev` (all contributor PRs go to `dev`; `main` only receives reviewed release PRs)
- [ ] Linked a GitHub issue above with `Closes #`
- [ ] Pull request title and commits follow [Conventional Commits](https://www.conventionalcommits.org/)
- [ ] All commits are signed off with `git commit -s` (DCO)
- [ ] Wrote the test first (TDD): a test that fails before this change and passes after, or an explanation below why none was needed
- [ ] Updated documentation where behavior changed
- [ ] Checked both Mobile (<600) and Desktop (>1000) layouts
- [ ] Checked both Light and Dark themes
- [ ] New dependencies are license-checked (MIT / BSD / Apache-2.0 / ISC / Zlib allowed — GPL / LGPL / AGPL forbidden) and `THIRD_PARTY_NOTICES.md` is updated
- [ ] No tokens, instance hostnames, credentials, or confidential data are included in the code, tests, logs, or screenshots
- [ ] Everything in this pull request is written in English

## Screenshots

<!--
For UI changes, attach both Mobile (<600) and Desktop (>1000) screenshots, in Light and Dark
themes where the change affects theming. Blur any hostname, project path, or token first.
Delete this section if it does not apply.
-->

## Notes for reviewers

<!--
Anything that helps review: trade-offs you made, areas you are unsure about, follow-up work you
deliberately left out, or GitLab API documentation the reviewer should check against.
-->
