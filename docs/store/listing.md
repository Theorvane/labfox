# Store listing copy

The text for the App Store and Play Console listings, kept here so it is
reviewed like anything else and does not live only in a console field.

**English is the source.** Translations live beside it as
`listing.<locale>.md` — currently [`listing.ko.md`](listing.ko.md). Change this
file first, then carry the change across.

Two rules it has to keep, both from `AGENTS.md`:

- **Never imply endorsement.** LabFox is an unofficial client. GitLab is a
  trademark of GitLab Inc. Every listing carries the disclaimer at the bottom.
- **Do not promise what is not built.** Push notifications and offline reading
  are on the roadmap, not in the app. They are named as *coming*, or not at all.

---

## App name

```
LabFox
```

**Subtitle** (App Store, 30 characters):

```
GitLab merge requests & CI
```

**Short description** (Play, 80 characters):

```
Review merge requests, watch pipelines and read job logs on your GitLab.
```

---

## Full description

Used for both stores. Play renders limited HTML; the App Store is plain text,
so this is written to read correctly with no markup at all.

```
Review a merge request on the train. Check why the pipeline went red before you
get to your desk. LabFox brings the parts of GitLab you touch every day onto
your phone, without asking you to pinch and scroll through the web UI.

WHAT YOU CAN DO

• Read merge requests in full, with the description, labels, approvals and
  discussion where you can actually read them
• Go through the diff with real line numbers and changed lines highlighted,
  file by file
• Approve, merge, or leave a comment
• Watch pipelines run, and see at a glance what passed, failed or is still going
• Open a job log in full, with the runner's colour output intact
• Retry a failed job, cancel one, or start a manual job
• Work through issues, your to-do inbox, and search across projects
• Browse the repository, branches, commits, and files

BUILT FOR HOW YOU ACTUALLY WORK

The layout follows the screen, not the device. On a phone you get a focused
single pane; on a tablet, a navigation rail and enough room to see twenty merge
requests at once. Same app, same features.

SELF-HOSTED IS A FIRST-CLASS CITIZEN

Point LabFox at gitlab.com or at your company's own instance. Both work the
same way. Sign in with a personal access token or through OAuth.

YOUR CREDENTIALS STAY YOURS

Tokens are held in the device keychain, never in plain text and never in a log.
There is no LabFox account and no LabFox server standing between you and your
GitLab — the app talks to your instance directly.

OPEN SOURCE

LabFox is Apache-2.0 licensed. Read the code, file an issue, or send a patch:
github.com/theorvane/labfox

—

LabFox is an unofficial, third-party client. It is not affiliated with,
endorsed by, or certified by GitLab Inc. "GitLab" is a trademark of GitLab Inc.
```

---

## Subscription copy

Shown where the store asks what the subscription unlocks. Keep it aligned with
`.agents/docs/monetization.md` §2 — if the boundary moves, this moves with it.

```
LabFox is free to download and free to use for reading: every project, issue,
merge request, diff, pipeline and job log, on one account.

A subscription unlocks the actions that finish the job:

• Approve and merge
• Retry, cancel, and run manual jobs
• More than one account, including several self-hosted instances
• Unlimited favourites and saved searches

The subscription renews automatically until cancelled, and is managed in your
store account. Desktop builds are free with every feature.
```

---

## Keywords

**App Store** (100 characters, comma-separated, no spaces):

```
gitlab,merge request,code review,ci,cd,pipeline,devops,git,repository,self-hosted,issues,diff
```

Do not put "LabFox" in the keyword field — the name is already indexed, and the
space is better spent on words nobody searching would guess.

---

## Notes for whoever fills in the console

- **Category**: Developer Tools (App Store), Tools (Play).
- **Content rating**: no objectionable content; the app shows whatever the
  user's own GitLab contains.
- **Privacy policy URL** is mandatory on both stores. `PRIVACY.md` is the text;
  it needs a public URL before submission.
- **Data safety (Play)** and **App Privacy (App Store)** must match `PRIVACY.md`:
  anonymous usage analytics, no advertising identifier, no data sold, and
  credentials stored only on the device.
