#!/usr/bin/env python3
"""Render an outcome-first Markdown report from a sanitized alpha.report.v2 summary.

Scaffolding for Phase 7. Does not qualify models, enable Unattended, or talk to
the cluster. Puts hashes / leases / K8s details under Supporting evidence.

Usage:
  ./scripts/render-outcome-report.py path/to/summary.json > report.md
  ./scripts/render-outcome-report.py --fixture scripts/fixtures/sample-summary.json
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

PROTOCOL_ID = "alpha-lab.held_out.first_attempt"
PROTOCOL_VERSION = "1.0.0"


def wilson_interval(successes: int, total: int, z: float = 1.959963984540054) -> tuple[float, float] | None:
    """Two-sided Wilson score interval; returns None when total == 0."""
    if total <= 0:
        return None
    n = float(total)
    p = successes / n
    z2 = z * z
    denom = 1.0 + z2 / n
    center = (p + z2 / (2.0 * n)) / denom
    half = (z / denom) * math.sqrt((p * (1.0 - p) / n) + (z2 / (4.0 * n * n)))
    return max(0.0, center - half), min(1.0, center + half)


def truthy_pass(value) -> bool:
    return value is True or value == 1 or value == 1.0


def partition_tasks(tasks: list[dict]) -> tuple[list[str], list[str], list[str]]:
    can_do, cannot, not_eval = [], [], []
    by_name: dict[str, list[dict]] = {}
    for t in tasks:
        by_name.setdefault(str(t.get("name")), []).append(t)

    for name, rows in sorted(by_name.items()):
        invalid = [r for r in rows if r.get("invalid") is True or r.get("scored") is False]
        scored = [r for r in rows if r not in invalid]
        if not scored:
            reason = invalid[0].get("invalid_reason") if invalid else "not scored"
            not_eval.append(f"`{name}`: {reason or 'not scored'}")
            continue
        passed = sum(1 for r in scored if truthy_pass(r.get("pass_at_1")))
        total = len(scored)
        if passed == total and total > 0:
            can_do.append(f"`{name}`: {passed}/{total} passed")
        else:
            failures = sorted(
                {
                    str(r.get("failure_class") or "unknown")
                    for r in scored
                    if not truthy_pass(r.get("pass_at_1"))
                }
            )
            cannot.append(
                f"`{name}`: {passed}/{total} passed\n  Observed failures: {', '.join(failures)}"
            )
    return can_do, cannot, not_eval


def coverage_and_reliability(tasks: list[dict]) -> tuple[list[str], list[str]]:
    coverage, reliability = [], []
    by_name: dict[str, list[dict]] = {}
    for t in tasks:
        by_name.setdefault(str(t.get("name")), []).append(t)
    for name, rows in sorted(by_name.items()):
        scored = [r for r in rows if r.get("invalid") is not True and r.get("scored") is not False]
        if not scored:
            coverage.append(f"`{name}`: not evaluated")
            continue
        coverage.append(f"`{name}`: attempted ({len(scored)} scored trial(s))")
        passed = sum(1 for r in scored if truthy_pass(r.get("pass_at_1")))
        total = len(scored)
        interval = wilson_interval(passed, total)
        if interval is None:
            band = "n/a"
        else:
            lo, hi = interval
            band = f"Wilson 95% [{lo:.3f}, {hi:.3f}]"
        seeds = sorted({r.get("seed") for r in scored if r.get("seed") is not None})
        reliability.append(
            f"`{name}`: {passed}/{total} first-attempt; {band}; seeds={seeds or 'undeclared'}"
        )
    return coverage, reliability


def render(summary: dict, *, unattended_enabled: bool = False) -> str:
    agg = summary.get("aggregate") or {}
    status = summary.get("status") or {}
    provenance = summary.get("provenance") or {}
    tasks = list(summary.get("tasks") or [])
    can_do, cannot, not_eval = partition_tasks(tasks)
    coverage, reliability = coverage_and_reliability(tasks)

    model_bits = [
        summary.get("model_id"),
        (provenance.get("model") or {}).get("quantization"),
        (provenance.get("model") or {}).get("model_sha256"),
    ]
    model_identity = " / ".join(str(x) for x in model_bits if x)

    n = int(agg.get("pass_at_1_numerator") or agg.get("tasks_passed") or 0)
    d = int(agg.get("pass_at_1_denominator") or agg.get("tasks_total") or 0)
    interval = wilson_interval(n, d)
    if interval is None:
        uncertainty = "not evaluated (denominator 0)"
    else:
        lo, hi = interval
        uncertainty = (
            f"Wilson score interval 95% two-sided [{lo:.3f}, {hi:.3f}] "
            f"on observed {n}/{d}; never interpret a 1.0 point estimate as certainty"
        )

    lines: list[str] = []
    lines.append(f"# Alpha Evaluation Report: {summary.get('run_id')}")
    lines.append("")
    lines.append(f"Model: `{model_identity or summary.get('model_id')}`")
    lines.append(
        f"Evaluated for: `{summary.get('scenario')}` / `{summary.get('prompt_preset')}` "
        f"/ protocol `{PROTOCOL_ID}@{PROTOCOL_VERSION}`"
    )
    lines.append("")
    lines.append("## Can do")
    lines.extend([f"- {row}" for row in can_do] or ["- _(none)_"])
    lines.append("")
    lines.append("## Cannot reliably do")
    if cannot:
        for row in cannot:
            for part in row.split("\n"):
                lines.append(f"- {part}" if not part.startswith("  ") else part)
    else:
        lines.append("- _(none)_")
    lines.append("")
    lines.append("## Not evaluated")
    lines.extend([f"- {row}" for row in not_eval] or ["- _(none)_"])
    lines.append("")
    lines.append("## Delegation decision")
    if unattended_enabled:
        lines.append("- Unattended: see active evidence index (must meet every protocol criterion)")
    else:
        lines.append(
            "- Unattended: none (protocol `unattended_enabled=false`; "
            "no active evidence index)"
        )
    lines.append("- Review required: all scored tasks pending fresh held-out promote")
    lines.append("- Do not delegate: tasks with critical semantic/safety failures (if any)")
    lines.append("")
    lines.append("## Evidence limits")
    lines.append(
        f"- Valid trials: {d}; invalid trials: {agg.get('invalid_trials', 0)}"
    )
    lines.append(f"- Uncertainty: {uncertainty}")
    runner = (provenance.get("runner") or {}).get("image_digest") or "—"
    jarvis = (provenance.get("jarvis") or {}).get("image_digest") or "—"
    lines.append(f"- Runtime identity: runner=`{runner}` · jarvis=`{jarvis}`")
    lines.append(
        "- Evidence expires when: model/runtime/source/fixture/protocol hashes change, "
        "or qualification TTL elapses"
    )
    lines.append(
        "- Coverage vs reliability: see Supporting evidence "
        "(coverage = attempted; reliability = repeated-trial N/D + Wilson)"
    )
    lines.append(
        "- Observed success only — never claim 100% confidence or certainty "
        f"(statistical_sufficiency={status.get('statistical_sufficiency') or 'not_evaluated'})"
    )
    lines.append("")
    lines.append("## Supporting evidence")
    lines.append("")
    lines.append("### Task coverage")
    lines.extend([f"- {row}" for row in coverage] or ["- _(none)_"])
    lines.append("")
    lines.append("### Repeated-trial reliability")
    lines.extend([f"- {row}" for row in reliability] or ["- _(none)_"])
    lines.append("")
    lines.append("### Metrics")
    lines.append("")
    lines.append("| Metric | Value |")
    lines.append("|---|---|")
    lines.append(
        f"| First-attempt success | {agg.get('pass_at_1')} ({n}/{d}) |"
    )
    lines.append(f"| Execution health | {status.get('execution_health') or '—'} |")
    lines.append(f"| Gate status | {status.get('gate_status') or '—'} |")
    lines.append(f"| Benchmark verdict | {status.get('benchmark_verdict') or '—'} |")
    lines.append(
        f"| Statistical sufficiency | {status.get('statistical_sufficiency') or '—'} |"
    )
    lines.append(
        f"| Meets delegation policy | "
        f"{'eligible evidence' if summary.get('qualification_eligible') else 'no'} |"
    )
    lines.append(f"| Promotable | {'yes' if summary.get('promotable') else 'no'} |")
    lines.append(
        f"| Routing authority | {status.get('routing_authority') or 'none'} |"
    )
    lines.append("")
    lines.append("### Provenance, Lease, and Kubernetes")
    repos = provenance.get("repositories") or {}
    lease = provenance.get("lease") or {}
    graded = provenance.get("graded_host") or {}
    lines.append(
        f"- Commits: alpha=`{(repos.get('alpha') or {}).get('commit') or '—'}` "
        f"alpha-lab=`{(repos.get('alpha_lab') or {}).get('commit') or '—'}` "
        f"homelab=`{(repos.get('homelab_k3s') or {}).get('commit') or '—'}`"
    )
    content = provenance.get("content") or {}
    lines.append(
        f"- Content hashes: scenario=`{content.get('scenario_hash') or '—'}` "
        f"fixture_set=`{content.get('fixture_set_hash') or '—'}`"
    )
    lines.append(
        f"- Lease: holder=`{lease.get('holder') or '—'}` "
        f"run_id=`{lease.get('run_id') or '—'}`"
    )
    lines.append(
        f"- Kubernetes Job: `{graded.get('job_name') or graded.get('watchtower_job') or '—'}` "
        "(graded suites are Watchtower Job-only)"
    )
    lines.append(
        f"- Run manifest: `{summary.get('run_manifest_uri') or '—'}`"
    )
    lines.append("")
    lines.append("---")
    lines.append(
        "*Rendered by alpha-lab `scripts/render-outcome-report.py` "
        f"({PROTOCOL_ID}@{PROTOCOL_VERSION})*"
    )
    lines.append("")
    return "\n".join(lines)


def load_protocol_unattended_flag(lab_root: Path) -> bool:
    path = lab_root / "schemas" / "statistical-protocol.v1.yml"
    if not path.is_file():
        return False
    for line in path.read_text().splitlines():
        if line.startswith("unattended_enabled:"):
            return line.split(":", 1)[1].strip().lower() == "true"
    return False


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("summary", nargs="?", help="Path to alpha.report.v2 summary.json")
    parser.add_argument("--fixture", help="Use a checked-in sample summary")
    parser.add_argument(
        "--lab-root",
        default=str(Path(__file__).resolve().parents[1]),
        help="alpha-lab root (for protocol unattended_enabled flag)",
    )
    args = parser.parse_args(argv)
    path = Path(args.fixture or args.summary or "")
    if not path.is_file():
        print("usage: render-outcome-report.py <summary.json> | --fixture <path>", file=sys.stderr)
        return 2
    summary = json.loads(path.read_text())
    if summary.get("schema") != "alpha.report.v2":
        print(f"unexpected schema: {summary.get('schema')!r}", file=sys.stderr)
        return 1
    enabled = load_protocol_unattended_flag(Path(args.lab_root))
    sys.stdout.write(render(summary, unattended_enabled=enabled))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
