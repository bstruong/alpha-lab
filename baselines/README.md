# Scenario integrity baselines (oracle-pass / nop-fail)

Qualification promotion (Phase 7) **requires** matching baseline artifacts for the
exact **scenario content hash** and **Alpha harness revision**. Phase 3 only
scaffolds the process and records real control runs — it does **not** invent
green results and does **not** publish an active evidence index.

## Required pair

For scenario `ikigai-dot` (and later every lab-owned scenario):

| Artifact | Expected outcome | Purpose |
|---|---|---|
| `oracle-pass__<scenario_hash>__<harness_rev>.json` | all tasks pass | Graders accept the committed solutions |
| `nop-fail__<scenario_hash>__<harness_rev>.json` | empty agent gets no credit | Nop must not pass; scored fails preferred (Alpha may still classify JSON missing-output under `exit_reason=nop` as infra-invalid — recorded honestly, not inventing green) |

Both files must embed:

- `scenario_id`
- `scenario_hash` (sha256-path-bytes-v1 over `scenarios/<id>/` excluding `held_out/`)
- `fixture_set_hash` (from `scenarios/<id>/held_out/fixture_set.yml` when present)
- `harness_repo` / `harness_rev` / `harness_dirty`
- `recorded_at` (UTC)
- raw command outcomes (pass/fail counts) — never hand-edited to green

## Record (diagnostic / Watchtower Job)

Prefer recording inside a Watchtower campaign Job. A laptop may run the same
script only as a **non-promotable diagnostic** (local Alpha + `ALPHA_ROOT` lab):

```bash
# From a machine that can invoke Alpha; graded suite promotion still requires
# Watchtower Jobs for model evidence — these controls are zero-model integrity.
export ALPHA_ROOT=/home/brian/Projects/alpha-lab
export ALPHA_REPO=/home/brian/Projects/alpha
./scripts/record-scenario-baselines.sh ikigai-dot
```

Artifacts land under `baselines/<scenario_id>/`.

## Validate before any future promote

```bash
./scripts/validate-phase3-evidence-rules.sh
# Later (Phase 7 promote path / Alpha qualify gate):
# require oracle-pass + nop-fail for the current scenario_hash + harness_rev
```

Absence of a matching pair ⇒ **Not evaluated** / refuse promote. Do not
regenerate `qualifications/manifest.json` or Unattended views in Phases 0–6.
