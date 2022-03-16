#include "lua_b2_circle_shape.h"
static void RegisterB2CircleShape(sol::table& table)
{
	auto luaBaseObject = table.new_usertype<b2CircleShape>("b2CircleShape",sol::constructors<b2CircleShape()>());
	luaBaseObject[sol::meta_function::new_index] = &b2CircleShape::SetPropertyLua; 
	luaBaseObject[sol::meta_function::index] = &b2CircleShape::GetPropertyLua;  
	luaBaseObject["Clone"] = &b2CircleShape::Clone; 
	luaBaseObject["GetType"] = &b2CircleShape::GetType; 
	luaBaseObject["GetChildCount"] = &b2CircleShape::GetChildCount; 
	luaBaseObject["TestPoint"] = &b2CircleShape::TestPoint;
	luaBaseObject["RayCast"] = &b2CircleShape::RayCast,  
	luaBaseObject["ComputeAABB"] = &b2CircleShape::ComputeAABB;   
	luaBaseObject["ComputeMass"] = &b2CircleShape::ComputeMass;
	luaBaseObject["m_type"] = &b2CircleShape::m_type;
	luaBaseObject["m_radius"] = &b2CircleShape::m_radius; 
	luaBaseObject["m_p"] = &b2CircleShape::m_p; 
	luaBaseObject["GetShapePoint"] = [](b2CircleShape& self)-> b2Shape& { 
		 return self;
	};
}  

void b2_circle_shape_Register(sol::table& table){  
	RegisterB2CircleShape(table); 
} 