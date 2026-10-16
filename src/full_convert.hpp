// MIT Copyright 2026 Salvador Fandiño.
#pragma once
#include "core_convert.hpp"
namespace llg::slice {
inline void value(lua_State* L,const c::DataItemRecord& v) {
 lua_createtable(L,0,7);
 field(L,"address",v.address); field(L,"end_address",v.end_address);
 field(L,"name",v.name); field(L,"data_type",v.data_type);
 field(L,"size",v.size); field(L,"value_repr",v.value_repr);
}
inline void value(lua_State* L,const c::PerfBenchmarkRecord& v) {
 lua_createtable(L,0,10);
 field(L,"bench_id",v.bench_id); field(L,"query_family",v.query_family);
 field(L,"dataset_profile",v.dataset_profile); field(L,"status",v.status);
 lua_pushnumber(L,v.cold_ms_p50); lua_setfield(L,-2,"cold_ms_p50");
 lua_pushnumber(L,v.cold_ms_p95); lua_setfield(L,-2,"cold_ms_p95");
 lua_pushnumber(L,v.warm_ms_p50); lua_setfield(L,-2,"warm_ms_p50");
 lua_pushnumber(L,v.warm_ms_p95); lua_setfield(L,-2,"warm_ms_p95");
 lua_pushnumber(L,v.throughput_qps); lua_setfield(L,-2,"throughput_qps");
 lua_pushnumber(L,v.regression_pct); lua_setfield(L,-2,"regression_pct");
}
}
