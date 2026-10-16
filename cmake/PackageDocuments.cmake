# MIT Copyright 2026 Salvador Fandiño.
# Sole native-package document inventory. Also usable with cmake -P by the site.
set(LLG_PACKAGE_DOCUMENTS
  README.md
  LICENSE
  native-inputs.lock.json
  native-patched.lock.json
  native-system.lock.json
  docs/EXAMPLES.md
  docs/API.md
  docs/NOTICES.md
  api/FIELDS.md
  docs/evidence/native-notices/libghidra.txt
  docs/evidence/native-notices/engine.txt
  docs/evidence/native-notices/protobuf.txt
  docs/evidence/native-notices/abseil.txt
  docs/evidence/native-notices/utf8-range.txt
  docs/evidence/native-notices/httplib.txt
  docs/evidence/native-notices/binutils.txt
  docs/evidence/native-notices/libiberty-dev.txt
  docs/evidence/native-notices/zlib1g.txt
  docs/evidence/native-notices/libzstd1.txt
  docs/evidence/native-notices/libc6.txt
  docs/evidence/native-notices/libstdc++6.txt
  docs/evidence/native-notices/lua.txt
  docs/evidence/native-notices/engine-zlib.txt
)
function(llg_export_package_documents output)
  string(REPLACE ";" "\n" documents "${LLG_PACKAGE_DOCUMENTS}")
  file(WRITE "${output}" "${documents}\n")
endfunction()
