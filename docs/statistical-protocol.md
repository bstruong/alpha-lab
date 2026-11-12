# Statistical protocol (v1.0.0)

Machine-readable source: [`schemas/statistical-protocol.v1.yml`](../schemas/statistical-protocol.v1.yml)
(`alpha.statistical_protocol.v1`).

This protocol is **scaffolding for Phase 7**. It predeclares how fresh held-out
campaigns will be scored and how reports must speak. It does **not** enable
**Unattended** routes, regenerate an active evidence index, or authorize live
GPU campaigns before Phases 0–6 merge and deploy.

## What is measured

| Concept | Machine field | Plain English |
|---|---|---|
| First-attempt success | `pass_at_1` | Did this independent held-out trial pass on the first attempt? |
| Exact counts | `pass_at_1_numerator` / `pass_at_1_denominator` | Always publish N/D, never a bare percentage |
| Invalid trials | `invalid_trials` + reasons | Infrastructure / dry / partial — **Not evaluated**, not model failure |

Never write “100% confidence” or “100% certainty.” Write observed success within
scope, for example:

> Observed success: 24/24 held-out trials (100%). This does not prove zero
> future failures. Unattended delegation is approved only for the tested task
> scope, model/runtime identity, evidence threshold, and expiry shown below.

## Coverage vs repeated-trial reliability

These are **different** answers and must not be collapsed:

1. **Task coverage** — which tasks/skills were attempted at least once.
2. **Repeated-trial reliability** — per-task / per-skill First-attempt success
   across declared seeds and parameterized instances, with exact N/D and a
   Wilson score interval.

A single shipping pass over five heterogeneous tasks is coverage evidence, not
reliability evidence for unattended delegation.

## Uncertainty

- Method: **Wilson score interval**, two-sided, confidence level **0.95**.
- **Unattended** decisions (when eventually enabled) use the **conservative
  lower bound**, never the point estimate alone.
- Protocol threshold for Unattended lower bound: **≥ 0.85**, and observed
  success must still be **24/24** (or whatever N/D the campaign declares) with
  rate **1.0** on every mandatory held-out case in scope.

## Minimum sample size (predeclared)

| Band | Minimum effective trials | Per-task seeds / instances |
|---|---|---|
| Unattended | 24 total; ≥4 per mandatory task | ≥4 distinct seeds; ≥2 distinct instances |
| Review required | ≥1 scored valid trial | optional |
| Not evaluated | missing / dry / infra-invalid / expired / below floors | — |

## Per-skill floors

Aggregate First-attempt success cannot hide a failed lane. For **Unattended**,
every mandatory skill must meet floor **1.0**. Missing a skill floor ⇒
**Review required**, **Do not delegate**, or **Not evaluated** — never silent
Unattended.

## Trust-band thresholds

| Band | Meaning |
|---|---|
| **Unattended** | Eligible without routine review, only for tested scope + runtime |
| **Review required** | Useful output expected; human must approve |
| **Do not delegate** | Observed failures exceed policy or include critical semantic failure |
| **Not evaluated** | Evidence missing, incomplete, dry, infra-invalid, expired, or statistically inadequate |

Absent active evidence index ⇒ **Review required** for every role (fail closed).
`unattended_enabled: false` in v1.0.0 until a later protocol bump after fresh
evidence passes every criterion.

## Canonical rerun rules

- Maximum attempts: **3** complete, infrastructure-valid campaigns for the same
  (model, quantization, scenario, profile, `fixture_set_hash`, protocol version).
- Canonical selection: **earliest** `started_at` among promotable attempts with
  `terminal_status=ok`.
- Do **not** pick the best score after seeing results.
- Infrastructure-invalid attempts are retained as evidence but do not count as
  model-scoring attempts.
- Preserve attempt lineage on the qualification artifact.

## Held-out binding

Qualification campaigns bind to:

- `scenarios/<id>/held_out/fixture_set.yml` → `fixture_set_hash`
- `scenarios/<id>/held_out/trial_plan.yml` → declared seeds / instances
- Matching `baselines/<id>/oracle-pass__…` and `nop-fail__…` for the exact
  scenario content hash and Alpha harness revision

Answer-bearing `invariant.md` and held-out cases must never enter evaluated
agent prompts or sandbox mounts.

## Graded execution host

Graded suites run **only** as Watchtower campaign Jobs (see
[`fresh-campaigns-after-deploy.md`](fresh-campaigns-after-deploy.md)). Laptops
may submit, monitor, and retrieve artifacts — never host the graded runner,
own the Lease, or provide the heartbeat.
