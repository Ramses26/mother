# Action items (2026-08-29 session)

Not documentation — working list for Ali. Check items off / delete as done.

## 🔴 Backups — Mother has none, Terminus has a real fix + a small cleanup

- [ ] **Mother's Backrest is deployed but completely unconfigured** — no repos, no plans, empty config. `scripts/backup.sh` exists but isn't scheduled anywhere (checked crontab — nothing) and defaults to writing locally to `/opt/mother/backups`, same disk as everything else (`/dev/mapper/ubuntu--vg-ubuntu--lv`, 74% used) — zero off-box protection even if it ran. Mother is a **VMware VM** — worth asking Chris directly whether there's hypervisor-level snapshot/backup happening (invisible from inside the guest, can't confirm either way from here). **Needs your call on a destination** (Unraid's `/mnt/unraid/home` share, matching Terminus's pattern, is one option — already mounted) before I configure it.
- [ ] Terminus's backup repo (`restic check`, run live 2026-08-29) has **one broken snapshot** — `55b1c4fa`, dated 2026-02-07, several missing blobs. Isolated: all 150 other snapshots including every recent nightly are fine, and a real restore (`latest`) never touches it. Cleanup command is in the new wiki doc — not run automatically (deletion is one-way).
- [x] Built `scripts/restore-terminus.sh` (committed to Terminus's repo locally, **not pushed** — review first, don't want to trigger their auto-deploy on an unrelated push) + a full **Terminus Disaster Recovery** wiki doc. Covers the real bootstrapping problem: the CIFS credentials to reach the backup repo, and the repo's own encryption password, are both *outside* the backup itself (can't recover them from the thing they protect) — store both in a password manager now, before you need them.
- [ ] The restore procedure has **not been end-to-end tested** against a real fresh host. Worth a deliberate rehearsal (wipe a test VM, run it top to bottom) rather than finding out during a real emergency.

## UniFi
- [x] ~~**Syslog forwarding ... not actually delivering — likely a UniFi firmware bug**~~ — **WRONG DIAGNOSIS, root-caused 2026-08-31.** The gateways were emitting syslog the whole time. Alloy's `loki.source.syslog` defaults to **RFC5424**, but UniFi/UDM emits legacy BSD-style **RFC3164** — every packet was rejected at the parser with `expecting a version value in the range 1-999 [col 4]`. Mother's Alloy had logged **5,370 of these in a single 2-hour window** while `service="unifi"` didn't exist as a Loki label at all. Found on Terminus first, identical bug on Mother. Fix: `syslog_format = "rfc3164"` in the listener block (`configs/alloy/config.alloy`). Verified: 0 parse errors since restart, UniFi lines now landing in Loki. **No Ubiquiti support ticket needed.** Lesson: "receiver is up + sender is configured + nothing in Loki" does not mean nothing is arriving — check the receiver's own logs for parse rejections before blaming the sender.
- [x] ~~Gomaa UCG syslog not arriving on Mother~~ — **not a defect, that's the design.** Each site ships to its own local Loki: Stuttler's UDM (10.0.0.1) → Mother, Gomaa's UCG (192.168.1.1) → Terminus. Cross-site correlation is done in Grafana through the already-live federated datasources (`loki-terminus` on Mother, `loki-mother` on Terminus), not by pointing both gateways at one collector. Mother receiving only `StuttlerNet ...` lines is correct — don't "fix" it by re-adding Gomaa here.
- [x] ~~Apply the rfc3164 + host-label changes to Terminus's Alloy~~ — **already done there**; verified live 2026-08-31: Terminus's Loki is ingesting `{host="gomaa-udm", job="syslog", service="unifi"}` at ~658 entries/30min. Mother's host label was renamed `unifi-stuttler` → **`stuttler-udm`** to match Terminus's existing convention (`service="unifi"` deliberately identical on both so a federated `{service="unifi"}` query returns both sites, with `host` distinguishing them).
- [ ] 🔴 **Unraid stopped shipping logs to Terminus's Loki at 2026-08-31 01:06 UTC** (~14.5h before this was noticed). Every `host="unraid"` stream — `Notifiarr`, `node-exporter`, `docker-stats-exporter` — cuts off within the same 9 seconds (01:05:52–01:06:01), which points at Alloy on Unraid dying rather than individual containers. Nothing alerted on it. Check: `ssh -i ~/.ssh/unraid_key root@192.168.1.10 "docker ps -a | grep alloy; docker logs alloy --tail 50"`. Config is `remote-hosts/unraid/alloy/` (correctly targets `192.168.1.14:3100`, so this isn't the two-Loki confusion). **Worth a follow-on: there is no alert for "a host stopped shipping logs"** — this and the UniFi parse bug were both found by hand. A Grafana rule on `absent_over_time({host="unraid"}[30m])` per expected host would have caught both.
- [ ] Pair the two sites in **UniFi Site Manager** (unifi.ui.com) and enable **Site Magic** site-to-site. Verified feasible — both gateways already have WireGuard keys generated (`magic_site_to_site_vpn` enabled=true on both). Keep the manual IPsec tunnel as fallback until Site Magic is confirmed stable.
- [ ] Gomaa network optimization (from the UniFi wiki doc — full detail there): add an IoT VLAN, map the `Pharaohs Reign-IoT` SSID to it, add a Guest VLAN, update controller (10.5.67 → latest), consider WPA3-mixed.
- [ ] Confirm WAN2's real ISP throughput via UniFi app → Settings → Internet → WAN2 → Speed Test (API couldn't target WAN2 specifically — always tested WAN1 regardless of params tried).

## Grafana / Loki federation — DONE, both directions verified live
- [x] Mother's Grafana → Terminus's Loki (`loki-terminus` datasource) — confirmed, real data returned.
- [x] Terminus's Grafana → Mother's Loki (`loki-mother` datasource) — confirmed live 2026-08-29 with the password you gave me (now stored in `/home/alig/secrets/monitoring.env` on Terminus as `GRAFANA_ADMIN_PASSWORD`).
- [ ] `grafana/provisioning/datasources/loki-mother.yml` was written directly onto Terminus's disk, **not committed** — that repo has other uncommitted work in progress from your other Claude session, wasn't mine to sweep into a commit. Commit it separately when convenient.
- [ ] Terminus's `alloy/config.alloy` (syslog receiver, below) and `docker-compose.yml` (its port mapping) also have **uncommitted changes** now, same reason.

## Nostromo / Plex
- [ ] Add an Uptime Kuma monitor for Nostromo's Plex — see the full Uptime Kuma section below (folded in there now instead of standalone).
- [ ] Consider Plex's own **Settings → Troubleshooting → Optimize Database / Clean Bundles** periodically (official tooling; DB itself is healthy — 1.33GB, 208k media parts, `freelist_count=0` = no bloat, checked 2026-08-29).
- [x] Nostromo Plex systemd hardened with `MemoryMax=12G`/`MemoryHigh=10G`/`WatchdogSec=300` (matches Hathor's pattern, Nostromo didn't have it before) — done, no restart needed to apply.

## Uptime Kuma — build out Mother's coverage (currently 1 monitor vs Terminus's 8)
Terminus's Kuma (`http://192.168.1.14:3001`) already has a good pattern worth mirroring: an `active` toggle per monitor, HTTP checks with `interval=60`/`retry_interval=60`, `ping` checks by hostname, and a `group` type used as a folder to nest related monitors. All URLs below verified reachable (2026-08-29) before listing — add these in **Mother's Uptime Kuma** (`http://10.0.0.162:3001`):

**Group: "Mother Services"** — create this as a Group monitor first, then add each below with Parent = this group.

| Name | Type | URL | Interval | Retry |
|---|---|---|---|---|
| sync-webhook | HTTP | `http://sync-webhook:5000/health` | 60 | 60 |
| Curatorr | HTTP | `http://curatorr:8000/api/health` | 60 | 60 |
| Upgraderr | HTTP | `http://upgraderr:5000/health` | 60 | 60 |
| Radarr HD | HTTP | `http://radarr-hd:7878/ping` | 60 | 60 |
| Radarr 4K | HTTP | `http://radarr-4k:7878/ping` | 60 | 60 |
| Sonarr HD | HTTP | `http://sonarr-hd:8989/ping` | 60 | 60 |
| Sonarr 4K | HTTP | `http://sonarr-4k:8989/ping` | 60 | 60 |
| Prowlarr | HTTP | `http://prowlarr:9696/ping` | 60 | 60 |
| Grafana | HTTP | `http://grafana:3000/api/health` | 60 | 60 |
| Loki | HTTP | `http://loki:3100/ready` | 60 | 60 |
| Prometheus | HTTP | `http://prometheus:9090/-/healthy` | 60 | 60 |
| Dockhand | HTTP | `http://dockhand:3000/api/health` | 60 | 60 |

Note: since Uptime Kuma runs as a container on `mother_network`, use the **container names** above (not `localhost`) — matches how the container actually reaches its neighbors. If you'd rather test from a browser first, the host-side equivalents (verified 200 today) are `http://10.0.0.162:<port><path>` for each (5001/9707/9706/7878/7879/8989/8990/9696/3003/3100/9090/3000 respectively).

**Group: "Remote Hosts"** — cross-network reachability, mirrors Terminus's "Mother VM Monitoring" pattern (watch the *other* side's key host from here too):

| Name | Type | Target | Interval | Retry |
|---|---|---|---|---|
| Nostromo (Plex) | HTTP | `http://10.0.0.250:32400/identity` | 60 | 60 |
| Unraid | Ping | `192.168.1.10` | 60 | 60 |
| Terminus | Ping | `192.168.1.14` | 60 | 60 |
| Download Synology | Ping | `10.0.1.203` | 60 | 60 |
| Stuttler UDM Gateway | Ping | `10.0.0.1` | 60 | 60 |
| Gomaa UCG Gateway | Ping | `192.168.1.1` | 60 | 60 |

The two gateway pings double as a rough site-to-site tunnel health signal (if the Gomaa UCG ping starts failing while Unraid's also unreachable, that's the tunnel, not just one host) — complements the Prometheus-based `unifi-exporter` alert, doesn't replace it.

Not written directly to Kuma's DB — no safe REST API for this version (Socket.IO only, confirmed earlier), and direct SQLite writes risk not reflecting in its running state. Add via the UI: **+ Add New Monitor** for each row above.

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
