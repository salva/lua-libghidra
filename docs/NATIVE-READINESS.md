# Native dependency readiness (M0 experiment, not a binding)

Original integration files are MIT, Copyright 2026 Salvador Fandiño. No M1
adapter is present. Dependency license/applicability decisions are independent;
this experiment does not authorize distribution.

## Reproduce

Requires the Ubuntu 24.04 amd64 toolchain recorded in
[evidence/native-toolchain.txt](evidence/native-toolchain.txt), CMake >=3.26,
C++20, Lua 5.4 with 64-bit integers, Python >=3.10 with zlib for upstream
embedding. Preparation script uses Python 3.12's safe tar extraction API.
Use caller-selected ignored paths, and a fresh extraction/build directory:

```sh
python3 scripts/prepare-native.py --archives /path/to/archive-cache --output /path/to/fresh-inputs
# Add --offline to require all verified archives without opening any URL.
cmake -S . -B /path/to/fresh-build -G Ninja \
  -DNATIVE_INPUT_ROOT=/path/to/fresh-inputs \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DCMAKE_BUILD_TYPE=Release
cmake --build /path/to/fresh-build -j8
ctest --test-dir /path/to/fresh-build --output-on-failure
scripts/check-native-smoke.sh /path/to/fresh-build /path/to/fresh-inputs/engine
```

Every top-level source can instead be overridden with
`NATIVE_{LIBGHIDRA,ENGINE,PROTOBUF,ABSEIL,HTTPLIB}_SOURCE`. Specs are overlaid
from the separately hashed release zip into `ENGINE` during preparation.
The lock records exact archives, versions, licenses and destinations; source
modifications in overrides are caller responsibility, not automatically certified
by the archive lock. No FetchContent download is allowed at configure time.
Protobuf's utf8_range is contained in its hashed archive; Abseil is separate.
The upstream protobuf PATCH_COMMAND is bypassed by a populated source override;
CMake 3.28 does not require those CMake-4 compatibility edits. Upstream libghidra
source is otherwise unchanged except its normal generator's known_languages.py.

## Actual reusable inputs in this guest

- Default source/spec root: `/work/lua-libghidra/.cache/native-inputs`.
- External specs: `/work/lua-libghidra/.cache/native-inputs/engine` (pass whole
  root, not just the x86 directory).
- Installed local archives/headers/CMake exports:
  `/work/lua-libghidra/.cache/native-sdk`.
- Working whole-archive native probe:
  `/work/lua-libghidra/.cache/native-sdk/native_probe`.
- Smoke ELF: `/work/lua-libghidra/.cache/native-sdk/native-smoke`, entry
  `native_smoke=0x401106`. Its source and digests are retained. Native call:
  `native_probe EXTERNAL_ROOT ELF 0x401106 ''`.

The SDK now includes independently installed PIC protobuf v29.3 (CMake package
version **29.3.0**), Abseil 20240722.0 and bundled utf8_range. An installed-only
consumer in `tests/installed-sdk` explicitly finds exact Protobuf CONFIG first,
then libghidra, recreates WHOLE_ARCHIVE for `libghidra::local`, and builds both
a shared `-z defs` closure and a working semantic probe. No ambient Protobuf
fallback is accepted. Reusable all-in-one build command:

```sh
scripts/build-native-sdk.sh /path/to/inputs /path/to/fresh-work /path/to/sdk
```

The entire recipe was exercised in a network-disabled namespace; see follow-up
logs in evidence. The SDK remains platform-specific and depends on the locked
Ubuntu shared-library closure, not a portable redistribution kit.

## Evidence and actual limitations

[evidence/native-offline-build.log](evidence/native-offline-build.log) is a
complete clean 490-step build in a network namespace (`sudo unshare -n`, then
`runuser` back to the guest user). Both configure and build exited zero, using
fresh offline-verified extracted inputs, not a warmed build tree. Global PIC
covers upstream local/client/engine/bundled zlib/protobuf/Abseil objects.
`native_link_closure` links **all** local objects into a shared library using
`libghidra::local_whole` and `-Wl,-z,defs`; this is actual ELF PIC/link closure,
not just an option assertion. Shared BFD 2.42 is explicitly selected rather than
upstream's preferred ambient libbfd.a. Shared sframe/zstd are selected and
libiberty.a excluded; shared BFD carries the needed internal implementation.
The linked closure has BFD, system zlib/zstd/sframe, libstdc++, libgcc, libc/libm
and no Lua, Python or Java runtime dependency (there is no binding yet).

The baseline toolchain log's query for `libssl-dev` failed because it is absent;
this is not needed for this build. The successful later ldd command did not
turn that package probe into success. httplib has no discovered OpenSSL dev
profile here. `native-system.lock.json` now records nine exact binary package URLs/hashes
(downloaded and verified) and six corresponding source control documents with
source-archive URLs/hashes. Installed BFD bytes were compared to the locked
libbinutils package payload. The source archive hashes are from fetched .dsc
metadata, not a claim that every large source archive was downloaded or built.
A portable binutils source build remains outside the evidenced guest profile.

Actual paired engine/spec smoke: both external and cold/warm embedded profiles
produced completed, nonfallback `return param_1 * 3 + 7;` for authored x86 ELF.
The pairing claim is restricted to this real operation, not all architectures or
fixture semantics. Cold extraction created `.complete`; warm process reused the
same HOME. `/proc` HOME emitted cache creation/extraction diagnostics and failed
open. Explicit missing and mode-000 roots failed open with `No sleigh
specification for x86:LE:64:default`; constructors/status alone succeeded and
were insufficient tests. An initial loop masked the unreadable exit with chmod;
[evidence/native-unreadable-corrected.log](evidence/native-unreadable-corrected.log)
records the actual open exit 4. Warm **unwritable** cache now passed via `scripts/check-native-cache.py`: all
cache files/directories lose write bits as an ordinary user, no path remains
writable, all three profiles preserve semantic results and sentinel/file
mtime/size inventory is unchanged.

**Explicit Sleigh hints currently fail unmodified ELF loading** with `Unable to
open image file`, while empty hints succeed. Inspection finds upstream's bundled
`cpp/patches/0001-bfd-sleigh-target-autodetect.patch`, not applied by its CMake;
LocalClient assumes that engine patch was applied. No patch was silently applied
here: the accepted unmodified-native constraint needs a precise disposition.
Empty hint success is diagnostic evidence, not a substitute for explicit-hint
fixture reproducibility. Analyzed-project fixture semantics remain untested.

## Notices / obligations

Original licenses/package copyright inventories are under
[evidence/native-notices](evidence/native-notices). libghidra is HOS, engine
Apache-2.0 with bundled zlib, protobuf BSD-3-Clause plus utf8_range MIT, Abseil
Apache-2.0, httplib MIT. BFD/binutils and its linked sframe closure are GPL, not
permissive; system libiberty was inspected but is not linked by this profile.
GPL combined-distribution/corresponding-source obligations and upstream HOS
applicability are independent unresolved legal gates. System zlib is zlib-licensed;
zstd has its own dual-license notices. System C/C++ runtimes have their own
LGPL/GPL-with-runtime-exception notices. Lock URLs identify original corresponding
sources for downloaded inputs; Ubuntu source package/version information is in
the retained copyright inventories. These notices are evidence, not a conclusion
that combined distribution is permitted or an already complete distribution kit.
