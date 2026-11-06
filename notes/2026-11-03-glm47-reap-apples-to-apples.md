# Campaign notes — 2026-11-03 glm47-reap apples-to-apples

Lab consumer run of [Alpha](https://github.com/bstruong/alpha) against a local OpenAI-compatible endpoint (homelab JARVIS wake/lease via [homelab-k3s](https://github.com/bstruong/homelab-k3s)).

## Layout used

| Piece | Role |
| --- | --- |
| `alpha` | Harness (`bin/alpha run` / `qualify`) |
| `homelab-k3s` | `jarvis-up` / `jarvis-lease` / `jarvis-down` |
| `alpha-lab` | Published reports + shipping qualifications |

## Results (`glm47-reap`, shipping)

Qualification uses **first-attempt** gate Pass@1 and graded Pass@1 against each scenario’s configured thresholds (not final-with-repair aggregates).

| Scenario | Aggregate Pass@1 | Gate Pass@1 | Graded Pass@1 | Thresholds | Qualified? | Report |
| --- | --- | --- | --- | --- | --- | --- |
| `ocr-extraction` | 1.00 | n/a | 1.00 | graded ≥ 0.90 | **yes** (extractor) | `reports/20261103T044619Z-ocr-extraction.md` |
| `pii-scrubbing` | 0.00 | n/a | 0.00 | graded ≥ 0.90 | no | `reports/20261103T044616Z-pii-scrubbing.md` |
| `scoped-coding` | 0.67 | n/a | 0.67 | graded ≥ 0.80 | no | `reports/20261103T045026Z-scoped-coding.md` |
| `qwen36-daily` | 0.89 | 0.67¹ | ~0.67² | gates = 1.0; graded ≥ 0.70 | no | `reports/20261103T050105Z-qwen36-daily.md` |

¹ `gate-hello` failed first attempt and required repair (final pass only).  
² Four of six graded tasks passed first attempt; `audit-three` failed; `erase-account` repaired.

Only the extractor shipping artifact from this campaign was promoted. Failed Nov 3 coder / sanitizer / scoped_coder JSON were not kept as active qualifications. Prior Oct sanitizer shipping for `glm47-reap` remains.

## Notes

- First attempt failed coding tasks in ~2s (Pi harness pointed at loopback). Re-run after pointing the Pi models config at the lab ingress URL.
- `node_class` in shipping JSON is generalized to `lab-gpu-32g` (no personal inventory hostname).
