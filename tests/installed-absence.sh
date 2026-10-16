#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Mount/network isolation is confined to a short-lived user namespace.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
prefix=$(realpath "${1:?installed prefix}")
work=${2:?fresh work directory}
[[ ! -e $work ]]
mkdir -p "$work/home"
work=$(realpath "$work")
export HOME="$work/home"
unshare -Urnm -- bash -s -- "$root" "$prefix" "$work" <<'ISOLATED'
set -euo pipefail
root=$1 prefix=$2 work=$3
mount --make-rprivate /
# Remove interpreters and their runtime trees, not merely PATH entries.
shopt -s nullglob
for p in /usr/bin/python* /usr/local/bin/python* /usr/bin/java /usr/bin/javac; do
 target=$(readlink -f "$p")
 [[ ! -f $target ]] || mount --bind /dev/null "$target"
done
for p in /usr/lib/python* /usr/local/lib/python* /usr/lib/jvm; do
 [[ ! -d $p ]] || mount -t tmpfs -o size=4k tmpfs "$p"
done
for name in python python3 python3.12 java javac; do
 if "$name" --version >/dev/null 2>&1; then echo "interpreter still usable: $name"; exit 1; fi
done
# Fresh network namespace: no routed interface, including no loopback setup.
# sysfs still reflects the parent mount; /proc/net is namespace-local.
[[ $(readlink /proc/self/ns/net) != $(readlink /proc/1/ns/net) ]]
! grep -qE 'eth[0-9]|en[[:alnum:]]+:' /proc/net/dev
[[ $(wc -l </proc/net/route) -le 1 ]]
printf 'isolated network and unusable Python/Java executables + masked runtime trees PASS\n'
for host in /usr/bin/lua5.4 "$root/build/boundary_static_host" "$root/build/boundary_shared_host"; do
 printf 'installed runtime host=%s prefix=%s\n' "$host" "$prefix"
 for test in installed_owner m2_slice m3_core m3_iterators; do
  "$host" "$root/tests/$test.lua" "$prefix" "$root"
 done
done
/usr/bin/lua5.4 "$root/tests/m3_persistence.lua" "$prefix" "$root" "$work"
printf 'installed standalone/static/shared real core runtime absence PASS\n'
ISOLATED
