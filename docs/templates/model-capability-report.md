# Model capability report (template)

Model: `<immutable model / quantization / model_sha256>`
Evaluated for: `<scenario_id>` / `<evaluation mode>` / protocol `alpha-lab.held_out.first_attempt@1.0.0`

## Can do

- `<task>`: `<N>/<D>` passed

## Cannot reliably do

- `<task>`: `<N>/<D>` passed
  - Observed failures: `<plain English>`

## Not evaluated

- `<task or condition>`: `<reason>`

## Delegation decision

- Unattended: none
- Review required: all roles / tasks lacking fresh held-out evidence that meets protocol v1.0.0
- Do not delegate: `<tasks with critical semantic or safety failures, or none>`

## Evidence limits

- Valid trials: `<N>`; invalid trials: `<N>` (`<reasons>`)
- Uncertainty: Wilson score interval (95% two-sided); Unattended would use the lower bound only when enabled
- Runtime identity: runner=`<digest>` · jarvis=`<digest>` · model=`<id/sha>`
- Evidence expires when: model, prompt, fixture, runtime, harness, or infrastructure identity changes; or qualification TTL elapses
- Coverage vs reliability: coverage=`<tasks attempted>`; reliability=`<per-task N/D across seeds>` (or “reliability not yet measured”)
- Observed success language only — never “100% confidence”

## Supporting evidence

### Per-task / per-skill

| Task | Skill | Coverage | Reliability N/D | Wilson 95% | Notes |
|---|---|---|---|---|---|
| | | attempted / not evaluated | | | |

### Provenance and infrastructure

- Commits: alpha=`…` alpha-lab=`…` homelab=`…` (dirty flags)
- Scenario / fixture / grader hashes
- Lease: `jarvis-gpu` holder / run id
- Kubernetes Job: `<name>` (Watchtower only)
- Seeds / trial IDs / generation parameters
- Oracle-pass / nop-fail baseline URIs
- Raw artifact hashes (sanitized bundle only in git)
