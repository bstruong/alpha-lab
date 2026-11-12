# Run provenance (Phase 5)

Alpha publishes graded evidence into this lab only as **sanitized** bundles.
Raw trial traces remain under ignored `results/runs/` on the Watchtower PVC /
local Alpha scratch.

## Required machine-readable fields

Every promotable campaign summary (`alpha.report.v2`) and qualification
(`alpha.qualification.v2`) must carry:

| Field | Meaning |
| --- | --- |
| `run_manifest_uri` | Path to `results/runs/<run_id>/run_manifest.json` |
| `provenance` | `alpha.provenance.v1` block |
| `promotable` | `true` only when Watchtower Job + pinned SHAs/digests + clean trees |

`run_manifest.json` (`alpha.run_manifest.v1`) is created at campaign start and
finalized in the same file at completion with terminal status and artifact
hashes.

Provenance must bind:

- Alpha / Alpha-lab / homelab commit SHAs and dirty flags
- runner image digest (`sha256:…`, never `:latest`)
- scenario / task / grader / fixture content hashes
- model SHA-256 + quantization identity when available
- JARVIS image/config digest + returned model id
- generation parameters and seeds
- unique run/trial ids
- GPU/driver/runtime/CPU governor/thermal/cache state (best-effort)
- Lease identity (`jarvis-gpu` holder + run id)
- reset/warm-up outcomes
- raw artifact hashes + terminal status

## Publishing rule

1. Keep raw traces under ignored `results/runs/`.
2. Copy only sanitized `summary.json` / `run_manifest.json` (via
   `Alpha::RunManifest.sanitized_bundle`) + rendered report + qualification JSON.
3. Commit those artifacts in one clean alpha-lab commit (Phase 7 regenerates
   the active evidence index). Do **not** enable Unattended here.

## Deterministic re-render

```bash
ALPHA_ROOT=/path/to/scratch mise exec -- bin/alpha render-report --run <run_id>
```

Report Markdown must regenerate from the retained bundle (documented
nondeterministic fields: wall-clock timestamps inside provenance
`collected_at` / `finished_at` only).
