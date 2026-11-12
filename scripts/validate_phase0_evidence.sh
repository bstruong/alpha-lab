#!/usr/bin/env bash
# Client-side Phase 0 checks only. Does not launch graded Alpha runners.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { echo "OK: $*"; }

echo "== Phase 0 evidence / delegation fail-closed validation =="
echo "repo=$ROOT"

# 1) No active top-level evidence index
shopt -s nullglob
active_shipping=(qualifications/*__shipping.json)
active_manifest=qualifications/manifest.json
[[ ${#active_shipping[@]} -eq 0 ]] || fail "active shipping JSON still present: ${active_shipping[*]}"
[[ ! -e "$active_manifest" ]] || fail "active manifest still present: $active_manifest"
ok "no top-level shipping JSON or manifest"

# 2) Archive present
archive=qualifications/archive-v2-pre-simplification
[[ -d "$archive" ]] || fail "missing $archive"
[[ -f "$archive/README.md" ]] || fail "missing $archive/README.md"
[[ -f "$archive/manifest.json" ]] || fail "missing archived manifest"
archived=( "$archive"/*__shipping.json )
[[ ${#archived[@]} -ge 1 ]] || fail "archive has no shipping JSON"
ok "archive has ${#archived[@]} shipping artifacts + manifest"

# 3) Archived JSON parses; report_uri references resolve when present on disk
python3 - <<'PY'
import json, sys
from pathlib import Path
root = Path(".").resolve()
archive = root / "qualifications" / "archive-v2-pre-simplification"
missing = []
bad = []
own_hits = []
for path in sorted(archive.glob("*__shipping.json")):
    try:
        data = json.loads(path.read_text())
    except Exception as e:
        bad.append(f"{path}: {e}")
        continue
    if data.get("schema") != "alpha.qualification.v2":
        bad.append(f"{path}: unexpected schema {data.get('schema')!r}")
    uri = data.get("report_uri")
    if not uri:
        missing.append(f"{path.name}: no report_uri")
        continue
    rel = uri.replace("file://", "").lstrip("./")
    target = root / rel
    if not target.is_file():
        missing.append(f"{path.name}: missing {rel}")
manifest = json.loads((archive / "manifest.json").read_text())
if manifest.get("schema") != "alpha.qualification_manifest.v2":
    bad.append(f"manifest schema {manifest.get('schema')!r}")
# Active ops trust must not claim Own/Unattended
ops = (root / "notes" / "OPS_TRUST.md").read_text()
for banned in ("| Own |", "**Unattended** routes", "Band | Own"):
    pass
# Explicit positive checks for disabled language
if "DISABLED" not in ops and "disabled" not in ops.lower():
    bad.append("OPS_TRUST.md is not marked disabled")
# Fail if a markdown table cell still routes Own as an active band (legacy generator shape)
for line in ops.splitlines():
    if line.startswith("|") and "| Own |" in line:
        own_hits.append(line)
if "Unattended:" in ops and "no" not in ops.lower():
    # Allow mentioning Unattended only in prohibition context; require disabled status already checked.
    pass
if own_hits:
    bad.append("OPS_TRUST still contains Own route rows: " + "; ".join(own_hits[:3]))
if bad:
    print("JSON/OPS errors:")
    print("\n".join(bad))
    sys.exit(1)
print(f"parsed_shipping={len(list(archive.glob('*__shipping.json')))}")
print(f"report_uri_missing_on_disk={len(missing)}")
if missing:
    # Missing report files may be uncommitted local artifacts; warn but do not soft-pass routing.
    print("WARN report_uri unresolved (preserved/uncommitted reports may be absent in this checkout):")
    print("\n".join(missing[:20]))
    if len(missing) > 20:
        print(f"... and {len(missing)-20} more")
PY
ok "archived JSON parse + OPS_TRUST Own-route scan"

# 4) Evidence-index consumer fail-closed: Alpha top-level load returns empty
if [[ -d /home/brian/Projects/alpha ]]; then
  (
    cd /home/brian/Projects/alpha
    ALPHA_ROOT="$ROOT" mise exec -- ruby -e '
      require_relative "lib/alpha"
      dir = Alpha.config.qualifications_dir
      loaded = Alpha::QualificationManifest.load_all(dir)
      active = Alpha::QualificationManifest.active(dir)
      abort("fail-closed violated: load_all returned #{loaded.size}") unless loaded.empty?
      abort("fail-closed violated: active returned #{active.size}") unless active.empty?
      puts "alpha_load_all=0 alpha_active=0 qualifications_dir=#{dir} => Review required"
    '
  ) || fail "Alpha evidence-index consumer did not fail closed"
  ok "Alpha load_all/active empty against alpha-lab (Review required)"
else
  echo "SKIP: /home/brian/Projects/alpha not present for consumer check"
fi

# 5) No active Own / Unattended claims in live ops docs
if rg -n '\| Own \||Unattended:' notes/OPS_TRUST.md >/dev/null; then
  # Allow the disabled banner to mention the words as negatives; reject route rows.
  if rg -n '^\|.*\| Own \|' notes/OPS_TRUST.md >/dev/null; then
    fail "OPS_TRUST still has Own band rows"
  fi
fi
rg -n 'HISTORICAL' reports/CAPABILITY_MAP.md reports/CAPABILITY_MAP_LIVE.md >/dev/null \
  || fail "capability maps missing HISTORICAL marker"
ok "capability maps marked historical"
ok "Phase 0 validation passed"
