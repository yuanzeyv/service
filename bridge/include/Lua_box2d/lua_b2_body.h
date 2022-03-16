#ifndef LUA_B2_BODY_H
#define LUA_B2_BODY_H 
#include <box2d/box2d.h>  
#include <sol/sol.hpp>   
struct b2BodyTypeEnum
{ 
	int b2_staticBody = 0;
	int b2_kinematicBody = 1;
	int b2_dynamicBody = 2;
};  
extern void b2_body_Register(sol::table& table);
#endif 