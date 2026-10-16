// MIT Copyright 2026 Salvador Fandiño.
#pragma once
// Test-only, nonallocating native-phase attribution. Never invokes Lua.
#ifdef LLG_NATIVE_PHASE_OBSERVER
namespace llg {
void native_phase_event(int kind, bool entering) noexcept;
struct NativePhaseTest {
 int kind;
 explicit NativePhaseTest(int k) noexcept : kind(k) { native_phase_event(kind,true); }
 ~NativePhaseTest() noexcept { native_phase_event(kind,false); }
};
}
#define LLG_NATIVE_PHASE(kind) llg::NativePhaseTest native_phase_test(kind)
#else
#define LLG_NATIVE_PHASE(kind) ((void)0)
#endif
