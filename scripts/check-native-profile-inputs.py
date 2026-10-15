#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Compare prepared profile to locked tar inputs.
Normal generated known_languages.py is excluded; no authored libghidra edits allowed.
"""
import zipfile
import argparse,hashlib,json,pathlib,tarfile
p=argparse.ArgumentParser();p.add_argument('archives',type=pathlib.Path);p.add_argument('inputs',type=pathlib.Path);a=p.parse_args()
spec_archive=a.archives/'specs.zip'
spec_row=next(r for r in json.loads((pathlib.Path(__file__).resolve().parents[1]/'native-inputs.lock.json').read_text())['inputs'] if r['name']=='specs')
if hashlib.sha256(spec_archive.read_bytes()).hexdigest()!=spec_row['sha256']: raise SystemExit('spec archive mismatch')
with zipfile.ZipFile(spec_archive) as z:
 overlay={n.split('/',1)[1]:z.read(n) for n in z.namelist() if '/data/languages/' in n and not n.endswith('/')}
root=pathlib.Path(__file__).resolve().parents[1];lock=json.loads((root/'native-inputs.lock.json').read_text());profile=json.loads((root/'native-patched.lock.json').read_text())
for name in ['libghidra','engine']:
 row=next(r for r in lock['inputs'] if r['name']==name); archive=a.archives/(name+'.tar.gz')
 if hashlib.sha256(archive.read_bytes()).hexdigest()!=row['sha256']: raise SystemExit('archive mismatch')
 changed=[]
 with tarfile.open(archive) as t:
  for member in t.getmembers():
   if not member.isfile(): continue
   relative=member.name.split('/',1)[1];f=a.inputs/row['directory']/relative
   expected_bytes=overlay.get(relative,t.extractfile(member).read()) if name=='engine' else t.extractfile(member).read()
   if not f.exists() or f.read_bytes()!=expected_bytes: changed.append(relative)
 expected=['Ghidra/Features/Decompiler/src/decompile/cpp/bfd_arch.cc','Ghidra/Features/Decompiler/src/decompile/cpp/loadimage_bfd.cc'] if name=='engine' else []
 if name=='libghidra' and 'python/src/libghidra/known_languages.py' in changed:
  changed.remove('python/src/libghidra/known_languages.py');print('Excluded normal generated language metadata')
 if sorted(changed)!=sorted(expected): raise SystemExit(str((name,'unexpected edits',changed)))
 if name=='engine':
  for relative,data in overlay.items():
   if (a.inputs/row['directory']/relative).read_bytes()!=data: raise SystemExit('overlay mismatch '+relative)
  print('All spec overlay bytes match separately locked release zip')
 print(name,'changed authored files:',changed)
print('Only the two authorized engine files differ from archive inputs')
