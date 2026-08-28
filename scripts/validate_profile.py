#!/usr/bin/env python3
"""Validate the minimal versioned research-tools profile schema."""
import pathlib
import sys

TOP_LEVEL_FIELDS = {
    "profile_version", "knowledge_root", "hot_file", "operation_log_file",
    "decision_log_file", "wiki_followup_destination", "artifact_followup_destination",
}


def fail(message):
    print(f"profile invalid: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse(path):
    lines = path.read_text().splitlines()
    if not lines or lines[0] != "---":
        fail("missing YAML frontmatter")
    values = {}
    for line in lines[1:]:
        if line == "---":
            return values
        if not line:
            continue
        if line.startswith(" "):
            fail("nested profile fields are not supported")
        if ":" not in line:
            fail("invalid profile field")
        key, value = line.split(":", 1)
        key = key.strip()
        if key not in TOP_LEVEL_FIELDS:
            fail(f"unsupported profile field: {key}")
        if key in values:
            fail(f"duplicate profile field: {key}")
        values[key] = value.strip()
    fail("unterminated YAML frontmatter")


def contained(root, candidate, label):
    resolved = candidate.resolve()
    try:
        resolved.relative_to(root)
    except ValueError:
        fail(f"{label} escapes knowledge_root")
    if not resolved.is_dir():
        fail(f"{label} is not an existing directory")
    return resolved


def contained_file(root, value, label):
    if not value:
        fail(f"missing {label}")
    candidate = pathlib.Path(value)
    if candidate.is_absolute():
        fail(f"{label} must be relative to knowledge_root")
    resolved = (root / candidate).resolve()
    try:
        resolved.relative_to(root)
    except ValueError:
        fail(f"{label} escapes knowledge_root")
    if not resolved.is_file():
        fail(f"{label} is not an existing file")
    return resolved


def main():
    if len(sys.argv) != 2:
        fail("usage: validate_profile.py PROFILE")
    values = parse(pathlib.Path(sys.argv[1]))
    if values.get("profile_version") != "4":
        fail("profile_version must be 4")
    root_value = values.get("knowledge_root")
    if not root_value or not pathlib.Path(root_value).is_absolute():
        fail("knowledge_root must be an absolute path")
    root = pathlib.Path(root_value).resolve()
    if not root.is_dir():
        fail("knowledge_root is not an existing directory")
    for key in ("raw", "wiki", "output", "docs"):
        contained(root, root / key, key)
    for key in ("hot_file", "operation_log_file", "decision_log_file"):
        contained_file(root, values.get(key), key)
    for key in ("wiki_followup_destination", "artifact_followup_destination"):
        if not values.get(key):
            fail(f"missing {key}")
    print(root)


if __name__ == "__main__":
    main()
