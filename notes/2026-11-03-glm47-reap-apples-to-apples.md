# Campaign notes — 2026-11-03 glm47-reap apples-to-apples

Lab consumer run of [Alpha](https://github.com/bstruong/alpha) against a local OpenAI-compatible endpoint (homelab JARVIS wake/lease via [homelab-k3s](https://github.com/bstruong/homelab-k3s)).

## Layout used

| Piece | Role |
| --- | --- |
| `alpha` | Harness (`bin/alpha run` / `qualify`) |
| `homelab-k3s` | `jarvis-up` / `jarvis-lease` / `jarvis-down` |
| `alpha-lab` | Published reports + shipping qualifications |

## Results (`glm47-reap`, shipping)

| Scenario | Pass@1 | Qualified? | Report |
| --- | --- | --- | --- |
| `ocr-extraction` | 1.00 | yes (extractor) | `reports/20261103T044619Z-ocr-extraction.md` |
| `pii-scrubbing` | 0.00 | no | `reports/20261103T044616Z-pii-scrubbing.md` |
| `scoped-coding` | 0.67 | no | `reports/20261103T045026Z-scoped-coding.md` |
| `qwen36-daily` | 0.89 | yes (coder) | `reports/20261103T050105Z-qwen36-daily.md` |

## Notes

- First attempt failed coding tasks in ~2s (Pi harness pointed at loopback). Re-run after pointing the Pi models config at the lab ingress URL.
- `node_class` in shipping JSON is generalized to `lab-gpu-32g` (no personal inventory hostname).
