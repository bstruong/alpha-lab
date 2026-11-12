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
Phase 7 publishes fresh held-out evidence.

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

Publication (after a Watchtower campaign) still looks like:

```bash
# On a launch client, after pulling sanitized artifacts from the campaign Job:
export ALPHA_ROOT=/path/to/alpha-lab
# Do not regenerate an active evidence index during Phase 0–6.
# bin/alpha qualify --manifest   # deferred until Phase 7
```
