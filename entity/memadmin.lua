local MemObj = require "memobj"
local print_r = require "print_r"
local skynet = require "skynet"
local MemAdmin = class("MemAdmin")

function MemAdmin:ctor(table_name, pk)
	self._table_name = table_name
	self._pk = pk
	local tmp_pks = string.split(pk, ",")
	if #tmp_pks > 1 then
		self._is_multi_pk = true
	else
		self._is_multi_pk = false
	end
end

function MemAdmin:create(data)
	local fields = get_fields(self._table_name)
	local data_new = {}
	for _, field in pairs(fields) do
		for key, value in pairs(data) do
			if field == key then
				data_new[key] = value
				break
			end
		end
	end
	local sql = construct_insert_str(self._table_name, data_new)
	local ret = skynet.call("mysqlpool", "lua", "execute", sql)
	if not ret then
		return nil
	end
	local pk = ""
	if self._is_multi_pk then
		local tmp_pks = string.split(self._pk, ",")
		local tmp_values = {}
		for _, key in pairs(tmp_pks) do
			table.insert(tmp_values, data[key])
		end
		pk = table.concat(tmp_values, "#")
	else
		pk = tostring(get_maxkey(self._table_name))
		data_new[self._pk] = pk
	end
    local mem_obj = MemObj.new(string.format("%s:%s", self._table_name, pk), self._pk, data_new)
    mem_obj:init_redis_from_local()
    return mem_obj
end

function MemAdmin:get_pk_by_fk(pres)
	local sql = construct_query_str(self._table_name, pres, self._pk)
	local ret = skynet.call("mysqlpool", "lua", "execute", sql)
	local result = {}
	if not table.empty(ret) then
		for _, value in pairs(ret) do
			table.insert(result, value[self._pk])
		end
	end
	return result
end

return MemAdmin

