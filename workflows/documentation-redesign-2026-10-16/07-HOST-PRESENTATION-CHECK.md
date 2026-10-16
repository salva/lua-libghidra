# Host presentation evidence and authorized continuation

Working operational evidence; not package documentation or website content.

## Artifact and reason for intervention

Operator requested resolving the blocked project and restarting it, and explicitly
authorized GitHub Pages publication. At inspection, runtime was stopped/idle and
root, stage, existing website and existing independent reviewer were blocked solely
on native browser 200% zoom and permitted visual observations. No current product
defect was reported. Product HEAD is `b4e532c` with package helper `7c3a04f`.

Before presentation inspection the coordinator reran the actual source-bound
checker in the dedicated container on:

```
.saivage/work/cards/card-h-d-a/raw-heading-render-final/project
```

Using its `project.json` report, base URL `/lua-libghidra`, source `.`, and the
existing verified Pandoc 3.6.4 binary under `site-toolchain-third`, it passed:
27 manifest members, source graph/content, exported bytes/graph/freshness and
independent regeneration. External URLs were inventoried, not network-tested.
A read-only loopback HTTP preview serves precisely that artifact under the same
project path at `http://127.0.0.1:8877/lua-libghidra/`.

## Native zoom: newly available host capability

Host OpenCode browser screenshot capture succeeded through its normal tools.
Synthetic Control-plus did not change that embedded browser's page zoom, and was
not counted. A separate **headed Google Chrome 155.0.8059.39**, on the existing
host display, was launched with a fresh isolated test profile and loopback-only
debugging, without changing the user's browser profile or product/runtime config.

Chrome's own `chrome://settings/appearance` **Page zoom** select was changed from
100% to 200% using its normal select/change handler. This is browser-native page
zoom, not CSS zoom, screenshot enlargement, device-scale-factor emulation or
pinch zoom. Measured on unchanged home, `docs/API.html`, `api/FIELDS.html` and
`docs/EXAMPLES.html`:

| Native setting | Outer window | Layout viewport | DPR | Root CSS zoom |
| --- | --- | --- | --- | --- |
| 100% | 1280 px | 1270 px | 1 | 1 |
| 200% | 1280 px | 635 px | 2 | 1 |

At 200%, document client/scroll widths were both 627 CSS px: no global horizontal
overflow. The visual viewport height was 431 CSS px. New screenshots of the
actually zoomed pages and scrolled table/code content were captured, and the
coordinator inspected them successfully with the ordinary image-reading tool.
No denied image was copied, re-encoded, transformed or reopened by an alternate
path. This is new host evidence, not a claim the container gained visual tools.

## Attributable visual observations

The coordinator (GPT-6.1 Sol, host OpenCode session) directly viewed the newly
captured native-200% home/API/fields screenshots and table/code detail captures:

- Home/navigation/TOC text is legible and separated; no overlay or text clipping
  was visible in inspected regions. Navigation links remain distinguishable.
- API return-shape table stays within its content width, with distinct cells,
  headers and readable return keys.
- Field table stays within its content width. Long identifiers wrap across lines;
  this is less comfortable than desktop 100%, but no cell content disappears or
  overlays an adjacent column in the inspected table.
- Example command is retained in an independently horizontally scrollable code
  region with a visible scrollbar; surrounding paragraphs and headings reflow
  without whole-page horizontal overflow.

A second, explicitly **emulated 360 CSS-px viewport at native 100%** supplied
narrow-screen visual observations (not native 200% evidence). DPR was 1, viewport
360, document client/scroll widths both 345. Directly viewed home, API table,
fields table and example-code captures show readable reflow, bounded/wrapped
table cells and local code scrolling. The narrow field table wraps identifiers
heavily, but its content remains present and distinguishable. This supplements
the existing independent 360/1280 keyboard/focus/contrast/reader checks; it does
not replace those checks or claim a comprehensive accessibility audit.

Initial attempts to resize the headed Chrome outer window to 360 were clamped by
Chrome/window-manager minimum width to 510 (viewport 500 at 100%, 250 at 200%).
Files named `*-360-*.png` in the initial observation batch record the requested
size, **not an actual 360-px viewport**, and are not evidence of that width.
Only `*-mobile360-detail.png` and `detail-observations.json` establish the exact
360 CSS-px observations. No acceptance claim relies on the clamped screenshots.

## Evidence location and ownership of acceptance

Host-only scratch evidence:
`/home/salva/g/ml/tmp/lua-libghidra-browser-unblock-2026-10-16/`:

- `observe.mjs`, `observations.json`: native Chrome setting, geometry and initial
  screenshots (including the explicitly qualified clamped narrow attempts).
- `detail.mjs`, `detail-observations.json`: actual native-200% table/code details
  and separately labeled exact-360 emulation; screenshots named in the JSON.

This signed-by-context report provides attributable host observations to the
existing reviewer. It does not mark E3 accepted or instruct anyone to bypass a
security denial. The independent reviewer retains the acceptance decision and
must assess the applicable new evidence with already accepted automated checks.
Reuse original stage/reviewer cards and preserve all history; do not create a
replacement review project or repeat unchanged native qualification.

## Publication authorization

The latest operator message explicitly authorizes publication on GitHub Pages.
After existing independent website acceptance and final checked-artifact review,
that authorizes the necessary repository push, Pages configuration and manual
publication workflow for this project's site. It does not authorize unrelated
repository changes, secret disclosure, scope expansion, or describing the site as
published before a successful deployment and public URL verification. Host-side
publication coordination may be needed if the container lacks GitHub credentials.
Publication is not needed to perform local acceptance and is not an acceptance
waiver. Resume uses supported Analyst reopen/notifications and ordinary Run, not
service restart or saved-runtime file edits.

## Supported recovery receipt

At 15:17:30 UTC on 2026-10-16 the Analyst's global `reopen_card` successfully
changed existing `card-h-d-b` from blocked to changed. Normal propagation reopened
`card-h-d`, `card-h` and `project`; all four statuses were verified changed before
Run. Four normal, noninterrupting notifications supplied this evidence and the
publication authorization to the same chain. No brief, history or runtime JSON
was rewritten. A separate ordinary `start_project` succeeded at 15:18:42 UTC.

Fresh root execution returned successful `get_card` at 15:18:49 and `read` at
15:18:53 UTC, with runtime running. These controls and actual new tool returns
establish restart, not final reviewer acceptance. Full control receipts are retained
mode 0600 as `reopen-notify-receipt.json` and `run-receipt.json` beside the host
browser evidence. No push or publication has occurred in this intervention.
