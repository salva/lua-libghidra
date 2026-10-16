# C alignment companion — build-owned document manifest

2026-10-16. Documentation-only intertrack alignment after reading B's independent
design/plan review and revision companion plus current B design/plan. This narrow
update awaits fresh independent recheck; it reports no implementation or test pass.

## Changed sections

* C analysis, historical-baggage/coordination: names the selected build's exported
  list, actual document root, checker/probe ownership and separate D website scope.
* C design, explicit driver contract: adds the manifest prerequisite, source and
  installed pristine checks in both modes, the exact four-argument shell interface,
  selected-build propagation and broader full-only document mutation group.
* C plan, batch 1 and concrete validation: replaces the obsolete three-argument
  handoff with exact caller commands, missing-export failure, coordinated B/C
  delivery, focused validation commands and explicit LuaRocks root/export rules.
  Completion dependencies now identify B's export/checkers and D's separate scope.

## Single final caller contract

Configure exports `BUILD/package-documents.txt` from B's sole shipping list.
All paths below are absolute. C's driver selects build/prefix/root; `run` is its
unique fresh work directory. No new manifest option, alias or fallback is added.

```sh
manifest="$build/package-documents.txt"
document_root="$prefix/share/doc/lua-libghidra"
lua5.4 "$root/tests/installed_documents.lua" source "$root" "$manifest"
lua5.4 "$root/tests/installed_documents.lua" installed \
  "$document_root" "$root" "$manifest"
# Full mode only:
documents="$run/documents"
mkdir "$documents"
bash "$root/tests/installed-documents.sh" \
  "$document_root" "$root" "$manifest" "$documents/probes"
```

Reduced mode omits the mutation probe explicitly, not either pristine check.
Missing export fails rather than selecting another build. B implements the Lua
checker and shell mutation/restoration loop; C implements these qualification
call sites. LuaRocks checks use the corresponding rock build export and actual
versioned document root with identical interfaces. The separate LuaRocks smoke
driver is not expanded.

B's wider mutation cases require category/path-specific failures and pristine
checks before/after each snapshot restoration; no excluded history is restored.
The alignment creates no duplicate shipping ledger, compatibility layer, new
framework or additional process gate. F09/F10 semantic design, full/reduced
selection policy, CTest separation and bounded cleanup remain intact. D owns
website consumption of B's maintained manual/manifest. Final-doc restrictions
remain documentation-only, not a ban on test/tool identifiers.

Only C's three implementer documents and this companion were edited. No source,
tests, fixtures, build, runtime operation, commit or push was performed.
