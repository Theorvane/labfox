#!/usr/bin/env python3
"""Generate every LabFox icon size from the single brand source.

    python3 scripts/generate-icons.py [SOURCE]

SOURCE defaults to brand/labfox-icon.png. Everything under brand/generated/ is
derived from it, so that source file is the only image anyone should edit.

Uses scripts/pnglite.py rather than ImageMagick so the pipeline runs anywhere
Python 3 does, including CI containers without image tooling installed.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pnglite  # noqa: E402

# Sampled from the corner of the brand source; the social preview pads with the
# same navy so the letterboxing is invisible.
BACKGROUND = (0x07, 0x12, 0x30)

SQUARE_SIZES = [
    (1024, "icon-1024.png", "master square"),
    (512, "icon-512.png", "organization avatar"),
    (256, "icon-256.png", "desktop app icon"),
    (192, "icon-192.png", "Android launcher / PWA"),
    (128, "icon-128.png", "README badge"),
    (64, "icon-64.png", ""),
    (32, "favicon-32.png", ""),
    (16, "favicon-16.png", ""),
]

SOCIAL_W, SOCIAL_H, SOCIAL_ICON = 1280, 640, 460


def main():
    source = sys.argv[1] if len(sys.argv) > 1 else "brand/labfox-icon.png"
    if not os.path.isfile(source):
        sys.exit(f"Source image not found: {source}")

    width, height, channels, pixels = pnglite.read(source)
    if width != height:
        print(f"warning: source is {width}x{height}, not square; icons will be distorted")

    out_dir = os.path.join("brand", "generated")
    os.makedirs(out_dir, exist_ok=True)

    print(f"Source: {source} ({width}x{height}, {channels} channels)")
    print()

    for size, name, note in SQUARE_SIZES:
        scaled = pnglite.resize(pixels, width, height, channels, size, size)
        path = os.path.join(out_dir, name)
        written = pnglite.write(path, size, size, channels, scaled)
        suffix = f"  # {note}" if note else ""
        print(f"  {path:38} {size:>4}x{size:<4} {written // 1024:>4} KB{suffix}")

    # GitHub link cards are 1280x640, so the square mark is centred on a padded
    # canvas instead of being stretched.
    icon = pnglite.resize(pixels, width, height, channels, SOCIAL_ICON, SOCIAL_ICON)
    board = pnglite.canvas(SOCIAL_W, SOCIAL_H, BACKGROUND)
    pnglite.paste(board, SOCIAL_W, icon, SOCIAL_ICON, SOCIAL_ICON, channels,
                  (SOCIAL_W - SOCIAL_ICON) // 2, (SOCIAL_H - SOCIAL_ICON) // 2)
    path = os.path.join(out_dir, "social-preview.png")
    written = pnglite.write(path, SOCIAL_W, SOCIAL_H, 3, board)
    print(f"  {path:38} {SOCIAL_W}x{SOCIAL_H}  {written // 1024:>4} KB  # GitHub link card")

    print()
    print("Generated files are derived. Do not edit them; re-run this script instead.")


if __name__ == "__main__":
    main()
