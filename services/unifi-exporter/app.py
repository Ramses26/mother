#!/usr/bin/env python3
"""
UniFi Prometheus exporter — polls both sites' UniFi controllers (Stuttler +
Gomaa) for WAN/VPN health and exposes Prometheus metrics. Built 2026-08-29
after a VPN MSS/MTU issue caused a throughput collapse that went undetected
for hours — this closes that gap so a tunnel drop or WAN failover pages
Mother Notifications within a scrape interval.

Metrics (all labeled site="stuttler"|"gomaa"):
  unifi_vpn_status              1=ok, 0=error
  unifi_vpn_active_tunnels
  unifi_vpn_inactive_tunnels
  unifi_wan_status{wan="wan1"|"wan2"}   1=ok, 0=error/down
  unifi_wan_latency_ms{wan=...}
  unifi_scrape_success           1=last poll of this site succeeded, 0=failed
"""
import os
import subprocess
import time
import threading
import requests
from flask import Flask, Response

app = Flask(__name__)

SITES = {
    "stuttler": {"gw": os.environ.get("UNIFI_STUTTLER_GW", "10.0.0.1"),
                 "key": os.environ.get("UNIFI_STUTTLER_API_KEY", "")},
    "gomaa":    {"gw": os.environ.get("UNIFI_GOMAA_GW", "192.168.1.1"),
                 "key": os.environ.get("UNIFI_GOMAA_API_KEY", "")},
}
POLL_INTERVAL = int(os.environ.get("UNIFI_POLL_INTERVAL", "30"))

_lock = threading.Lock()
_cache = {}  # site -> list of metric lines


def _poll_site(name, cfg):
    lines = []
    if not cfg["key"]:
        lines.append(f'unifi_scrape_success{{site="{name}"}} 0')
        return lines
    try:
        r = requests.get(
            f"https://{cfg['gw']}/proxy/network/api/s/default/stat/health",
            headers={"X-API-KEY": cfg["key"], "Accept": "application/json"},
            verify=False, timeout=10,
        )
        r.raise_for_status()
        data = r.json().get("data", [])
        vpn = next((s for s in data if s.get("subsystem") == "vpn"), None)
        if vpn:
            lines.append(f'unifi_vpn_status{{site="{name}"}} '
                         f'{1 if vpn.get("status") == "ok" else 0}')
            lines.append(f'unifi_vpn_active_tunnels{{site="{name}"}} '
                         f'{vpn.get("site_to_site_num_active", 0)}')
            lines.append(f'unifi_vpn_inactive_tunnels{{site="{name}"}} '
                         f'{vpn.get("site_to_site_num_inactive", 0)}')
        for sub in data:
            if sub.get("subsystem") == "www":
                lines.append(f'unifi_wan_status{{site="{name}",wan="primary"}} '
                             f'{1 if sub.get("status") == "ok" else 0}')
                if sub.get("latency") is not None:
                    lines.append(f'unifi_wan_latency_ms{{site="{name}",wan="primary"}} '
                                 f'{sub.get("latency")}')
        lines.append(f'unifi_scrape_success{{site="{name}"}} 1')
    except Exception:
        lines.append(f'unifi_scrape_success{{site="{name}"}} 0')
    return lines


def _ping_check(label, host):
    """Real reachability across the tunnel — UniFi's own 'vpn' health
    subsystem was found unreliable (reports status=error/0-active-tunnels/
    0-bytes even while traffic demonstrably flows), so don't alert on that
    field. This is the trustworthy signal: can Mother actually reach a host
    on the far side right now."""
    try:
        r = subprocess.run(["ping", "-c", "2", "-W", "2", host],
                           capture_output=True, timeout=8)
        return f'unifi_tunnel_reachable{{peer="{label}"}} {1 if r.returncode == 0 else 0}'
    except Exception:
        return f'unifi_tunnel_reachable{{peer="{label}"}} 0'


def _poll_loop():
    while True:
        for name, cfg in SITES.items():
            lines = _poll_site(name, cfg)
            with _lock:
                _cache[name] = lines
        with _lock:
            _cache["_reachability"] = [
                _ping_check("gomaa_gateway", "192.168.1.1"),
                _ping_check("unraid", "192.168.1.10"),
            ]
        time.sleep(POLL_INTERVAL)


@app.route("/metrics")
def metrics():
    with _lock:
        out = []
        for lines in _cache.values():
            out.extend(lines)
    return Response("\n".join(out) + "\n", mimetype="text/plain")


@app.route("/health")
def health():
    return {"ok": True, "sites": list(SITES.keys())}


if __name__ == "__main__":
    import urllib3
    urllib3.disable_warnings()
    threading.Thread(target=_poll_loop, daemon=True).start()
    app.run(host="0.0.0.0", port=9110)
