#!/bin/bash
# Runs once via LinuxServer.io's s6 custom-cont-init.d hook, before qBittorrent starts.
#
# Every container recreation is a guaranteed-fresh process against a persistent
# /config volume. Any lockfile/ipc-socket left over from the previous container
# instance is therefore always stale by the time this runs -- a live conflict can
# only happen if qBittorrent were already running inside *this* container, which
# never occurs at startup. Safe to clear unconditionally.
#
# Root cause: 2026-07-19 and 2026-07-24 incidents -- qBittorrent crash-looped
# (new process every ~1s, clean exit, zero Docker-level restart signal) because a
# stale lockfile recorded the previous container's hostname and every new process
# got ECONNREFUSED handing off via ipc-socket. See /opt/mother/CLAUDE.md.
rm -f /config/qBittorrent/lockfile /config/qBittorrent/ipc-socket
