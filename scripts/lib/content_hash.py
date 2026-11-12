#!/usr/bin/env python3
"""Content-addressed tree hashes for alpha-lab Phase 3 evidence rules."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path


def sha256_path_bytes(root: Path, *, exclude_parts: set[str] | None = None) -> tuple[str, list[str]]:
    exclude_parts = exclude_parts or set()
    files = sorted(
        p
        for p in root.rglob("*")
        if p.is_file() and not any(part in exclude_parts for part in p.parts)
    )
    digest = hashlib.sha256()
    rels: list[str] = []
    for path in files:
        rel = path.relative_to(root).as_posix()
        rels.append(rel)
        digest.update(rel.encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest(), rels


def scenario_hash(lab_root: Path, scenario_id: str) -> dict:
    scenario_root = lab_root / "scenarios" / scenario_id
    if not scenario_root.is_dir():
        raise SystemExit(f"scenario not found: {scenario_root}")
    digest, files = sha256_path_bytes(scenario_root, exclude_parts={"held_out"})
    held = scenario_root / "held_out" / "fixture_set.yml"
    fixture_set_hash = None
    if held.is_file():
        # Prefer declared hash; verify it matches recomputation excluding the manifest itself.
        text = held.read_text()
        for line in text.splitlines():
            if line.startswith("fixture_set_hash:"):
                fixture_set_hash = line.split(":", 1)[1].strip()
                break
        recomputed, _ = sha256_path_bytes(
            scenario_root / "held_out",
            exclude_parts=set(),
        )
        # Recompute excluding fixture_set.yml
        digest_h = hashlib.sha256()
        held_root = scenario_root / "held_out"
        for path in sorted(p for p in held_root.rglob("*") if p.is_file() and p.name != "fixture_set.yml"):
            rel = path.relative_to(held_root).as_posix()
            digest_h.update(rel.encode())
            digest_h.update(b"\0")
            digest_h.update(path.read_bytes())
            digest_h.update(b"\0")
        recomputed = digest_h.hexdigest()
        if fixture_set_hash and fixture_set_hash != recomputed:
            raise SystemExit(
                f"fixture_set_hash mismatch: declared={fixture_set_hash} recomputed={recomputed}"
            )
        fixture_set_hash = recomputed
    return {
        "algorithm": "sha256-path-bytes-v1",
        "scenario_id": scenario_id,
        "scenario_hash": digest,
        "scenario_file_count": len(files),
        "fixture_set_hash": fixture_set_hash,
    }


def main(argv: list[str]) -> int:
    if len(argv) < 3 or argv[1] != "scenario":
        print("usage: content_hash.py scenario <lab_root> <scenario_id>", file=sys.stderr)
        return 2
    lab_root = Path(argv[2]).resolve()
    scenario_id = argv[3]
    print(json.dumps(scenario_hash(lab_root, scenario_id), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
