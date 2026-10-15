#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Preserve unmodified BFD gap evidence.

This regression expects the known failures, NOT readiness. It fails if any
branch changes so a future upstream repair requires explicit requalification.
"""
import argparse,pathlib,subprocess
p=argparse.ArgumentParser();p.add_argument('build',type=pathlib.Path);p.add_argument('specs');p.add_argument('work',type=pathlib.Path);a=p.parse_args()
a.work.mkdir(parents=True,exist_ok=True)
probe=str((a.build/'native_probe').resolve());elf=str((a.build/'native_smoke').resolve());raw=str((a.work/'smoke-text.raw').resolve())
subprocess.run(['objcopy','-O','binary','--only-section=.text',elf,raw],check=True)
nm=subprocess.check_output(['nm',elf],text=True)
address=next('0x'+line.split()[0] for line in nm.splitlines() if line.split()[-1:] == ['native_smoke'])
sections=subprocess.check_output(['objdump','-h',elf],text=True)
base=next('0x'+line.split()[3] for line in sections.splitlines() if len(line.split())>3 and line.split()[1]=='.text')
for name,file,language,fmt,vma in [('elf-explicit',elf,'x86:LE:64:default','','0'),('elf-format-raw',elf,'x86:LE:64:default','raw','0'),('raw-explicit',raw,'x86:LE:64:default','raw',base)]:
    r=subprocess.run([probe,a.specs,file,address,language,fmt,vma],text=True,capture_output=True)
    print(name,'exit=',r.returncode);print(r.stdout,end='');print(r.stderr,end='')
    if r.returncode!=4 or 'Unable to open image file:' not in r.stderr:
        raise SystemExit('Known gap changed: requalify '+name)
r=subprocess.run([probe,a.specs,elf,address,''],text=True,capture_output=True)
print('elf-auto control exit=',r.returncode);print(r.stdout,end='');print(r.stderr,end='')
if r.returncode or 'param_1 * 3 + 7' not in r.stdout or 'completed=1 fallback=0' not in r.stdout:
    raise SystemExit('Control failed')
print('KNOWN GAP CONFIRMED, NOT READINESS PASS')
