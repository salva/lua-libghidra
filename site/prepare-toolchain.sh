#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
# Explicit network-enabled preparation only; build/check never invoke this.
set -eu
[ "$#" = 1 ] || { echo 'usage: sh site/prepare-toolchain.sh ABSOLUTE_FRESH_DIRECTORY' >&2; exit 2; }
root=$1
case "$root" in /*) ;; *) exit 2 ;; esac
[ ! -e "$root" ] && [ ! -L "$root" ] || { echo 'fresh directory required' >&2; exit 2; }
# Use the same lock as local/CI builds; print shell-safe values through Lua.
values=$(lua5.4 - "$root" <<'LUA'
package.path='scripts/?.lua;site/?.lua;'..package.path
local c=require('content')
local lock=require('tool_json').decode(c.read('site/toolchain.lock.json'))
c.absolute(arg[1]); c.safe_path(arg[1],'fresh')
assert(lock.platform=='linux-amd64' and lock.sha256:match('^%x+$') and #lock.sha256==64)
assert(lock.url:match('^https://github.com/jgm/pandoc/releases/download/'))
c.relative(lock.executable)
for key,value in pairs{url=lock.url,hash=lock.sha256,executable=lock.executable,version=lock.version} do
  print(key..'='..c.quote(value))
end
LUA
) || exit 1
eval "$values"
mkdir "$root"
curl --fail --location --retry 2 "$url" -o "$root/pandoc.tar.gz"
printf '%s  %s\n' "$hash" "$root/pandoc.tar.gz" | sha256sum -c -
# Refuse unexpected archive paths/types before extraction.
tar -tzf "$root/pandoc.tar.gz" | while IFS= read -r path; do
  case "$path" in pandoc-*/bin/*|pandoc-*/share/*|pandoc-*/|pandoc-*/bin/|pandoc-*/share/) ;;
    *) echo 'unexpected converter archive path' >&2; exit 1 ;;
  esac
  case "/${path%/}/" in */../*|*/./*|*//*) exit 1 ;; esac
done
tar -xzf "$root/pandoc.tar.gz" -C "$root"
[ "$("$root/$executable" --version | head -n 1)" = "pandoc $version" ]
printf 'Prepared %s\n' "$root/$executable"
