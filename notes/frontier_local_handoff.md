# Frontier manager / local worker handoff (internal)

Personal protocol: frontier subscription = **manager/reviewer**; Watchtower JARVIS = **worker** for Own/Assist roles in `OPS_TRUST.md`.

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

`pii_class: raw_local_only` never leaves the Vault/Carnelian trust boundary. Frontier must not receive raw statement text or message bodies with PII.

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
3. Route to the **primary local model** from `OPS_TRUST.md` for that role.
4. Validate JSON / run product-side schema checks.
5. **Own** band: accept on schema OK (spot-check optional).
6. **Assist** band: frontier or you merge before side effects (send, ledger write).
7. **Escalate-only**: do not call local as authority; frontier/you own the task.
8. Never re-prompt local to “try harder” after `money_invariant`, isolation, or recon fail-loud.

## Escalation matrix

| Signal | Action |
|---|---|
| Schema / grader fail | Frontier rewrite or you |
| Isolation / PII leak | You (stop automation) |
| Recon / money_invariant | You; local never silent-fix cents |
| Triage P1 phishing / Suspect | You approve |
| `status: abstain` | Treat as success of safety; escalate content |

## Product bindings (defaults)

| App | Local role | Default model (2026-11-09 ops requal) | Frontier |
|---|---|---|---|
| Carnelian enrichment | `triager` | `qwen36-coder-hybrid` | Suspect / P1 only |
| Carnelian receipt hints | `extractor` | `qwen36-coder-hybrid` | optional Assist review |
| Sapphire strip/extract | `sanitizer` / `extractor` | `gemma4-4b` / `qwen36-coder-hybrid` | never on raw PDF to cloud; vault_* Escalate-only |
| Sapphire recon | `recon_ops` | Escalate-only | you / frontier on aggregates only |
| Ikigai Dot | `crm_ops` | `gemma4-12b` | review outreach before send |
