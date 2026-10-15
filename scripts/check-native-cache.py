#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Isolated cold/warm/read-only profiles."""
import argparse, os, pathlib, subprocess
p=argparse.ArgumentParser()
p.add_argument('probe',type=pathlib.Path)
p.add_argument('binary',type=pathlib.Path)
p.add_argument('home',type=pathlib.Path)
p.add_argument('address')
a=p.parse_args()
if a.home.exists(): raise SystemExit('HOME must be fresh')
if os.geteuid()==0: raise SystemExit('Run as ordinary user, not root')
a.home.mkdir(parents=True)
env=dict(os.environ, HOME=str(a.home.resolve()))
def run(profile):
    result=subprocess.run([str(a.probe.resolve()),'',str(a.binary.resolve()),a.address,''],env=env,text=True,capture_output=True)
    print(profile,'exit=',result.returncode,flush=True)
    print(result.stdout,end=''); print(result.stderr,end='')
    if result.returncode or 'completed=1 fallback=0' not in result.stdout or 'param_1 * 3 + 7' not in result.stdout:
        raise SystemExit('profile failed: '+profile)
run('cold')
sentinels=list(a.home.rglob('.complete'))
if len(sentinels)!=1: raise SystemExit('expected one extracted cache sentinel')
before={str(f.relative_to(a.home)): (f.stat().st_mtime_ns,f.stat().st_size) for f in a.home.rglob('*') if f.is_file()}
run('warm')
paths=list(a.home.rglob('*'))+[a.home]
modes={x:x.stat().st_mode & 0o777 for x in paths}
try:
    for x in paths: x.chmod(modes[x] & ~0o222)
    if any(os.access(x,os.W_OK) for x in paths): raise SystemExit('cache still writable')
    run('warm-unwritable')
finally:
    for x,mode in modes.items(): x.chmod(mode)
after={str(f.relative_to(a.home)): (f.stat().st_mtime_ns,f.stat().st_size) for f in a.home.rglob('*') if f.is_file()}
if before!=after: raise SystemExit('warm cache changed')
print('Sentinel/files unchanged; ordinary-user read-only cache reuse verified')
