# Regression selection and semantic evidence: design

## Boundaries

Implement F08–F10 only after authorization. Keep native-local scope, no SWIG/HTTP,
the pinned dependencies and approved unchanged upstream source-generator exception.
Use existing real ELF/project inputs and Lua/native tests. No dependency repairs,
fixture regeneration, engine fault campaign or new framework is needed.

## Explicit driver contract

Extend `tests/installed-qualification.sh` to accept exactly:

```text
--build DIR --prefix DIR --work-root DIR --mode full|reduced
[--external-specs DIR] [--help]
```

`--build` is an existing configured build with testing enabled. `--prefix` is a
nonexistent staging destination; refuse an existing destination, including symlinks,
so stale installed files cannot pass. `--work-root` is an existing writable directory.
Canonicalize paths before changing directories. Mode defaults to `full`; all three
directory options are required. Full mode additionally requires `--external-specs`
pointing at a prepared engine tree containing `Ghidra/Processors`. No environment
variable selects tests or supplies an implicit reduced mode. Reject positional
legacy inputs and unknown/duplicate flags with usage and nonzero status.

Preflight selected-group prerequisites before building/installing: configured
build/cache and readable `BUILD/package-documents.txt`, `cmake`, `lua5.4`,
`readelf`, `nm`, `ldd`, fixture files and hashes;
full mode also requires `cc`, a non-root user, the external tree, `unshare` and
mount/network namespace capability. Probe capability in a short-lived namespace,
not by altering the host. A denied namespace or missing fixture is a named
prerequisite failure, never a skip. Keep ordinary child failures fatal.

Allocate one unique `mktemp -d "$work_root/llg-integration.XXXXXX"`; make a fresh
`run` cwd and isolated HOME there. Children receive absolute prefix/root/build
paths. Always print selected groups before work and their completion after work.
On failure name the current group and retained run directory. Retain artifacts
on success too, printing prefix/run paths. Permission-restoring traps in profile
tests remain restricted to their own fresh child directory. No recursive cleanup
of the caller's work root, build tree or an existing prefix; no automatic broad
deletes. Caller can remove the exact newly allocated artifacts after inspection.

| Group | reduced | full |
| --- | --- | --- |
| Build/install and ELF VM/guard closure | run | run |
| installed_owner, m2_slice, m3_core, m3_iterators, m4_full_reproducer, m4_services, m4_contract on standalone/static/shared hosts | run | run |
| Installed first_slice/core_mutation examples and source/installed pristine document checks | run | run |
| Installed-document membership/freshness/link/fragment/content/credit mutation probes | OMIT | run |
| m3_persistence and m4_persistence | OMIT | run |
| Compile existing branch.c and run m3_branch | OMIT | run |
| External and embedded cold/warm/permission profiles | OMIT | run |
| Runtime Python/Java/network absence | OMIT | run |

Reduced mode emits every omitted row and ends with `REDUCED CHECKS PASS — full
integration NOT QUALIFIED`; success means only the selected checks passed. Full
mode emits `FULL INTEGRATION PASS` only after every required child succeeds.
Neither result is a blanket release approval. CTest stays the separately named
boundary/ownership/native-seeded suite, not an alias for full integration.

Preserve child scripts, extending their positional interfaces as follows:

```text
installed-profiles.sh PREFIX FRESH_WORK EXTERNAL_SPECS
installed-absence.sh PREFIX FRESH_WORK BUILD
installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

The first two require their new argument (no `root/build` or spec-cache fallback).
Both run from a fresh cwd; absence uses the passed build's two embedded hosts.
Update callers of the changed
child interfaces with explicit paths; currently both are in the qualification
driver. `tests/package-foundation.sh` is a separate LuaRocks smoke route and does
not invoke these children; preserve that scope rather than expanding it here.

B owns the document checker and mutation-driver implementations. Their exact
interfaces, with every path absolute, are:

```text
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

Configure exports `BUILD/package-documents.txt` directly from B's sole
`LLG_PACKAGE_DOCUMENTS` list: repository-relative paths, one per line, final
newline, no comments/blanks. It is build-owned, not installed or independently
edited. Reconfigure the selected build after manifest-list changes; require its
export rather than guessing another build. No integration manifest option,
module-prefix argument, environment fallback or old-signature adapter is added.

C's qualification driver derives and passes these exact inputs after install:

```sh
manifest="$build/package-documents.txt"
document_root="$prefix/share/doc/lua-libghidra"
lua5.4 "$root/tests/installed_documents.lua" source "$root" "$manifest"
lua5.4 "$root/tests/installed_documents.lua" installed \
  "$document_root" "$root" "$manifest"
# Full mode only; run is the driver's unique absolute work directory.
documents="$run/documents"
mkdir "$documents"
bash "$root/tests/installed-documents.sh" \
  "$document_root" "$root" "$manifest" "$documents/probes"
```

Both pristine checks run in full and reduced modes; only the mutation driver is
omitted in reduced mode. `DOCUMENT_ROOT` names the doc directory itself. For B's
separate LuaRocks verification it is the actual versioned package prefix's
`share/doc/lua-libghidra`, paired with that route's own `LLG_BUILD_DIR` export,
never a sibling build manifest or top-level rocks share directory.

B's shell probe requires nonexistent FRESH_WORK and uses a disposable document
copy plus untouched snapshot. It checks pristine before each mutation and after
restoration, requires the intended diagnostic category/path for missing/stale
members, links/fragments, forbidden content, credit misuse and unlisted files,
and ends pristine. Targets must be manifest members except the deliberate extra
file; excluded historical files are never restored. Membership/graph/content
diagnostics precede freshness so stale bytes cannot mask another intended fault.
C invokes and reports this group; it does not duplicate B's implementation/list.

Add an opt-in `integration` custom target under `BUILD_TESTING`, never an `ALL`
target or registered CTest test. Cache inputs are `LLG_INTEGRATION_PREFIX`,
`LLG_INTEGRATION_WORK_ROOT`, `LLG_INTEGRATION_EXTERNAL_SPECS`; unset inputs cause a
clear prerequisite error when invoked, not during unrelated builds. It calls the
driver in full mode with `CMAKE_BINARY_DIR`. Use `USES_TERMINAL` and `VERBATIM`.
The driver builds the default targets; since integration is not in `ALL`, that
does not recurse. Direct invocation remains the primary documented interface.

## Observable specialist sequences

Strengthen [services](/tests/m4_services.lua#L26) and
[persistence](/tests/m4_persistence.lua#L20) on both binary/project routes. Keep
assertions local and keyed by native identity, never array index alone. Member
and enum ordinals are UInt64; parameter ordinals are Lua integers. Use `.hex()`
or exact UInt64 comparison for identities; never float conversion.

* Struct: create and read its kind/path; add `x:int`, read ordinal zero and size
  four; rename to `y`, read; retype to `char`, read type/size; set binary-safe
  comment and read it before deletion. Verify deletion by absence of that member,
  then rename/read the type and delete/read absence. A second member is warranted
  only if needed to demonstrate wrong-ordinal detection; it is not a new fixture.
* Alias: read `target_type` after creation (`int`) and after retarget (`char`),
  matching path/name, then read absence after delete.
* Enum: read created enum using list/type queries; keep actual ignored width
  behavior distinct from signedness. Add zero, read ordinal/name/value; rename,
  read; set value seven, read; set NUL-bearing comment, read; delete, read absence.
  Do not infer ignored-sign coverage from `length ~= 123` or a boolean type check.
* Signature/parameter: after setting the int signature, fetch signature and locate
  ordinal zero. Read renamed parameter before retyping. Try a supported genuinely
  different type (`char` first), then fetch signature and assert its observed type
  differs from the original and equals the qualified expected spelling. Request
  echoes are separate acknowledgement assertions, not the state oracle.
* Local: inspect completed decompilation, select a record by stable `local_id` and
  kind, record name/type, rename and re-decompile to read that identity; then
  retype to a different supported type and re-read. Do not silently substitute a
  parameter for an absent `kind='local'` record and label it a local qualification.
  If only a parameter-kind record is available, name that bounded coverage and
  leave true-local coverage unqualified rather than manufacturing a fixture.
* Data/comment/benchmark/bytes: read exact address/type/name, address/kind/text,
  bench_id/value, and overlay bytes respectively before deletion or save. Preserve
  existing overlap/NUL patch and invalidation tests.

During implementation, first establish these observations on the pinned real
backend. If a write is ignored or not exposed, inspect its existing native path
only far enough to attribute that limitation. Freeze a deterministic assertion
of actual readback plus acknowledgement, with a named limitation comment/output.
Do not use runtime `if changed then test loss else pass` logic. An unexplained
wrapper mismatch is a failure routed to its owner, not automatically upstream.
No unconditional successful-change requirement is imposed on ignored upstream
fields, and no dependency fix is implied.

For persistence, capture detached scalar/identity snapshots immediately before
`save_program`; assert the intended observable state at that point. Preserve the
post-discard overlay check. Close/reopen through a new owner without reseeding;
compare the same categories with pre-save snapshots. A vanished struct member
can establish member loss; it does not independently isolate comment loss from
member loss. A category never observable before save is labelled acknowledged
only/unobservable, never lost on reload. Do not equate saved=true or shutdown's
accepted flag with restoration. Assert explicit expected outcomes once real
behavior is established, not merely `before ~= after`. Keep the existing struct
shell/absent-category expectations only where those prerequisites support them.

## Exact leaf oracle

In the project arm of [services](/tests/m4_services.lua#L15), use the existing
authored fixture and `n:list_leaf_functions` with range `0x401106..0x40113f`:

1. limit 100, offset 0 returns exactly two entries, in order, with UInt64 hex
   `0x0000000000401106` and `0x000000000040113c`.
2. Explicitly reject caller `0x000000000040111f` in every returned page.
3. limit 1 at offsets 0, 1, 2 returns first leaf, second leaf, empty respectively.
4. Inclusive singleton ranges at each leaf return exactly that leaf; singleton
   caller range returns empty. A range starting `0x401107` and ending `0x40113f`
   returns only the second leaf. This detects ignored bounds independently of
   pagination and does not assume a zero-end sentinel for leaves.

Retain raw ELF `NOT_SUPPORTED`. Expectations are authored constants from
[the native probe](/tests/project_probe.cpp#L19), not values sampled from a second
call to the same adapter. No iterator or facade convenience is added.

## Ownership of documentation changes

B applies C's evidence correction payload to the final current qualification and
crosswalk locations: distinguish acknowledgement, observed state and reload;
remove unsupported GetRevision test citations and ignored enum-sign claims;
describe integration versus CTest and exact commands. C does not concurrently
edit those documents or B's document-copy tests. Historical reports remain
historical. Do not create another runtime ledger or rewrite generated source-only
slots as passes. A supplies the validated Lua ABI/build profile; C consumes it
without modifying boundary behavior. The final package-doc reference restriction
does not require deleting automation identifiers from test/tool source.
