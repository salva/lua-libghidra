// MIT Copyright 2026 Salvador Fandiño. Direct native M0 qualification.
#include <libghidra/local.hpp>
#include <iostream>
#include <stdexcept>
using namespace libghidra::client;
void require(bool b, const char* m) { if (!b) throw std::runtime_error(m); }
int main(int argc, char** argv) { try {
 require(argc==4,"usage: project_probe SPECS PROJECT ELF");
 LocalClientOptions o; o.ghidra_root=argv[1]; o.pool_size=1;
 auto c=CreateLocalClient(o); OpenProgramRequest r;
 r.project_path=argv[2]; r.program_path=argv[3];
 auto opened=c->OpenProgram(r); require(opened.status.ok(),opened.status.message.c_str());
 std::cout<<"project open passed\n";
 auto d=c->GetDecompilation(0x401106,30000);
 require(d.status.ok() && d.value && d.value->decompilation.has_value(),"decompilation absent");
 auto &v=*d.value->decompilation;
 std::cout<<"completed="<<v.completed<<" fallback="<<v.is_fallback<<"\n"<<v.pseudocode<<"\n";
 require(v.completed && !v.is_fallback && v.pseudocode.find("* 3 + 7")!=std::string::npos,"arithmetic semantics");
 auto leaves=c->ListLeafFunctions(0x401106,0x40113f,100,0);
 require(leaves.status.ok() && leaves.value,"project leaves unavailable");
 std::cout<<"leaves="<<leaves.value->functions.size()<<"\n";
 require(leaves.value->functions.size()==2 && leaves.value->functions[0].entry_address==0x401106 && leaves.value->functions[1].entry_address==0x40113c,"leaf identities");
 for(auto &f:leaves.value->functions) std::cout<<"leaf "<<std::hex<<f.entry_address<<" "<<f.name<<"\n";
 auto bytes=c->ReadBytes(0x401106,4); require(bytes.status.ok() && bytes.value,"bytes unavailable"); require(bytes.value->data==std::vector<uint8_t>({0xf3,0x0f,0x1e,0xfa}),"entry bytes");
 auto ins=c->GetInstruction(0x401106); require(ins.status.ok() && ins.value,"instruction unavailable"); require(ins.value->instruction && ins.value->instruction->address==0x401106 && ins.value->instruction->length==4,"entry instruction"); std::cout<<ins.value->instruction->disassembly<<"\n";
 auto main_d=c->GetDecompilation(0x40111f,30000); require(main_d.status.ok(),"main decompile");
 if(main_d.value && main_d.value->decompilation) std::cout<<main_d.value->decompilation->pseudocode<<"\n";
 auto x=c->ListXrefs(0x40111f,0x40113f,100,0);
 require(x.status.ok() && x.value && !x.value->xrefs.empty(),"call xrefs absent");
 require(x.value->xrefs.size()==1 && x.value->xrefs[0].to_address==0x401106,"call destination");
 std::cout<<"xrefs="<<x.value->xrefs.size()<<"\n";
 auto s=c->SetComment(0x401106,CommentKind::kEol,"authored native comment"); require(s.status.ok(),"set comment");
 auto comments=c->GetComments(0x401106,0x401106,100,0);
 require(comments.status.ok() && comments.value && !comments.value->comments.empty(),"comments absent");
 require(comments.value->comments[0].text=="authored native comment","comment content");
 std::cout<<"comment="<<comments.value->comments[0].text<<"\n";
 auto rd=c->GetDecompilation(0x40113c,30000); require(rd.status.ok(),"data read decompile");
 if(rd.value && rd.value->decompilation) std::cout<<rd.value->decompilation->pseudocode<<"\n";
 auto data=c->ListDataItems(0,~uint64_t(0),100,0);
 require(data.status.ok() && data.value,"data query failed");
 require(data.value->data_items.size()==1 && data.value->data_items[0].address==0x404010 && data.value->data_items[0].size==4,"data identity");
 std::cout<<"data="<<data.value->data_items.size()<<"\n";
 }catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;} }
