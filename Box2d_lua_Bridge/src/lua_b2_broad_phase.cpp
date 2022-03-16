#include "lua_b2_broad_phase.h"
static void RegisterB2Pair(sol::table& table)
{
	table.new_usertype<b2Pair>("b2Pair",
	 "proxyIdA", &b2Pair::proxyIdA, 
	 "proxyIdB", &b2Pair::proxyIdB
	);

}
static void RegisterB2BroadPhase(sol::table& table)
{
	table.new_usertype<b2BroadPhase>("b2BroadPhase",
	 "CreateProxy", &b2BroadPhase::CreateProxy, 
	 "DestroyProxy", &b2BroadPhase::DestroyProxy, 
	 "MoveProxy", &b2BroadPhase::MoveProxy, 
	 "TouchProxy", &b2BroadPhase::TouchProxy,  
	 "GetFatAABB", &b2BroadPhase::GetFatAABB, 
	 "GetUserData", &b2BroadPhase::GetUserData, 
	 "TestOverlap", &b2BroadPhase::TestOverlap, 
	 "GetProxyCount", &b2BroadPhase::GetProxyCount,   
	 "GetTreeHeight", &b2BroadPhase::GetTreeHeight, 
	 "GetTreeBalance", &b2BroadPhase::GetTreeBalance, 
	 "GetTreeQuality", &b2BroadPhase::GetTreeQuality, 
	 "ShiftOrigin", &b2BroadPhase::ShiftOrigin
	);   
}  

void b2_broad_phase_Register(sol::table& table){  
	RegisterB2BroadPhase(table);
	RegisterB2Pair(table);
} 