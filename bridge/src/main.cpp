#include "Lua_box2d/lua_b2_world.h"
#include "Lua_box2d/lua_b2_block_allocator.h"
#include "Lua_box2d/lua_b2_body.h"
#include "Lua_box2d/lua_b2_math.h" 
#include "Lua_box2d/lua_b2_fixture.h" 
#include "Lua_box2d/lua_b2_broad_phase.h"
#include "Lua_box2d/lua_b2_chain_shape.h"
#include "Lua_box2d/lua_b2_circle_shape.h" 
#include "Lua_box2d/lua_b2_edge_shape.h"
#include "Lua_box2d/lua_b2_polygon_shape.h"
#include "Lua_box2d/lua_b2_shape.h" 
#include <sol/sol.hpp>
#include <iostream>
using namespace std;
sol::table RegisterAll(sol::this_state L) { 
	sol::state_view lua(L);   
	sol::table module = lua.create_table(); 
    b2_world_Register(module); 
    b2BlockAllocator_Register(module);
    b2_body_Register(module);
    b2_math_Register(module);
    b2_fixture_Register(module);
    b2_broad_phase_Register(module);
    b2_chain_shape_Register(module);
    b2_circle_shape_Register(module);
    b2_edge_shape_Register(module);
	b2_polygon_shape_Register(module);
    b2_shape_Register(module);
    cout << "AAAAAAAAA" << endl;
	return module ;
}       

extern "C" int luaopen_libb2d(lua_State* L) {  
	sol::stack::call_lua(L, -1, RegisterAll);
	return 1;
}  