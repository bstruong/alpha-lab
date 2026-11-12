# Ops trust (DISABLED)

**Status:** disabled as of Phase 0 (benchmark simplification).

There is **no active evidence index**, and therefore **no** `Own` or
**Unattended** routes. Every Alpha role is **Review required** until a
fresh pinned qualification campaign meets the post-simplification
delegation policy (Phase 7).

| Role | Primary local model | Band | Notes |
|---|---|---|---|
| `triager` | — | Review required | No active qualification |
| `extractor` | — | Review required | No active qualification |
| `sanitizer` | — | Review required | No active qualification |
| `crm_ops` | — | Review required | No active qualification |
| `vault_extractor` | — | Review required / Do not delegate | Not evaluated for unattended use |
| `vault_sanitizer` | — | Review required / Do not delegate | Not evaluated for unattended use |
| `recon_ops` | — | Review required / Do not delegate | Not evaluated for unattended use |
| `scoped_coder` / `coder` / `ruby_coder` / `frontend_coder` / `hotwire_coder` / `ledger_coder` | — | Review required | No active qualification |

## Invariants

- Do **not** accept local model output unattended on schema OK.
- Do **not** regenerate an active evidence index or enable **Unattended**
  from archived `qualifications/archive-v2-pre-simplification/` records.
- Graded benchmark suites execute **only** as Watchtower/homelab campaign
  Jobs. Laptops and workstations are launch/monitor clients only and must
  not host graded runners.
- Historical shipping JSON under `qualifications/archive-*` is audit data,
  not routing authority.

See `notes/frontier_local_handoff.md`.
