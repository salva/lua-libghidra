#!/usr/bin/env python3
"""MIT Copyright 2026 Salvador Fandiño. Capture exact Ubuntu closure metadata.

Online lock refresh, not part of offline configure. Downloads Debian source
control documents and verifies binary archives against apt SHA256 metadata.
"""
import argparse,hashlib,json,pathlib,re,subprocess,urllib.request
p=argparse.ArgumentParser();p.add_argument('archives',type=pathlib.Path);a=p.parse_args();a.archives.mkdir(parents=True,exist_ok=True)
packages=['libbinutils','libsframe1','binutils-dev','libiberty-dev','libzstd1','zlib1g','libc6','libstdc++6','libgcc-s1']
rows=[];sources={}
base='https://archive.ubuntu.com/ubuntu/'
for pkg in packages:
    fields=subprocess.check_output(['dpkg-query','-W','-f=${Version}\t${source:Package}\t${source:Version}',pkg],text=True).split('\t')
    version,src,sv=fields
    raw=subprocess.check_output(['apt-cache','show',pkg+'='+version],text=True)
    meta=dict(re.findall(r'^([A-Za-z0-9-]+): (.*)$',raw,re.M))
    url=base+meta['Filename']; dest=a.archives/pathlib.Path(meta['Filename']).name
    if not dest.exists(): urllib.request.urlretrieve(url,dest)
    sha=hashlib.sha256(dest.read_bytes()).hexdigest()
    if sha!=meta['SHA256']: raise SystemExit('binary SHA256 mismatch '+pkg)
    rows.append(dict(package=pkg,version=version,url=url,sha256=sha,source=src,source_version=sv))
    if src not in sources:
        directory='/'.join(meta['Filename'].split('/')[:-1])+'/'
        # libstdc++ binary and gcc source share gcc-14 directory; all other
        # selected packages likewise use their source pool directory.
        dsc=src+'_'+sv.split(':')[-1]+'.dsc'
        u=base+directory+dsc
        data=urllib.request.urlopen(u).read();(a.archives/dsc).write_bytes(data)
        text=data.decode(); section=text.split('Checksums-Sha256:\n',1)[1].split('\n\n',1)[0]
        files=[]
        for line in section.splitlines():
            m=re.fullmatch(r' ([0-9a-f]{64}) (\d+) (\S+)',line)
            if m: files.append(dict(url=base+directory+m[3],sha256=m[1],bytes=int(m[2])))
            elif files: break
        if not files: raise SystemExit('no source checksums '+u)
        sources[src]=dict(version=sv,dsc_url=u,dsc_sha256=hashlib.sha256(data).hexdigest(),archives=files)
lock=dict(platform='Ubuntu 24.04 amd64',binaries=rows,sources=sources)
pathlib.Path('native-system.lock.json').write_text(json.dumps(lock,indent=2)+'\n')
print('Verified',len(rows),'binary archives; locked',len(sources),'source control documents')
