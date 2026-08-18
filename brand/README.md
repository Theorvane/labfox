# Brand assets

## Source of truth

```
brand/labfox-icon.png      the only file to edit
brand/generated/*.png      derived — never edit by hand
```

Regenerate everything after changing the source:

```bash
python3 scripts/generate-icons.py
```

The generator uses `scripts/pnglite.py`, a small standard-library PNG
reader/writer, so it needs nothing beyond Python 3 — no ImageMagick, no
librsvg, no Pillow. That keeps icon generation reproducible in CI containers
and on machines where those tools cannot be installed.

## Generated sizes

| File | Size | Used for |
|---|---|---|
| `icon-1024.png` | 1024 | Master square, store submissions |
| `icon-512.png` | 512 | Organization avatar, Play Store |
| `icon-256.png` | 256 | Windows and macOS app icon |
| `icon-192.png` | 192 | Android launcher, PWA |
| `icon-128.png` | 128 | README, documentation |
| `icon-64.png` | 64 | Small UI surfaces |
| `favicon-32.png` | 32 | Browser tab |
| `favicon-16.png` | 16 | Browser tab |
| `social-preview.png` | 1280x640 | GitHub link card |

The social preview is not square: the mark is centred on a `#071230` canvas,
the same navy as the source background, so the padding is invisible.

## Two things that are not automated

GitHub exposes neither the repository social preview nor the organization
avatar through its REST API. Both are uploaded through the web interface:

- Social preview: repository **Settings** -> **General** -> **Social preview**
  -> upload `brand/generated/social-preview.png`
- Organization avatar: organization **Settings** -> **Profile** -> upload
  `brand/generated/icon-512.png`

## Licensing

The LabFox mark is **not** covered by the Apache-2.0 license that applies to
the source code. It is a trademark. See [TRADEMARK.md](../TRADEMARK.md) — forks
must ship a different name and a different icon.
