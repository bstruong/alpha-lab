# alpha-lab

Personal **benchmark suite and campaign archive** for [Alpha](https://github.com/bstruong/alpha) (`alpha-eval` gem).

Alpha is the reusable evaluation **mechanism** (runner, graders, qualify, capability-map). This repo is the **lab**: sole owner of `scenarios/ikigai-dot`, immutable published evidence, held-out fixtures, and (after Phase 7) the active evidence index.

Inference wake/lease for the lab GPU stack lives in [homelab-k3s](https://github.com/bstruong/homelab-k3s). Graded suites run only as Watchtower campaign Jobs; laptops may submit/monitor, never host graded runners.

## Layout

```
scenarios/         # Lab-owned eval batteries (ikigai-dot sole owner)
  ikigai-dot/
    tasks/         # Prompt-visible shipping/measurement tasks
    held_out/      # Qualification fixtures hidden from evaluated agents
baselines/         # oracle-pass + nop-fail artifacts keyed by scenario/harness hashes
reports/           # Sanitized campaign write-ups (capability maps marked historical until Phase 7)
qualifications/    # Active evidence index deferred (Phase 0 archived; Phase 7 regenerates)
notes/             # Ops trust disabled until fresh held-out evidence
scripts/           # Client-side validators + baseline recorder (not graded runners)
```

Shared Alpha batteries (`email-triage`, `vault-*`, `ledger-coding`, …) live in the Alpha repo; promote sanitized reports/quals here after Watchtower campaigns.

## Integrity controls (Phase 3)

```bash
export ALPHA_ROOT="/path/to/alpha-lab"
# Zero-model controls (oracle / nop) — may run as diagnostics; prefer Job logs for attestation:
bin/alpha oracle --scenario ikigai-dot
bin/alpha run --scenario ikigai-dot --executor nop --no-gate-halt --profile shipping
./scripts/record-scenario-baselines.sh ikigai-dot
./scripts/validate-phase3-evidence-rules.sh
```

Shipping / measurement profiles set `include_invariant: false`. Answer-bearing `invariant.md` files remain on disk for `oracle` / `debug` profiles only (requires Alpha harness to honor `Profile#include_invariant`). Held-out cases under `scenarios/ikigai-dot/held_out/` must never enter agent prompts or sandbox mounts.

Do **not** run `bin/alpha qualify --manifest` until Phase 7 — there is no active evidence index.

## Scenarios

| Scenario | Role | What it grades |
|---|---|---|
| `ikigai-dot` | `crm_ops` | Deterministic rule-application first, then LLM gaps (ikigai-crm) |

### `ikigai-dot` architecture (ladder)

| Task | Rung | Intent |
|---|---|---|
| `rank-fill-template` | L0 | Fill ranking JSON template |
| `rank-from-candidates` | L1 | Sort CRM-emitted candidates with explicit rules |
| `scorecard-apply-rules` | L1 | Map structured facts → dims via R1–R5 |
| `draft-outreach` | L2 | Grounded cold email (LLM gap) |
| `isolation-grounding` | L2 | Abstain when context poisoned |
| `draft-outreach-vague` | L3 | Measurement ceiling (vague PM ticket) |

Shipping profile `max_rung: L2`. Qualification promote (Phase 7) requires matching oracle-pass and nop-fail baselines for the exact scenario and harness hashes — see [`baselines/README.md`](baselines/README.md).

## Vault note

Alpha’s `vault-extract` / `vault-sanitize` / `vault-reconcile` / `ledger-coding` scenarios are **Ruby/Rails eval analogs** of sapphire runtime invariants (integer cents, fail-loud recon, closed schemas, PII scrub). They are not the Python Vault app.

## Sanitization

No personal emails, LAN/Tailscale IPs, MAC addresses, secrets, private hostnames, or real bank identifiers. Prefer `*.example` / `example.local` fiction.

## License

[MIT](LICENSE).
