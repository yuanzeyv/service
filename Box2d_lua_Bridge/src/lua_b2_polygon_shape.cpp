#include "lua_b2_polygon_shape.h"
#include "sol/sol.hpp"
using namespace std;
static void RegisterB2PolygonShape(sol::table& table)
{
	auto luaBaseObject = table.new_usertype<b2PolygonShape>("b2PolygonShape", sol::constructors<b2PolygonShape()>(),  
	 "Clone", &b2PolygonShape::Clone,  
	 "GetChildCount", &b2PolygonShape::GetChildCount,   
	 "SetAsBox",[](b2PolygonShape& self,float hx, float hy){ 
		self.SetAsBox(hx,hy);
	  },     
	 "SetAsBox_Center",[](b2PolygonShape& self,float hx, float hy, const b2Vec2& center, float angle){ 
		self.SetAsBox(hx,hy,center,angle);
	  },     
	 "TestPoint", &b2PolygonShape::TestPoint,  
	 "RayCast", &b2PolygonShape::RayCast,  
	 "ComputeAABB", &b2PolygonShape::ComputeAABB,  
	 "ComputeMass", &b2PolygonShape::ComputeMass,  
	 "Validate", &b2PolygonShape::Validate,  
	 "m_centroid", &b2PolygonShape::m_centroid,  
	 "m_vertices", &b2PolygonShape::m_vertices,  
	 "m_normals", &b2PolygonShape::m_normals,  
	 "m_count", &b2PolygonShape::m_count,
	 "GetShapePoint",[](b2PolygonShape& self)-> b2Shape& { 
		 return self;
	  }	,
	  "Set",[](b2PolygonShape& self, sol::table table){  
		  //é¦–å…ˆèŽ·å–åˆ°å½“å‰çš„å¤§å°
		  int size = table.size();
		  //ç„¶åŽé€šè¿‡å¤§å°åˆ›å»ºä¸€ä¸ªæ•°ç»„
		  b2Vec2 arr[size];
		  for(int i = 0 ; i < size ; i++ ) {
			sol::table cell = table.get<sol::table>(i + 1 );
			float x = cell.get<float>(1);
			float y = cell.get<float>(2);
			arr[i].Set(x,y);
		  }     
		  self.Set(arr,size);  
	  }
	  
	);  
	luaBaseObject[sol::meta_function::new_index] = &b2PolygonShape::SetPropertyLua; 
	luaBaseObject[sol::meta_function::index] = &b2PolygonShape::GetPropertyLua;  
}  

void b2_polygon_shape_Register(sol::table& table){  
	RegisterB2PolygonShape(table); 
} 