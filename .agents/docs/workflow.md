# Workflow — Issue → Branch → PR

## Hosting

origin is **GitHub**.

```
https://github.com/theorvane/labfox.git
```

| | |
|---|---|
| CLI | **`gh`** |
| Proposing changes | **Pull Request (PR)** |
| Templates | **`.github/`** |

> ⚠️ **Don't confuse the two.** LabFox is a *GitLab client* but is *developed on GitHub*.
> - What the code deals with → GitLab (Merge Request, `iid`, `/api/v4`)
> - Development workflow → GitHub (Pull Request, `gh`)
>
> App domain terminology stays **Merge Request**. Only the development process uses PR.

`origin` (GitHub) is the only remote. The project previously lived on a personal self-hosted
GitLab instance; that remote is gone.

This is a public repository, so **never put the old instance address in docs, issues, or commit
messages.**

---

## Branch model

```
feature branch ──PR──> dev ──release PR──> main
```

| Branch | Role |
|---|---|
| `dev` | Default branch. Integration target. **Every contributor PR goes here.** |
| `main` | Releases only. Updated through a separate reviewed `dev` → `main` release PR. |

Rules:

- Branch from `dev`, open the PR into `dev`.
- Never commit directly to `dev` or `main`.
- Never open a PR against `main`. Promoting `dev` to `main` is a maintainer decision and gets its
  own reviewed release PR.
- Rebase or merge `dev` into your branch to resolve conflicts. Do not rewrite published history.

### Branch protection

Ruleset definitions live in `.github/rulesets/` and are **active** on `dev` and `main`. They block
direct pushes, force pushes, and branch deletion, and every merge requires:

- **CI green** — the required status checks pass.
- **One approval** from someone other than the author. GitHub does not let you approve your own
  pull request, so the author cannot self-merge.
- **All review conversations resolved.** An unresolved thread keeps the pull request `BLOCKED`,
  regardless of approval or CI. This is `required_review_thread_resolution`.

The definitions under `.github/rulesets/` are the source of truth; edit them and re-apply with
`gh api` rather than changing the rules in the web UI. See `.github/rulesets/README.md`.

### Who resolves review threads

**The reviewer resolves their own threads, not the author.** A thread is a question or a request;
it is done when the person who raised it is satisfied, not when the author decides it is. The
author replies, pushes a fix, or discusses — then the reviewer resolves and the merge unblocks.

This matters because the author has the mechanical ability to resolve any thread. Doing so on your
own pull request turns the resolution gate into a rubber stamp. Leave the reviewer's threads for
the reviewer.

An author may resolve a thread only when the reviewer explicitly says so, or for a thread the
author opened themselves (a note to reviewers, say).

---

## Overall Flow

```
Create Issue
   ↓
Create branch (branched from dev)
   ↓
Commit (with Signed-off-by)
   ↓
Quality gate (format / analyze / test)
   ↓
Push
   ↓
Create PR (Closes #N)
   ↓
CI passes + Review
   ↓
Merge  ← done by a maintainer
```

Never commit or push directly to `dev` or `main`.

---

## 1. Issue

Create the Issue before starting work.

```
gh issue create --title "Implement MR Diff Viewer" --body "..." --label feat
gh issue list
gh issue view 12
```

### Rules

- The title says **what it does** in one line. Standalone titles like "fix", "improve", "refactor" are forbidden.
- Split work so that **one Issue = one PR**.
  Don't use milestone-sized Issues like "Implement M2 Collaboration" as units of work.
- If it falls outside the 1.0 scope (`AGENTS.md` §9), get confirmation before creating the Issue.
- Templates: `.github/ISSUE_TEMPLATE/` (`task`, `bug`)

### Labels

Labels are defined in `.github/labels.sh` and synced with:

```bash
bash .github/labels.sh
```

The script is idempotent — it creates missing labels and updates existing ones.
Edit the script rather than the GitHub UI, so the taxonomy stays reviewable.

### Automation

| Trigger | What happens | Where |
|---|---|---|
| Pull request opened / updated | `area:*` labels from changed paths | `.github/workflows/triage.yml` + `.github/labeler.yml` |
| Pull request opened / retitled | type label (`feat`, `fix`, …) from the Conventional Commit title | `.github/workflows/triage.yml` |
| Pull request opened | author set as assignee | `.github/workflows/triage.yml` |
| Pull request opened | reviewers requested | `.github/CODEOWNERS` |
| Issue opened / reopened | `status:needs-triage` added, maintainer assigned | `.github/workflows/triage.yml` |

Notes:

- Type labels come from the **title**, not the changed files — the kind of change is not a
  function of which paths were touched. A title that is not a Conventional Commit gets no type
  label and does not fail the run.
- All pull request steps live in one job in `.github/workflows/triage.yml`, running in order:
  area labels, then the type label, then assignment. They were once two workflows that raced —
  applied labels in an undefined order and could remove each other's — so they were merged.
- The workflow uses `pull_request_target` so labels also apply to pull requests from forks.
  It never checks out or executes contributor code, which is what makes that safe.
- Assignment is best effort. Outside contributors cannot be assignees until they are
  collaborators, so the step logs and continues instead of failing.
- `CODEOWNERS` requests review but does not require it — `require_code_owner_review` is `false`
  in the rulesets.

Structured prefixes so filters stay useful as the tracker grows.

| Prefix | Labels |
|---|---|
| type | `feat` `fix` `docs` `refactor` `test` `chore` |
| area | `area:api` `area:ui` `area:design-system` `area:ci` `area:docs` `area:mobile` `area:desktop` `area:security` |
| milestone | `M0` `M1` `M2` `M3` `M4` |
| platform | `platform:android` `platform:ios` `platform:windows` `platform:macos` |
| priority | `priority:critical` `priority:high` `priority:medium` `priority:low` |
| size | `size:XS` `size:S` `size:M` `size:L` `size:XL` |
| status | `status:needs-triage` `status:in-progress` `status:blocked` |
| special | `self-hosted` `good first issue` `help wanted` `question` `duplicate` `invalid` |

`self-hosted` marks problems that only reproduce against a self-managed GitLab instance.
Those are hard for maintainers to reproduce, so they need extra detail from the reporter.

---

## 2. Branch

```
<type>/<issue-number>-<slug>
```

```
feat/12-mr-diff-viewer
fix/28-self-hosted-cert-error
docs/31-api-reference
chore/35-upgrade-flutter
```

- type: `feat` · `fix` · `docs` · `refactor` · `test` · `chore`
- The number is the GitHub Issue number.
- The slug is lowercase + hyphens. Keep it short.

```
git switch dev && git pull
git switch -c feat/12-mr-diff-viewer
```

**Always branch from the latest `dev`.** Don't stack on top of another working branch.
If a dependency is unavoidable, state the prerequisite PR in the PR description.

---

## 3. Commit

[Conventional Commits](https://www.conventionalcommits.org/) format. The scope is a package or feature name.

```
feat(merge_requests): add unified diff viewer
fix(gitlab_api): handle keyset pagination in project list
refactor(design_system): extract spacing tokens
docs(agents): add PR workflow
chore(deps): bump dio to 5.5.0
```

**Include a DCO sign-off on every commit.**

```
git commit -s -m "fix(gitlab_api): handle keyset pagination"
```

### Rules

- One commit = one logical change. Don't mix in unrelated changes.
- **Put generated files (`*.g.dart`, `*.freezed.dart`) in the same commit as the source change.**
  Committing them separately breaks the build at some point in history.
- Write **why** in the body. The diff already says what changed.
- Don't leave commits like `WIP`, `fix typo`, or `asdf`. Clean them up before pushing.
- Never put tokens, passwords, or internal URLs in commit messages.

---

## 4. Quality Gate

Must pass before pushing.

```
dart run build_runner build --delete-conflicting-outputs   # when models change
dart format .
flutter analyze
flutter test
```

- Don't open a PR with `analyze` warnings left in.
- If it fails, **report that it failed.** Don't move on as if it passed.

---

## 5. Pull Request

```
git push -u origin feat/12-mr-diff-viewer
gh pr create --fill --base dev
```

Start as a Draft:

```
gh pr create --draft --fill --base dev
gh pr ready 42
```

Listing / checking:

```
gh pr list
gh pr view 42
gh pr checks
gh run list
```

### Rules

- Put **`Closes #12`** in the description to link the Issue. It closes automatically on merge.
- Template: actually verify and check off the `.github/PULL_REQUEST_TEMPLATE.md` checklist.
- The title uses the same format as the commit title: `feat(merge_requests): add unified diff viewer`
- **CI must pass before merging.**
- Attach screenshots for UI changes. Both mobile and desktop.
- All review threads must be resolved before merging (by the reviewer — see "Who resolves review threads"). The ruleset enforces this.

### PR Size

Keep it reviewable. Past 1000 lines, first consider whether it can be split.
Growth caused by generated code (`*.g.dart`) is an exception — say so in the PR description.

---

## 6. Permission Boundaries

What agents may do without confirmation:

- Create, view, and comment on Issues
- Create branches, commit, push
- Create (including Draft), view, and comment on PRs
- Check CI status

**What they do not do:**

- ❌ Push directly to `dev` or `main`
- ❌ Open a PR against `main` (release promotion is a maintainer decision)
- ❌ Force push (both `--force` and `--force-with-lease`)
- ❌ **Merge PRs** — a maintainer does that
- ❌ Delete Issues / PRs / branches
- ❌ Create release tags
- ❌ Change repository settings · toggle repository visibility

When asked, do these too. But since they're hard to undo, confirm the target first, then proceed.

---

## 7. Parallel Work / Subagents

When working on several Issues at once, keep the branches separate and use git worktrees where possible.
Don't switch back and forth between branches in the same working tree.

Work well suited to subagents:

| Task | Why |
|---|---|
| Researching reference repositories (OctoLab, LabCoat, etc.) | Read-only and high volume. Only the conclusion is needed |
| Checking GitLab API docs | Several endpoints can be checked in parallel |
| Implementing independent feature slices | Different features don't conflict |
| PR review / code inspection | An independent perspective is useful |
| Broad code exploration | Saves context |

Caveats:

- **Subagents follow `AGENTS.md` too.** When delegating, spell out the relevant rules (license, id/iid, scope) in the prompt.
- Don't run tasks that modify the same file in parallel. Isolate them with worktrees or do them sequentially.
- Don't hand a subagent work that requires merge or push permissions.
- Don't trust subagent results at face value. Verify API paths and licenses yourself.
