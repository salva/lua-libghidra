// MIT Copyright 2026 Salvador Fandiño.
// Direct native authority for the extreme-address failure; intentionally isolated.
#include <libghidra/local.hpp>
#include <iostream>
#include <stdexcept>
#include <limits>
using namespace libghidra::client;
template<class T> T take(StatusOr<T> r) {
 if(!r.status.ok() || !r.value) throw std::runtime_error(r.status.message);
 return std::move(*r.value);
}
int main(int argc,char** argv) {
 if(argc!=4) return 2;
 auto c=CreateLocalClient({}); OpenProgramRequest p;
 p.program_path=argv[1]; p.language_id="x86:LE:64:default"; p.compiler_spec_id="gcc";
 if(std::string(argv[2])=="project") p.project_path=argv[3];
 take(c->OpenProgram(p));
 for(auto a:{0x401106,0x40111f,0x40113c}) take(c->GetDecompilation(a,30000));
 for(int view=0;view<2;++view) {
  take(c->GetStatus()); take(c->GetCapabilities()); take(c->GetFunction(0x401106));
  take(c->GetInstruction(0x401106)); take(c->ReadBytes(0x401106,4));
  for(auto end:{uint64_t(0),uint64_t(0),UINT64_MAX}) {
   take(c->ListFunctions(0x401106,end,2,0)); take(c->ListInstructions(0x401106,end,2,0));
  }
  take(c->ListInstructions(0x401106,0x401106,2,0)); take(c->ListInstructions(0,UINT64_MAX,2,0));
  take(c->ListFunctions(0x401106,0x401106,100,0)); take(c->ListFunctions(0x401106,UINT64_MAX,2,0));
  take(c->GetDecompilation(0x401106,30000));
 }
 take(c->GetFunction(UINT64_MAX));
 std::cerr<<"direct native before UINT64_MAX decompilation\n";
 auto r=take(c->GetDecompilation(UINT64_MAX,30000));
 if(r.decompilation) std::cerr<<"completed="<<r.decompilation->completed<<" fallback="<<r.decompilation->is_fallback<<" error="<<r.decompilation->error_message<<"\n";
 take(c->CloseProgram(ShutdownPolicy::kDiscard));
}
