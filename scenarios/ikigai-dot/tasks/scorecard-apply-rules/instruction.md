You are **not** inventing a scorecard. Apply the **deterministic mapping rules** below to structured facts already extracted by CRM code. Output the exact integers those rules require.

In product code, `ScorecardCalculator` only sums these five 1–4 fields and maps the total to follow-up cadence. Your job here is the rule table that would live next to that calculator.

### Mapping rules

| id | If fact present | Set |
|---|---|---|
| R1 | `fundraising_help` = true AND operator goal includes seed/angel | `goal_importance` = 4 |
| R2 | `offered_informal_advisor` = true | `ring_level` = 4 AND `soi_ring` = `"board_of_advisors"` |
| R3 | `lp_intros_last_quarter` ≥ 1 | `value_exchange` = 4 |
| R4 | `coffee_cadence` = `"monthly"` | `past_interaction_freq` = **3** (never 4; 4 is reserved for weekly+) |
| R5 | `domain_overlap` includes `"rails_saas"` OR `"angels"` | `objective_alignment` = 4 |

If a rule’s condition is false, do not apply it. All five rules match this record.

### Output schema

```json
{
  "goal_importance": 1,
  "ring_level": 1,
  "value_exchange": 1,
  "past_interaction_freq": 1,
  "objective_alignment": 1,
  "soi_ring": "board_of_advisors",
  "applied_rules": ["R1", "R2", "R3", "R4", "R5"]
}
```

`applied_rules` must list every matching rule id (exact strings R1–R5).

### Structured facts (from CRM extractors — do not reinterpret prose)

```json
{
  "contact_name": "Elena Vargas",
  "fundraising_help": true,
  "offered_informal_advisor": true,
  "lp_intros_last_quarter": 3,
  "coffee_cadence": "monthly",
  "coffee_months": 18,
  "domain_overlap": ["angels", "rails_saas"],
  "operator_goals": ["seed_adjacent_angel_round", "sf_ruby_network", "solo_b2b_product"]
}
```
