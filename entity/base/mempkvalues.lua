local skynet = require "skynet"
local print_r = require "print_r"
local MemPkValues = class("MemPkValues")

function MemPkValues:ctor(name, value_type, use_local)
	self._name = name
	self._value_type = value_type
	self._use_local = use_local
	self._has_load = false
	self._local_cache = {}
end

function MemPkValues:add_item(values)
	if table.empty(values) then
		return false
	end
	if self._use_local then
		for _, value in pairs(values) do
			local is_exist = false
			for _, item in pairs(self._local_cache) do
				if value == item then
					is_exist = true
					break
				end
			end
			if not is_exist then
				table.insert(self._local_cache, value)
			end
		end
	end
	local ret = skynet.call("redispool", "lua", "sadd", self._name, values)
	return ret
end

function MemPkValues:remove_item(value)
	if self._use_local then
		local pos = 0
		for index, item in pairs(self._local_cache) do
			if value == item then
				pos = index
				break
			end
		end
		if pos ~= 0 then
			table.remove(self._local_cache, pos)
		end
	end
	local ret = skynet.call("redispool", "lua", "srem", self._name, value)
	return ret
end

function MemPkValues:has_item(value)
	if self._use_local and not table.empty(self._local_cache) then
		for _, item in pairs(self._local_cache) do
			if value == item then
				return true
			end
		end
	end
	local ret = skynet.call("redispool", "lua", "sismember", self._name, value)
	return ret
end

function MemPkValues:exists_item()
	if self._use_local and not table.empty(self._local_cache) then
		return true
	end
	local ret = skynet.call("redispool", "lua", "exists", self._name)
	return ret
end

function MemPkValues:get_items()
	if self._use_local and self._has_load then
		return self._local_cache
	end
	local ret = skynet.call("redispool", "lua", "smembers", self._name)
	for key, value in pairs(ret) do
		if self._value_type == "number" then
			ret[key] = tonumber(value)
		end
	end
	if self._use_local then
		self._local_cache = ret
	end
	self._has_load = true
	return ret
end

return MemPkValues

