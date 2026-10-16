# B revision companion — document-checker handoff

2026-10-16. Proposal revision only, awaiting independent review. This responds
to `B-DESIGN-PLAN-REVIEW-r1.md` required item 1 and its optional nm clarification.
No source, tooling, tests, runtime or C-owned plan files were changed.

## Selected single interface for C to adopt

Configure exports `${CMAKE_BINARY_DIR}/package-documents.txt` from the sole
`LLG_PACKAGE_DOCUMENTS` list in future `cmake/PackageDocuments.cmake`: relative
paths, one per line, final newline, no comments/blanks. It is build-owned,
not installed, independently authored or a second shipping list.

```text
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

All paths absolute. DOCUMENT_ROOT is the actual `share/doc/lua-libghidra`
directory. MANIFEST is the selected build's `package-documents.txt`; no default
build, environment fallback, old signature adapter or module-prefix parameter.

## Required C-owned changes

1. Replace C design's old `installed-documents.sh MODULE_PREFIX DOCUMENT_PREFIX
   FRESH_WORK` signature and matching plan descriptions with the signature above.
2. In future `tests/installed-qualification.sh`, derive
   `manifest="$build/package-documents.txt"` and
   `document_root="$prefix/share/doc/lua-libghidra"` from its explicit selected
   build/prefix. Call source and installed checks with that manifest in both
   full/reduced modes. Full mode invokes the shell probe with the same manifest
   and a fresh child under C's explicitly selected work root:

   ```sh
   lua5.4 "$root/tests/installed_documents.lua" source "$root" "$manifest"
   lua5.4 "$root/tests/installed_documents.lua" installed \
     "$document_root" "$root" "$manifest"
   bash "$root/tests/installed-documents.sh" \
     "$document_root" "$root" "$manifest" "$documents/probes"
   ```

3. Keep selection ownership in C. Reduced mode explicitly omits the mutation
   probe, not the pristine checks; no new integration manifest option is needed.
   The selected configured build supplies the export. Require it to exist and
   fail clearly rather than falling back. Land caller integration with B's new
   checker/shell interface; there is no temporary legacy adapter.
4. Update C validation descriptions to acknowledge the wider document mutation
   cases and pristine restoration checks. B owns their implementation, not C.
   Do not duplicate the manifest or expand the separate LuaRocks smoke driver.

## B-owned correction

B design section 7 and plan section 5 now name the export and exact source,
installed and shell-probe commands, including explicit LuaRocks rock-build
manifest and actual versioned package document root. B owns replacement of
`tests/installed-documents.sh`'s old M4-FULL/coverage mutation loop and every
checker call in that shell script. Missing/stale probes use manifest members;
graph/content/credit probes assert their selected prose targets are members;
the unlisted-file probe intentionally adds then removes a disposable extra file.
Each probe checks pristine before mutation and after snapshot restoration,
asserts the intended diagnostic category/path, and never restores excluded
historical files. Structural/content checks precede freshness so an unrelated
byte mismatch cannot falsely satisfy a link/content regression test.

All three B self-contained documents were revised. `nm` addresses are explicitly
prefixed with `0x` before passing to `u64`. The website subplan receives stable
maintained source paths and the same manifest; B neither designs the website nor
introduces another manual or source relocation. Historical-baggage analysis
explicitly rejects duplicate shipping lists and compatibility scaffolding.

C alignment remains pending its author's revision; this companion does not claim
agreement, execution success or reviewer approval. The revised B documents and
C's matching handoff should receive fresh independent review together.
