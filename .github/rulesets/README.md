# Branch rulesets

Declarative copies of the GitHub branch rulesets for this repository, kept in version control so
the protection rules are reviewable and reproducible instead of living only in the web UI.

## Status

**Not applied yet.** GitHub rejects ruleset creation on a private repository on the free plan:

```
Upgrade to GitHub Pro or make this repository public to enable this feature.
```

`labfox-app/labfox` is currently private. Apply these the moment the repository goes public
(or the organization moves to a paid plan).

## Applying

```bash
gh api -X POST repos/labfox-app/labfox/rulesets --input .github/rulesets/dev.json
gh api -X POST repos/labfox-app/labfox/rulesets --input .github/rulesets/main-release.json
```

Verify:

```bash
gh api repos/labfox-app/labfox/rulesets --jq '.[] | "\(.name) \(.enforcement)"'
```

Updating an existing ruleset instead of creating a duplicate:

```bash
gh api -X PUT repos/labfox-app/labfox/rulesets/<id> --input .github/rulesets/dev.json
```

## What they enforce

| | `dev` | `main-release` |
|---|---|---|
| Branch deletion | blocked | blocked |
| Force push | blocked | blocked |
| Direct push | blocked — pull request required | blocked — pull request required |
| Merge method | squash only | merge commit only |
| Review threads | must be resolved | must be resolved |
| Required checks | `Language policy (English only)`, `Detect Flutter project` | same |

`dev` squashes so feature branches land as one commit. `main` uses a merge commit so release
promotion preserves the `dev` history rather than flattening it again.

## Two settings to revisit

**`required_approving_review_count` is `1`.** Every pull request needs one approval from an
account other than its author before it can merge — GitHub does not let you approve your own. With
two accounts on the repository (`sjungwon03` and `sjungwon03-ai`), this is enforceable. It was `0`
during the initial bootstrap, when a single account meant requiring an approval would have made
every pull request unmergeable; that no longer applies.

`dismiss_stale_reviews_on_push` and `require_last_push_approval` are both on, so an approval does
not carry over to commits pushed after it — the state that was approved is the state that merges.

**`Flutter quality gate` is not a required check.** The repository is documentation-only until
milestone M0, so that job is skipped and cannot be required yet. Add it to
`required_status_checks` in both files once M0 lands `pubspec.yaml`:

```json
{ "context": "Flutter quality gate" }
```
