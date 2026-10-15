#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Download/verify or reuse exact archives.

Preparation is explicitly online unless --offline. Configuration never fetches.
All output goes to a caller-selected ignored/disposable directory. Fresh output
is required so stale mixed source trees cannot masquerade as locked inputs.
"""
import subprocess
import argparse, hashlib, json, pathlib, shutil, tarfile, urllib.request, zipfile
p = argparse.ArgumentParser()
p.add_argument('--archives', type=pathlib.Path, required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
p.add_argument('--offline', action='store_true')
p.add_argument('--profile', choices=['unmodified','bfd-sleigh-target-autodetect'], default='unmodified')
a = p.parse_args()
lock = json.loads((pathlib.Path(__file__).resolve().parents[1]/'native-inputs.lock.json').read_text())
if a.output.exists():
    raise SystemExit('output must not exist: use a fresh directory')
a.archives.mkdir(parents=True, exist_ok=True)
# Verify ALL archives before extracting any source.
for row in lock['inputs']:
    suffix = '.zip' if row['name'] == 'specs' else '.tar.gz'
    archive = a.archives/(row['name']+suffix)
    if not archive.exists():
        if a.offline:
            raise SystemExit(f'missing offline archive: {archive}')
        with urllib.request.urlopen(row['url']) as src, archive.open('wb') as dst:
            shutil.copyfileobj(src, dst)
    digest = hashlib.file_digest(archive.open('rb'), 'sha256').hexdigest()
    if digest != row['sha256']:
        raise SystemExit(f'SHA256 mismatch: {archive}')
    print(row['name'], digest, flush=True)
a.output.mkdir(parents=True)
for row in lock['inputs']:
    if row['name'] == 'specs':
        with zipfile.ZipFile(a.archives/'specs.zip') as z:
            for name in z.namelist():
                if '/data/languages/' not in name or name.endswith('/'):
                    continue
                relative = pathlib.PurePosixPath(name.split('/',1)[1])
                if relative.is_absolute() or '..' in relative.parts:
                    raise SystemExit('unsafe zip member')
                dest = a.output/'engine'/relative
                dest.parent.mkdir(parents=True,exist_ok=True)
                dest.write_bytes(z.read(name))
    else:
        dest = a.output/row['directory']; dest.mkdir()
        with tarfile.open(a.archives/(row['name']+'.tar.gz')) as t:
            # Python 3.12's data filter prevents escaping destination links/paths.
            members = t.getmembers()
            for member in members:
                member.name = member.name.split('/',1)[1] if '/' in member.name else ''
            t.extractall(dest, members=[m for m in members if m.name], filter='data')
print('Prepared', a.output)

if a.profile != 'unmodified':
    root = pathlib.Path(__file__).resolve().parents[1]
    profile = json.loads((root/'native-patched.lock.json').read_text())
    if hashlib.sha256((root/'native-inputs.lock.json').read_bytes()).hexdigest() != profile['base_lock_sha256']:
        raise SystemExit('base lock changed; requalify patched profile')
    lib = next(row for row in lock['inputs'] if row['name']=='libghidra')
    engine = next(row for row in lock['inputs'] if row['name']=='engine')
    if lib['revision'] != profile['patch_source_revision'] or engine['revision'] != profile['engine_revision']:
        raise SystemExit('profile revision mismatch')
    patch = a.output/lib['directory']/profile['patch_path']
    if hashlib.sha256(patch.read_bytes()).hexdigest() != profile['patch_sha256']:
        raise SystemExit('patch digest mismatch')
    subprocess.run(['patch','--batch','--fuzz=0','-p1','-d',str((a.output/'engine').resolve()),'-i',str(patch.resolve())],check=True)
    (a.output/'native-profile.json').write_text(json.dumps(profile,indent=2)+'\n')
    print('Applied exact authorized profile:', a.profile)
