#include "lua_b2_edge_shape.h"
static void RegisterB2EdgeShape(sol::table& table)
{
	table.new_usertype<b2EdgeShape>("b2EdgeShape",sol::constructors<b2EdgeShape()>(),  
	 "SetOneSided", & b2EdgeShape::SetOneSided,  
	 "SetTwoSided", & b2EdgeShape::SetTwoSided,  
	 "Clone", & b2EdgeShape::Clone,  
	 "GetChildCount", & b2EdgeShape::GetChildCount,   
	 "GetType", & b2EdgeShape::GetType,   
	 "TestPoint", & b2EdgeShape::TestPoint,
	 "RayCast", & b2EdgeShape::RayCast,  
	 "ComputeAABB", & b2EdgeShape::ComputeAABB,  
	 "ComputeMass", &b2EdgeShape::ComputeMass,  
	 "m_vertex1", &b2EdgeShape::m_vertex1,  
	 "m_vertex2", &b2EdgeShape::m_vertex2,  
	 "m_vertex0", &b2EdgeShape::m_vertex0,  
	 "m_vertex3", &b2EdgeShape::m_vertex3,  
	 "m_oneSided", &b2EdgeShape::m_oneSided 
	);   
}  

void b2_edge_shape_Register(sol::table& table){  
	RegisterB2EdgeShape(table); 
} 