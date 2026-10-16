# Static project website — execution and acceptance plan

Future authorized batch D, F14 plus website F13. Planning baseline `4903eb7`,
2026-10-16. No implementation, commits, push, GitHub settings or deployment now.
Commands below specify future interfaces to implement; they are not existing
commands asserted to have passed.

## Dependency and ownership sequence

1. Accept A's public-contract dispositions and B's final compact manual, package
   manifest, notices, example, field generation and shared checks. C's test
   selection is consumed by B for real recipe/example validation. D does not
   independently rerun or replace native qualification.
2. Reconcile this design against accepted B. Record the actual integration commit.
   B owns README, EXAMPLES, API, NOTICES, PackageDocuments.cmake, generated fields,
   example and shared doc helper. D owns the new site files/workflows/checkers.
3. D can prepare isolated presentation tooling after its own authorization, but
   cannot integrate content or claim acceptance until B's required outputs pass.
   Schedule necessary B shared-helper/anchor/link edits in a sequential handoff:
   B finishes, D proposes precise compatibility edits, B integrates/revalidates
   source/install docs, then D validates the site. No parallel edits to those
   shared files and no second manifest/helper/API generator.

## Implementation batches

### D1 — explicit rendering and toolchain

Implement the exact layout and source/output map in the design. Export B's list
with script-mode CMake, validate path containment/symlinks, stage only individually
approved inputs, pin/verify a real Pandoc release and document offline provisioning.
Use the existing Lua tooling conventions and JSON helper where appropriate.
Add the single template, stylesheet, AST link/heading filter and render the entire
own-input example from B's file. Avoid absolute host paths or timestamps in output.
No native build files/dependencies need alteration.

### D2 — artifact and presentation validation

Implement graph checking of emitted HTML href/src and IDs, including percent
encoding, fragment-only links, nested pages, raw downloads and project-base URL
resolution. Enumerate exact outputs; require copied-byte equality and current
source fingerprints. Share B's source content/anchor logic through a small helper
instead of weakening B's checks for the renderer. Record external links separately
without treating network reachability as a required pass.

Add focused disposable-copy mutation cases: missing notice, missing fragment,
root-relative escaping asset, incorrect README rewrite, duplicate heading IDs,
stale manual output, altered example, extra history/private file, source symlink,
encoded prohibited reference, and duplicated/misplaced credit. Each must fail with
an actionable path/target diagnostic; preserve original source. These tests verify
the artifact boundary rather than merely replaying rendering implementation.

### D3 — CI and publication preparation

Add read-only build CI and a separate manual publication workflow with the design's
branch, permissions, environment, SHA pins and concurrency controls. Inspect the
actual default branch at implementation time; do not guess `main` in security
guards. Use the same commands locally and in CI. Action pin changes and converter
lock changes require deliberate review. Document the operator enablement steps in
source-only `site/README.md`, never in the public manual. Preparing workflow YAML
does not authorize running deployment, pushing it or changing settings.

## Concrete local validation contract

Run from checkout root after future scripts exist and B is complete. Use an
existing verified local converter; `$PANDOC` must be an absolute executable path
matching `site/toolchain.lock.json`. These commands need Lua/CMake/Pandoc, not
libghidra, fixtures, Java or a native build. Workspace temporary artifacts belong
under `/home/salva/g/ml/tmp`; outside this workspace use a caller-owned work root.

```sh
WORK=$(mktemp -d /home/salva/g/ml/tmp/lua-libghidra-site.XXXXXX)
export PANDOC=/absolute/path/to/verified/pandoc
lua5.4 scripts/render-fields.lua --check
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/preview/lua-libghidra" --report "$WORK/build.json"
lua5.4 scripts/check-site.lua --root "$WORK/preview/lua-libghidra" \
  --baseurl /lua-libghidra --report "$WORK/build.json" --source .
lua5.4 tests/site_contract.lua --work "$WORK/mutations" --pandoc "$PANDOC"
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$WORK/rebuilt" --report "$WORK/rebuilt.json"
diff -r "$WORK/preview/lua-libghidra" "$WORK/rebuilt"
sh scripts/preview-site.sh --root "$WORK/preview" --bind 127.0.0.1 --port 8088
```

Preview runs in the foreground and serves the **parent** directory, preserving
the actual project path. Open `http://127.0.0.1:8088/lua-libghidra/`, not server
root, then nested API/field/notice URLs directly. The wrapper must invoke local
BusyBox httpd bound to loopback and fail clearly if absent. Stop with Ctrl-C.
In a second shell, bounded HTTP checks may use:

```sh
curl --fail http://127.0.0.1:8088/lua-libghidra/ -o /dev/null
curl --fail http://127.0.0.1:8088/lua-libghidra/docs/API.html -o /dev/null
curl --fail http://127.0.0.1:8088/lua-libghidra/api/FIELDS.html -o /dev/null
curl --fail http://127.0.0.1:8088/lua-libghidra/assets/style.css -o /dev/null
```

Also build/check with empty baseurl into a distinct fresh output to expose hidden
prefix assumptions. The required production-path test remains `/lua-libghidra`.
Verify the actual rendered browser page at 360px and desktop width, keyboard-only
skip/navigation/TOC, zoom 200%, visible focus and horizontal table/code scrolling.
Check normal text/link contrast against WCAG AA thresholds. Record observations;
do not claim a complete accessibility audit from a browser smoke check.

The checker must compare the current sources as well as the report; trusting an
old report alone cannot establish freshness. B's source/install graph/content and
generator checks must still pass after shared-file integration. B's pinned-source
inventory qualification is prerequisite evidence; the website-only CI uses its
checked-in current ledger and renderer check, not a network fetch or runtime oracle.

## Acceptance and master-plan handoff

Add **D — static website (F14; F13 applies)** to the master plan after B integration.
Dependency graph: A contracts → B content; C selection → B recipe validation;
B accepted documentation/generator/manifest → D integration → combined package/site
acceptance. D publication is a separate operator-authorized terminal activity,
not a prerequisite to declaring local implementation/build validation complete.

| Gate | Required evidence |
| --- | --- |
| User journey | Landing/about, install, own-input quickstart/example, all API subsystem navigation, fields, practical limitations and notices reachable without history |
| One source | Five pages rendered from B sources; complete example from one executable; current source hashes, render-fields check, identical fresh rebuild |
| Content boundary | Actual artifact exactly equals computed allowlist; no audits/plans/operator/private paths or process references, except the narrowly scoped optional credit |
| Notice integrity | Byte equality for all notice/license/lock downloads; attribution and material obligations/qualifications preserved in HTML |
| URL correctness | Local links/assets/fragments close under project path; direct nested navigation works; external links inventoried, not claimed reachable |
| Usability | Recorded keyboard, narrow/desktop, zoom and contrast checks; no required JS/remote assets |
| Checker sensitivity | Required negative mutations rejected, including stale source/report and encoded-content cases |
| CI separation | Reviewed action SHA pins, locked converter, no PR deployment/secrets, restricted deploy-only privileges, environment and concurrency |
| Authority | Build results reported separately from unperformed push/enablement/deployment; no implied live URL or release approval |

After later explicit publication authorization, an operator may verify current
Pages settings/default branch/environment, push the approved commit, enable the
Actions source if needed, dispatch publication and inspect the actual target URL
and a nested page/notice. Record that independently; do not claim broad external
link availability or native qualification from a live-site smoke test.

Rollback before publication is removal/reversion of D's isolated tooling/workflow
changes with B's shared-helper changes reconciled by its owner; retain B's manual
and exact notices. After publication, any rollback deployment also requires
operator authority and must rebuild a known accepted revision through the same
checks. Never solve a rendering failure by uploading the repository or weakening
the publication allowlist.
