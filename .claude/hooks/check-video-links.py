#!/usr/bin/env python3
"""Guard against raw YouTube video links in CHEME 5660 student-facing files.

Every course video links through https://varnerlab.org/watch.html?v=<id>.
A bare youtube.com/embed/<id> link opened in a browser tab fails with
"Video player configuration error 153", and students see the broken link.

Usage (wired up in .claude/settings.json):
  check-video-links.py pre    PreToolUse on Edit|MultiEdit|Write|NotebookEdit.
                              Denies the call if its new text adds a raw video
                              link to a student-facing file.
  check-video-links.py stop   Stop. Scans the student-facing files on disk, which
                              catches edits made through Bash (perl, sed, heredocs),
                              and sends Claude back to fix any raw link it finds.

Channel links such as youtube.com/@TED are allowed: the player takes a video id only.
Historical records under lectures/archive/ and lectures/instructor/ are not checked.
"""
import json
import os
import re
import sys

# A raw YouTube *video* link: needs an 11-character video id, so prose that
# mentions "youtube.com/embed/<id>" as a placeholder does not match.
VIDEO = re.compile(
    r"(?:youtube(?:-nocookie)?\.com/(?:embed/|shorts/|live/|v/|watch\?(?:[^\s\"')<>]*?&(?:amp;)?)?v=)"
    r"|youtu\.be/)[A-Za-z0-9_-]{11}",
    re.IGNORECASE,
)

FIX = (
    "Course videos must link to https://varnerlab.org/watch.html?v=<11-char id> "
    "(optional &t=<seconds>), never youtube.com/embed, youtube.com/watch, or youtu.be. "
    "A raw embed link fails for students with player error 153. "
    "Verify the id with https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=<id>&format=json (200 = OK)."
)

ROOT = os.path.realpath(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())

# Student-facing trees scanned at the end of a turn, relative to ROOT.
SCAN_DIRS = ("lectures", "private/canvas", "code")
SCAN_FILES = ("README.md",)
SCAN_EXT = {".ipynb", ".md", ".tex", ".html", ".htm", ".qmd", ".jl", ".txt", ".xml"}

# Paths that are never checked: historical records and tool internals.
SKIP_PREFIXES = ("lectures/archive/", "lectures/instructor/", ".git/", ".claude/")
SKIP_PARTS = ("/archive/", "/build/", "/.ipynb_checkpoints/")


def relpath_in_repo(path):
    """Return the repo-relative path, or None when the file lies outside the repo."""
    if not path:
        return None
    full = os.path.realpath(path if os.path.isabs(path) else os.path.join(ROOT, path))
    if full != ROOT and not full.startswith(ROOT + os.sep):
        return None
    return os.path.relpath(full, ROOT).replace(os.sep, "/")


def in_scope(rel):
    """True when a repo-relative path is a student-facing file we check."""
    if rel is None or rel.startswith(SKIP_PREFIXES):
        return False
    if any(part in "/" + rel for part in SKIP_PARTS):
        return False
    return True


def new_text(tool_input):
    """Collect the text an edit tool would write (never the text it removes)."""
    pieces = []
    for key in ("new_string", "content", "new_source"):
        value = tool_input.get(key)
        if isinstance(value, str):
            pieces.append(value)
    for edit in tool_input.get("edits") or []:
        if isinstance(edit, dict) and isinstance(edit.get("new_string"), str):
            pieces.append(edit["new_string"])
    return "\n".join(pieces)


def run_pre(payload):
    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path") or tool_input.get("notebook_path")
    rel = relpath_in_repo(path)
    if not in_scope(rel):
        return 0
    found = sorted(set(m.group(0) for m in VIDEO.finditer(new_text(tool_input))))
    if not found:
        return 0
    reason = f"Blocked: raw YouTube video link(s) in {rel}: {', '.join(found)}. {FIX}"
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    return 0


def scan_repo():
    """Return {repo-relative path: [raw links]} for every student-facing file on disk."""
    hits = {}
    candidates = [os.path.join(ROOT, f) for f in SCAN_FILES]
    for d in SCAN_DIRS:
        top = os.path.join(ROOT, d)
        for dirpath, dirnames, filenames in os.walk(top):
            rel_dir = os.path.relpath(dirpath, ROOT).replace(os.sep, "/") + "/"
            dirnames[:] = [n for n in dirnames if in_scope(rel_dir + n + "/")]
            for name in filenames:
                if os.path.splitext(name)[1].lower() in SCAN_EXT:
                    candidates.append(os.path.join(dirpath, name))
    for full in candidates:
        rel = relpath_in_repo(full)
        if not in_scope(rel) or not os.path.isfile(full):
            continue
        if os.path.getsize(full) > 20_000_000:
            continue
        with open(full, "r", encoding="utf-8", errors="ignore") as fh:
            found = sorted(set(m.group(0) for m in VIDEO.finditer(fh.read())))
        if found:
            hits[rel] = found
    return hits


def run_stop(payload):
    hits = scan_repo()
    if not hits:
        return 0
    listing = "; ".join(f"{rel}: {', '.join(links)}" for rel, links in sorted(hits.items()))
    if payload.get("stop_hook_active"):
        # Already sent Claude back once this turn; warn the user instead of looping.
        print(json.dumps({"systemMessage": f"Raw YouTube video links still present: {listing}"}))
        return 0
    print(json.dumps({
        "decision": "block",
        "reason": f"Raw YouTube video links found in student-facing files: {listing}. {FIX} "
                  "Fix them (and rebuild any deck whose .tex changed) before finishing.",
    }))
    return 0


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    raw = sys.stdin.read()
    payload = json.loads(raw) if raw.strip() else {}
    if mode == "pre":
        return run_pre(payload)
    if mode == "stop":
        return run_stop(payload)
    print(f"check-video-links.py: unknown mode {mode!r} (use pre or stop)", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
