# Baseline validation

Baseline: `4903eb7`. The coordinator ran the existing configured native build and
registered tests inside the dedicated container:

```sh
sudo lxc-attach -n saivage-lua-libghidra -- sh -c \
  'cd /work/lua-libghidra && cmake --build build -j4 && ctest --test-dir build --output-on-failure'
```

Result: Ninja reported no work; **18/18 registered tests passed**, 16.23 seconds.
This was not a clean rebuild, installed-route qualification, a sanitizer rerun,
or a complete full-tier test run. Passing it does not refute findings outside
its registered coverage.

Host-local raw log (not a portable package artifact):
`/home/salva/g/ml/tmp/lua-libghidra-package-audit-2026-10-16/baseline-build-ctest.log`.

The runtime status probe before review reported stopped/idle with no active
actors. No lifecycle commands were issued. Only audit/design/plan documents may
be committed during this task; implementation and submission remain unapproved.
