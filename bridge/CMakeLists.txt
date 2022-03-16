include_directories("./include")
include_directories("./include/Lua_box2d")
LINK_DIRECTORIES("/usr/local/lib")
add_library(
   b2d 
    SHARED 
    src/lua_b2_world.cpp 
    src/lua_b2_block_allocator.cpp 
    src/lua_b2_body.cpp
    src/lua_b2_math.cpp
    src/lua_b2_fixture.cpp
    src/lua_b2_broad_phase.cpp
    src/lua_b2_chain_shape.cpp
    src/lua_b2_circle_shape.cpp
    src/lua_b2_edge_shape.cpp
    src/lua_b2_polygon_shape.cpp
    src/lua_b2_shape.cpp
    src/main.cpp
)  
add_compile_options(-fPIC)
set(CMAKE_CXX_FLAGS "-std=c++17")
target_link_libraries( 
    b2d 
    libbox2d.a
)  
install(TARGETS b2d LIBRARY DESTINATION /root/work/Service/scripts/luaclib/)
