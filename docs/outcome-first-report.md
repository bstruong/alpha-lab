# Outcome-first report shape

Every human-facing model report (Alpha renderer + lab promote path) must lead
with plain English. Technical provenance supports the answers; it must not
replace them as the headline.

Companion template: [`templates/model-capability-report.md`](templates/model-capability-report.md).
Alpha hook: `Alpha::Report` (Phase 7) renders the same sections from
`alpha.report.v2` + optional `alpha.statistical_protocol.v1`.

## Required lead sections

```text
Model: <immutable model and quantization identity>
Evaluated for: <bounded task and operating scope>

Can do
- <task>: <passed>/<valid held-out trials> passed

Cannot reliably do
- <task>: <passed>/<valid trials> passed
  Observed failures: <plain-English failure summary>

Not evaluated
- <task or condition>: <reason>

Delegation decision
- Unattended: <strictly bounded tasks, or none>
- Review required: <tasks, or none>
- Do not delegate: <tasks, or none>

Evidence limits
- Valid trials: <N>; invalid trials: <N and reasons>
- Uncertainty: <method and interval>
- Runtime identity: <immutable reference>
- Evidence expires when: <conditions/date>
- Coverage vs reliability: <what was only covered vs repeatedly measured>
```

## Supporting evidence (after the lead)

Put the following **below** the outcome summary, never above it:

1. Per-task and per-skill tables (coverage + reliability)
2. Observed failure examples
3. Comparison with other self-hosted models (optional)
4. Technical provenance: commit SHAs, image digests, scenario/fixture hashes,
   generation parameters, seeds, trial IDs
5. Infrastructure / audit: Lease holder, Kubernetes Job name, GPU/driver state,
   warm-up/reset outcomes, validation logs

## Vocabulary

| Prefer | Avoid as headline |
|---|---|
| First-attempt success | Pass@1 (ok in machine JSON) |
| Meets delegation policy | qualified (alone) |
| Mandatory prerequisite | gate (alone) |
| Not evaluated: infrastructure failure | counting infra as model fail |
| Evaluation mode | profile (alone) |
| Machine-readable evidence index | manifest (alone) |
| Unattended | Own |

## Scaffolding constraints (this PR)

- Do **not** enable Unattended routes.
- Do **not** regenerate an active evidence index.
- Renderers must still say **Unattended: none** and default **Review required**
  while `schemas/statistical-protocol.v1.yml` has `unattended_enabled: false`
  or while no active top-level shipping JSON exists.
