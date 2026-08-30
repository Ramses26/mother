#!/usr/bin/env python3
"""
Docker-stats Prometheus exporter — replaces cAdvisor for per-container
CPU/memory/network metrics on this host.

Why: cAdvisor's docker-mode writable-layer lookup fails against this host's
containerd image store ("failed to identify the read-write layer ID"),
skipping every container. Pointing it at containerd directly (--containerd
flags) resolves it *temporarily* but the fix demonstrably degrades after
some uptime and needs a periodic restart (confirmed on both Mother and
Terminus, 2026-08-29) -- not a real fix, just a recurring workaround.

This exporter instead talks to the **Docker Engine API** directly (same
API `docker stats` itself uses), which has never had this problem -- it
doesn't touch containerd's storage layout at all, just the container
runtime's own stats endpoint. Polls in a background thread, serves a
cached Prometheus snapshot on /metrics so scrapes are always fast even
though Docker's stats call itself takes ~1s per container.
"""
import json
import os
import threading
import time

import requests
import requests_unixsocket
from flask import Flask, Response

# Talk to the Docker Engine API directly over the unix socket via plain HTTP,
# bypassing the docker-py SDK. docker-py's `container.stats(stream=False)`
# was found to hang indefinitely in this environment (confirmed 2026-08-29:
# even the first container's call never returned) -- a known-flaky wrapper
# around what the daemon actually serves as a single-chunk streaming
# response. Raw requests against the socket, with an explicit timeout,
# sidesteps it entirely.
SOCK = "http+unix://%2Fvar%2Frun%2Fdocker.sock"
_session = requests_unixsocket.Session()

app = Flask(__name__)
POLL_INTERVAL = int(os.environ.get("POLL_INTERVAL", "30"))

_lock = threading.Lock()
_cache = []


def _cpu_percent(stats):
    try:
        cpu_delta = (stats["cpu_stats"]["cpu_usage"]["total_usage"]
                     - stats["precpu_stats"]["cpu_usage"]["total_usage"])
        sys_delta = (stats["cpu_stats"].get("system_cpu_usage", 0)
                     - stats["precpu_stats"].get("system_cpu_usage", 0))
        online_cpus = stats["cpu_stats"].get("online_cpus") or len(
            stats["cpu_stats"]["cpu_usage"].get("percpu_usage") or [1])
        if sys_delta > 0 and cpu_delta > 0:
            return (cpu_delta / sys_delta) * online_cpus * 100.0
    except (KeyError, TypeError, ZeroDivisionError):
        pass
    return 0.0


def _mem_bytes(stats):
    try:
        usage = stats["memory_stats"]["usage"]
        cache = stats["memory_stats"].get("stats", {}).get("cache", 0)
        limit = stats["memory_stats"].get("limit", 0)
        return max(usage - cache, 0), limit
    except (KeyError, TypeError):
        return 0, 0


def _net_bytes(stats):
    rx = tx = 0
    for iface in (stats.get("networks") or {}).values():
        rx += iface.get("rx_bytes", 0)
        tx += iface.get("tx_bytes", 0)
    return rx, tx


def _list_containers():
    r = _session.get(f"{SOCK}/containers/json?all=true", timeout=10)
    r.raise_for_status()
    return r.json()


def _container_stats(cid):
    r = _session.get(f"{SOCK}/containers/{cid}/stats?stream=false", timeout=10)
    r.raise_for_status()
    return r.json()


def _poll_loop():
    while True:
        lines = [
            "# HELP docker_container_cpu_percent CPU usage percent (100 = 1 full core)",
            "# TYPE docker_container_cpu_percent gauge",
            "# HELP docker_container_memory_usage_bytes Memory usage (cache excluded)",
            "# TYPE docker_container_memory_usage_bytes gauge",
            "# HELP docker_container_memory_limit_bytes Memory limit",
            "# TYPE docker_container_memory_limit_bytes gauge",
            "# HELP docker_container_network_receive_bytes_total Cumulative network bytes received",
            "# TYPE docker_container_network_receive_bytes_total counter",
            "# HELP docker_container_network_transmit_bytes_total Cumulative network bytes transmitted",
            "# TYPE docker_container_network_transmit_bytes_total counter",
            "# HELP docker_container_up 1 if the container is running",
            "# TYPE docker_container_up gauge",
        ]
        try:
            containers = _list_containers()
        except Exception as e:  # noqa: BLE001
            with _lock:
                _cache[:] = [f'docker_stats_exporter_scrape_success 0  # {e}']
            time.sleep(POLL_INTERVAL)
            continue

        for c in containers:
            cid = c["Id"]
            name = c["Names"][0].lstrip("/") if c.get("Names") else cid[:12]
            image = c.get("Image", "unknown")
            labels = f'name="{name}",image="{image}"'
            if c.get("State") != "running":
                lines.append(f'docker_container_up{{{labels}}} 0')
                continue
            try:
                stats = _container_stats(cid)
            except Exception:
                lines.append(f'docker_container_up{{{labels}}} 0')
                continue
            lines.append(f'docker_container_up{{{labels}}} 1')
            lines.append(f'docker_container_cpu_percent{{{labels}}} {_cpu_percent(stats):.4f}')
            mem, limit = _mem_bytes(stats)
            lines.append(f'docker_container_memory_usage_bytes{{{labels}}} {mem}')
            lines.append(f'docker_container_memory_limit_bytes{{{labels}}} {limit}')
            rx, tx = _net_bytes(stats)
            lines.append(f'docker_container_network_receive_bytes_total{{{labels}}} {rx}')
            lines.append(f'docker_container_network_transmit_bytes_total{{{labels}}} {tx}')

        lines.append('docker_stats_exporter_scrape_success 1')
        with _lock:
            _cache[:] = lines
        time.sleep(POLL_INTERVAL)


@app.route("/metrics")
def metrics():
    with _lock:
        body = "\n".join(_cache) + "\n"
    return Response(body, mimetype="text/plain")


@app.route("/health")
def health():
    return {"ok": True}


if __name__ == "__main__":
    threading.Thread(target=_poll_loop, daemon=True).start()
    app.run(host="0.0.0.0", port=9330)
