# Release notes

The "What's New" text for each store, newest first. Written here rather than
typed into a console field, so it is reviewed and kept.

**Play caps release notes at 500 characters per language.** The App Store allows
4000, but a listing that says the same thing in both places is easier to keep
honest, so the short version is the one that matters — write it first and let
the App Store text be the same or a little longer.

Rules, the same two the listing keeps:

- Say what changed for the **user**, not what changed in the repository. Nobody
  reading a store update cares which provider was refactored.
- Do not name what is not shipped. If a feature is behind a subscription that is
  not live yet, or on the roadmap, it does not appear here.

Translations live beside this file as `release-notes.<locale>.md`. English is
the source: change this first, then carry it across.

---

## 0.1.3

**Play** (500 characters max):

```
What's new:

• Background to-do checks. LabFox looks at your to-do list while it is closed
  and tells you when something new needs you — a review, a failed pipeline, an
  assignment. Part of the subscription; turn it on in Settings.
• The subscription is easier to find, and shows its state on your profile.

Android checks about every fifteen minutes; iOS decides when, so this is a
background check rather than an instant push.
```

**App Store**:

```
What's new:

• Background to-do checks. LabFox looks at your to-do list while it is closed
  and tells you when something new needs you — a review requested, a pipeline
  that failed, an issue assigned to you. Part of the subscription, and off
  until you turn it on in Settings.
• The subscription is easier to find, and your profile shows whether it is
  active.

This is a background check, not a push. There is no LabFox server that could
send you one: your device asks your own GitLab on a schedule the operating
system decides. Android checks about every fifteen minutes; iOS picks its own
moments.
```

---

## 1.0.0 — first release

**Play** (500 characters max):

```
LabFox brings GitLab to your phone.

• Read merge requests in full, with approvals and discussion
• Go through the diff file by file, with real line numbers
• Approve, merge, or comment
• Watch pipelines, open job logs with colour intact, retry or cancel
• Issues, to-do inbox, search, and repository browsing

Works with gitlab.com or your own self-hosted instance. Tokens stay in the
device keychain — no LabFox account, no LabFox server.

Open source, Apache-2.0.
```

**App Store**:

```
The first release of LabFox.

Review a merge request on the train. Check why the pipeline went red before you
get to your desk.

• Merge requests in full — description, labels, approvals, discussion
• Diffs file by file, with real line numbers and changed lines highlighted
• Approve, merge, or leave a comment
• Pipelines at a glance, and job logs with the runner's colour output intact
• Retry a failed job, cancel one, or start a manual job
• Issues, to-do inbox, search, repository, branches, commits

The layout follows the screen, not the device: a focused single pane on a
phone, a navigation rail and room for twenty merge requests on a tablet.

gitlab.com and self-hosted instances work the same way. Tokens are held in the
device keychain — there is no LabFox account and no LabFox server between you
and your GitLab.

Open source under Apache-2.0: github.com/theorvane/labfox
```

---

## Template for later releases

Keep the shape. Lead with the thing most people will notice, and skip anything
they would not.

```
What's new:

• <the change someone would notice, in their words>
• <the next one>

Fixes:

• <what was broken, described by the symptom rather than the cause>
```
