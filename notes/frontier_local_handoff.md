# Frontier manager / local worker handoff (internal)

Personal protocol: frontier subscription = **manager/reviewer**; Watchtower
JARVIS = **worker candidate** only. Until a fresh post-simplification
qualification exists, **every** local role is **Review required**.

`notes/OPS_TRUST.md` is currently **disabled** (no `Own` / **Unattended**
routes). Do not treat archived shipping qualifications as routing authority.

## Schemas

### `task_packet` (manager → worker)

```json
{
  "schema": "alpha.task_packet.v1",
  "role": "triager|extractor|sanitizer|vault_extractor|vault_sanitizer|recon_ops|crm_ops",
  "goal": "one sentence",
  "constraints": ["closed JSON only", "no invented contacts", "..."],
  "schema_id": "carnelian.enrichment.v1",
  "pii_class": "none|redacted|raw_local_only",
  "abort_conditions": ["schema_fail", "isolation_leak", "money_invariant"],
  "allowed_tools": [],
  "model_hint": "gemma4-4b"
}
```

`pii_class: raw_local_only` never leaves the Vault/Carnelian trust boundary.
Frontier must not receive raw statement text or message bodies with PII.

### `worker_result` (worker → manager)

```json
{
  "schema": "alpha.worker_result.v1",
  "status": "ok|abstain|error",
  "role": "triager",
  "model_id": "gemma4-4b",
  "payload": {},
  "evidence": ["quoted span or field ids"],
  "abort_reason": null
}
```

## Manager duties

1. Decompose work into a single Alpha **role**.
2. Attach a closed output schema (`schema_id`).
3. **Do not auto-route from OPS_TRUST.** There is no active primary local
   model. Choose a worker only as a draft aid, then require human review.
4. Validate JSON / run product-side schema checks.
5. **Review required (current default):** frontier or you must approve
   before any side effect (send, ledger write, CRM mutation).
6. **Do not delegate:** vault money/recon lanes and any role lacking fresh
   held-out evidence — frontier/you own the task.
7. Never re-prompt local to “try harder” after `money_invariant`,
   isolation, or recon fail-loud.
8. Graded Alpha campaigns launch via Watchtower/homelab Jobs only; this
   machine is a client, not a graded runner host.

## Escalation matrix

| Signal | Action |
|---|---|
| Schema / grader fail | Frontier rewrite or you |
| Isolation / PII leak | You (stop automation) |
| Recon / money_invariant | You; local never silent-fix cents |
| Triage P1 phishing / Suspect | You approve |
| `status: abstain` | Treat as success of safety; escalate content |
| Missing active evidence index | **Review required** — never select a default Own/Unattended model |

## Product bindings (Phase 0)

| App | Local role | Default model | Frontier / you |
|---|---|---|---|
| Carnelian enrichment | `triager` | none (Review required) | always review |
| Carnelian receipt hints | `extractor` | none (Review required) | always review |
| Sapphire strip/extract | `sanitizer` / `extractor` | none (Review required) | always review; never raw PDF to cloud |
| Sapphire recon | `recon_ops` | none (Do not delegate) | you / frontier on aggregates only |
| Ikigai Dot | `crm_ops` | none (Review required) | review outreach before send |
