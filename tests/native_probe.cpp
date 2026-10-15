// MIT, Copyright 2026 Salvador Fandiño. Native dependency experiment only.
#include <libghidra/local.hpp>
#include <iostream>
int main(int argc, char** argv) {
  try {
    libghidra::client::LocalClientOptions options;
    if (argc > 1) options.ghidra_root = argv[1];
    options.pool_size = 1;
    auto client = libghidra::client::CreateLocalClient(options);
    auto status = client->GetStatus();
    if (!status.status.ok()) { std::cerr << status.status.code << ": " << status.status.message << '\n'; return 2; }
    std::cout << "constructed profile=" << (options.ghidra_root.empty() ? "embedded" : "external") << '\n';
    if (argc > 3) {
      libghidra::client::OpenProgramRequest request;
      request.program_path = argv[2];
      request.language_id = argc > 4 ? argv[4] : "x86:LE:64:default";
      request.compiler_spec_id = request.language_id.empty() ? "" : "gcc";
      auto opened = client->OpenProgram(request);
      if (!opened.status.ok()) { std::cerr << opened.status.code << ": " << opened.status.message << '\n'; return 4; }
      auto result = client->GetDecompilation(std::stoull(argv[3], nullptr, 0), 30000);
      if (!result.status.ok()) { std::cerr << result.status.message << '\n'; return 5; }
      if (!result.value || !result.value->decompilation) return 6;
      const auto& d = *result.value->decompilation;
      std::cout << "completed=" << d.completed << " fallback=" << d.is_fallback << " error=" << d.error_message << '\n' << d.pseudocode << '\n';
      if (!d.completed || d.is_fallback || d.pseudocode.empty()) return 7;
    }
    return 0;
  } catch (const std::exception& e) { std::cerr << e.what() << '\n'; return 3; }
}
