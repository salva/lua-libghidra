#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
set -eu
root= bind= port=
while [ "$#" -gt 0 ]; do
  [ "$#" -ge 2 ] || { echo 'option requires value' >&2; exit 2; }
  case "$1" in
    --root) [ -z "$root" ] || exit 2; root=$2 ;;
    --bind) [ -z "$bind" ] || exit 2; bind=$2 ;;
    --port) [ -z "$port" ] || exit 2; port=$2 ;;
    *) echo 'unknown option' >&2; exit 2 ;;
  esac
  shift 2
done
[ "$bind" = 127.0.0.1 ] || { echo 'loopback --bind 127.0.0.1 required' >&2; exit 2; }
case "$root" in /*) ;; *) echo 'absolute --root required' >&2; exit 2 ;; esac
[ -d "$root" ] && [ ! -L "$root" ] || { echo 'regular directory root required' >&2; exit 2; }
case "$port" in ''|*[!0-9]*) exit 2 ;; esac
[ "$port" -ge 1024 ] && [ "$port" -le 65535 ] || exit 2
command -v busybox >/dev/null 2>&1 || { echo 'Optional preview prerequisite unavailable: BusyBox httpd' >&2; exit 1; }
busybox --list | grep -qx httpd || { echo 'BusyBox lacks httpd' >&2; exit 1; }
echo "Serving $root on http://$bind:$port/ (foreground; Ctrl-C to stop)"
exec busybox httpd -f -p "$bind:$port" -h "$root"
