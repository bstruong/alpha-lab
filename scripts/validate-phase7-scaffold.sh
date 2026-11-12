#!/usr/bin/env bash
# Client-side Phase 7 scaffolding checks. Does not launch graded model runners,
# regenerate qualifications, or enable Unattended.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { echo "OK: $*"; }

echo "== Phase 7 scaffold validation =="
echo "repo=$ROOT"

# 1) Fail closed: still no active evidence index / Unattended enablement
shopt -s nullglob
active_shipping=(qualifications/*__shipping.json)
[[ ${#active_shipping[@]} -eq 0 ]] || fail "active shipping JSON present: ${active_shipping[*]}"
[[ ! -e qualifications/manifest.json ]] || fail "active manifest present"
rg -n 'unattended_enabled:\s*false' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "protocol must keep unattended_enabled: false during scaffolding"
rg -n 'DISABLED|disabled' notes/OPS_TRUST.md >/dev/null || fail "OPS_TRUST not disabled"
ok "active evidence index absent; Unattended disabled; OPS_TRUST disabled"

# 2) Versioned statistical protocol present
[[ -f schemas/statistical-protocol.v1.yml ]] || fail "missing schemas/statistical-protocol.v1.yml"
[[ -f docs/statistical-protocol.md ]] || fail "missing docs/statistical-protocol.md"
rg -n 'protocol_version:\s*"1\.0\.0"' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "protocol_version missing"
rg -n 'wilson_score_interval' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "uncertainty method missing"
rg -n 'min_effective_trials_unattended:\s*24' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "min sample size missing"
rg -n 'separate_coverage_from_reliability:\s*true' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "coverage/reliability separation missing"
rg -n 'max_attempts:\s*3' schemas/statistical-protocol.v1.yml >/dev/null \
  || fail "canonical rerun max_attempts missing"
rg -n '100% confidence|100% certainty' -i schemas/statistical-protocol.v1.yml docs/statistical-protocol.md \
  >/dev/null || fail "forbidden-certainty language list missing"
ok "statistical protocol v1.0.0 fields present"

# 3) Outcome-first docs + template
[[ -f docs/outcome-first-report.md ]] || fail "missing docs/outcome-first-report.md"
[[ -f docs/templates/model-capability-report.md ]] || fail "missing report template"
[[ -f docs/fresh-campaigns-after-deploy.md ]] || fail "missing fresh-campaigns runbook"
for section in "Can do" "Cannot reliably do" "Not evaluated" "Delegation decision" "Evidence limits" "Supporting evidence"; do
  rg -n "$section" docs/outcome-first-report.md docs/templates/model-capability-report.md >/dev/null \
    || fail "report docs missing section: $section"
done
ok "outcome-first report docs present"

# 4) Held-out parameterized fixtures + trial plan
[[ -f scenarios/ikigai-dot/held_out/trial_plan.yml ]] || fail "missing trial_plan.yml"
[[ -f scenarios/ikigai-dot/held_out/fixture_set.yml ]] || fail "missing fixture_set.yml"
python3 scripts/lib/content_hash.py scenario "$ROOT" ikigai-dot >/tmp/phase7-ikigai-hash.json
python3 - <<'PY'
import json, sys
from pathlib import Path
meta = json.loads(Path("/tmp/phase7-ikigai-hash.json").read_text())
fx = Path("scenarios/ikigai-dot/held_out/fixture_set.yml").read_text()
plan = Path("scenarios/ikigai-dot/held_out/trial_plan.yml").read_text()
declared = None
for line in fx.splitlines():
    if line.startswith("fixture_set_hash:"):
        declared = line.split(":", 1)[1].strip()
if declared != meta["fixture_set_hash"]:
    print(f"fixture_set_hash mismatch declared={declared} recomputed={meta['fixture_set_hash']}")
    sys.exit(1)
if "agent_visible: false" not in fx or "agent_visible: false" not in plan:
    print("held_out manifests must declare agent_visible: false"); sys.exit(1)
if "separates_coverage_from_reliability: true" not in fx:
    print("fixture_set must separate coverage from reliability"); sys.exit(1)
if "seeds:" not in plan or "instances:" not in plan:
    print("trial_plan must declare seeds and instances"); sys.exit(1)
cases = list(Path("scenarios/ikigai-dot/held_out/cases").rglob("case-*.yml"))
if len(cases) < 10:
    print(f"expected >=10 held-out cases (2 instances x 5 tasks), found {len(cases)}"); sys.exit(1)
for path in cases:
    body = path.read_text()
    if "agent_visible: false" not in body:
        print(f"{path} missing agent_visible: false"); sys.exit(1)
print(f"held_out_ok cases={len(cases)} fixture_set_hash={declared}")
PY
ok "held-out fixtures + seeds/instances hash-ok"

# 5) Outcome renderer scaffolding (offline sample; no GPU)
chmod +x scripts/render-outcome-report.py
out="$(mktemp)"
python3 scripts/render-outcome-report.py --fixture scripts/fixtures/sample-summary.json >"$out"
for section in "## Can do" "## Cannot reliably do" "## Not evaluated" "## Delegation decision" "## Evidence limits" "## Supporting evidence"; do
  rg -n -F "$section" "$out" >/dev/null || fail "renderer missing section: $section"
done
rg -n -F "Unattended: none" "$out" >/dev/null || fail "renderer must keep Unattended: none"
# Ban affirmative certainty claims; allow explicit "never claim …" wording.
if rg -n -i 'with 100% confidence|is 100% certain|proves zero future failures' "$out" >/dev/null; then
  fail "renderer must not claim certainty"
fi
rg -n -F "Supporting evidence" "$out" >/dev/null || fail "renderer missing Supporting evidence"
rg -n -F "Lease:" "$out" >/dev/null || fail "Lease belongs under Supporting evidence"
# Lead sections must appear before Supporting evidence
python3 - <<PY
from pathlib import Path
text = Path("$out").read_text()
lead = ["## Can do", "## Cannot reliably do", "## Not evaluated", "## Delegation decision", "## Evidence limits"]
support = text.index("## Supporting evidence")
for h in lead:
    i = text.index(h)
    if i > support:
        raise SystemExit(f"{h} must precede Supporting evidence")
print("section_order_ok")
PY
ok "outcome renderer leads with plain English; tech under Supporting evidence"

# 6) Fresh-campaign runbook mentions Watchtower Job + pinned digests + walk-away
rg -n 'alpha_watchtower_kick|Watchtower|sha256|walk-away|power off' docs/fresh-campaigns-after-deploy.md >/dev/null \
  || fail "fresh-campaigns runbook incomplete"
ok "fresh-campaigns-after-deploy runbook present"

echo
echo "Phase 7 scaffold validation PASSED"
echo "Blocked on merge/deploy of Phases 0–6 before live Watchtower campaigns or Unattended promote."
