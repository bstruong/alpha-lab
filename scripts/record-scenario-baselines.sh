#!/usr/bin/env bash
# Record oracle-pass + nop-fail baseline artifacts for a lab scenario.
# Zero-model integrity controls only. Does not invent green results.
# Prefer Watchtower Jobs for graded model evidence; this script may run on a
# launch client as a diagnostic when Alpha is available locally.
set -euo pipefail

SCENARIO_ID="${1:-ikigai-dot}"
LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ALPHA_REPO="${ALPHA_REPO:-/home/brian/Projects/alpha}"
OUT_DIR="${LAB_ROOT}/baselines/${SCENARIO_ID}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

[[ -d "$ALPHA_REPO" ]] || { echo "FAIL: ALPHA_REPO not found: $ALPHA_REPO" >&2; exit 1; }
[[ -d "$LAB_ROOT/scenarios/$SCENARIO_ID" ]] || { echo "FAIL: scenario missing" >&2; exit 1; }

HASH_JSON="$(python3 "$LAB_ROOT/scripts/lib/content_hash.py" scenario "$LAB_ROOT" "$SCENARIO_ID")"
SCENARIO_HASH="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["scenario_hash"])' <<<"$HASH_JSON")"
FIXTURE_HASH="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("fixture_set_hash") or "")' <<<"$HASH_JSON")"

HARNESS_REV="$(git -C "$ALPHA_REPO" rev-parse HEAD)"
if [[ -n "$(git -C "$ALPHA_REPO" status --porcelain)" ]]; then
  HARNESS_DIRTY=true
else
  HARNESS_DIRTY=false
fi

mkdir -p "$OUT_DIR"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/alpha-lab-baselines.XXXXXX")"
# Ephemeral ALPHA_ROOT so diagnostic runs do not pollute lab reports/.
ALPHA_ROOT_TMP="$WORKDIR/alpha-root"
mkdir -p "$ALPHA_ROOT_TMP/results" "$ALPHA_ROOT_TMP/reports" "$ALPHA_ROOT_TMP/qualifications"
ln -s "$LAB_ROOT/scenarios" "$ALPHA_ROOT_TMP/scenarios"
trap 'rm -rf "$WORKDIR"' EXIT

echo "== Recording baselines for ${SCENARIO_ID} =="
echo "lab_root=$LAB_ROOT"
echo "scenario_hash=$SCENARIO_HASH"
echo "fixture_set_hash=${FIXTURE_HASH:-none}"
echo "harness_rev=$HARNESS_REV dirty=$HARNESS_DIRTY"
echo "ephemeral_alpha_root=$ALPHA_ROOT_TMP"

run_alpha() {
  local logfile="$1"; shift
  (
    cd "$ALPHA_REPO"
    export ALPHA_ROOT="$ALPHA_ROOT_TMP"
    set +e
    mise exec -- bin/alpha "$@" >"$logfile" 2>&1
    echo $? >"${logfile}.exit"
    set -e
  )
}

ORACLE_LOG="$WORKDIR/oracle.log"
NOP_LOG="$WORKDIR/nop.log"

run_alpha "$ORACLE_LOG" oracle --scenario "$SCENARIO_ID"
ORACLE_EXIT="$(cat "${ORACLE_LOG}.exit")"
run_alpha "$NOP_LOG" run --scenario "$SCENARIO_ID" --executor nop --no-gate-halt --profile shipping
NOP_EXIT="$(cat "${NOP_LOG}.exit")"

python3 - "$OUT_DIR" "$SCENARIO_ID" "$SCENARIO_HASH" "$FIXTURE_HASH" "$HARNESS_REV" "$HARNESS_DIRTY" \
  "$ORACLE_EXIT" "$NOP_EXIT" "$ORACLE_LOG" "$NOP_LOG" "$STAMP" "$ALPHA_REPO" <<'PY'
import json, pathlib, re, sys, hashlib

(
    out_dir, scenario_id, scenario_hash, fixture_hash, harness_rev, harness_dirty,
    oracle_exit, nop_exit, oracle_log, nop_log, stamp, alpha_repo
) = sys.argv[1:]

out = pathlib.Path(out_dir)
oracle_text = pathlib.Path(oracle_log).read_text(errors="replace")
nop_text = pathlib.Path(nop_log).read_text(errors="replace")

def summarize_oracle(text: str) -> dict:
    marked_pass = len(re.findall(r"✓ PASS", text))
    marked_fail = len(re.findall(r"✗ FAIL", text))
    lines = [ln for ln in text.splitlines() if ("PASS" in ln or "FAIL" in ln)]
    return {
        "task_lines": lines[-20:],
        "pass_count": marked_pass,
        "fail_count": marked_fail,
        "log_sha256": hashlib.sha256(text.encode()).hexdigest(),
    }

def summarize_nop(text: str) -> dict:
    m = re.search(r"First-attempt success:\s*([0-9.]+)\s*\((\d+)/(\d+)\)", text)
    aggregate = None
    if m:
        aggregate = {
            "pass_at_1": float(m.group(1)),
            "tasks_passed": int(m.group(2)),
            "tasks_total": int(m.group(3)),
        }
    return {
        "aggregate": aggregate,
        "pass_count": len(re.findall(r"✓ PASS", text)),
        "fail_count": len(re.findall(r"✗ FAIL", text)),
        "log_sha256": hashlib.sha256(text.encode()).hexdigest(),
        "tail": text.splitlines()[-40:],
    }

oracle_summary = summarize_oracle(oracle_text)
nop_summary = summarize_nop(nop_text)
oracle_ok = int(oracle_exit) == 0 and oracle_summary["fail_count"] == 0 and oracle_summary["pass_count"] > 0
# Empty agent must receive no credit. For openai_chat_completions JSON tasks,
# current Alpha TrialOutcome may mark missing output.txt as infrastructure_invalid
# instead of a scored fail when exit_reason=nop — still not a model pass.
nop_no_pass = nop_summary["pass_count"] == 0
agg = nop_summary.get("aggregate") or {}
scored_total = int(agg.get("tasks_total") or 0)
scored_passed = int(agg.get("tasks_passed") or 0)
infra_invalid = "infrastructure_invalid" in nop_text
all_invalid_markers = (
    len(re.findall(r"⚠ INVALID", nop_text)) > 0
    and nop_summary["fail_count"] == 0
    and nop_no_pass
)
nop_failed_as_expected = nop_no_pass and scored_passed == 0 and (
    (scored_total > 0 and nop_summary["fail_count"] >= scored_total)
    or (infra_invalid and all_invalid_markers)
)

key = f"{scenario_hash}__{harness_rev[:12]}"
common = {
    "schema": "alpha.baseline.v1",
    "scenario_id": scenario_id,
    "scenario_hash": scenario_hash,
    "fixture_set_hash": fixture_hash or None,
    "harness_repo": str(pathlib.Path(alpha_repo).resolve()),
    "harness_rev": harness_rev,
    "harness_dirty": harness_dirty == "true",
    "recorded_at": stamp,
    "promotable": harness_dirty != "true",
    "note": (
        "Integrity baseline only. Phase 7 promote requires matching hashes, "
        "observed_ok=true on both controls, clean harness_rev, and Watchtower Job evidence."
    ),
}

oracle_path = out / f"oracle-pass__{key}.json"
nop_path = out / f"nop-fail__{key}.json"

oracle_doc = {
    **common,
    "control": "oracle-pass",
    "command": ["bin/alpha", "oracle", "--scenario", scenario_id],
    "exit_code": int(oracle_exit),
    "expected": "all tasks pass",
    "observed_ok": oracle_ok,
    "summary": oracle_summary,
}
nop_doc = {
    **common,
    "control": "nop-fail",
    "command": [
        "bin/alpha", "run", "--scenario", scenario_id,
        "--executor", "nop", "--no-gate-halt", "--profile", "shipping",
    ],
    "exit_code": int(nop_exit),
    "expected": "empty nop agent receives no graded credit (scored fails or nop-induced invalid trials)",
    "observed_ok": nop_failed_as_expected,
    "summary": nop_summary,
    "alpha_followup": (
        "Prefer TrialOutcome to treat exit_reason=nop + missing output as scored fail, "
        "not infrastructure_invalid."
    ),
}

oracle_path.write_text(json.dumps(oracle_doc, indent=2, sort_keys=True) + "\n")
nop_path.write_text(json.dumps(nop_doc, indent=2, sort_keys=True) + "\n")
(out / f"oracle-pass__{key}.log").write_text(oracle_text)
(out / f"nop-fail__{key}.log").write_text(nop_text)

print(json.dumps({
    "oracle_artifact": str(oracle_path),
    "nop_artifact": str(nop_path),
    "oracle_observed_ok": oracle_ok,
    "nop_observed_ok": nop_failed_as_expected,
    "harness_dirty": harness_dirty == "true",
}, indent=2))

rc = 0
if not oracle_ok:
    print("FAIL: oracle did not fully pass; artifact recorded with observed_ok=false", file=sys.stderr)
    rc = 1
if not nop_failed_as_expected:
    print("FAIL: nop did not fail all graded tasks; artifact recorded with observed_ok=false", file=sys.stderr)
    rc = 1
if harness_dirty == "true":
    print("WARN: harness tree dirty — artifacts marked promotable=false", file=sys.stderr)
raise SystemExit(rc)
PY
