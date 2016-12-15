local skynet = require "skynet"
local CacheBase = class("CacheBase")

function CacheBase:ctor(key_name, table_name, fields)
	self._k = key_name
	self._t = table_name
	self._f = fields
	self._m_cache = {}
end

function CacheBase:get_key(key)
	return string.format("%s:%s", self._t, key)
end

function CacheBase:convert_to_lua_data_type(key, value)
    local column_data = get_schema_data(self._t)
    local field_type = column_data["fields"][key]
    if field_type == "number" then
        return tonumber(value)
    end
    return value
end

function CacheBase:convert_to_lua_data(origin_data)
	local column_data = get_schema_data(self._t)
    local result_data = {}
    for key, value in pairs(origin_data) do
        local is_in = false
        local tmp_value = value
        for field_name, field_type in pairs(column_data["fields"]) do
            if key == field_name then
                is_in = true
                break
            end
        end
        if is_in and column_data["fields"][key] == "number" then
            tmp_value = tonumber(value)
        end
        result_data[key] = tmp_value
    end
    return result_data
end

function CacheBase:convert_value(key, value)
	return value
end

function CacheBase:cache_data()
	local query_sql = construct_query_str(self._t, {}, self._f)
	local ret = skynet.call("mysqlpool", "lua", "execute", query_sql)
	if table.empty(ret) then
		return
	end
	if ret["error"] ~= nil or ret["badresult"] ~= nil then
		return
	end
	for _, item in pairs(ret) do
		local key = item[self._k]
		local redis_key = self:get_key(key)
		skynet.call("redispool", "lua", "hmset", redis_key, item)
		self._m_cache[key] = self:convert_to_lua_data(item)
	end
end

function CacheBase:get_data(key)
	local data = self._m_cache[key]
	if data == nil then
		local ret = skynet.call("redispool", "lua", "hgetall", self:get_key(key))
		if not table.empty(ret) then
			-- parse redis data
			data = {}
	        for i=1, #ret, 2 do
	            data[ret[i]] = ret[i+1]
	        end
	        self._m_cache[key] = self:convert_to_lua_data(data)
	        data = self._m_cache[key]
	    end
	end
	return data
end

function CacheBase:get_all_data()
	return self._m_cache
end

return CacheBase

