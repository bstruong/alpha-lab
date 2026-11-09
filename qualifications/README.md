# Qualifications / evidence index

## Active evidence index

**None.** Phase 0 of the benchmark simplification archived all top-level
`alpha.qualification.v2` shipping artifacts and `manifest.json` under
`archive-v2-pre-simplification/`.

Consumers of the evidence index and delegation views **must fail closed**:

- If no top-level active shipping JSON / evidence index exists → treat every
  role as **Review required**.
- Never load `archive-v1/`, `archive-v2-pre-simplification/`, or
  `archive-sinatra/` for routing, primary-model selection, or **Unattended**
  / `Own` decisions.
- Never invent a default model when the active index is absent.

Alpha’s top-level glob (`qualifications/*.json`) intentionally ignores
archive subdirectories. Regenerating an active index is forbidden until
Phase 7 **promote** (after Phases 0–6 deploy + fresh held-out evidence that
meets `schemas/statistical-protocol.v1.yml`). This scaffolding PR only adds
protocol/docs/fixtures — it does **not** create top-level shipping JSON,
`manifest.json`, capability views, or **Unattended** routes.

## Historical archives

| Path | Contents |
|---|---|
| `archive-v2-pre-simplification/` | Pre-correction `alpha.qualification.v2` + manifest |
| `archive-v1/` | Legacy `alpha.qualification.v1` |
| `archive-sinatra/` | Retired sinatra_coder snapshots |

## Campaign execution invariant

Graded benchmark suites must execute only as Watchtower/homelab campaign
Jobs. Laptops/workstations are launch/monitor clients only and must not
host graded runners.

## Promote prerequisites (fail closed)

Before any future promote of a shipping qualification / active evidence index:

1. Shipping/measurement prompts must not include answer-bearing `invariant.md`
   (`include_invariant: false`). Oracle/debug profiles may include them.
2. Held-out fixtures under `scenarios/<id>/held_out/` must exist, hash-match
   `fixture_set.yml`, declare seeds/instances in `trial_plan.yml`, and remain
   invisible to evaluated agents.
3. Matching `baselines/<id>/oracle-pass__<scenario_hash>__<harness_rev>.json`
   and `nop-fail__…json` artifacts must both have `observed_ok: true` for the
   exact scenario content hash and Alpha harness revision. Do not invent green
   control results.
4. Campaign evidence must satisfy `schemas/statistical-protocol.v1.yml`
   (exact N/D, Wilson intervals, min sample size, per-skill floors, canonical
   rerun rule). Separate **task coverage** from **repeated-trial reliability**.
5. Reports must lead with Can do / Cannot reliably do / Not evaluated /
   Delegation decision / Evidence limits; hashes/Lease/K8s stay under
   Supporting evidence. Never claim 100% confidence.
6. Do not regenerate this directory’s active evidence index or Unattended /
   delegation views until every criterion above passes on a Watchtower Job
   after Phases 0–6 deploy. Absent index ⇒ **Review required**.

See `../baselines/README.md`, `../docs/statistical-protocol.md`,
`../docs/fresh-campaigns-after-deploy.md`,
`../scripts/validate-phase3-evidence-rules.sh`, and
`../scripts/validate-phase7-scaffold.sh`.

Publication (after a Watchtower campaign) still looks like:

```bash
# On a launch client, after pulling sanitized artifacts from the campaign Job:
export ALPHA_ROOT=/path/to/alpha-lab
# Do not regenerate an active evidence index during scaffolding / Phases 0–6.
# bin/alpha qualify --manifest   # only after protocol criteria pass
```
