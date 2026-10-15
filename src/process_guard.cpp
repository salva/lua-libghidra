// MIT Copyright 2026 Salvador Fandiño.
#include "process_guard.hpp"
namespace llg {
ProcessGuard& process_guard() noexcept {
 static ProcessGuard guard;
 return guard;
}
}
