#include "lua_b2_world.h"
#include <box2d/box2d.h>
static void RegisterB2World(sol::table& table)
{	   
	table.new_usertype<b2World>("b2World",sol::constructors<b2World(const b2Vec2&)>(),  
	 sol::meta_function::new_index, &b2World::SetPropertyLua, 
	 sol::meta_function::index, &b2World::GetPropertyLua, 
	 "SetDestructionListener", &b2World::SetDestructionListener, 
	 "SetContactFilter", &b2World::SetContactFilter, 
	 "SetContactListener", &b2World::SetContactListener, 
	 "CreateBody", &b2World::CreateBody, 
	 "DestroyBody", &b2World::DestroyBody, 
	 "CreateJoint", &b2World::CreateJoint, 
	 "DestroyJoint", &b2World::DestroyJoint, 
	 "Step", &b2World::Step, 
	 "ClearForces", &b2World::ClearForces, 
	 "Dump", &b2World::Dump, 
	 "GetProfile", &b2World::GetProfile, 
	 "GetContactManager", &b2World::GetContactManager, 
	 "ShiftOrigin", &b2World::ShiftOrigin, 
	 "GetAutoClearForces", &b2World::GetAutoClearForces, 
	 "SetAutoClearForces", &b2World::SetAutoClearForces, 
	 "IsLocked", &b2World::IsLocked, 
	 "GetGravity", &b2World::GetGravity, 
	 "SetGravity", &b2World::SetGravity, 
	 "GetTreeQuality", &b2World::GetTreeQuality, 
	 "GetTreeBalance", &b2World::GetTreeBalance, 
	 "GetTreeHeight", &b2World::GetTreeHeight, 
	 "GetContactCount", &b2World::GetContactCount, 
	 "GetJointCount", &b2World::GetJointCount, 
	 "GetBodyCount", &b2World::GetBodyCount, 
	 "GetProxyCount", &b2World::GetProxyCount, 
	 "GetSubStepping", &b2World::GetSubStepping, 
	 "SetSubStepping", &b2World::SetSubStepping, 
	 "GetContinuousPhysics", &b2World::GetContinuousPhysics, 
	 "SetContinuousPhysics", &b2World::SetContinuousPhysics, 
	 "GetWarmStarting", &b2World::GetWarmStarting, 
	 "SetWarmStarting", &b2World::SetWarmStarting, 
	 "GetAllowSleeping", &b2World::GetAllowSleeping, 
	 "SetAllowSleeping", &b2World::SetAllowSleeping, 
	 "RayCast", &b2World::RayCast, 
	 "QueryAABB", &b2World::QueryAABB ,
	 "GetBodyList",[](b2World& self)->b2Body* { 
		 return self.GetBodyList();
	 	},    
	 "GetJointList",[](b2World& self)->b2Joint* { 
		 return self.GetJointList();
	 	},    
	 "GetContactList",[](b2World& self)->b2Contact* { 
		 return self.GetContactList();
	 	}
	);   
} 

void b2_world_Register(sol::table& table){  
	RegisterB2World(table);
}  