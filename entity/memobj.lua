local skynet = require "skynet"
local print_r = require "print_r"
local MemObj = class("MemObj")

function MemObj:ctor(name, pk, data)
    self._name = name
    self._update = {}
    self._pk = pk
    local tmp_pks = string.split(pk, ",")
    if #tmp_pks > 1 then
        self.is_multi_pk = true
    else
        self.is_multi_pk = false
    end
    if not data then
        self._data = {}
    else
        self._data = data
    end
end

function MemObj:get_data()
    if table.empty(self._data) then
        self:load()
    end
    return self._data
end

function MemObj:load()
    -- load an entire data from redis, return data
    -- otherwise load data from mysql
    local data = skynet.call("redispool", "lua", "hgetall", self._name)
    if  table.empty(data) then
        local pres = {}
        local tmp_table = string.split(self._name, ":")
        local table_name = tmp_table[1]
        local tmp_value_str = tmp_table[2]
        if self.is_multi_pk then
            local keys = string.split(self._pk, ",")
            local values = string.split(tmp_value_str, "#")
            for index, key in pairs(keys) do
                pres[key] = values[index]
            end
        else
            pres[self._pk] = tmp_value_str
        end
        local sql = construct_query_str(table_name, pres)
        data = skynet.call("mysqlpool", "lua", "execute", sql)
        -- set local and redis
        if not table.empty(data) then
            self._data = data[1]
            skynet.call("redispool", "lua", "hmset", self._name, self._data)
        end
    else
        self._data = data
    end
end

function MemObj:delete()
    -- delete an entire data from redis by primary_key
    skynet.call("redispool", "lua", "del", self._name)
    local pres = {}
    local tmp_table = string.split(self._name, ":")
    local table_name = tmp_table[1]
    local tmp_value_str = tmp_table[2]
    if self.is_multi_pk then
        local keys = string.split(self._pk, ",")
        local values = string.split(tmp_value_str, "#")
        for index, key in pairs(keys) do
            pres[key] = values[index]
        end
    else
        pres[self._pk] = tmp_value_str
    end
    local sql = construct_delete_str(table_name, pres)
    skynet.call("mysqlpool", "lua", "execute", sql)
end

function MemObj:save()
    -- 添加到change_list队列上
    -- TODO
    if table.empty(self._update) then
        return
    end
    local pipeline = {}
    for key, value in pairs(self._update) do
        table.insert(pipeline, {"hset", self._name, key, value})
    end
    skynet.call("redispool", "lua", "pipeline", pipeline)
end

function MemObj:get(key)
    if table.empty(self._data) or not self._data[key] then
        self:load()
    end
    return self._data[key]
end

function MemObj:set(key, value)
    self._data[key] = value
    self._update[key] = value
end

function MemObj:set_multi_values(multi_values)
    for key, value in pairs(multi_values) do
        self._data[key] = value
        self._update[key] = value
    end
end

function MemObj:init_redis_from_local()
    if table.empty(self._data) then
        return
    end
    skynet.call("redispool", "lua", "hmset", self._name, self._data)
end

function MemObj:get_primary_keys()
    return string.split(self._name, ":")[2]
end

function MemObj:get_name()
    return self._name
end

return MemObj

