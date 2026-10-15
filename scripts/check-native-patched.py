#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Actual installed patched SDK qualification."""
import argparse, os, pathlib, subprocess
p=argparse.ArgumentParser();p.add_argument('build',type=pathlib.Path);p.add_argument('specs',type=pathlib.Path);p.add_argument('work',type=pathlib.Path);a=p.parse_args()
if os.geteuid()==0: raise SystemExit('ordinary user required')
if a.work.exists(): raise SystemExit('fresh work directory required')
a.work.mkdir(parents=True)
probe=str((a.build/'native_probe').resolve()); elf=str((a.build/'native_smoke').resolve())
nm=subprocess.check_output(['nm',elf],text=True)
address=next('0x'+line.split()[0] for line in nm.splitlines() if line.split()[-1:] == ['native_smoke'])
def run(label,root,home,hint,expected=0,diagnostic=None):
    r=subprocess.run([probe,str(root),elf,address,hint],env=dict(os.environ,HOME=str(home)),text=True,capture_output=True)
    print(label,'exit=',r.returncode,flush=True);print(r.stdout,end='');print(r.stderr,end='')
    if r.returncode!=expected: raise SystemExit('unexpected exit '+label)
    if not expected and not all(x in r.stdout for x in ['completed=1 fallback=0','param_1 * 3 + 7']): raise SystemExit('missing semantic result '+label)
    if diagnostic and diagnostic not in r.stderr: raise SystemExit('missing diagnostic '+label)
for hint in ['x86:LE:64:default','']:
    tag='explicit' if hint else 'auto'
    external_home=a.work/('external-home-'+tag) # must not be created by external constructor
    run('external-'+tag,a.specs.resolve(),external_home,hint)
    if external_home.exists(): raise SystemExit('external path used HOME cache')
    home=(a.work/('embedded-home-'+tag)).resolve();home.mkdir()
    run('embedded-cold-'+tag,'',home,hint)
    if len(list(home.rglob('.complete')))!=1: raise SystemExit('cache sentinel absent')
    before={str(f.relative_to(home)):(f.stat().st_mtime_ns,f.stat().st_size) for f in home.rglob('*') if f.is_file()}
    run('embedded-warm-'+tag,'',home,hint)
    paths=list(home.rglob('*'))+[home];modes={x:x.stat().st_mode&0o777 for x in paths}
    try:
        for x in paths: x.chmod(modes[x]&~0o222)
        if any(os.access(x,os.W_OK) for x in paths): raise SystemExit('cache writable')
        run('embedded-warm-unwritable-'+tag,'',home,hint)
    finally:
        for x,mode in modes.items(): x.chmod(mode)
    after={str(f.relative_to(home)):(f.stat().st_mtime_ns,f.stat().st_size) for f in home.rglob('*') if f.is_file()}
    if before!=after: raise SystemExit('warm cache changed')
    run('embedded-cold-unwritable-'+tag,'',pathlib.Path('/proc'),hint,4,'failed to create cache dir')
    run('external-missing-'+tag,a.work/'absent',external_home,hint,4,'No sleigh specification')
    unreadable=a.work/('unreadable-'+tag);unreadable.mkdir();unreadable.chmod(0)
    try: run('external-unreadable-'+tag,unreadable,external_home,hint,4,'No sleigh specification')
    finally: unreadable.chmod(0o700)
print('ALL PATCHED PROFILE CONTROLS PASSED')
