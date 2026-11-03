# alpha-lab

Public **campaign artifacts** for [Alpha](https://github.com/bstruong/alpha): sanitized evaluation reports and qualification snapshots from self-hosted open-weight model runs.

This repository **consumes** Alpha; it is not the harness. The eval engine lives in `bstruong/alpha`. Inference wake/lease for the lab GPU stack lives in [homelab-k3s](https://github.com/bstruong/homelab-k3s) (`scripts/jarvis-*.sh`, `scripts/alpha-engine/`).

## Layout

```
reports/           # Human-readable campaign write-ups (sanitized)
qualifications/    # Shipping qualification JSON + manifest snapshots
```

## Running campaigns

```bash
# In a checkout of Alpha (or after installing the gem):
export OPENAI_BASE_URL="http://127.0.0.1:8080/v1"
# Optional: wake shared inference first (homelab-k3s)
#   ./scripts/jarvis-up.sh && ./scripts/jarvis-lease.sh acquire alpha-lab 90

bin/alpha run --scenario qwen36-daily --model <preset>
bin/alpha qualify --run <run_id> --role coder
# Copy generated qualifications/*.json into this repo when publishing a campaign.
```

## Sanitization

Files here must not contain personal emails, LAN/Tailscale IPs, MAC addresses, secrets, or private hostnames. Prefer `lab-node` / `example.local` fiction in fixtures and prose.

## License

Campaign text and JSON in this repo are published for transparency around Alpha eval methodology. Alpha itself is MIT-licensed.
