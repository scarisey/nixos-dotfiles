#!/usr/bin/env python3
"""
filter_nef_by_rating.py

Filter NEF files based on their darktable XMP sidecar rating.
Non-destructive: never modifies or deletes source files.
Output is either printed paths, symlinks, or hard links.

Rating values (darktable):
  -1  Rejected
   0  Unrated
  1-5 Stars

Usage examples:
  python filter_nef_by_rating.py /path/to/photos -r ">=3"
  python filter_nef_by_rating.py /path/to/photos -r "=5" -o ./best --link symlink
  python filter_nef_by_rating.py /path/to/photos -r ">=3,<=4" -R
  python filter_nef_by_rating.py /path/to/photos -r "=-1"        # rejected
  python filter_nef_by_rating.py /path/to/photos -r "!=0"        # rated (any star)
"""

import argparse
import re
import sys
from pathlib import Path
from xml.etree import ElementTree as ET


# ── Rating parsing ────────────────────────────────────────────────────────────

CONDITION_RE = re.compile(r"^(>=|<=|!=|>|<|=)?(-?[0-9]+)$")
OPS = {
    "=":  lambda r, v: r == v,
    ">=": lambda r, v: r >= v,
    "<=": lambda r, v: r <= v,
    ">":  lambda r, v: r > v,
    "<":  lambda r, v: r < v,
    "!=": lambda r, v: r != v,
}


def parse_rating_expr(expr: str) -> list[tuple[str, int]]:
    """Parse a comma-separated rating expression like '>=3,<=5' into conditions."""
    conditions = []
    for part in expr.split(","):
        part = part.strip()
        m = CONDITION_RE.match(part)
        if not m:
            raise ValueError(f"Invalid rating expression: '{part}'")
        op = m.group(1) or "="
        val = int(m.group(2))
        conditions.append((op, val))
    return conditions


def rating_matches(rating: int, conditions: list[tuple[str, int]]) -> bool:
    return all(OPS[op](rating, val) for op, val in conditions)


# ── XMP rating extraction ─────────────────────────────────────────────────────

# Darktable may write rating as a tag or as an RDF attribute.
# We try both: proper XML parse first, then a regex fallback for edge cases.
XMP_NS = "http://ns.adobe.com/xap/1.0/"
RATING_TAG_RE = re.compile(r'xmp:Rating\s*=\s*"([^"]+)"|<xmp:Rating>([^<]+)</xmp:Rating>')


def get_xmp_rating(xmp_path: Path) -> int | None:
    """
    Return the xmp:Rating integer from a darktable sidecar, or None if absent.
    Tries XML parsing first, falls back to regex for non-standard XMP files.
    """
    text = xmp_path.read_text(encoding="utf-8", errors="replace")

    # XML parse (preferred)
    try:
        # Wrap in a root so ElementTree can parse partial XMP documents
        root = ET.fromstring(f"<root xmlns:xmp='{XMP_NS}'>{text}</root>")
        for elem in root.iter(f"{{{XMP_NS}}}Rating"):
            return int(elem.text.strip())
        # Also check attributes on any element
        for elem in root.iter():
            val = elem.get(f"{{{XMP_NS}}}Rating")
            if val is not None:
                return int(val.strip())
    except ET.ParseError:
        pass

    # Regex fallback
    m = RATING_TAG_RE.search(text)
    if m:
        return int((m.group(1) or m.group(2)).strip())

    return None


# ── Output actions ────────────────────────────────────────────────────────────

def make_output_path(nef: Path, output_dir: Path) -> Path:
    return output_dir / nef.name


def do_symlink(src: Path, dest: Path, dry_run: bool) -> str:
    if dest.exists() or dest.is_symlink():
        return f"skip (exists): {dest}"
    if not dry_run:
        dest.symlink_to(src.resolve())
    return f"symlink -> {dest}"


def do_hardlink(src: Path, dest: Path, dry_run: bool) -> str:
    if dest.exists():
        return f"skip (exists): {dest}"
    if not dry_run:
        dest.hardlink_to(src)
    return f"hardlink -> {dest}"


def do_copy_xmp(xmp: Path, dest_dir: Path, dry_run: bool):
    dest = dest_dir / xmp.name
    if dest.exists():
        return
    if not dry_run:
        dest.write_bytes(xmp.read_bytes())


# ── Main ──────────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Filter NEF files by their darktable XMP sidecar rating.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
rating expressions:
  =5          exactly 5 stars
  >=3         3 stars or more
  >=3,<=4     between 3 and 4 stars (AND)
  !=0         any rated file (not unrated)
  =-1         rejected files

link modes (when --output is set):
  symlink     create symbolic links (default)
  hardlink    create hard links (same filesystem only)
  none        don't link, just print matched paths
""",
    )
    p.add_argument("directory", type=Path, help="Directory to search")
    p.add_argument("-r", "--rating", required=True, metavar="EXPR",
                   help="Rating filter expression (e.g. '>=3' or '>=3,<=5')")
    p.add_argument("-o", "--output", type=Path, metavar="DIR",
                   help="Output directory for links (non-destructive)")
    p.add_argument("--link", choices=["symlink", "hardlink", "none"],
                   default="symlink",
                   help="Link mode when --output is set (default: symlink)")
    p.add_argument("-R", "--recursive", action="store_true",
                   help="Search recursively")
    p.add_argument("-n", "--dry-run", action="store_true",
                   help="Print actions without executing them")
    p.add_argument("-v", "--verbose", action="store_true",
                   help="Show all files, including skipped ones")
    return p


def main():
    args = build_parser().parse_args()

    # Validate source directory
    if not args.directory.is_dir():
        print(f"error: not a directory: {args.directory}", file=sys.stderr)
        sys.exit(1)

    # Parse rating expression
    try:
        conditions = parse_rating_expr(args.rating)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(1)

    # Prepare output directory (never touches existing files)
    if args.output:
        if not args.dry_run:
            args.output.mkdir(parents=True, exist_ok=True)

    # Collect NEF files
    glob = args.directory.rglob("*.[Nn][Ee][Ff]") if args.recursive \
           else args.directory.glob("*.[Nn][Ee][Ff]")
    nef_files = sorted(glob)

    if not nef_files:
        print(f"No NEF files found in {args.directory}", file=sys.stderr)
        sys.exit(0)

    matched = 0
    no_xmp = 0
    no_rating = 0

    for nef in nef_files:
        xmp = nef.with_suffix(nef.suffix + ".xmp")  # e.g. DSC_0001.NEF.xmp

        if not xmp.exists():
            # darktable also sometimes writes DSC_0001.xmp (no .nef in stem)
            xmp_alt = nef.with_suffix(".xmp")
            if xmp_alt.exists():
                xmp = xmp_alt
            else:
                if args.verbose:
                    print(f"  no xmp : {nef}")
                no_xmp += 1
                continue

        rating = get_xmp_rating(xmp)

        if rating is None:
            if args.verbose:
                print(f"  no tag : {nef}")
            no_rating += 1
            continue

        if not rating_matches(rating, conditions):
            if args.verbose:
                print(f"  skip [{rating:+d}★]: {nef}")
            continue

        matched += 1

        # Always print the matched path
        print(nef)

        # Optionally create a link in output dir
        if args.output and args.link != "none":
            dest = make_output_path(nef, args.output)
            action_fn = do_symlink if args.link == "symlink" else do_hardlink
            msg = action_fn(nef, dest, args.dry_run)
            if args.verbose:
                print(f"  [{rating:+d}★] {msg}")
            # Copy XMP sidecar alongside (read-only copy, never overwrites)
            if not args.dry_run:
                do_copy_xmp(xmp, args.output, args.dry_run)

    # Summary to stderr so it doesn't pollute piped output
    print(
        f"\n{matched} matched | {no_xmp} missing XMP | {no_rating} missing rating tag",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
