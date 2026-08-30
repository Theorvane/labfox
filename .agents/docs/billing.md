# Billing

What LabFox sells, how a purchase becomes an entitlement, and the exact values
the two consoles need.

`.agents/docs/monetization.md` is the policy — what is free and why.
[`docs/store/store-setup.md`](../../docs/store/store-setup.md) is the console
walkthrough around this one product. This file is the middle: the product
itself and the mechanism behind it.

---

## Store purchases only

The app charges through **App Store and Play Billing, and nothing else**. What
is sold is digital access inside the app, which both stores require to go
through their own purchase flow. LabFox never links out to a payment page and
carries no such link anywhere in the UI.

There is **no LabFox account and no LabFox server**. Entitlement comes from the
store the app was installed from, and nowhere else.

---

## One product

| | |
|---|---|
| Product ID | `labfox_subscription` |
| Kind | Auto-renewing subscription, monthly |
| Sold on | Android, iOS, iPadOS, macOS |
| Never sold on | Windows — and macOS ships free too, so the offer is hidden there |

**Why a subscription and not one-off products.** What it unlocks is ongoing
access, not an artifact the user keeps: the actions that finish work, extra
accounts, and an ad-free app are worth something every week the user keeps
LabFox installed. A one-time unlock would charge once for a cost that recurs.

**One product, not a tier ladder.** There is a single boundary — free reads,
paid finishes (`monetization.md` §2) — so a second price would have nothing
distinct to sell. Adding a tier later means a new product in the *same* Apple
subscription group, so upgrades and downgrades work; see the console section.

---

## What the subscription actually changes today

**Ads.** `adsEnabledProvider` is the only gate in the app that reads the
entitlement: subscribers see no ads, free mobile users do.

The rest of the boundary in `monetization.md` §2 — approve/merge/retry,
multiple accounts, push notifications, unlimited favorites — is **designed but
not gated**. Every one of those features currently works for everyone.

Two things follow, and neither is optional before the product goes on sale:

- **The subscription screen already lists those four benefits.** Selling a
  subscription that does not deliver what its own screen promises is a store
  rejection under Apple 3.1.1 / Play's payments policy, and a broken promise to
  whoever pays first.
- **Fix one side before selling.** Either gate the features, or reduce the
  screen and the listing copy to what the subscription does today. `AGENTS.md`
  §8 already forbids promising what is not built.

---

## The product ID is compiled in

`subscriptionProductId` defaults to `labfox_subscription`. It is overridable at
build time (`--dart-define=LABFOX_SUBSCRIPTION_ID=...`), but **the release
workflow passes no dart-defines**, so shipped builds always use the default.

The console must match it exactly. It is used in two places, and a mismatch
fails silently in both:

- `queryProductDetails({subscriptionProductId})` returns nothing → the screen
  says the subscription is unavailable, with no error anywhere.
- The purchase stream **skips any purchase whose `productID` is not this id** →
  a user could pay and stay on the free tier.

Renaming the product therefore means editing the default and shipping a
release, not editing a console field.

Apple's iOS and macOS targets share the bundle id `com.sloki9637.labfox`, so
Universal Purchase makes one Apple subscription cover iPhone, iPad, and Mac.
Apple and Google entitlements do not cross — there is no server to link them —
so a Play subscriber on a Mac is the one uncovered case. Say so in the listing
rather than engineering around it (`monetization.md` §3).

---

## Price is never in the code

The app displays `product.price`, the string the store returns already
formatted for the user's region and currency. Nothing else is honest: a
hardcoded price is wrong in every other country and wrong everywhere the moment
pricing changes.

When the store has not answered yet, there is no price and therefore nothing to
buy — the screen says so instead of inventing a number.

**This is what makes price a console decision.** Raising or lowering it, or
adding a regional price, needs no build, no review, and no release.

**Start low and move up.** A monthly charge on a developer tool competes with
"I'll just open the web UI"; the first price only has to beat that, and raising
a price later is easier than cutting one. The console proposes the other
storefronts' prices from whatever you set for your own — take those.

> A free trial or introductory offer is a console-side lever too, but the app
> is not ready for one: `SubscriptionOffer` exposes only price, title, and
> description, and both stores require the trial's terms to be disclosed on the
> purchase screen. Adding an offer means UI work first.

---

## What to create in each console

Field-level values. The click paths are in
[`docs/store/store-setup.md`](../../docs/store/store-setup.md).

### Play Console — Monetize → Products → Subscriptions

| Field | Value | Note |
|---|---|---|
| Product ID | `labfox_subscription` | Permanent; cannot be edited or reused after deletion |
| Name | `LabFox` | User-visible |
| Description | From [`listing.md`](../../docs/store/listing.md) | |
| **Base plan ID** | `monthly` | Permanent, never shown to users. Do not repeat the product id — `labfox-subscription-monthly` is longer for nothing, since it already lives inside that product |
| Base plan type | **Auto-renewing** | *Prepaid* is a fixed top-up that does not renew, which is not what this is |
| Billing period | Monthly | |
| Grace period / account hold | Leave the defaults | They keep a subscriber working through a failed payment retry |
| Tags | Skip | Only used for Play's own grouping |

Then **activate the base plan**. A subscription whose base plan is inactive
returns nothing to the app, which on screen is indistinguishable from a wrong
product id.

> Play has no consumable/non-consumable choice — that is an App Store concept.
> On Play the subscription itself is the whole product.

### App Store Connect — Monetization → Subscriptions

| Field | Value | Note |
|---|---|---|
| Subscription group | One group, reference name `LabFox` | Upgrades and downgrades only work *within* a group, so a future tier belongs in this one |
| Type | **Auto-renewable** | The place where the product type genuinely has to be chosen |
| Product ID | `labfox_subscription` | Must equal the Play id |
| Reference name | `LabFox subscription` | Internal only |
| Duration | 1 month | Match the Play base plan |
| Price | Same tier as Play | Apple proposes the other storefronts |
| Localizations | Display name and description from [`listing.md`](../../docs/store/listing.md) | |
| Review screenshot | The in-app subscription screen | Settings → LabFox subscription |

The **Paid Applications agreement must be active** first, or the subscription
cannot be created or bought — including in sandbox. A new subscription is
reviewed together with the first app version that offers it, and stays *Waiting
for Review* until that version is submitted.

---

## How a purchase becomes an entitlement

1. The screen reads the offer with `queryProductDetails`. No offer, no button.
2. `subscribe()` calls `buyNonConsumable` — both stores route auto-renewing
   subscriptions through it; the plugin has no separate subscription call.
3. The store answers on `purchaseStream`, never as a return value:
   `purchased`/`restored` → subscribed, `error`/`canceled` → free, `pending` →
   leave the current answer alone.
4. **Anything with `pendingCompletePurchase` is completed.** Both stores refund
   a purchase that is never acknowledged — Android within three days — so this
   is not bookkeeping, it is the difference between being paid and not.
5. The answer is cached in preferences under `entitlement`. It holds no
   receipt, no token, and no identifier — only which of two states was last
   seen (`AGENTS.md` §7).

### Verification is on-device, and that is a trade-off

There is no server, so nothing re-checks the receipt server-side: the app
trusts what the store SDK reports. A modified client could therefore claim to
be subscribed.

That is bounded on purpose. The unlocked capability is local UI — every byte of
GitLab data still requires the user's own token against their own instance — so
there is no server-side asset to steal and no other user to affect. If LabFox
ever grows a server, receipt validation belongs there on day one.

### Restore

Apple requires a visible restore control for subscriptions (Review Guideline
3.1.1), and it is what a user on a new device needs. `restore()` re-reads
entitlement, which calls `restorePurchases()` and waits **up to five seconds**
for the stream: a store with nothing to restore says nothing at all, so the
wait has to be bounded rather than indefinite. The same control ships on both
platforms so they behave alike.

### Fail open

A store that cannot be answered leaves the last known entitlement alone. A
store that answers *free* is believed, because a lapsed subscription has to be
able to lapse. Entitlement is never on the critical path of the first frame.

---

## Testing a purchase

- **Play**: install from the **internal** track with an account listed under
  Setup → License testing. A sideloaded build cannot complete a purchase — Play
  Billing checks the install came from Play.
- **Apple**: a Sandbox tester account, or TestFlight. Sandbox subscriptions
  renew on an accelerated clock, so a monthly plan expires in minutes; that is
  the fastest way to see the lapse path.

---

## When it does not work

| Symptom | Cause | Fix |
|---|---|---|
| Subscription screen says unavailable | Product not approved yet, id mismatch, Play base plan not activated, or the Paid Apps agreement is not active | Check the id first — it is the silent failure |
| User pays, app stays free | The purchase's `productID` is not `labfox_subscription`, so the stream skips it | The console product must match the compiled id |
| Play refunds a purchase after ~3 days | The purchase was never acknowledged | `completePurchase` regressed; it must run for every `pendingCompletePurchase` |
| Subscriber shows as free offline | The cached entitlement was lost or overwritten by a failed read | Fail-open: a failed read must return without writing |
| Restore returns nothing on a new device | Different store account, or a Play subscriber on a Mac | Expected; entitlement does not cross vendors |

---

## Cross-references

- [`monetization.md`](monetization.md) — the free/paid boundary and why
- [`docs/store/store-setup.md`](../../docs/store/store-setup.md) — the console
  walkthrough, declarations, and per-release steps
- [`docs/store/listing.md`](../../docs/store/listing.md) — the subscription copy
