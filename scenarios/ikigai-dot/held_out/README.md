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

- **Phase 3:** commit the hidden fixture set + `fixture_set.yml` hash identity.
  Do not publish an active evidence index or Unattended/delegation view.
- **Phase 7:** wire parameterized multi-seed evaluation against this set, then
  regenerate the active evidence index only if every mandatory prerequisite passes
  (including oracle-pass / nop-fail baselines for the exact scenario + harness hashes).

## Cases

See `cases/` — each file is a self-contained input + expected grading surface that
differs from the public fixed shipping prompt. Rotate or expand cases in Phase 7;
changing any case bytes changes `fixture_set_hash` in `fixture_set.yml`.
