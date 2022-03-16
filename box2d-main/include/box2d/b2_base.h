

#ifndef B2_BASE_H
#define B2_BASE_H 
#include <unordered_map>
#include <sol/sol.hpp>
class  b2Base
{
public: 
	struct obj_hash {
		std::size_t operator()(const sol::object& obj) const noexcept {
			return std::hash<const void*>()(obj.pointer());
		}
	}; 
	std::unordered_map<sol::object, sol::object, obj_hash> props;

	sol::object GetPropertyLua(sol::stack_object key) const {
		if (auto it = props.find(key); it != props.cend()) {
			return it->second;
		}
		return sol::lua_nil;
	}

	void SetPropertyLua(sol::stack_object key, sol::stack_object value) {
		props.insert_or_assign(key, sol::object(value));
	}
};  
#endif
