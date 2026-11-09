# Ops trust (internal)

Generated `2026-11-09T17:06Z` from Alpha shipping qualifications (v2).
Bands: **Own** = unattended local; **Assist** = local draft + frontier/you review; **Escalate-only** = do not trust local alone.

| Role | Primary local model | Max rung | Band | App | Pass@1 | Qualified |
|---|---|---|---|---|---|---|
| `triager` | `qwen36-coder-hybrid` | L2 | Own | Carnelian enrichment / email triage assist | 0.80 | yes |
| `extractor` | `qwen36-coder-hybrid` | L1 | Own | Carnelian receipts; Sapphire doc extract (non-money) | 1.00 | yes |
| `sanitizer` | `gemma4-4b` | L1 | Own | Carnelian + Sapphire PII strip | 1.00 | yes |
| `vault_extractor` | `—` | — | Escalate-only | Sapphire Vault extract | — | no |
| `vault_sanitizer` | `—` | — | Escalate-only | Sapphire Vault sanitize | — | no |
| `recon_ops` | `—` | — | Escalate-only | Sapphire recon proposals | — | no |
| `crm_ops` | `gemma4-12b` | L2 | Own | Ikigai Dot rank/draft/scorecard | 0.80 | yes |

## Escalation triggers

- Schema / grader fail → frontier or you
- Isolation / PII leak → you
- Recon / money_invariant → you (never silent local fix)
- Triage P1 phishing → you

See `notes/frontier_local_handoff.md`.

