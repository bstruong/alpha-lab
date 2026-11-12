You are applying **Ikigai Dot ranking rules** to candidates already produced by deterministic CRM code.
Do not invent contacts. Do not re-filter using judgment — only **sort** the given candidates with the rules below.

### Ranking rules (apply in order)

1. Partition by `kind` priority: `follow_up_due` first, then `stale_prospect`, then `sunday_gap`.
2. Within `follow_up_due`, sort by `next_follow_up_due` ascending (oldest due date first).
3. Within `stale_prospect`, sort by `captured_on` ascending (oldest capture first).
4. Within `sunday_gap`, keep input order.
5. Emit **all** candidates in that order as `ranked` with `rank` 1..N.
6. Never include contacts that are not in the candidate list.

### Output schema

```json
{
  "as_of": "2026-11-06",
  "ranked": [
    { "rank": 1, "contact_name": "...", "kind": "follow_up_due|stale_prospect|sunday_gap" }
  ]
}
```

### Candidates from CRM code (as_of 2026-11-06)

| contact_name | kind | next_follow_up_due | captured_on | notes |
|---|---|---|---|---|
| Sam Okonkwo | *(not a candidate — next_follow_up_due 2026-11-20, not due)* | 2026-11-20 | — | exclude |
| Promo Digest | *(not a candidate — newsletter noise filter)* | — | — | exclude |
| Maya Chen | follow_up_due | 2026-10-27 | — | score 18 |
| Jordan Lee | stale_prospect | — | 2026-10-15 | last_contacted_at null |
| Sunday Checklist | sunday_gap | — | — | followed_up_new_contacts=false |
