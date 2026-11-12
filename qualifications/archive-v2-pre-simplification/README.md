# Archive: v2 qualifications (pre-simplification)

These `alpha.qualification.v2` shipping artifacts and the accompanying
`alpha.qualification_manifest.v2` file are **historical**.

They were produced **before** the benchmark-simplification corrections
(repair-inflated Pass@1 semantics, answer-bearing shipping invariants,
insufficient statistical evidence, and incomplete provenance).

## Routing policy

- **Not eligible for routing.** Do not treat any record here as `Own`,
  **Unattended**, or any other unattended-delegation authority.
- **Must not be loaded** by the active evidence-index reader.
  Active loaders must read only top-level `qualifications/*.json`
  (excluding archive directories). Absence of a top-level evidence index
  means **Review required**, never a default model selection.
- Preserve these files for audit and rollback of *historical data only*.
  Restoring them as routing authority requires completing Phase 7 of the
  simplification plan with fresh held-out evidence.

## Related archives

- `../archive-v1/` — legacy `alpha.qualification.v1` artifacts
- `../archive-sinatra/` — retired sinatra_coder shipping snapshots
