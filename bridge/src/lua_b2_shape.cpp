#include <box2d/box2d.h> 
#include "lua_b2_shape.h"
static void RegisterB2MassData(sol::table& table)
{ 
	table.new_usertype<b2MassData>("b2MassData",
	 "mass", &b2MassData::mass ,
	 "center", &b2MassData::center ,
	 "I", &b2MassData::I  
	);
}
static void RegisterB2ShapeType(sol::table& table)
{
	
	table.new_usertype<b2ShapeType>("b2ShapeType",
	 "e_circle", &b2ShapeType::e_circle ,
	 "e_edge", &b2ShapeType::e_edge ,
	 "e_polygon", &b2ShapeType::e_polygon ,
	 "e_chain", &b2ShapeType::e_chain ,
	 "e_typeCount", &b2ShapeType::e_typeCount 
	); 
}
static void RegisterB2Shape(sol::table& table)
{
	auto luaBaseObject = table.new_usertype<b2Shape>("b2Shape");
	luaBaseObject[sol::meta_function::new_index] = &b2Shape::SetPropertyLua; 
	luaBaseObject[sol::meta_function::index] = &b2Shape::GetPropertyLua;  
	luaBaseObject["Clone"] = &b2Shape::Clone; 
	luaBaseObject["GetType"] = &b2Shape::GetType; 
	luaBaseObject["GetChildCount"] = &b2Shape::GetChildCount; 
	luaBaseObject["TestPoint"] = &b2Shape::TestPoint;
	luaBaseObject["RayCast"] = &b2Shape::RayCast,  
	luaBaseObject["ComputeAABB"] = &b2Shape::ComputeAABB;   
	luaBaseObject["ComputeMass"] = &b2Shape::ComputeMass;
	luaBaseObject["m_type"] = &b2Shape::m_type;
	luaBaseObject["m_radius"] = &b2Shape::m_radius; 
}

void b2_shape_Register(sol::table& table){  
	RegisterB2MassData(table);  
	RegisterB2ShapeType(table);
	RegisterB2Shape(table); 
} 