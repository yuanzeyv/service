
#include "lua_b2_chain_shape.h"
static void RegisterB2ChainShape(sol::table& table)
{
	table.new_usertype<b2ChainShape>("b2BroadPhase",sol::constructors<b2ChainShape()>(),
	 "Clear", &b2ChainShape::Clear,  
	 "CreateLoop", &b2ChainShape::CreateLoop,  
	 "CreateChain", &b2ChainShape::CreateChain,  
	 "Clone", &b2ChainShape::Clone,  
	 "GetChildCount", &b2ChainShape::GetChildCount,  
	 "GetChildEdge", &b2ChainShape::GetChildEdge,  
	 "TestPoint", &b2ChainShape::TestPoint,  
	 "RayCast", &b2ChainShape::RayCast,  
	 "ComputeAABB", &b2ChainShape::ComputeAABB,  
	 "ComputeMass", &b2ChainShape::ComputeMass,  
	 "m_vertices", &b2ChainShape::m_vertices,  
	 "m_count", &b2ChainShape::m_count,  
	 "m_prevVertex", &b2ChainShape::m_prevVertex,  
	 "m_nextVertex", &b2ChainShape::m_nextVertex 
	);   
}  

void b2_chain_shape_Register(sol::table& table){  
	RegisterB2ChainShape(table); 
}
 