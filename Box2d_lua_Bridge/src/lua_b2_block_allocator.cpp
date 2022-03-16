#include "lua_b2_block_allocator.h" 
static void RegisterB2BlockAllocator(sol::table& table)
{ 
	table.new_usertype<b2BlockAllocator>("b2BlockAllocator",sol::constructors<b2BlockAllocator()>(),  
	 "Allocate", &b2BlockAllocator::Allocate, 
	 "Free", &b2BlockAllocator::Free, 
	 "Clear", &b2BlockAllocator::Clear
	);   
}  
void b2BlockAllocator_Register(sol::table& table){  
	 RegisterB2BlockAllocator(table);
} 