# Third-Party Notices

LabFox is Apache-2.0 open source, and its mobile apps are sold for a price in the app stores.
It includes the third-party components listed below, and states each license and copyright notice.

> ⚠️ **This document is a legal obligation.** Permissive licenses such as MIT, BSD, and Apache-2.0
> **also require a copyright notice and the full license text to be included.** Whenever a dependency is added, it must be recorded here.

## In-app display

Flutter collects dependency licenses automatically. It must be exposed in the app's settings screen.

```dart
showLicensePage(
  context: context,
  applicationName: 'LabFox',
  applicationLegalese: '© 2026 sjungwon03',
);
```

LabFox itself is also Apache-2.0, so it is displayed on this screen as well.
Because `LicenseRegistry` automatically collects the LICENSE files of pub packages,
this screen alone satisfies the notice obligation for most pub.dev dependencies.
**Code copied in directly, and assets such as fonts and icons, are not collected automatically, so register them manually.**

```dart
LicenseRegistry.addLicense(() async* {
  yield LicenseEntryWithLineBreaks(
    ['<component>'],
    await rootBundle.loadString('assets/licenses/<component>.txt'),
  );
});
```

---

## Permitted licenses

| License | Paid distribution allowed | Conditions |
|---|---|---|
| MIT | ✅ | Copyright notice + full license text |
| BSD-2 / BSD-3 | ✅ | Copyright notice + full license text |
| Apache-2.0 | ✅ | Notice + statement of changes + pass on the NOTICE file if one exists |
| ISC | ✅ | Copyright notice |
| Zlib | ✅ | Notice (state modifications) |

## Forbidden licenses

| License | Reason |
|---|---|
| GPL-2.0 / GPL-3.0 | copyleft propagation — nullifies Apache-2.0, blocks App Store distribution |
| AGPL | Stronger copyleft — extends even to network use |
| LGPL | Flutter links statically → the dynamic linking exception cannot be used |
| SSPL / BUSL / Commons Clause | Restricts paid distribution |
| No license | No rights granted = cannot be used |

> GPL is forbidden not because it is not open source. LabFox is already open source.
> **If copyleft propagates, users who receive the paid app gain the right to demand the source and
> redistribute it for free**, which breaks the paid model and also conflicts with Apple's terms.

**Always check the license before adding a dependency.** (`AGENTS.md` §8)

---

## Included components

<!-- Update the table below whenever a dependency is added. -->

| Component | Version | License | Source |
|---|---|---|---|
| Flutter SDK | — | BSD-3-Clause | https://github.com/flutter/flutter |

*(To be filled in with the actual dependencies after scaffolding)*

---

## Assets

| Asset | License | Source |
|---|---|---|
| *(none)* | | |

Fonts, icons, and images are also subject to license review.
In particular, **icon sets often have restrictive commercial-use conditions**, so verify before adopting them.
