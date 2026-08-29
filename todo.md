# Action items (2026-08-29 session)

Not documentation — working list for Ali. Check items off / delete as done.

## UniFi
- [ ] Enable remote syslog on **both** UDMs: Settings → System → Logging → Remote Syslog Server → `10.0.0.162` / UDP `51514` (Stuttler UDM at 10.0.0.1, Gomaa UCG at 192.168.1.1). Receiver is already listening on Mother.
- [ ] Pair the two sites in **UniFi Site Manager** (unifi.ui.com) and enable **Site Magic** site-to-site. Verified feasible — both gateways already have WireGuard keys generated (`magic_site_to_site_vpn` enabled=true on both). Keep the manual IPsec tunnel as fallback until Site Magic is confirmed stable.
- [ ] Gomaa network optimization (from the UniFi wiki doc — full detail there): add an IoT VLAN, map the `Pharaohs Reign-IoT` SSID to it, add a Guest VLAN, update controller (10.5.67 → latest), consider WPA3-mixed.
- [ ] Confirm WAN2's real ISP throughput via UniFi app → Settings → Internet → WAN2 → Speed Test (API couldn't target WAN2 specifically — always tested WAN1 regardless of params tried).

## Grafana / Loki federation
- [ ] Terminus's Grafana admin password unknown to me — verify the new **"Loki (Mother)"** datasource (uid `loki-mother`) works from the UI (Mother→Terminus direction already confirmed working from this end).
- [ ] `configs/grafana/provisioning/datasources/loki-mother.yml` was written directly onto `/home/alig/terminus/grafana/provisioning/datasources/` — **not committed**, since that repo has other uncommitted work in progress from your other Claude session. Commit it separately when convenient (or let that session fold it in).

## Nostromo / Plex
- [ ] Add an Uptime Kuma monitor for Nostromo's Plex (mirrors Terminus's existing "Plex on Hathor" pattern): **Mother's Uptime Kuma** → Add Monitor → HTTP → `http://10.0.0.250:32400/identity`.
- [ ] Consider Plex's own **Settings → Troubleshooting → Optimize Database / Clean Bundles** periodically (official tooling; DB itself is healthy — 1.33GB, 208k media parts, `freelist_count=0` = no bloat, checked 2026-08-29).
- [x] Nostromo Plex systemd hardened with `MemoryMax=12G`/`MemoryHigh=10G`/`WatchdogSec=300` (matches Hathor's pattern, Nostromo didn't have it before) — done, no restart needed to apply.

## Terminus stack — findings from this session's audit (yours to triage, not touched)
- **8 unhealthy containers**: workout-api, mealie, lubelogger, outline, cloudflare-ddns, dockhand, termix, dozzle. Outline is the one you actively use for the wiki — worth a first look.
- **Duplicate `tracearr` + `tracearr-db` + `tracearr-redis`** stack running on Terminus in addition to Mother's — intentional (per-Plex-server tracking) or leftover duplication? Worth confirming.
- **Duplicate `dockhand`** on Terminus (also unhealthy) — same broken-Telegram issue as Mother's likely applies.
- **cadvisor on Terminus has the same containerd/overlayfs bug** I fixed on Mother (90 "read-write layer" errors/2min, same `overlayfs` storage driver) — same fix (`--containerd` flags) would apply if you want per-container metrics there.
- **Version drift vs Mother**: Loki 2.9.8 (Mother: 3.4.2), Prometheus v2.51.2 (Mother: v3.3.1), Grafana `latest`/unpinned (Mother: pinned 11.6.0).
- Mother's Uptime Kuma has only **1 monitor** vs Terminus's 8 — worth building out proper Mother-side coverage (services, VPN, key containers) to match.

## Deferred from earlier (still open)
- Swap flaky cAdvisor on Mother for a lighter docker-stats exporter (cosmetic, not blocking) — low priority.
