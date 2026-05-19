#!/usr/bin/env python3
"""
Update CHANGELOG.md with entries from recent commits.

Reads commit SHAs from the COMMIT_SHAS environment variable (JSON array).

Handles:
  - Dependabot grouped commits (parses the markdown table from the commit body)
  - Dependabot single-package commits (parses the subject line)
  - Conventional commits (maps type to Added / Changed / Fixed section)

Date-based sections are merged if today already has an entry; otherwise a new
section is prepended after the file header.
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from datetime import date

TODAY = date.today().strftime("%Y-%m-%d")

SECTION_ORDER = ["Added", "Changed", "Fixed", "Dependencies"]

TYPE_TO_SECTION = {
    "feat": "Added",
    "fix": "Fixed",
    "docs": "Changed",
    "style": "Changed",
    "refactor": "Changed",
    "perf": "Changed",
    "test": "Changed",
    "build": "Changed",
    "ci": "Changed",
    "chore": "Changed",
    "revert": "Changed",
}

# Commit subjects matching these patterns are skipped entirely
SKIP_PATTERNS = [
    r"\[skip ci\]",
    r"^docs: update changelog",
    r"^chore: update changelog",
    r"^chore: update dependabot",
]


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------


def git(*args):
    result = subprocess.run(
        ["git"] + list(args),
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


# ---------------------------------------------------------------------------
# Dependabot parsers
# ---------------------------------------------------------------------------


def parse_dependabot_grouped(body):
    """
    Extract individual package bumps from a Dependabot grouped commit body.

    Dependabot formats the body as a markdown table:
      | Package | From | To |
      | --- | --- | --- |
      | [traefik](https://...) | `v3.7.0` | `v3.7.1` |
    """
    entries = []
    for line in body.splitlines():
        match = re.match(
            r"^\|\s*\[([^\]]+)\]\([^)]+\)\s*\|\s*`?([^`|\s]+)`?\s*\|\s*`?([^`|\s]+)`?\s*\|",
            line,
        )
        if match:
            pkg, frm, to = match.group(1), match.group(2), match.group(3)
            # Skip the header separator row (--- cells)
            if frm.startswith("-"):
                continue
            entries.append(f"Bumped `{pkg}` from {frm} to {to}.")
    return entries


def parse_dependabot_single(subject):
    """
    Parse a single-package Dependabot subject line.

    Handles:
      chore(deps): bump traefik from v3.7.0 to v3.7.1
      chore(deps): bump gitea/gitea from 1.26.0 to 1.26.1 in /docker/gitea
    """
    match = re.match(
        r"chore\(deps\):\s+bump\s+(\S+)\s+from\s+(\S+)\s+to\s+(\S+)(?:\s+in\s+(\S+))?",
        subject,
        re.IGNORECASE,
    )
    if match:
        pkg, frm, to, path = (
            match.group(1),
            match.group(2),
            match.group(3),
            match.group(4),
        )
        if path:
            return f"Bumped `{pkg}` from {frm} to {to} in `{path}`."
        return f"Bumped `{pkg}` from {frm} to {to}."
    return None


# ---------------------------------------------------------------------------
# Commit parser
# ---------------------------------------------------------------------------


def parse_commit(sha):
    """
    Parse a single commit SHA and return a dict with 'section' and 'entries',
    or None if the commit should be skipped.
    """
    author = git("log", "-1", "--format=%an", sha)
    subject = git("log", "-1", "--format=%s", sha)
    body = git("log", "-1", "--format=%b", sha)

    # Skip automated / changelog update commits
    for pattern in SKIP_PATTERNS:
        if re.search(pattern, subject, re.IGNORECASE):
            return None

    is_dependabot = author == "dependabot[bot]" or bool(
        re.match(r"^chore\(deps\):", subject)
    )

    if is_dependabot:
        # Grouped PR: parse markdown table from body
        grouped = parse_dependabot_grouped(body)
        if grouped:
            return {"section": "Dependencies", "entries": grouped}

        # Single-package PR: parse subject line
        single = parse_dependabot_single(subject)
        if single:
            return {"section": "Dependencies", "entries": [single]}

        # Fallback: strip the conventional prefix and capitalise
        desc = re.sub(r"^chore\(deps\):\s*", "", subject, flags=re.IGNORECASE)
        desc = desc[0].upper() + desc[1:] if desc else desc
        return {"section": "Dependencies", "entries": [f"{desc}."]}

    # Parse conventional commit: type(scope)!: description
    match = re.match(
        r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)"
        r"(\(([^)]+)\))?(!)?: (.+)",
        subject,
    )
    if not match:
        return None

    commit_type = match.group(1)
    scope = match.group(3)
    description = match.group(5)
    description = description[0].upper() + description[1:] if description else description

    entry = f"`{scope}` — {description}." if scope else f"{description}."
    return {
        "section": TYPE_TO_SECTION.get(commit_type, "Changed"),
        "entries": [entry],
    }


# ---------------------------------------------------------------------------
# CHANGELOG manipulation
# ---------------------------------------------------------------------------


def parse_changelog(content):
    """
    Parse CHANGELOG.md into:
      - header_lines: list of lines before the first "## [" section
      - sections: list of dicts {"date": str, "lines": [str]}
    """
    lines = content.split("\n")
    header_lines = []
    sections = []
    current = None
    in_header = True

    for line in lines:
        if re.match(r"^## \[", line):
            in_header = False
            if current is not None:
                sections.append(current)
            date_match = re.match(r"^## \[([^\]]+)\]", line)
            current = {
                "date": date_match.group(1) if date_match else "",
                "lines": [line],
            }
        elif in_header:
            header_lines.append(line)
        elif current is not None:
            current["lines"].append(line)

    if current is not None:
        sections.append(current)

    return header_lines, sections


def insert_into_subsection(section_lines, subsection, new_entries):
    """
    Insert new bullet entries under an existing subsection header, or append
    a new subsection if it does not yet exist.
    """
    header = f"### {subsection}"
    entry_lines = [f"- {e}" for e in new_entries]

    # Find an existing subsection header
    for i, line in enumerate(section_lines):
        if line == header:
            # Advance past existing entries; stop at the next ### / ## or end
            j = i + 1
            while j < len(section_lines) and not section_lines[j].startswith(
                ("### ", "## ")
            ):
                j += 1
            # Trim trailing blank lines so we don't gap before new entries
            while j > i + 1 and section_lines[j - 1] == "":
                j -= 1
            return section_lines[:j] + entry_lines + section_lines[j:]

    # Subsection absent — append it before any trailing blank lines
    j = len(section_lines)
    while j > 1 and section_lines[j - 1] == "":
        j -= 1
    return section_lines[:j] + ["", header] + entry_lines + section_lines[j:]


def build_new_section(sections_data):
    """Build the line list for a brand-new date section."""
    lines = [f"## [{TODAY}]", ""]
    for subsection in SECTION_ORDER:
        if sections_data.get(subsection):
            lines.append(f"### {subsection}")
            for entry in sections_data[subsection]:
                lines.append(f"- {entry}")
            lines.append("")
    return lines


def normalise(lines):
    """Collapse runs of >1 blank line and ensure a single trailing newline."""
    output = []
    blank_run = 0
    for line in lines:
        if line == "":
            blank_run += 1
            if blank_run <= 1:
                output.append(line)
        else:
            blank_run = 0
            output.append(line)
    while output and output[-1] == "":
        output.pop()
    output.append("")  # single trailing newline
    return output


def update_changelog(sections_data, changelog_path="CHANGELOG.md"):
    """
    Prepend or merge changelog entries into CHANGELOG.md.
    Returns True if the file was modified, False otherwise.
    """
    if not any(sections_data.get(s) for s in SECTION_ORDER):
        print("No changelog entries to add.")
        return False

    with open(changelog_path, "r") as f:
        content = f.read()

    header_lines, existing_sections = parse_changelog(content)

    if existing_sections and existing_sections[0]["date"] == TODAY:
        # Merge new entries into today's existing section
        today_section = existing_sections[0]
        for subsection in SECTION_ORDER:
            if sections_data.get(subsection):
                today_section["lines"] = insert_into_subsection(
                    today_section["lines"], subsection, sections_data[subsection]
                )
    else:
        # Prepend a fresh section for today
        existing_sections.insert(
            0, {"date": TODAY, "lines": build_new_section(sections_data)}
        )

    # Reconstruct the file
    parts = list(header_lines)
    for sec in existing_sections:
        parts.append("")
        parts.extend(sec["lines"])

    with open(changelog_path, "w") as f:
        f.write("\n".join(normalise(parts)))

    total = sum(len(v) for v in sections_data.values())
    print(f"CHANGELOG.md updated with {total} new entr{'y' if total == 1 else 'ies'}.")
    return True


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main():
    commit_shas_json = os.environ.get("COMMIT_SHAS", "[]")
    try:
        shas = json.loads(commit_shas_json)
    except json.JSONDecodeError:
        print("ERROR: COMMIT_SHAS is not valid JSON.", file=sys.stderr)
        sys.exit(1)

    if not shas:
        print("No commit SHAs provided — nothing to do.")
        sys.exit(0)

    sections = defaultdict(list)

    for sha in shas:
        try:
            result = parse_commit(sha)
        except subprocess.CalledProcessError as exc:
            print(f"WARNING: Could not read commit {sha}: {exc}", file=sys.stderr)
            continue
        if result:
            sections[result["section"]].extend(result["entries"])

    update_changelog(dict(sections))


if __name__ == "__main__":
    main()
