#include "lua_b2_fixture.h"
static void RegisterB2Filter(sol::table& table)
{
	table.new_usertype<b2Filter>("b2Filter",sol::constructors<b2Filter()>(),   
	 "categoryBits",&b2Filter::categoryBits, 
	 "maskBits",&b2Filter::maskBits, 
	 "groupIndex",&b2Filter::groupIndex
	);
} 
static void RegisterB2FixtureDef(sol::table& table)
{
	table.new_usertype<b2FixtureDef>("b2FixtureDef",
	sol::constructors<b2FixtureDef()>(),   
	 "filter",&b2FixtureDef::filter, 
	 "isSensor",&b2FixtureDef::isSensor, 
	 "density",&b2FixtureDef::density, 
	 "restitutionThreshold",&b2FixtureDef::restitutionThreshold, 
	 "restitution",&b2FixtureDef::restitution, 
	 "friction",&b2FixtureDef::friction, 
	 "userData",&b2FixtureDef::userData, 
	 "shape",&b2FixtureDef::shape,  
	 "density",&b2FixtureDef::density
	);
}

static void RegisterB2FixtureProxy(sol::table& table)
{
	table.new_usertype<b2FixtureProxy>("b2FixtureProxy",sol::constructors<b2FixtureProxy()>(),   
	 "proxyId",&b2FixtureProxy::proxyId, 
	 "childIndex",&b2FixtureProxy::childIndex, 
	 "fixture",&b2FixtureProxy::fixture, 
	 "aabb",&b2FixtureProxy::aabb
	);
} 
 
static void RegisterB2Fixture(sol::table& table)
{
	table.new_usertype<b2Fixture>("b2Fixture",
	 "GetType",&b2Fixture::GetType, 
	 "Dump",[](b2Fixture& self)->b2Shape* { 
		 return self.GetShape();
	 	},
	 "SetSensor",&b2Fixture::SetSensor, 
	 "IsSensor",&b2Fixture::IsSensor, 
	 "SetFilterData",&b2Fixture::SetFilterData, 
	 "GetFilterData",&b2Fixture::GetFilterData, 
	 "Refilter",&b2Fixture::Refilter,  
	 "GetBody",[](b2Fixture& self)->b2Body* { 
		 return self.GetBody();
	 	},
	 "GetNext",[](b2Fixture& self)->b2Fixture* { 
		 return self.GetNext();
	 	},
	 "GetUserData",[](b2Fixture& self)->b2FixtureUserData& { 
		 return self.GetUserData();
	 	},
	 "TestPoint",&b2Fixture::TestPoint,  
	 "RayCast",&b2Fixture::RayCast,  
	 "GetMassData",&b2Fixture::GetMassData,  
	 "SetDensity",&b2Fixture::SetDensity,  
	 "GetDensity",&b2Fixture::GetDensity,  
	 "GetDensity",&b2Fixture::GetDensity,  
	 "GetFriction",&b2Fixture::GetFriction,  
	 "SetFriction",&b2Fixture::SetFriction,  
	 "GetRestitution",&b2Fixture::GetRestitution,  
	 "SetRestitution",&b2Fixture::SetRestitution,  
	 "GetRestitutionThreshold",&b2Fixture::GetRestitutionThreshold,  
	 "SetRestitutionThreshold",&b2Fixture::SetRestitutionThreshold,  
	 "GetAABB",&b2Fixture::GetAABB,  
	 "Dump",&b2Fixture::Dump
	);
}  

void b2_fixture_Register(sol::table& table){  
	RegisterB2Filter(table);
	RegisterB2FixtureDef(table);
	RegisterB2FixtureProxy(table);
	RegisterB2Fixture(table);
}   