# Fresh campaigns after Phases 0–6 deploy

This document is the **operator runbook** for Phase 7 graded campaigns. Do not
execute it until Phases 0–6 are merged and deployed. This scaffolding PR does
**not** submit Jobs, wake JARVIS, or regenerate qualifications.

## Preconditions (fail closed)

1. Homelab native `jarvis-gpu` Lease + Watchtower campaign Job path deployed.
2. Alpha first-attempt scoring, sandbox isolation, provenance/run manifests, and
   submission-only kick merged.
3. Alpha-lab Phase 0 archive in place (no active Own/Unattended routes).
4. Lab-owned scenarios + held-out `fixture_set_hash` + `trial_plan.yml` present.
5. Matching oracle-pass and nop-fail baselines for the **exact** scenario hash
   and Alpha harness revision about to run.
6. `schemas/statistical-protocol.v1.yml` pinned; cite `protocol_version: 1.0.0`.
7. Digest-pinned runner image and full 40-char SHAs for alpha, alpha-lab, and
   homelab-k3s (no `:latest`, no moving `main`).

If any precondition fails → **Not evaluated** / **Review required**. Never
enable Unattended.

## Submit (laptop = fire-and-disconnect)

From a launch client with cluster access (SSH to Watchtower or kube context):

```bash
export ALPHA_RUNNER_IMAGE='registry.example.local/alpha-runner@sha256:<digest>'
export ALPHA_GIT_SHA='<40-char alpha commit>'
export ALPHA_LAB_GIT_SHA='<40-char alpha-lab commit>'
export HOMELAB_GIT_SHA='<40-char homelab-k3s commit>'
# Optional explicit refs must equal those SHAs — never main/latest.
export ALPHA_ROOT='/path/to/alpha-lab'   # lab scenarios + protocol on the Job PVC/checkout

cd /path/to/alpha
./scripts/alpha_watchtower_kick.sh
# Print Job/run id, then exit. Safe to close laptop / sleep / power off.
```

The Watchtower Job owns: run id, Lease acquire/renew/release, JARVIS scale
0→1→0, heartbeat, bounded graded execution, artifact finalization.

## What the Job must run

1. Load `schemas/statistical-protocol.v1.yml` and record `protocol_id` +
   `protocol_version` on the run manifest.
2. Bind held-out fixtures via `fixture_set_hash` and execute
   `held_out/trial_plan.yml` seeds/instances (not answer-bearing shipping
   invariants).
3. Score First-attempt success with exact N/D; classify infra-invalid separately.
4. Compute Wilson 95% intervals; separate **coverage** from **reliability**.
5. Finalize `run_manifest.json`; keep raw traces under ignored `results/runs/`.
6. Publish only sanitized summary + report + (later) qualification into
   alpha-lab in one clean commit.

## Promote gate (after successful Job)

```bash
cd /path/to/alpha-lab
./scripts/validate-phase3-evidence-rules.sh
./scripts/validate-phase7-scaffold.sh
# Only when every Unattended criterion in the protocol is met AND
# unattended_enabled has been intentionally flipped in a later protocol bump:
#   bin/alpha qualify …   # still fail closed if index/prereqs missing
```

Until then:

- Keep top-level `qualifications/*__shipping.json` and `manifest.json` **absent**.
- Keep `notes/OPS_TRUST.md` disabled (**Review required**).
- Do not generate capability/delegation views that claim Unattended.

## Walk-away checklist

- [ ] Kick printed Job name + run id
- [ ] Laptop disconnected without interrupting the Job
- [ ] Job terminal status persisted; JARVIS scaled to 0; Lease released
- [ ] Sanitized bundle retrieved; secrets/topology scrubbed
- [ ] Report leads with Can do / Cannot reliably do / Not evaluated /
      Delegation decision / Evidence limits
- [ ] Supporting evidence holds hashes, Lease, and K8s details
- [ ] Active evidence index still absent unless every promote criterion passed
