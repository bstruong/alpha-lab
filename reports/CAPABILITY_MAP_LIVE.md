# Capability map (LIVE) — HISTORICAL

> **Historical (Phase 0).** This table was generated from pre-simplification
> shipping qualifications. Those artifacts are now under
> `qualifications/archive-v2-pre-simplification/` and are **not** routing
> authority. Do not treat any `Qualified: yes` row below as `Own` or
> **Unattended**. Active policy: **Review required** for every role until
> Phase 7 publishes a fresh evidence index.
>
> Individual timestamped run reports are preserved. This aggregate view is
> retained for audit only.

| Model | Role | Max rung | Ceiling | Credit | Pass@1 | Qualified | Top failures |
|---|---|---|---|---|---|---|---|
| `gemma4-27b` | `crm_ops` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `gemma4-12b` | `crm_ops` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `gemma4-4b` | `crm_ops` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `qwen25-coder-14b` | `crm_ops` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `qwen36-coder-hybrid` | `crm_ops` | L2 | L2 | 0.6 | 0.60 | no | partial:2 |
| `glm47-reap` | `crm_ops` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `gemma4-27b` | `recon_ops` | L2 | L2 | 0.67 | 0.67 | no | partial:1 |
| `gemma4-27b` | `vault_sanitizer` | L1 | L1 | 0.67 | 0.67 | no | partial:1 |
| `gemma4-27b` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `gemma4-12b` | `recon_ops` | L2 | L2 | 0.33 | 0.33 | no | partial:2 |
| `gemma4-12b` | `vault_sanitizer` | L1 | L1 | 0.67 | 0.67 | no | partial:1 |
| `gemma4-12b` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `gemma4-4b` | `recon_ops` | L2 | L2 | 0.33 | 0.33 | no | partial:2 |
| `gemma4-4b` | `vault_sanitizer` | L1 | L1 | 0.67 | 0.67 | no | partial:1 |
| `gemma4-4b` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `qwen25-coder-14b` | `recon_ops` | L2 | L2 | 0.33 | 0.33 | no | partial:2 |
| `qwen25-coder-14b` | `vault_sanitizer` | L1 | L1 | 0.67 | 0.67 | no | partial:1 |
| `qwen25-coder-14b` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `qwen36-coder-hybrid` | `recon_ops` | L2 | L2 | 0.33 | 0.33 | no | partial:2 |
| `qwen36-coder-hybrid` | `vault_sanitizer` | L1 | L1 | 0.67 | 0.67 | no | partial:1 |
| `qwen36-coder-hybrid` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `glm47-reap` | `recon_ops` | — | — | 0.0 | 0.00 | no | partial:3 |
| `glm47-reap` | `vault_sanitizer` | — | — | 0.0 | 0.00 | no | partial:3 |
| `glm47-reap` | `vault_extractor` | L1 | L1 | 0.33 | 0.33 | no | money_invariant:2 |
| `gemma4-27b` | `extractor` | L1 | L1 | 0.5 | 0.50 | no | partial:1 |
| `gemma4-27b` | `sanitizer` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `gemma4-27b` | `triager` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `gemma4-12b` | `extractor` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `gemma4-12b` | `sanitizer` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `gemma4-12b` | `triager` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `gemma4-4b` | `extractor` | L1 | L1 | 0.5 | 0.50 | no | partial:1 |
| `gemma4-4b` | `sanitizer` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `gemma4-4b` | `triager` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `qwen25-coder-14b` | `extractor` | L1 | L1 | 0.5 | 0.50 | no | partial:1 |
| `qwen25-coder-14b` | `sanitizer` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `qwen25-coder-14b` | `triager` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `qwen36-coder-hybrid` | `extractor` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `qwen36-coder-hybrid` | `sanitizer` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `qwen36-coder-hybrid` | `triager` | L2 | L2 | 0.8 | 0.80 | yes | partial:1 |
| `glm47-reap` | `extractor` | L1 | L1 | 1.0 | 1.00 | yes |  |
| `glm47-reap` | `sanitizer` | L0 | L0 | 0.5 | 0.50 | no | partial:1 |
| `glm47-reap` | `triager` | L2 | L2 | 0.6 | 0.60 | no | partial:2 |
| `qwen25-coder-14b` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
| `qwen36-coder-hybrid` | `extractor` | — | — | 0.0 | 0.00 | no | infra:2 |
| `qwen36-coder-hybrid` | `sanitizer` | — | — | 0.0 | 0.00 | no | infra:2 |
| `qwen36-coder-hybrid` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
| `glm47-reap` | `extractor` | — | — | 0.0 | 0.00 | no | infra:2 |
| `glm47-reap` | `sanitizer` | — | — | 0.0 | 0.00 | no | infra:2 |
| `glm47-reap` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
| `qwen25-coder-14b` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
| `qwen36-coder-hybrid` | `extractor` | — | — | 0.0 | 0.00 | no | infra:2 |
| `qwen36-coder-hybrid` | `sanitizer` | — | — | 0.0 | 0.00 | no | infra:2 |
| `qwen36-coder-hybrid` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
| `glm47-reap` | `extractor` | — | — | 0.0 | 0.00 | no | infra:2 |
| `glm47-reap` | `sanitizer` | — | — | 0.0 | 0.00 | no | infra:2 |
| `glm47-reap` | `triager` | — | — | 0.0 | 0.00 | no | infra:5 |
