#!/usr/bin/env bash
# Client-side Phase 3 evidence-rule checks. Does not launch graded model runners.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { echo "OK: $*"; }
warn() { echo "WARN: $*"; }

echo "== Phase 3 lab evidence rules =="
echo "repo=$ROOT"

# 1) Still no active evidence index / Unattended views (Phase 7 only)
shopt -s nullglob
active_shipping=(qualifications/*__shipping.json)
[[ ${#active_shipping[@]} -eq 0 ]] || fail "active shipping JSON present: ${active_shipping[*]}"
[[ ! -e qualifications/manifest.json ]] || fail "active manifest present"
rg -n 'DISABLED|disabled' notes/OPS_TRUST.md >/dev/null || fail "OPS_TRUST not disabled"
ok "no active evidence index; OPS_TRUST remains disabled"

# 2) Shipping invariants off; oracle/debug reserved
python3 - <<'PY'
import sys
from pathlib import Path
try:
    import yaml
except ImportError:
    # Minimal YAML subset reader for this manifest shape
    yaml = None

text = Path("scenarios/ikigai-dot/scenario.yml").read_text()
# Lightweight parse without PyYAML dependency
def profile_flag(name, key):
    in_profile = False
    for line in text.splitlines():
        if line.startswith("  " + name + ":"):
            in_profile = True
            continue
        if in_profile:
            if line.startswith("  ") and not line.startswith("    ") and line.strip().endswith(":"):
                break
            if line.strip().startswith(key + ":"):
                return line.split(":", 1)[1].strip()
    return None

ship = profile_flag("shipping", "include_invariant")
meas = profile_flag("measurement", "include_invariant")
oracle = profile_flag("oracle", "include_invariant")
debug = profile_flag("debug", "include_invariant")
errors = []
if ship != "false":
    errors.append(f"shipping.include_invariant expected false, got {ship!r}")
if meas != "false":
    errors.append(f"measurement.include_invariant expected false, got {meas!r}")
if oracle != "true":
    errors.append(f"oracle.include_invariant expected true, got {oracle!r}")
if debug != "true":
    errors.append(f"debug.include_invariant expected true, got {debug!r}")
# invariant.md must still exist for oracle/debug
inv = list(Path("scenarios/ikigai-dot/tasks").glob("*/invariant.md"))
if len(inv) < 1:
    errors.append("expected invariant.md files retained for oracle/debug")
if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"profiles_ok invariants_on_disk={len(inv)}")
PY
ok "shipping/measurement omit invariants; oracle/debug retain them"

# 3) Held-out fixtures present, hashed, agent_visible=false
[[ -f scenarios/ikigai-dot/held_out/fixture_set.yml ]] || fail "missing held_out/fixture_set.yml"
[[ -d scenarios/ikigai-dot/held_out/cases ]] || fail "missing held_out/cases"
python3 scripts/lib/content_hash.py scenario "$ROOT" ikigai-dot >/tmp/ikigai-hash.json
python3 - <<'PY'
import json, sys
from pathlib import Path
meta = json.loads(Path("/tmp/ikigai-hash.json").read_text())
fx = Path("scenarios/ikigai-dot/held_out/fixture_set.yml").read_text()
declared = None
for line in fx.splitlines():
    if line.startswith("fixture_set_hash:"):
        declared = line.split(":", 1)[1].strip()
if not meta.get("fixture_set_hash"):
    print("missing recomputed fixture_set_hash"); sys.exit(1)
if declared != meta["fixture_set_hash"]:
    print(f"fixture_set_hash mismatch declared={declared} recomputed={meta['fixture_set_hash']}")
    sys.exit(1)
if "agent_visible: false" not in fx:
    print("fixture_set.yml must declare agent_visible: false"); sys.exit(1)
cases = list(Path("scenarios/ikigai-dot/held_out/cases").rglob("case-*.yml"))
if len(cases) < 5:
    print(f"expected >=5 held-out cases, found {len(cases)}"); sys.exit(1)
for path in cases:
    body = path.read_text()
    if "agent_visible: false" not in body:
        print(f"{path} missing agent_visible: false"); sys.exit(1)
print(f"held_out_ok cases={len(cases)} fixture_set_hash={declared} scenario_hash={meta['scenario_hash']}")
PY
ok "held-out fixtures hashed and marked agent_visible=false"

# 4) Baseline process present; matching pair required for promote (warn if absent)
[[ -f baselines/README.md ]] || fail "missing baselines/README.md"
[[ -x scripts/record-scenario-baselines.sh ]] || fail "record-scenario-baselines.sh not executable"
shopt -s nullglob
oracle_arts=(baselines/ikigai-dot/oracle-pass__*.json)
nop_arts=(baselines/ikigai-dot/nop-fail__*.json)
if [[ ${#oracle_arts[@]} -eq 0 || ${#nop_arts[@]} -eq 0 ]]; then
  warn "no recorded oracle/nop baseline pair yet — run scripts/record-scenario-baselines.sh ikigai-dot"
  warn "Phase 7 promote must fail closed until a matching observed_ok pair exists"
else
  python3 - <<'PY'
import json, sys
from pathlib import Path
oracles = sorted(Path("baselines/ikigai-dot").glob("oracle-pass__*.json"))
nops = sorted(Path("baselines/ikigai-dot").glob("nop-fail__*.json"))
# Require at least one hash-aligned pair
pairs = 0
ok_pairs = 0
for o in oracles:
    key = o.name.removeprefix("oracle-pass__")
    n = Path("baselines/ikigai-dot") / f"nop-fail__{key}"
    if not n.is_file():
        continue
    pairs += 1
    od = json.loads(o.read_text()); nd = json.loads(n.read_text())
    if od.get("scenario_hash") != nd.get("scenario_hash"):
        print(f"pair hash mismatch {o.name}"); sys.exit(1)
    if od.get("harness_rev") != nd.get("harness_rev"):
        print(f"pair harness mismatch {o.name}"); sys.exit(1)
    if od.get("observed_ok") and nd.get("observed_ok"):
        ok_pairs += 1
if pairs == 0:
    print("oracle/nop filenames present but no matching scenario_hash__harness key pair"); sys.exit(1)
print(f"baseline_pairs={pairs} observed_ok_pairs={ok_pairs}")
if ok_pairs == 0:
    print("WARN: no pair with observed_ok=true on both controls — not promotable")
PY
  ok "baseline artifact pair(s) present for ikigai-dot"
fi

# 5) Watchtower-only graded runs still documented
rg -n 'Watchtower' qualifications/README.md baselines/README.md >/dev/null \
  || fail "Watchtower Job-only invariant missing from evidence docs"
ok "Watchtower Job-only graded-run boundary documented"

ok "Phase 3 evidence-rule validation passed"
