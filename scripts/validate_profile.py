#!/usr/bin/env python3
"""Validate the minimal versioned research-tools profile schema."""
import pathlib
import sys

TOP_LEVEL_FIELDS = {
    "profile_version", "knowledge_root", "raw_dir", "wiki_dir", "output_dir",
    "docs_dir", "capabilities",
}
CAPABILITIES = {"firecrawl", "apple_speech"}


def fail(message):
    print(f"profile invalid: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse(path):
    lines = path.read_text().splitlines()
    if not lines or lines[0] != "---":
        fail("missing YAML frontmatter")
    values = {}
    capabilities = {}
    in_capabilities = False
    for line in lines[1:]:
        if line == "---":
            return values, capabilities
        if not line:
            continue
        if line.startswith(" "):
            if not in_capabilities or not line.startswith("  ") or ":" not in line:
                fail("invalid nested profile field")
            key, value = line.strip().split(":", 1)
            if key not in CAPABILITIES:
                fail(f"unsupported capability: {key}")
            if key in capabilities:
                fail(f"duplicate capability: {key}")
            if value.strip() not in ("true", "false"):
                fail(f"capability {key} must be true or false")
            capabilities[key] = value.strip() == "true"
            continue
        if ":" not in line:
            fail("invalid profile field")
        key, value = line.split(":", 1)
        key = key.strip()
        if key not in TOP_LEVEL_FIELDS:
            fail(f"unsupported profile field: {key}")
        if key in values:
            fail(f"duplicate profile field: {key}")
        if key == "capabilities":
            if value.strip():
                fail("capabilities must be a mapping")
            in_capabilities = True
            values[key] = None
            continue
        in_capabilities = False
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


def main():
    if len(sys.argv) != 2:
        fail("usage: validate_profile.py PROFILE")
    values, capabilities = parse(pathlib.Path(sys.argv[1]))
    if values.get("profile_version") != "1":
        fail("profile_version must be 1")
    root_value = values.get("knowledge_root")
    if not root_value or not pathlib.Path(root_value).is_absolute():
        fail("knowledge_root must be an absolute path")
    root = pathlib.Path(root_value).resolve()
    if not root.is_dir():
        fail("knowledge_root is not an existing directory")
    if set(capabilities) != CAPABILITIES:
        fail("capabilities must declare firecrawl and apple_speech")
    for key, default in (("raw_dir", "raw"), ("wiki_dir", "wiki"),
                         ("output_dir", "output"), ("docs_dir", "docs")):
        value = values.get(key, default)
        child = pathlib.Path(value)
        if child.is_absolute():
            fail(f"{key} must be relative to knowledge_root")
        contained(root, root / child, key)
    print(root)


if __name__ == "__main__":
    main()
