# Campaign notes — 2026-11-13 capability-map-v2

Lab consumer run of [Alpha](https://github.com/bstruong/alpha) against the shared OpenAI-compatible lab ingress (JARVIS wake/lease via [homelab-k3s](https://github.com/bstruong/homelab-k3s)). Full capability-map ladder: **ruby → frontend → hotwire → manifest** for `qwen36-coder-hybrid` and `glm47-reap`.

**Not qualified.** No top-level `qualifications/*__shipping.json` from this campaign (promote blocked; live map roles remain max rung L1 / credit 1.0 / not qualified). Failures are model/task outcomes, not infra.

## Job

| Field | Value |
| --- | --- |
| Job | `alpha-campaign-20261113-210218` |
| Phase | Complete 1/1 (exit 0) |
| Wall | ~74m (`21:02:21Z` → `22:16:38Z`) |
| Trials | **35 PASS / 3 FAIL / 0 INVALID** |
| Infra regressions | None (0 EROFS / Pi-not-found / gem fail-fast) |
| Log | `capability-map-v2-20261113T210229Z.log` → `=== DONE full capability-map … 22:16:36 UTC ===` |

## Pins

| Item | Value |
| --- | --- |
| Alpha | `f07fdc140cf4c5f0d193d571980c58e691a86765` ([alpha#55](https://github.com/bstruong/alpha/pull/55) EROFS / Pi overlay) |
| Homelab | `285fa439b860d2bdaa8a23a5223fca1b0fe816b0` |
| Alpha-lab | `2222ec84b8533a43b8b4abcff925245a7dee505d` |
| Runner image digest | `sha256:16df5877bfdbfbbd9bb99e41c40520dc8bd0427fc955020e440f6e67e93e3140` |
| `FROM` | `ruby` |

## Ladder scores

| Scenario | Shipping | Measurement |
| --- | --- | --- |
| `ruby-coding` | 2/2 both models | 4/4 both models |
| `frontend-coding` | 2/2 both models | qwen 4/4; glm **3/4** (1× `unknown`) |
| `hotwire-coding` | 2/2 both models | both **4/5** (`slice-note-tags`: qwen `wrong_file`, glm `tool_thrash`) |

## FAIL classes (3)

### 1. Frontend · `symptom-list-filter` · glm47-reap · measurement · `unknown`

| Field | Value |
| --- | --- |
| Run | `20261113T214112Z-frontend-coding` |
| Task | `symptom-list-filter` (L2, `frontend_js`, scaffold `symptom`) |
| Fail class | `unknown` (verifier fail, no path drift) |
| Ask | Fix catalog filter controller so typing narrows names (case-insensitive substring); empty query shows all |
| What went wrong | Edit stayed on the allowed path; suite green; product verifier failed (`catalog-query=ban` still showed Apple). 4 tool calls / ~30s |

### 2. Hotwire · `slice-note-tags` · qwen36-coder-hybrid · measurement · `wrong_file`

| Field | Value |
| --- | --- |
| Run | `20261113T215003Z-hotwire-coding` |
| Task | `slice-note-tags` (L4, `hotwire_vertical_slice`, scaffold `pm_ticket`) |
| Fail class | `wrong_file` |
| Ask | Optional `notes.tag` (migration + model), set tag on create, turbo-stream prepend, Stimulus `#tag-query` filter; keep title search + Rails tests green |
| What went wrong | Drifted `app/javascript/controllers/search_controller.js` (not in `stable_except`). Verifier: `#new-note` missing. 8 tools / ~391s |

### 3. Hotwire · `slice-note-tags` · glm47-reap · measurement · `tool_thrash`

| Field | Value |
| --- | --- |
| Run | `20261113T221004Z-hotwire-coding` |
| Task | same L4 vertical slice |
| Fail class | `tool_thrash` |
| What went wrong | Hit tool budget 24/24 (`exit_reason=tool_budget_exceeded`). No path drift; verifier still failed (`#note_tag` not present). ~160s |

## Capability TL;DR (`qwen36-coder-hybrid` · `glm47-reap`)

Both models **clear shipping** on ruby / frontend / hotwire (**2/2** each). Measurement is strong through mid ladder: **ruby 4/4 both**; **frontend** qwen **4/4**, glm **3/4** (one L2 filter miss); **hotwire** both **4/5**, shared miss only on **L4 `slice-note-tags`**.

Practical read: these local LLMs are **reliable for small Rails/Stimulus/Hotwire repairs under review**, not yet for **unattended multi-file Hotwire vertical slices**—qwen wanders into the wrong JS file; glm burns the tool budget without shipping `#note_tag`.

## Notes

- Suite/runner stable vs earlier Pi/gems/EROFS fail-fast Jobs: doctor OK, graded trials with tools>0 throughout; lease released cleanly after session end.
- No slim per-trial `reports/` promoted here (raw graded markdown not sanitized for this publish). Durable record is this note only.
- Do **not** treat this campaign as shipping qualification evidence.
