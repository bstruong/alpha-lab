# Held-out qualification fixtures (ikigai-dot)

These cases are **not** part of the evaluated agent's visible task tree.

## Visibility rules

- Prompt-visible shipping/measurement content lives only under `../tasks/*/instruction.md`
  (and the sandbox `library/` app). Answer-bearing `invariant.md` files are for
  oracle/debug profiles only and must not be injected into shipping/measurement prompts.
- Everything under this `held_out/` directory is harness/qualification material.
  It must never be copied into the sandbox app, never listed in agent mounts, and
  never appended to evaluated prompts.
- Graded campaign Jobs on Watchtower may load these fixtures through the harness
  only. Laptops must not host graded runners.

## Phase boundary

- **Phase 3:** hidden fixture set + `fixture_set.yml` hash identity.
- **Phase 7 (this scaffold):** parameterized multi-instance cases +
  `trial_plan.yml` seed/instance declarations bound to
  `schemas/statistical-protocol.v1.yml`. Do **not** publish an active evidence
  index or Unattended routes until Phases 0–6 deploy and a fresh pinned campaign
  meets every protocol criterion (including oracle-pass / nop-fail baselines).

## Coverage vs reliability

- **Coverage:** exercising each shipping task/skill at least once
  (`trial_plan.yml` → `coverage`).
- **Reliability:** repeating across declared seeds × instances
  (`trial_plan.yml` → `reliability` + `instances`).

Single-pass shipping proportions are coverage, not Unattended reliability.

## Cases

See `cases/` — each file is a self-contained input + expected grading surface that
differs from the public fixed shipping prompt. Each shipping task has ≥2
parameterized instances (`case-01`, `case-02`). Changing any case or
`trial_plan.yml` bytes changes `fixture_set_hash` in `fixture_set.yml`.
