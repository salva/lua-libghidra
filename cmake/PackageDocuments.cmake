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
  docs/notices/libghidra.txt
  docs/notices/engine.txt
  docs/notices/protobuf.txt
  docs/notices/abseil.txt
  docs/notices/utf8-range.txt
  docs/notices/httplib.txt
  docs/notices/binutils.txt
  docs/notices/libiberty-dev.txt
  docs/notices/zlib1g.txt
  docs/notices/libzstd1.txt
  docs/notices/libc6.txt
  docs/notices/libstdc++6.txt
  docs/notices/lua.txt
  docs/notices/engine-zlib.txt
)
function(llg_export_package_documents output)
  string(REPLACE ";" "\n" documents "${LLG_PACKAGE_DOCUMENTS}")
  file(WRITE "${output}" "${documents}\n")
endfunction()
