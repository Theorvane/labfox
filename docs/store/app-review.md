# App Review

What to paste into App Store Connect, and the answers to the rejections this
app has actually received. Written here rather than retyped each submission,
because every one of them so far was a question about what LabFox *is* rather
than a defect in what it does.

Korean translation: none. This file is read by whoever fills in the console,
and the text in it is submitted to Apple in English.

---

## Review Notes

Paste this into **App Store Connect → the version → Review Notes**. It answers,
before it is asked, everything review has stopped on so far.

```
LabFox is an unofficial client for GitLab. It is not affiliated with or
endorsed by GitLab Inc.

SIGNING IN (guideline 4.8)
LabFox has no account of its own and no server. The user signs in directly to
their own GitLab account — gitlab.com or a self-hosted GitLab instance — with
GitLab OAuth or a GitLab personal access token, and the credential is held in
the device keychain. Nothing is sent to us; there is no LabFox identity for
Sign in with Apple to establish. This is the exemption in 4.8 for an app that
is "a client for a specific third-party service" whose users "sign in to their
mail, social media, or other third-party account directly to access their
content".

TRACKING (guideline 5.1.2)
The App Tracking Transparency prompt appears on first launch, immediately
after the first screen is drawn, for users on the free tier. It is requested
before the ad SDK is initialised. Subscribers see no ads, are not tracked, and
are never shown the prompt — to see it, review the app without subscribing.

DEMO ACCOUNT
The demo account fields hold a GitLab.com account and a personal access token.
Paste the token into the sign-in screen's token field with the instance left
at gitlab.com. The account has projects, issues, merge requests and pipelines
to look at.

SUBSCRIPTION
One auto-renewable subscription, "labfox_subscription". The app is fully
usable without it: reading every project, issue, merge request, diff, pipeline
and job log is free. The subscription adds the actions — approve, merge,
retry, cancel, run manual jobs — plus multiple accounts, unlimited favourites,
and background to-do checks.
```

---

## If review raises guideline 4.8 (Login Services)

They have raised it once, on the 1.0 (8) submission. **Do not add Sign in with
Apple.** It would authenticate the user to nothing: there is no LabFox account
for it to establish, and the app would still have to ask for GitLab
credentials immediately afterwards.

The guideline lists the exemption plainly. Reply in App Store Connect with:

```
LabFox does not use a third-party or social login service to set up or
authenticate a primary account with the app, because the app has no account of
its own. There is no LabFox account, no LabFox server, and no user record
anywhere in our infrastructure.

LabFox is a client for GitLab. To see anything at all, the user signs in
directly to their own GitLab account — either gitlab.com or a GitLab instance
they host themselves — using GitLab OAuth or a GitLab personal access token
that they issue. The credential is stored in the device keychain and is sent
only to the GitLab instance the user named.

This is the fifth exemption listed under 4.8: "Your app is a client for a
specific third-party service and users are required to sign in to their mail,
social media, or other third-party account directly to access their content."

Sign in with Apple cannot serve as an equivalent option here. It would
identify the user to us, which we neither want nor have anywhere to record,
and it would not give them access to their GitLab content — the app would
still have to ask for a GitLab credential immediately afterwards.
```

---

## If review says the subscription is unavailable to purchase (2.1(b))

Raised on the 1.0 (8) submission. The app queries exactly one product id,
`labfox_subscription`, and shows "The store is not available right now" for
every reason a store can fail to offer it. From inside the app these are
indistinguishable, so the cause is always found in the console, not the code:

1. **Paid Apps Agreement.** Business → Agreements. Without it in effect, no
   in-app purchase is offered to anyone, review included. This is the most
   common cause and the easiest to miss, because nothing in the app says so.
2. **The subscription must be submitted with the version.** A subscription
   that has never been reviewed is not offered to a reviewer just because it
   exists. On the version page, under In-App Purchases, add
   `labfox_subscription` to the submission.
3. **The product must be complete.** A subscription in "Missing Metadata"
   never becomes available. It needs a localized display name and description,
   a price for every territory, and a review screenshot.
4. **The product id must match exactly** — `labfox_subscription`, with the
   underscore. It is permanent in both stores and cannot be renamed later; a
   test in the app holds the code and the documentation to the same string.
5. **Banking and tax.** Agreements, Tax, and Banking must be complete for the
   territory being reviewed.

Check them in that order and reply saying which one it was, so the next
submission does not repeat it.
