# Fresh independent review — Lua API contract

Reviewed project HEAD `699cc8a1efa534cc15f100a487f7afab50215cb1` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` in
`/home/salva/g/ml/tmp/lua-libghidra-upstream`.

Read AGENTS.md, README.md, SPEC, DESIGN, PLAN and COVERAGE before assessing the
contract. No prior review reports were read. Scope: local-only Lua types, UInt64,
errors, pagination and naming; no implementation or runtime qualification claimed.

## F1 — Medium: Signature pagination does not satisfy the prescribed cursor/exhaustion rules

**Documentation evidence:** `docs/SPEC.md:157-160` prescribes advancing by actual
returned count. `docs/DESIGN.md:76-77` includes signatures among page families;
`docs/DESIGN.md:89-98` makes identity/order qualification the gate and prescribes
actual-count advancement and empty-page exhaustion. `docs/COVERAGE.md:23` includes
ListFunctionSignatures in core.

**Pinned upstream evidence:** `cpp/src/local_client.cpp:1059-1071` first paginates
the **function** collection, then adds only successfully obtained signatures to
the response. `cpp/src/local_arch_adapter.cpp:774-783,825-828` can return an absent
signature, including on a caught exception. The response contains only a signature
vector (`cpp/include/libghidra/models.hpp:612-614`), without consumed-function count
or continuation metadata.

Consequently, native offset counts candidate functions, not returned signatures.
For candidate functions A/B/C and limit 2, if A has no signature and B does, the
first response is [B]. Advancing by one requests B/C next, yielding B again and a
false `PAGINATION_STALLED`. With limit 1, an absent signature for A produces an
empty first page even if B has a signature: the documented rule silently ends the
iterator. Stable serial ordering and unique identities do not resolve either
case. This is a known semantic exception at the pin, not merely unperformed
runtime qualification.

**Fix:** Scope the generic actual-count/empty-page rules to operations whose
returned records share the native cursor domain. Explicitly mark signature
iteration pages-only at this pin unless a separately specified cursor strategy
can establish candidate consumption and genuine exhaustion. Preserve native page
responses; do not infer exhaustion from an empty filtered signature page or
invent continuation metadata. Extend the per-operation pagination contract/gate
to record cursor domain and post-pagination filtering, with missing-signature
cases required if an iterator is later enabled. No implementation is requested
as part of this documentation correction.

## Other assessed areas

The exact UInt64 output policy, checked integer inputs/helpers, binary strings,
optional/false preservation, Lua-reserved `function` field access, structured
error conventions and facade third-result convention are internally coherent.
The explicit field-manifest and runtime gates are appropriate deferred work;
their incompleteness is not itself a finding.

## VERDICT CHANGES_REQUESTED

## Re-review disposition — be084da

Reviewed correction commit `be084da9cb713aee39665d9e6acee476a56d992f`, including
the product-document diff and new EXAMPLES, against the same upstream pin.
The original assessment above is preserved.

**F1: RESOLVED.** `docs/SPEC.md:214-219` restricts actual-count advancement to
returned-record cursor domains and explicitly makes signatures pages-only.
`docs/DESIGN.md:99-109` separates cursor/filtering qualification from order,
rejects empty signature pages as exhaustion, and requires a separate design
and missing-signature tests for future traversal. `docs/COVERAGE.md:53-55,77-81`
and `docs/PLAN.md:67-70` carry that restriction into scope and qualification.
This addresses both duplicate traversal and premature exhaustion without
inventing native continuation metadata.

Regression review of the added call grammar, open metadata return convention,
examples, numeric representations and error/pagination policies found no new
substantive Lua API contract issue. Approval covers documentation only; deferred
implementation and real-backend qualification remain gates.

## VERDICT APPROVED
