// MIT Copyright 2026 Salvador Fandiño.
#pragma once
#include <mutex>
namespace llg {
// ABI shared by every binding DSO in the ordinary process loader namespace.
struct ProcessGuard { std::mutex engine; bool occupied = false; };
ProcessGuard& process_guard() noexcept;
}
