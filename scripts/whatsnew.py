#!/usr/bin/env python3
"""Extract a release's Play notes from docs/store into files Play understands.

The notes are written and reviewed in `docs/store/release-notes*.md`. Play
accepts them with the upload, so the release workflow calls this to turn the
section for the version being released into one `whatsnew-<locale>` file per
language, which is the layout `upload-google-play` expects.

Exits non-zero when a version has no notes, or when a locale's text exceeds
Play's 500-character limit. Both are better caught here than discovered as a
release published with nothing to say, or with a sentence cut in half.
"""

import argparse
import pathlib
import re
import sys

# Play's locale codes, and the file each language's notes live in. English is
# the source; `AGENTS.md` exempts the translations from the English-only rule.
LOCALES = {
    "en-US": "docs/store/release-notes.md",
    "ko-KR": "docs/store/release-notes.ko.md",
}

PLAY_LIMIT = 500


def section(text: str, version: str) -> str:
    """The part of the document under `## <version>`, up to the next release."""
    pattern = rf"^## {re.escape(version)}\s*$(.*?)(?=^## |\Z)"
    found = re.search(pattern, text, re.S | re.M)
    return found.group(1) if found else ""


def play_block(body: str) -> str:
    """The fenced block under the **Play** heading of a release section."""
    found = re.search(r"\*\*Play\*\*[^\n]*\n+```\n(.*?)```", body, re.S)
    return found.group(1).strip("\n") if found else ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="e.g. 0.1.5")
    parser.add_argument("--out", required=True, help="directory to write into")
    args = parser.parse_args()

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    failures = []
    for locale, path in LOCALES.items():
        source = pathlib.Path(path)
        if not source.exists():
            failures.append(f"{path} is missing")
            continue
        notes = play_block(section(source.read_text(encoding="utf-8"), args.version))
        if not notes:
            failures.append(f"{path} has no Play notes for {args.version}")
            continue
        if len(notes) > PLAY_LIMIT:
            failures.append(
                f"{path}: {locale} notes are {len(notes)} characters, "
                f"over Play's limit of {PLAY_LIMIT}"
            )
            continue
        (out / f"whatsnew-{locale}").write_text(notes + "\n", encoding="utf-8")

    for failure in failures:
        print(f"error: {failure}", file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
