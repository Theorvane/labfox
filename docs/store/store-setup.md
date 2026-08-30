# Store setup

What has to be done **in the consoles** before a build the pipeline uploads can
actually be reviewed, sold, or subscribed to.

`RELEASING.md` covers the pipeline and its credentials. This file covers the
part no workflow can do: the app records, the declarations, and the subscription
product. Most of it is one-time; the parts that repeat are marked
**[per release]**.

> The pipeline uploads. It never submits for review and never promotes a track —
> that stays a human decision (`RELEASING.md`).

---

## Identifiers the app hardcodes

The consoles must match these exactly. They are compiled into the binary, so a
mismatch is not a setting to fix later — it is a release.

| What | Value | Where it comes from |
|---|---|---|
| Android package | `com.sloki9637.labfox` | `apps/labfox/android/app/build.gradle.kts` |
| Apple bundle id | `com.sloki9637.labfox` | `apps/labfox/ios/Runner.xcodeproj` |
| Subscription product id | `labfox_subscription` | [`store_entitlement_source.dart`](../../apps/labfox/lib/core/entitlement/store_entitlement_source.dart) |
| Privacy policy URL | `https://www.sloki9637.com/privacy` | `PRIVACY.md` |
| Terms URL | `https://www.sloki9637.com/terms` | Settings → Terms of service |

**Both stores use the same subscription product id.** The app queries one id and
accepts a purchase only when `productID` matches it, so a product named anything
else is invisible to the app: the subscription screen shows no price and no
purchase can complete.

The id is overridable at build time
(`--dart-define=LABFOX_SUBSCRIPTION_ID=...`), but **the release workflow builds
without it**. Production is always `labfox_subscription`. Renaming the product
means changing the default in code and shipping a release, not editing a console
field.

Apple's bundle id is shared by the iOS and macOS targets on purpose — that is
what Universal Purchase requires, so one Apple subscription covers iPhone, iPad,
and Mac (`.agents/docs/monetization.md` §3).

---

## Google Play Console

### 1. App record

Create the app with package name `com.sloki9637.labfox`. The package cannot be
changed afterwards, and it is what the pipeline's service account uploads to.

Under **Setup → API access**, create the service account and grant it release
permissions; its JSON is the `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret
(`RELEASING.md`).

### 2. Store listing

Copy comes from [`listing.md`](listing.md) — English is the source, Korean is
[`listing.ko.md`](listing.ko.md). Do not write listing text directly into the
console; change the file, then carry it across.

| Asset | Source |
|---|---|
| App icon (512×512) | `brand/generated/icon-512.png` |
| Feature graphic (1024×500) | derive from `brand/labfox-icon.png` |
| Screenshots | captured from a signed-in build |

Everything under `brand/generated/` is produced by
`python3 scripts/generate-icons.py`. Do not hand-edit it.

> The launcher icon inside the app is a different thing, and Play checks it:
> a build without an adaptive icon is rejected. That one is fixed in the
> repository, not the console.

### 3. App content declarations

This section is where uploads get rejected, so treat it as part of the release,
not paperwork.

| Declaration | Answer | Why |
|---|---|---|
| Privacy policy | `https://www.sloki9637.com/privacy` | Required; the same policy ships in-app under Settings |
| Ads | **Contains ads** | The free mobile tier shows LevelPlay ads |
| **Advertising ID** | **Yes — used for advertising or marketing** | The bundle declares `com.google.android.gms.permission.AD_ID` |
| Data safety | See below | Must match `PRIVACY.md` |
| Target audience | Adults; not designed for children | Developer tool |
| Government / financial / health | No | — |

**Data safety**, matching what the app actually does:

- **Collected: device or other IDs** — the advertising identifier, by the
  LevelPlay SDK, for advertising. Not linked to a user identity by LabFox.
- **Collected: app activity (app interactions)** — anonymous product analytics
  (screen views with numeric ids stripped, a handful of action events).
- **Not collected**: names, email addresses, GitLab credentials, repository
  content. Tokens live only in OS secure storage and are sent only to the user's
  own GitLab instance.
- Data is **not sold** and **not shared** with third parties beyond the ad SDK's
  own processing under Unity's privacy policy.

### 4. Subscription product

Field-level values, including the base plan, are in
[`.agents/docs/billing.md`](../../.agents/docs/billing.md).

**Monetize → Products → Subscriptions → Create subscription.**

| Field | Value |
|---|---|
| Product ID | `labfox_subscription` — must match exactly, and cannot be changed later |
| Name / description | From the *Subscription copy* section of [`listing.md`](listing.md) |
| Base plan | Auto-renewing, monthly; set the price, then **activate it** |

A subscription with no active base plan returns no product to the app, which
looks identical to a wrong id: an empty subscription screen.

Play will not let a subscription be created for an app that has never had a
build uploaded — that is why the first upload is manual (`RELEASING.md`).

### 5. Testing purchases

- **Setup → License testing**: add the tester accounts. They are billed nothing
  and can subscribe repeatedly.
- Install from the **internal testing** track with a tester account. Sideloaded
  builds cannot complete a purchase: Play Billing checks that the install came
  from Play.

### 6. Per release

**[per release]** The pipeline uploads the bundle to the **internal** track.
Then, by hand:

1. Confirm the new version code appears on the internal track.
2. Promote to the review track (closed/open/production) when it should ship.
3. Submit for review.

Promoting is deliberate: an upload is reversible, a production release is not.

---

## App Store Connect

### 1. Paid Apps agreement

**Business → Agreements**: sign the Paid Applications agreement and complete the
bank and tax details. Until it is active, in-app purchases cannot be created or
purchased — including in sandbox.

### 2. App record

Create the app with bundle id `com.sloki9637.labfox`.

**Enable Universal Purchase before adding the macOS platform.** It cannot be
turned on afterwards, and without it the Mac app is a separate purchase — which
would break the "one Apple subscription covers iPhone, iPad, and Mac" rule the
monetization design depends on.

### 3. Subscription product

Field-level values are in
[`.agents/docs/billing.md`](../../.agents/docs/billing.md).

**Monetization → Subscriptions**: create a subscription group (one group, so
future tiers can upgrade and downgrade within it), then an auto-renewable
subscription in it:

| Field | Value |
|---|---|
| Product ID | `labfox_subscription` — the same id as Play |
| Reference name | LabFox subscription |
| Duration / price | Monthly, matching the Play base plan |
| Localizations | Display name and description from [`listing.md`](listing.md) |
| Review screenshot | The in-app subscription screen (Settings → LabFox subscription) |

A subscription is reviewed **with the app version that first offers it**. It
stays "Waiting for Review" until that build is submitted.

### 4. App Privacy

Answer to match `PRIVACY.md` and the Play data-safety answers:

- **Identifiers → Device ID**: collected, for *Third-Party Advertising*, **not**
  linked to identity, **not** used for tracking beyond the ad SDK's own use.
- **Usage Data → Product Interaction**: collected for *Analytics*, not linked to
  identity.
- Nothing else. No contact info, no user content, no search history.

The app already ships `NSUserTrackingUsageDescription` and the ironSource
`SKAdNetworkIdentifier`, so the ATT prompt and attribution work without further
console setup.

### 5. Review notes — the part reviewers get stuck on

LabFox is a client for someone else's server. A reviewer with no GitLab account
sees a sign-in screen and nothing else, and the app gets rejected as incomplete.

In **App Review Information**, supply:

- A GitLab.com account and a **Personal Access Token** with `api` and
  `read_user`, in the demo-account fields.
- A note that the token is pasted into the sign-in screen, that LabFox is an
  **unofficial** GitLab client not affiliated with GitLab Inc., and that the
  account has projects, issues, merge requests, and pipelines to look at.

### 6. Per release

**[per release]** The pipeline uploads the build to App Store Connect and
**submits nothing**. Choose the build, complete "What's New" from
[`release-notes.md`](release-notes.md), and submit.

---

## Failures we have actually hit

| Symptom | Cause | Fix |
|---|---|---|
| Play upload fails: *"includes the com.google.android.gms.permission.AD_ID permission but your declaration … says your app doesn't use advertising ID"* | Ads shipped before the console declaration was updated | Set **App content → Advertising ID → Yes**, then re-run the failed release job |
| Play rejects the build over the app icon | No adaptive icon in the bundle | Fixed in the repository (`mipmap-anydpi-v26`); re-cut a release |
| Subscription screen shows no price | Product id mismatch, or a base plan that was created but never activated | The product must be `labfox_subscription` **and** active |
| Purchase cannot complete on a test device | Sideloaded build, or the account is not a license tester | Install from the internal track with a tester account |

---

## Cross-references

- [`RELEASING.md`](../../RELEASING.md) — the pipeline, its secrets, and what is
  still manual
- [`.agents/docs/monetization.md`](../../.agents/docs/monetization.md) — what the
  subscription unlocks and why entitlement is designed this way
- [`listing.md`](listing.md) — the listing and subscription copy
- [`PRIVACY.md`](../../PRIVACY.md) — the source of truth for both privacy forms
