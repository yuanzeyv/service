#include "lua_b2_math.h" 
static void RegisterB2Vec2(sol::table& table ){
	table.new_usertype<b2Vec2>("b2Vec2",sol::constructors<b2Vec2(),b2Vec2(float, float)>(),
	 "SetZero", &b2Vec2::SetZero,
	 "Set", &b2Vec2::Set,
	 "Length", &b2Vec2::Length,
	 "LengthSquared", &b2Vec2::LengthSquared,
	 "Normalize", &b2Vec2::Normalize,
	 "IsValid", &b2Vec2::IsValid,
	 "Skew", &b2Vec2::Skew,
	 "x" , sol::readonly(&b2Vec2::x),
	 "y" , sol::readonly(&b2Vec2::y)
	);  
}

static void RegisterB2Vec3(sol::table& table){
	table.new_usertype<b2Vec3>("b2Vec3",sol::constructors<b2Vec3(),b2Vec3(float, float, float)>(), 
	"SetZero", &b2Vec3::SetZero,  
	"Set", &b2Vec3::Set,   
	"x", &b2Vec3::x,  
	"y", &b2Vec3::y,  
	"z", &b2Vec3::z  
	);  
}     
  
static void RegisterB2Mat22(sol::table& table)
{ 
	table.new_usertype<b2Mat22>("b2Mat22",sol::constructors<b2Mat22(),b2Mat22(const b2Vec2&, const b2Vec2&),b2Mat22(float,float, float,float)>(),  
	"Set", &b2Mat22::Set,   
	"SetIdentity", &b2Mat22::SetIdentity,   
	"SetZero", &b2Mat22::SetZero,   
	"GetInverse", &b2Mat22::GetInverse,   
	"Solve", &b2Mat22::Solve,   
	"ex", &b2Mat22::ex,   
	"ey", &b2Mat22::ey    
	);   
}
static void RegisterB2Mat33(sol::table& table)
{ 
	table.new_usertype<b2Mat33>("b2Mat33",sol::constructors<b2Mat33(),b2Mat33(const b2Vec3&, const b2Vec3&,const b2Vec3&)>(),
	"SetZero", &b2Mat33::SetZero,   
	"Solve33", &b2Mat33::Solve33,   
	"Solve22", &b2Mat33::Solve22,   
	"GetInverse22", &b2Mat33::GetInverse22,   
	"GetSymInverse33", &b2Mat33::GetSymInverse33,   
	"ex", &b2Mat33::ex,   
	"ey", &b2Mat33::ey,   
	"ez", &b2Mat33::ez   
	);   
}
static void RegisterB2Rot(sol::table& table)
{ 
	table.new_usertype<b2Rot>("b2Rot",sol::constructors<b2Rot(),b2Rot(float)>(),
	"Set", &b2Rot::Set,   
	"GetYAxis", &b2Rot::GetYAxis,   
	"c", &b2Rot::c,   
	"s", &b2Rot::s,   
	"GetXAxis", &b2Rot::GetXAxis,   
	"GetAngle", &b2Rot::GetAngle,   
	"SetIdentity", &b2Rot::SetIdentity
	);   
}
 
static void RegisterB2Transform(sol::table& table)
{ 
	table.new_usertype<b2Transform>("b2Transform",sol::constructors<b2Transform(),b2Transform(const b2Vec2&, const b2Rot&)>(),
	"SetIdentity", &b2Transform::SetIdentity,  
	"Set", &b2Transform::Set,  
	"p", &b2Transform::p,  
	"q", &b2Transform::q
	);   
}
static void Registerb2Sweep(sol::table& table)
{ 
	table.new_usertype<b2Sweep>("b2Sweep", sol::constructors<b2Sweep()>(),
	 "GetTransform", &b2Sweep::GetTransform, 
	 "Advance", &b2Sweep::Advance, 
	 "Normalize", &b2Sweep::Normalize ,
	 "localCenter",&b2Sweep::localCenter,
	 "c0",&b2Sweep::c0,
	 "c",&b2Sweep::c,
	 "a0",&b2Sweep::a0,
	 "a",&b2Sweep::a,
	 "alpha0",&b2Sweep::alpha0
	);   
}
void b2_math_Register(sol::table& table){  
	Registerb2Sweep(table); 
	RegisterB2Transform(table);
	RegisterB2Rot(table);
	RegisterB2Mat33(table);
	RegisterB2Mat33(table);
	RegisterB2Vec3(table);
	RegisterB2Vec2(table);
}  