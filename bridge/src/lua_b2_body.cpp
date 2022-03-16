#include "lua_b2_body.h"
static void RegisterB2BodyDef(sol::table& table)
{
	table.new_usertype<b2BodyDef>("b2BodyDef",sol::constructors<b2BodyDef()>(),   
	 "type",&b2BodyDef::type,
	 "position",&b2BodyDef::position,
	 "angle",&b2BodyDef::angle,
	 "linearVelocity",&b2BodyDef::linearVelocity,
	 "angularVelocity",&b2BodyDef::angularVelocity,
	 "linearDamping",&b2BodyDef::linearDamping,
	 "angularDamping",&b2BodyDef::angularDamping,
	 "allowSleep",&b2BodyDef::allowSleep,
	 "awake",&b2BodyDef::awake,
	 "fixedRotation",&b2BodyDef::fixedRotation,
	 "bullet",&b2BodyDef::bullet,
	 "enabled",&b2BodyDef::enabled,
	 "userData",&b2BodyDef::userData,
	 "gravityScale",&b2BodyDef::gravityScale
	);
}
static void RegisterB2Body(sol::table& table)
{ 
	table.new_usertype<b2Body>("b2Body",
	 "CreateFixture_Fixture", [](b2Body& self,const b2FixtureDef* def)->b2Fixture*  { 
		 return self.CreateFixture(def);
	 	},
	 "CreateFixture_Shape",[](b2Body& self,const b2Shape* shape, float density)->b2Fixture*  { 
		 return self.CreateFixture(shape,density);
	 	},
	 "DestroyFixture", &b2Body::DestroyFixture,
	 "SetTransform", &b2Body::SetTransform,
	 "GetTransform", &b2Body::GetTransform,
	 "GetPosition", &b2Body::GetPosition,
	 "GetAngle", &b2Body::GetAngle,
	 "GetWorldCenter", &b2Body::GetWorldCenter,
	 "GetLocalCenter", &b2Body::GetLocalCenter,
	 "SetLinearVelocity", &b2Body::SetLinearVelocity,
	 "GetLinearVelocity", &b2Body::GetLinearVelocity,
	 "SetAngularVelocity", &b2Body::SetAngularVelocity,
	 "GetAngularVelocity", &b2Body::GetAngularVelocity,
	 "ApplyForce", &b2Body::ApplyForce,
	 "ApplyForceToCenter", &b2Body::ApplyForceToCenter,
	 "ApplyTorque", &b2Body::ApplyTorque,
	 "ApplyLinearImpulse", &b2Body::ApplyLinearImpulse,
	 "ApplyLinearImpulseToCenter", &b2Body::ApplyLinearImpulseToCenter,
	 "ApplyAngularImpulse", &b2Body::ApplyAngularImpulse,
	 "GetMass", &b2Body::GetMass,
	 "GetInertia", &b2Body::GetInertia,
	 "GetMassData", &b2Body::GetMassData,
	 "SetMassData", &b2Body::SetMassData,
	 "ResetMassData", &b2Body::ResetMassData,
	 "GetWorldPoint", &b2Body::GetWorldPoint,
	 "GetWorldVector", &b2Body::GetWorldVector,
	 "GetLocalPoint", &b2Body::GetLocalPoint,
	 "GetLocalVector", &b2Body::GetLocalVector,
	 "GetLinearVelocityFromLocalPoint",  [](b2Body& self,const b2Vec2& localPoint)->b2Vec2 { 
		 return self.GetLinearVelocityFromLocalPoint(localPoint);
	 	},
	 "GetLinearDamping", &b2Body::GetLinearDamping,
	 "SetLinearDamping", &b2Body::SetLinearDamping,
	 "GetAngularDamping", &b2Body::GetAngularDamping,
	 "SetAngularDamping", &b2Body::SetAngularDamping,
	 "GetGravityScale", &b2Body::GetGravityScale,
	 "SetGravityScale", &b2Body::SetGravityScale,
	 "SetType", &b2Body::SetType,
	 "GetType", &b2Body::GetType,
	 "SetBullet", &b2Body::SetBullet,
	 "IsBullet", &b2Body::IsBullet,
	 "SetSleepingAllowed", &b2Body::SetSleepingAllowed,
	 "IsSleepingAllowed", &b2Body::IsSleepingAllowed,
	 "SetAwake", &b2Body::SetAwake,
	 "IsFixedRotIsAwakeation", &b2Body::IsAwake,
	 "SetEnabled", &b2Body::SetEnabled,
	 "IsEnabled", &b2Body::IsEnabled,
	 "SetFixedRotation", &b2Body::SetFixedRotation,
	 "IsFixedRotation", &b2Body::IsFixedRotation,
	 "GetContactList", [](b2Body& self)->b2ContactEdge* { 
		 return self.GetContactList();
	 	},
	 "GetNext", [](b2Body& self)->b2Body* { 
		 return self.GetNext();
	 	},
	 "GetUserData", [](b2Body& self)->b2BodyUserData& { 
		 return self.GetUserData();
	 	},
	 "GetWorld",[](b2Body& self)->b2World* { 
		 return self.GetWorld();
	 	},    
	 "Dump", &b2Body::Dump
	);   
}
 

static void RegisterB2BodyType(sol::table& table)
{ 
	table.new_usertype<b2BodyTypeEnum>("b2BodyType", 
	 "b2_staticBody", &b2BodyTypeEnum::b2_staticBody, 
	 "b2_kinematicBody", &b2BodyTypeEnum::b2_kinematicBody, 
	 "b2_dynamicBody", &b2BodyTypeEnum::b2_dynamicBody 
	);   
}
void b2_body_Register(sol::table& table){  
	RegisterB2BodyType(table);
	RegisterB2Body(table);
	RegisterB2BodyDef(table);
}  