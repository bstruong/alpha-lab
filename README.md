# alpha-lab

Personal **benchmark suite and campaign archive** for [Alpha](https://github.com/bstruong/alpha) (`alpha-eval` gem).

Alpha is the reusable evaluation **mechanism** (runner, graders, qualify). This repo is the **lab**: personal scenarios, shipping qualifications, and sanitized reports from self-hosted open-weight runs.

Inference wake/lease for the lab GPU stack lives in [homelab-k3s](https://github.com/bstruong/homelab-k3s) (`scripts/jarvis-*.sh`, `scripts/alpha-engine/`).

## Layout

```
scenarios/         # Personal eval batteries (suite)
reports/           # Human-readable campaign write-ups (sanitized)
qualifications/    # Shipping qualification JSON + manifest snapshots
notes/             # Short campaign write-ups / run context
```

## Running the suite

```bash
export ALPHA_ROOT="/path/to/alpha-lab"
export OPENAI_BASE_URL="http://127.0.0.1:8080/v1"
# Optional: ./scripts/jarvis-up.sh && ./scripts/jarvis-lease.sh acquire alpha-lab 90

bin/alpha oracle --scenario ikigai-dot
bin/alpha run --scenario ikigai-dot --model <preset>
bin/alpha qualify --run <run_id> --role crm_ops
```

## Scenarios

| Scenario | Role | What it grades |
|---|---|---|
| `ikigai-dot` | `crm_ops` | Deterministic rule-application first, then LLM gaps |

### `ikigai-dot` architecture

| Task | Layer | Intent |
|---|---|---|
| `rank-from-candidates` | Rules | Sort CRM-emitted candidates with explicit priority/date rules (exact order) |
| `scorecard-apply-rules` | Rules | Map structured facts → 1–4 dims via rule table R1–R5 (exact ints; cadence math stays in app code) |
| `draft-outreach` | **LLM gap** | Write grounded cold email copy for a contact the CRM already selected |
| `isolation-grounding` | Hybrid safety | Abstain when `contacts_loaded=false` / poisoned context — never invent |

Reports always include per-task **`wall_ms`**. Latency budgets are tabled until correctness is solid.

## Sanitization

No personal emails, LAN/Tailscale IPs, MAC addresses, secrets, or private hostnames. Prefer `*.example` / `example.local` fiction.

## License

[MIT](LICENSE).
