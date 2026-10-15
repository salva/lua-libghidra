# Authored M0 fixtures

MIT Copyright 2026 Salvador Fandiño. These small ELF and Ghidra database inputs
are intentional offline test assets, not generated runtime state. SHA256SUMS
covers source, generator and retained bytes. No upstream Python bindings used.

## Provenance / regeneration

Ubuntu amd64 GCC `13.3.0-6ubuntu2~24.04.1`, binutils 2.42:

```sh
cc -O0 -g -fno-pie -no-pie tests/fixtures/authored.c -o tests/fixtures/inputs/authored.elf
objcopy -O binary --only-section=.text tests/fixtures/inputs/authored.elf tests/fixtures/inputs/text.bin
# Empty project output directory required. GHIDRA is a development tool only.
$GHIDRA/support/analyzeHeadless "$PWD/tests/fixtures/project" authored \
  -scriptPath "$PWD/tests/fixtures" -preScript MakeFixture.java "$PWD/tests/fixtures/inputs/text.bin"
```

Generator: real Ghidra 12.1.3 PUBLIC (20260817), OpenJDK 21.0.12.1 Ubuntu.
Release zip SHA256 `93a5d11a9ad510622acaaf908c556a7b9b764d338e78a7567f3689bf5081fd54`
from native-inputs.lock.json; reused retained offline archive, not downloaded.
The project is a real ProgramDB with byte-array initialized memory, disassembled
functions, autoanalysis/reference index, comment and DWORD. It deliberately has
**no FileBytes**, exercising native loadProject's documented external ELF override
branch. This is not a fabricated database or a claim that the BFD raw-memory
branch works. Native loadProject imports names/leaves, not all Ghidra comments,
data definitions or prototypes. Native comments are explicitly set/read in the
probe; data is discovered from the ELF global read, not asserted imported from DB.

Expected addresses: native_smoke 0x401106, main 0x40111f,
read_authored_value 0x40113c, authored_value 0x404010 (DWORD 23).
Entry bytes f3 0f 1e fa, four-byte ENDBR64; arithmetic x*3+7;
main calls native_smoke and compares against 19; global reader adds 5.
The native project decompiler currently renders the input as `unaff_EDI`, since
project function prototypes are not imported; expected arithmetic remains checked.
Leaves are exactly native_smoke and read_authored_value, not main.

## Qualification

```sh
scripts/check-project-fixture.sh "$PWD/.cache/native-sdk-patched" \
  "$PWD/.cache/native-inputs-patched/engine" "$SAIVAGE_CARD_WORK_ROOT/fixture-consumer"
```

This builds installed-only direct C++ probes and runs binary and project semantic
checks; needs no Java/Python/network at runtime. Logs in docs/evidence/fixture-*.
The original binary-only probe/reproducer is preserved. Missing project is an
error, not binary success. Upstream library/engine were not edited. Existing
patched SDK profile controls remain independently applicable.

Not a release qualification: Java is permitted only for development generation;
project-owned Python migration and dependency notices/source distribution remain
M5 obligations. MIT wrapper is not a license grant for combined dependencies.
