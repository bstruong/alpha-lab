# Capability map (v2) — HISTORICAL

> **Historical (Phase 0).** This document is not an active capability or
> delegation view. Pre-simplification shipping qualifications were moved to
> `qualifications/archive-v2-pre-simplification/` and are **not** eligible for
> routing. There is no active evidence index; all roles are **Review required**.
> Individual run reports under `reports/` are preserved unchanged.
>
> Graded campaigns must run only as Watchtower/homelab Jobs (clients launch
> and monitor; they do not host graded runners). Do not enable **Unattended**
> until Phase 7.

Supersedes the blended Pass@1 scorecards in `HOMELAB_MODEL_EVALUATION_REPORT.md` for *procedure documentation only* — not for shipping decisions while disabled.

## Status

Legacy `alpha.qualification.v1` artifacts were archived to `qualifications/archive-v1/` on 2026-11-08. Pre-simplification `alpha.qualification.v2` artifacts and `manifest.json` were archived to `qualifications/archive-v2-pre-simplification/` in Phase 0. Neither archive is loadable by the active evidence-index reader.

Fresh **shipping + measurement** campaigns must be re-run as Watchtower/homelab Jobs before publishing a new active evidence index (Phase 7). Until then, this file documents the role ladder and the historical requal procedure only.

## Roles and scenarios

| Role | Scenario | Shipping band | Product / analog |
|---|---|---|---|
| `crm_ops` | `ikigai-dot` (alpha-lab) | ≤ L2 | ikigai-crm |
| `triager` | `email-triage` | ≤ L2 | carnelian |
| `sanitizer` | `pii-scrubbing` | ≤ L1 | PII scrub lane |
| `extractor` | `ocr-extraction` | ≤ L1 | OCR / docs |
| `scoped_coder` | `scoped-coding` | ≤ L1 | constrained Rails edits |
| `coder` | `qwen36-daily` | ≤ L2 | general Rails toy app |
| `ruby_coder` | `ruby-coding` | ≤ L1 | Ruby services on shared `web-rails` app |
| `frontend_coder` | `frontend-coding` | ≤ L1 | HTML/CSS/JS on shared `web-rails` UI (Ferrum product) |
| `hotwire_coder` | `hotwire-coding` | ≤ L1 | Turbo/Stimulus on shared `web-rails` (Ferrum product) |
| `vault_extractor` | `vault-extract` | ≤ L2 | sapphire-analog (Rails eval) |
| `vault_sanitizer` | `vault-sanitize` | ≤ L2 | sapphire-analog (Rails eval) |
| `recon_ops` | `vault-reconcile` | ≤ L2 | sapphire-analog (Rails eval) |
| `ledger_coder` | `ledger-coding` | ≤ L1 | sapphire-analog coding |

Vault / ledger batteries encode sapphire invariants (integer cents, fail-loud recon, closed schemas, zero PII egress) as **Ruby/Rails Alpha scenarios**. They do not run the Python Vault.

Web coding progression shares one Rails app (`scenarios/web-rails/library`) and is ordered: qualify `ruby_coder` before `frontend_coder`, then `hotwire_coder`. Graders require rendered-product checks (Ferrum/Cuprite); source-only near-misses fail. Resume with `ALPHA_CAMPAIGN_FROM=ruby|frontend|hotwire`.

## Requal procedure (historical; Watchtower Jobs only)

Graded `bin/alpha run` / qualify campaigns execute inside the Watchtower
Alpha campaign Job. From a laptop/workstation, only launch/monitor (for
example `scripts/alpha_watchtower_kick.sh`) and pull sanitized artifacts.
Do **not** host graded runners locally.

```bash
# Launch client — kick the homelab campaign Job (does not run graders here).
# After the Job finishes, pull sanitized reports/qualifications into alpha-lab.
# Regenerating an active evidence index / capability map is deferred to Phase 7.
```

## Live table

_Disabled in Phase 0. `reports/CAPABILITY_MAP_LIVE.md` is marked historical.
No active qualified rows. All roles: **Review required**._

| Model | Role | Max rung | Ceiling | Credit | Pass@1 | Qualified | Top failures |
|---|---|---|---|---|---|---|---|
| — | — | — | — | — | — | none (Review required) | — |
