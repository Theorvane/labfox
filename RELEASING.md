# Releasing

A release is a `dev` → `main` pull request. Landing it runs `release.yml`, which
verifies the commit, packages Windows, uploads to App Store Connect and Google
Play, tags, and publishes a GitHub release.

Nothing else publishes. An ordinary push to `main` with an already-tagged
version does nothing, so the pipeline cannot ship the same version twice.

---

## How to cut one

1. Bump `version:` in `apps/labfox/pubspec.yaml`.
   The part before `+` becomes the tag (`1.2.0` → `v1.2.0`). The part after is
   Android's `versionCode` and Apple's build number: **both stores reject a
   build that reuses one**, so it must increase on every release.
2. Open a `dev` → `main` pull request. `release-promotion.yml` rejects anything
   that is not the repository's own `dev` branch.
3. Merge it. `release.yml` takes over.

The Play upload targets the **internal** track. Promoting to production is a
decision made in the Play Console, not a side effect of merging.

---

## What the pipeline does, in order

| Job | What it does | Reversible? |
|---|---|---|
| `check` | Reads the version, skips if tagged, then runs format, analyze, and every package's tests | — |
| `windows` | Builds and zips the Windows app | — |
| `app-store-connect` | Uploads an iOS build. **Submits nothing** | yes |
| `google-play` | Uploads to the internal track | published to testers |
| `release` | Tags and publishes the GitHub release with the Windows zip | — |

Apple runs before Google deliberately. The two are not equally reversible, and
if Play published and a later step then failed, the release would be shipped but
untagged — so the next push would re-enter the pipeline and re-upload a
`versionCode` Play rejects. Live, unrecorded, and stuck until someone bumps the
version.

---

## Secrets and variables

Configured under the repository's `play-store` and `app-store` environments.
None of these exist yet; the pipeline cannot run until they do.

### Android — `play-store`

| Name | Kind | Where it comes from |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | secret | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | secret | the keystore password |
| `ANDROID_KEY_ALIAS` | secret | `keytool -list -v -keystore <file>` |
| `ANDROID_KEY_PASSWORD` | secret | the key password |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | secret | Play Console → Setup → API access → service account, then grant it release permissions |

The keystore itself is never committed: `.gitignore` covers `*.jks`,
`*.keystore` and `android/key.properties`, and the workflow writes
`key.properties` from these secrets at build time.

### Apple — `app-store`

| Name | Kind | Where it comes from |
|---|---|---|
| `APPLE_TEAM_ID` | variable | App Store Connect → Membership |
| `ASC_KEY_ID` | secret | App Store Connect → Users and Access → Integrations → App Store Connect API |
| `ASC_ISSUER_ID` | secret | the same page |
| `ASC_PRIVATE_KEY` | secret | the contents of the downloaded `.p8`, which Apple lets you download **once** |
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | secret | an Apple Distribution certificate exported as `.p12`, base64-encoded |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | secret | the password set during that export |
| `APP_STORE_PROVISIONING_PROFILE_BASE64` | secret | an App Store provisioning profile for `com.sloki9637.labfox`, base64-encoded |

---

## The first release is manual

The pipeline cannot bootstrap either store.

**Google Play** will not create a subscription product for an app with no
uploaded build, and the API access needed for
`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` requires a working Play Console. So the first
bundle goes up by hand:

```
cd apps/labfox && flutter build appbundle --release
```

Upload `build/app/outputs/bundle/release/app-release.aab` to the internal
testing track.

**App Store Connect** needs the app record, and Universal Purchase has to be
enabled on it before the macOS platform is added — see
`.agents/docs/monetization.md` §3.

Once both stores have an app and the pipeline's credentials exist, releases are
the three steps at the top of this file.

---

## Not automated yet

**macOS.** LabFox ships to the Mac App Store, which needs a signed installer
package rather than the app bundle the other platforms produce: a `3rd Party Mac
Developer Application` certificate for the app, a `3rd Party Mac Developer
Installer` certificate for the `.pkg`, and a Mac App Store provisioning profile.
That is a different signing path from the iOS job and worth landing on its own.
Until then, macOS releases are built and uploaded by hand.

**Windows code signing.** The Windows zip is unsigned, so SmartScreen warns on
first run. The release notes say so. Fixing it needs a code-signing certificate.
