#!/usr/bin/env bash
# Sync LabFox issue labels. Idempotent: creates or updates.
set -euo pipefail
R="${LABELS_REPO:-theorvane/labfox}"
failed=0

# --force makes create act as upsert. Without an explicit failure branch a
# transient API error would be swallowed and the sync would report success.
add() {
  if gh label create "$1" --repo "$R" --color "$2" --description "$3" --force >/dev/null 2>&1; then
    echo "  ok   $1"
  else
    echo "  FAIL $1" >&2
    failed=$((failed + 1))
  fi
}

trap 'if [ "$failed" -gt 0 ]; then echo "$failed label(s) failed to sync" >&2; exit 1; fi' EXIT

# type
add "feat"                 "0E8A16" "New feature"
add "fix"                  "D73A4A" "Bug fix"
add "docs"                 "0075CA" "Documentation only"
add "refactor"             "5319E7" "Code change that neither fixes a bug nor adds a feature"
add "test"                 "BFD4F2" "Tests only"
add "chore"                "FEF2C0" "Tooling, build, or maintenance"
# area
add "area:api"             "1D76DB" "packages/gitlab_api — GitLab REST/GraphQL client"
add "area:ui"              "1D76DB" "Screens and feature UI"
add "area:design-system"   "1D76DB" "packages/design_system"
add "area:ci"              "1D76DB" "CI, build, release automation"
add "area:docs"            "1D76DB" "AGENTS.md, .agents/, README and friends"
add "area:mobile"          "1D76DB" "Android / iOS specific"
add "area:desktop"         "1D76DB" "Windows / macOS specific"
add "area:security"        "B60205" "Tokens, auth, secure storage, TLS"
# milestone
for m in M0 M1 M2 M3 M4; do add "$m" "C5DEF5" "Milestone $m"; done
# platform
add "platform:android"     "C2E0C6" "Reproduces on Android"
add "platform:ios"         "C2E0C6" "Reproduces on iOS"
add "platform:windows"     "C2E0C6" "Reproduces on Windows"
add "platform:macos"       "C2E0C6" "Reproduces on macOS"
# priority
add "priority:critical"    "B60205" "Drop everything"
add "priority:high"        "D93F0B" "Next up"
add "priority:medium"      "FBCA04" "Normal"
add "priority:low"         "0E8A16" "Nice to have"
# size
add "size:XS"              "EEEEEE" "Trivial"
add "size:S"               "EEEEEE" "Small"
add "size:M"               "EEEEEE" "Medium"
add "size:L"               "EEEEEE" "Large"
add "size:XL"              "EEEEEE" "Consider splitting"
# status
add "status:needs-triage"  "E4E669" "Not yet assessed"
add "status:in-progress"   "E4E669" "Being worked on"
add "status:blocked"       "E4E669" "Waiting on something else"
# special
add "self-hosted"          "5319E7" "Only reproduces against a self-managed GitLab instance"
add "good first issue"     "7057FF" "Good for newcomers"
add "help wanted"          "008672" "Maintainer would like help here"
add "question"             "D876E3" "Needs more information"
add "duplicate"            "CFD3D7" "Already reported"
add "invalid"              "CFD3D7" "Not actionable"
add "bug"                  "D73A4A" "Something is broken"

echo "Label sync complete."
