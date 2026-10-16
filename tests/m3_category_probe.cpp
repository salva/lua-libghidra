// MIT Copyright 2026 Salvador Fandiño.
// Direct native category qualification; not new Lua M4 mutation adapters.
#include <libghidra/local.hpp>
#include <iostream>
#include <stdexcept>
using namespace libghidra::client;
template<class T> T checked(StatusOr<T> r) {
 if(!r.status.ok() || !r.value) throw std::runtime_error(r.status.code+": "+r.status.message);
 return std::move(*r.value);
}
int main(int argc,char** argv) {
 if(argc!=3) return 2;
 try {
 LocalClientOptions opts; opts.state_path=argv[2];
 auto c=CreateLocalClient(opts);
 OpenProgramRequest p; p.program_path=argv[1]; p.language_id="x86:LE:64:default";p.compiler_spec_id="gcc";
 checked(c->OpenProgram(p)); checked(c->GetDecompilation(0x401106,30000));
 auto report=[](const char* op,auto r){std::cout<<op<<" status="<<r.status.code<<" value="<<bool(r.value)<<std::endl;return checked(std::move(r));};
 if(! report("struct",c->CreateType("M3Struct","struct",16)).updated) throw std::runtime_error("mutation flag false");
 if(! report("member",c->AddTypeMember("M3Struct","field","int",4)).updated) throw std::runtime_error("mutation flag false");
 if(! report("alias",c->CreateTypeAlias("M3Alias","int")).updated) throw std::runtime_error("mutation flag false");
 if(! report("enum",c->CreateTypeEnum("M3Enum",4,true)).updated) throw std::runtime_error("mutation flag false");
 if(! report("enum member",c->AddTypeEnumMember("M3Enum","ONE",1)).updated) throw std::runtime_error("mutation flag false");
 if(! report("signature",c->SetFunctionSignature(0x401106,"int native_smoke(int x)")).updated) throw std::runtime_error("mutation flag false");
 if(! report("comment",c->SetComment(0x401106,CommentKind::kEol,"M3 persisted comment")).updated) throw std::runtime_error("mutation flag false");
 if(! report("data",c->ApplyDataType(0x404010,"int")).updated) throw std::runtime_error("mutation flag false");
 PerfBenchmarkRecord perf;perf.bench_id="m3_perf";perf.status="ok";
 if(!report("benchmark",c->AddPerfBenchmark(perf)).added) throw std::runtime_error("benchmark flag false");
 auto observe=[&](const char* phase) {
  std::cout<<phase<<" aliases="<<checked(c->ListTypeAliases("M3",100,0)).aliases.size()
   <<" enums="<<checked(c->ListTypeEnums("M3",100,0)).enums.size()
   <<" members="<<checked(c->ListTypeMembers("M3Struct",100,0)).members.size()
   <<" enum_members="<<checked(c->ListTypeEnumMembers("M3Enum",100,0)).members.size()
   <<" comments="<<checked(c->GetComments(0x401106,0x401106,100,0)).comments.size()
   <<" data="<<checked(c->ListDataItems(0x404010,0x404010,100,0)).data_items.size()
   <<" benchmarks="<<checked(c->ListPerfBenchmarks()).records.size()<<std::endl;
 };
 observe("before-save");
 auto saved=checked(c->SaveProgram());std::cout<<"saved="<<saved.saved<<std::endl;
 checked(c->CloseProgram(ShutdownPolicy::kDiscard)); c.reset();
 c=CreateLocalClient(opts);checked(c->OpenProgram(p));observe("after-reopen");
 } catch(const std::exception& e) {std::cerr<<e.what()<<std::endl;return 1;}
}
