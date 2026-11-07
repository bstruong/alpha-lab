# Campaign notes — 2026-11-06/07 strict re-qual + glm47 post-merge archive

Lab consumer runs of [Alpha](https://github.com/bstruong/alpha) against the shared OpenAI-compatible lab ingress (JARVIS wake/lease via [homelab-k3s](https://github.com/bstruong/homelab-k3s)).

Qualification uses **first-attempt** gate Pass@1 and graded Pass@1 (Alpha Qualifier after the shipping threshold fix). Banner “Pass@1” that includes self-repair is **not** used for shipping.

## Why this campaign

1. Most shipping quals were set to expire on **2026-11-16**.
2. `qwen36-coder-hybrid` **coder** shipping recorded Pass@1 `1.0` from `20261017T035031Z`, but true graded first-attempt was **0.50** (3 self-repairs). **Dropped.**
3. `glm47-reap` **sanitizer** still shipped from Oct 17 while Nov 3 / Nov 6 / Nov 7 re-runs scored **0.00**. **Dropped.**
4. Nov 6 post-merge glm47 apples-to-apples reports lived only under `alpha/reports/`; promoted here.

## Nov 6 post-merge (`glm47-reap`, shipping) — archived

| Scenario | Banner Pass@1 | Graded P@1 (first) | Gate P@1 | Strict qualify? | Report |
| --- | --- | --- | --- | --- | --- |
| `ocr-extraction` | 1.00 | 1.00 | n/a | yes (refreshed Nov 7) | `reports/20261106T224921Z-ocr-extraction.md` |
| `pii-scrubbing` | 0.00 | 0.00 | n/a | no | `reports/20261106T224918Z-pii-scrubbing.md` |
| `scoped-coding` | 0.67 | 0.67 | n/a | no (need ≥ 0.80) | `reports/20261106T224926Z-scoped-coding.md` |
| `qwen36-daily` | 0.78 | 0.50 | 1.00 | no (need graded ≥ 0.70) | `reports/20261106T225531Z-qwen36-daily.md` |

Harness-debug smokes from earlier the same day were **not** promoted.

## Artifacts removed

| Artifact | Reason |
| --- | --- |
| `qwen36-coder-hybrid__coder__shipping.json` | Repair-inflated Oct 17 banner; fails current Qualifier |
| `glm47-reap__sanitizer__shipping.json` | Oct 17 ship contradicted by Nov 3 / Nov 6 / Nov 7 strict fails |

## Nov 7 strict re-qual (non-coding)

Re-ran expiring **triager / sanitizer / extractor** batteries. Coding roles were **not** re-shipped — no model meets coder / scoped_coder thresholds on true first-attempt Pass@1.

| Role | Model | Graded P@1 | Qualified? | Run |
| --- | --- | --- | --- | --- |
| triager | gemma4-4b | 1.00 | **yes** | `20261107T002547Z-email-triage` |
| triager | gemma4-12b | 1.00 | **yes** | `20261107T002601Z-email-triage` |
| triager | gemma4-27b | 1.00 | **yes** | `20261107T002633Z-email-triage` |
| triager | qwen25-coder-14b | 1.00 | **yes** | `20261107T002715Z-email-triage` |
| triager | qwen36-coder-hybrid | 1.00 | **yes** | `20261107T002749Z-email-triage` |
| triager | glm47-reap | 0.75 | **yes** | `20261107T002845Z-email-triage` |
| sanitizer | qwen25-coder-14b | 1.00 | **yes** | `20261107T002944Z-pii-scrubbing` |
| sanitizer | qwen36-coder-hybrid | 1.00 | **yes** | `20261107T002953Z-pii-scrubbing` |
| sanitizer | glm47-reap | 0.00 | no | `20261107T003015Z-pii-scrubbing` |
| extractor | qwen25-coder-14b | 1.00 | **yes** | `20261107T003052Z-ocr-extraction` |
| extractor | qwen36-coder-hybrid | 1.00 | **yes** | `20261107T003103Z-ocr-extraction` |
| extractor | glm47-reap | 1.00 | **yes** | `20261107T003122Z-ocr-extraction` |

Fresh shipping artifacts expire **2026-12-07** (~+30 days). Manifest regenerated at `qualifications/manifest.json` with roles: `crm_ops`, `extractor`, `sanitizer`, `triager` (no `coder`).

`crm_ops` / `ikigai-dot` (`gemma4-4b`) from the parallel Nov 6–7 lab work remains independent of this suite.

## Notes

- Pi personal agent SYSTEM.md (rules 7–12) stays out of Alpha on purpose; evals use thin `alpha/harness/pi/SYSTEM.md`.
- CLI reminder: `--preset` is the engine/models.ini section (usually == model id); `--profile shipping` is the prompt profile. Passing `--preset shipping` records `model_id: shipping` and fails immediately.
