# Action items (2026-08-29 session)

Not documentation — working list for Ali. Check items off / delete as done.

## UniFi
- [ ] **Syslog forwarding is configured correctly on both gateways but not actually delivering — likely a UniFi firmware bug, not our setup.** Both UDMs (Stuttler 10.0.0.1, Gomaa UCG 192.168.1.1) have "SIEM Server" logging `enabled: true`, correct target IP/port, all relevant categories selected (config verified round-trip via API). Both receivers (Mother :51514, Terminus :51514) are confirmed working — proven via a real cross-device UDP test (Unraid → Terminus landed instantly) and manual test packets. Tried, no effect on either: force-provisioning the gateway, toggling the setting off/on via API. Conclusion: the devices aren't actually emitting syslog despite the setting reading as active — same symptom independently on two different gateway models, so likely a real UniFi bug in this firmware's SIEM Server feature, not a config/network issue on our end. **Next step: open a Ubiquiti support ticket**, or try a manual UI-side toggle (off/save/on/save) in case it behaves differently from the API path. Not blocking anything — the Prometheus-based VPN/WAN alerting (unifi-exporter) is independent of syslog and already fully live.
- [ ] Pair the two sites in **UniFi Site Manager** (unifi.ui.com) and enable **Site Magic** site-to-site. Verified feasible — both gateways already have WireGuard keys generated (`magic_site_to_site_vpn` enabled=true on both). Keep the manual IPsec tunnel as fallback until Site Magic is confirmed stable.
- [ ] Gomaa network optimization (from the UniFi wiki doc — full detail there): add an IoT VLAN, map the `Pharaohs Reign-IoT` SSID to it, add a Guest VLAN, update controller (10.5.67 → latest), consider WPA3-mixed.
- [ ] Confirm WAN2's real ISP throughput via UniFi app → Settings → Internet → WAN2 → Speed Test (API couldn't target WAN2 specifically — always tested WAN1 regardless of params tried).

## Grafana / Loki federation — DONE, both directions verified live
- [x] Mother's Grafana → Terminus's Loki (`loki-terminus` datasource) — confirmed, real data returned.
- [x] Terminus's Grafana → Mother's Loki (`loki-mother` datasource) — confirmed live 2026-08-29 with the password you gave me (now stored in `/home/alig/secrets/monitoring.env` on Terminus as `GRAFANA_ADMIN_PASSWORD`).
- [ ] `grafana/provisioning/datasources/loki-mother.yml` was written directly onto Terminus's disk, **not committed** — that repo has other uncommitted work in progress from your other Claude session, wasn't mine to sweep into a commit. Commit it separately when convenient.
- [ ] Terminus's `alloy/config.alloy` (syslog receiver, below) and `docker-compose.yml` (its port mapping) also have **uncommitted changes** now, same reason.

## Nostromo / Plex
- [ ] Add an Uptime Kuma monitor for Nostromo's Plex (mirrors Terminus's existing "Plex on Hathor" pattern): **Mother's Uptime Kuma** → Add Monitor → HTTP → `http://10.0.0.250:32400/identity`.
- [ ] Consider Plex's own **Settings → Troubleshooting → Optimize Database / Clean Bundles** periodically (official tooling; DB itself is healthy — 1.33GB, 208k media parts, `freelist_count=0` = no bloat, checked 2026-08-29).
- [x] Nostromo Plex systemd hardened with `MemoryMax=12G`/`MemoryHigh=10G`/`WatchdogSec=300` (matches Hathor's pattern, Nostromo didn't have it before) — done, no restart needed to apply.

## Terminus stack — findings from this session's audit (yours to triage, not touched)
- **8 unhealthy containers**: workout-api, mealie, lubelogger, outline, cloudflare-ddns, dockhand, termix, dozzle. Outline is the one you actively use for the wiki — worth a first look.
- **Duplicate `tracearr` + `tracearr-db` + `tracearr-redis`** stack running on Terminus in addition to Mother's — intentional (per-Plex-server tracking) or leftover duplication? Worth confirming.
- **Duplicate `dockhand`** on Terminus (also unhealthy) — same broken-Telegram issue as Mother's likely applies.
- **cadvisor on Terminus** — already had the same `--containerd` fix I applied on Mother (not a config bug); I restarted it 2026-08-29 to clear its accumulated errors. Same caveat as Mother's: this fix **degrades over time** (works after a restart, drifts back to erroring after some uptime) — a known cAdvisor/containerd flakiness, not something either of us has fully solved. If it starts erroring again, `docker restart cadvisor` is the workaround; a real fix would mean swapping it for a different exporter (deferred on Mother too, see below).
- **Version drift vs Mother**: Loki 2.9.8 (Mother: 3.4.2), Prometheus v2.51.2 (Mother: v3.3.1), Grafana `latest`/unpinned (Mother: pinned 11.6.0).
- Mother's Uptime Kuma has only **1 monitor** vs Terminus's 8 — worth building out proper Mother-side coverage (services, VPN, key containers) to match.

## Deferred from earlier
- [x] Replaced cAdvisor on Mother with a custom `docker-stats-exporter` (talks to the Docker Engine API directly, sidesteps the containerd bug entirely — no more periodic restarts). cAdvisor container removed. Verified: real CPU/mem/network data for all 32 containers. Metrics: `docker_container_{up,cpu_percent,memory_usage_bytes,memory_limit_bytes,network_receive_bytes_total,network_transmit_bytes_total}`.
- [ ] Same swap on Terminus (still has the flaky cAdvisor, currently working after a manual restart) — not done, that's their stack; can port the same service there if wanted.
