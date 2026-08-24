#!/usr/bin/env python3
"""Compose App Store promotional screenshots.

Takes raw simulator captures and produces store-ready images at an exact pixel
size, each with a caption above a rounded device shot on a brand gradient.

    ./scripts/store_screenshots.py --raw build/store/raw --out build/store/out

Captures are matched to captions by filename order. Anything the simulator
produced at a different aspect ratio is fitted rather than stretched, so a shot
from a device that is not the target size still composes correctly.
"""

from __future__ import annotations

import argparse
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

# .agents/docs — packages/design_system/lib/src/tokens/colors.dart
NAVY = (0x07, 0x12, 0x30)
ORANGE = (0xF5, 0x47, 0x14)
ORANGE_LIGHT = (0xFF, 0x8A, 0x1F)

# App Store 6.5" portrait.
DEFAULT_SIZE = (1242, 2688)

FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"

# One caption per capture, in filename order. Each says what the screen does for
# the user rather than naming the screen. --tablet-captions swaps in the set
# written for the larger canvas, where the selling point is how much fits at
# once rather than that it fits in a hand at all.
TABLET_CAPTIONS = [
    ("The whole queue at a glance", "Twenty merge requests, labels and all, without scrolling"),
    ("Every project, in full", "README, issues, pipelines and branches on one screen"),
    ("Review without the squint", "The entire description and the merge button together"),
    ("Diffs that fit", "Several files at once, with room for the code to breathe"),
    ("CI at a glance", "Running, passed, failed and cancelled, all in view"),
]

CAPTIONS = [
    ("Your whole GitLab", "Issues, merge requests and pipelines, one tap away"),
    ("Approve from anywhere", "The whole review, right down to the merge button"),
    ("Read the diff properly", "Real syntax, real line numbers, no pinching"),
    ("Follow the job log live", "Full output with colour, exactly as the runner wrote it"),
    ("Know what CI is doing", "Every pipeline and its state, without opening a laptop"),
]


def gradient(size: tuple[int, int]) -> Image.Image:
    """A vertical navy-to-orange wash, dark at the top so captions stay legible."""
    width, height = size
    base = Image.new("RGB", (1, height))
    pixels = base.load()
    for y in range(height):
        t = y / max(height - 1, 1)
        # Ease so most of the canvas stays dark and the warmth arrives late.
        t = t**1.7
        pixels[0, y] = (
            round(NAVY[0] + (ORANGE[0] - NAVY[0]) * t),
            round(NAVY[1] + (ORANGE[1] - NAVY[1]) * t),
            round(NAVY[2] + (ORANGE[2] - NAVY[2]) * t),
        )
    return base.resize(size, Image.Resampling.BILINEAR)


def rounded(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [(0, 0), (image.size[0] - 1, image.size[1] - 1)], radius=radius, fill=255
    )
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def fit(shot: Image.Image, box: tuple[int, int]) -> Image.Image:
    """Scale to fit inside box, preserving aspect ratio. Never stretches."""
    scale = min(box[0] / shot.width, box[1] / shot.height)
    return shot.resize(
        (round(shot.width * scale), round(shot.height * scale)),
        Image.Resampling.LANCZOS,
    )


def wrap(draw, text, font, max_width):
    words, lines, line = text.split(), [], ""
    for word in words:
        candidate = f"{line} {word}".strip()
        if draw.textlength(candidate, font=font) <= max_width:
            line = candidate
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def compose(shot_path, headline, subtitle, size):
    canvas = gradient(size).convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    width, height = size

    # A tablet canvas is far squarer than a phone's, so the phone proportions
    # leave the shot stranded in the middle with dead margins either side.
    # Give the wider canvas more of its width and proportionally smaller type.
    tablet = width / height > 0.6
    shot_width = 0.92 if tablet else 0.84
    head_scale = 0.048 if tablet else 0.062
    sub_scale = 0.026 if tablet else 0.034
    margin = round(width * (0.06 if tablet else 0.08))

    head_font = ImageFont.truetype(FONT_BOLD, round(width * head_scale))
    sub_font = ImageFont.truetype(FONT_REGULAR, round(width * sub_scale))

    y = round(height * (0.045 if tablet else 0.055))
    for line in wrap(draw, headline, head_font, width - margin * 2):
        draw.text((margin, y), line, font=head_font, fill=(255, 255, 255))
        y += round(head_font.size * 1.18)

    y += round(height * 0.008)
    for line in wrap(draw, subtitle, sub_font, width - margin * 2):
        draw.text((margin, y), line, font=sub_font, fill=(255, 255, 255, 205))
        y += round(sub_font.size * 1.35)

    # The device shot fills what is left, bleeding off the bottom edge so the
    # image reads as a phone rather than a framed thumbnail.
    top = y + round(height * 0.035)
    shot = fit(
        Image.open(shot_path).convert("RGB"),
        (round(width * shot_width), height - top),
    )
    shot = rounded(shot, round(shot.width * 0.055))

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    x = (width - shot.width) // 2
    shadow.paste((0, 0, 0, 90), (x + 8, top + 14, x + shot.width + 8, top + shot.height + 14))
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.paste(shot, (x, top), shot)
    return canvas.convert("RGB")


# ---------------------------------------------------------------------------
# Google Play feature graphic
# ---------------------------------------------------------------------------
#
# 1024x500, landscape, and shown at the top of the Play listing — often cropped
# and sometimes played as video, so nothing essential goes near the edges and
# no screenshot detail is small enough to matter. It is a banner, not a
# screenshot: the app art is a supporting element, the name and line are the
# message.


def feature_graphic(icon_path, shot_path, out_path, size=(1024, 500)):
    width, height = size
    canvas = gradient((width, width)).resize(size, Image.Resampling.BILINEAR)
    canvas = canvas.convert("RGBA")

    # A phone shot bleeding off the right edge, tilted slightly so the banner
    # reads as a product shot rather than a boxed thumbnail.
    shot = Image.open(shot_path).convert("RGB")
    shot_h = round(height * 1.25)
    shot_w = round(shot.width * shot_h / shot.height)
    shot = shot.resize((shot_w, shot_h), Image.Resampling.LANCZOS)
    shot = rounded(shot, round(shot_w * 0.06))
    shot = shot.rotate(-8, expand=True, resample=Image.Resampling.BICUBIC)
    canvas.alpha_composite(shot, (round(width * 0.63), round(height * 0.16)))

    draw = ImageDraw.Draw(canvas)
    margin = round(width * 0.06)

    icon = Image.open(icon_path).convert("RGBA")
    icon_size = round(height * 0.19)
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    icon = rounded(icon.convert("RGB"), round(icon_size * 0.22))
    canvas.alpha_composite(icon, (margin, round(height * 0.17)))

    name_font = ImageFont.truetype(FONT_BOLD, round(height * 0.145))
    line_font = ImageFont.truetype(FONT_REGULAR, round(height * 0.062))

    y = round(height * 0.42)
    draw.text((margin, y), "LabFox", font=name_font, fill=(255, 255, 255))
    y += round(name_font.size * 1.2)
    for line in wrap(
        draw,
        "Your GitLab merge requests, pipelines and job logs, wherever you are",
        line_font,
        round(width * 0.55),
    ):
        draw.text((margin, y), line, font=line_font, fill=(255, 255, 255, 215))
        y += round(line_font.size * 1.4)

    out = canvas.convert("RGB")
    assert out.size == size, f"{out.size} != {size}"
    out.save(out_path)
    return out_path

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--raw", required=True, help="directory of simulator captures")
    parser.add_argument("--out", required=True, help="where to write the store images")
    parser.add_argument("--width", type=int, default=DEFAULT_SIZE[0])
    parser.add_argument("--height", type=int, default=DEFAULT_SIZE[1])
    parser.add_argument(
        "--tablet-captions",
        action="store_true",
        help="use the caption set written for a tablet canvas",
    )
    parser.add_argument(
        "--feature-graphic",
        action="store_true",
        help="compose the Play listing banner instead of screenshots",
    )
    parser.add_argument("--icon", default="brand/generated/icon-512.png")
    args = parser.parse_args()

    raw_dir, out_dir = pathlib.Path(args.raw), pathlib.Path(args.out)
    shots = sorted(p for p in raw_dir.glob("*.png"))
    if not shots:
        print(f"no captures in {raw_dir}", file=sys.stderr)
        return 1
    out_dir.mkdir(parents=True, exist_ok=True)

    if args.feature_graphic:
        target = feature_graphic(
            args.icon, shots[0], out_dir / "feature-graphic.png", (args.width, args.height)
        )
        print(f"{target}  {args.width}x{args.height}")
        return 0

    size = (args.width, args.height)
    captions = TABLET_CAPTIONS if args.tablet_captions else CAPTIONS
    for index, shot in enumerate(shots):
        headline, subtitle = captions[index % len(captions)]
        image = compose(shot, headline, subtitle, size)
        assert image.size == size, f"{image.size} != {size}"
        target = out_dir / f"{index + 1:02d}-{shot.stem}.png"
        image.save(target)
        print(f"{target}  {image.size[0]}x{image.size[1]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
