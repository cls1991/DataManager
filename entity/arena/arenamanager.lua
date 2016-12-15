local ArenaManager = class("ArenaManager")
local MemPkValues = require "mempkvalues"

function ArenaManager:ctor()
	self._arena_deskids = {}
	self._arena_onlines = {}
	local mem_pk_values = MemPkValues.new("tb_arena_ids", "number", true)
	if not mem_pk_values:exists_item() then
		local ids = mem_arena_admin:get_pk_by_fk({})
        mem_pk_values:add_item(ids)
	end
	local ids = mem_pk_values:get_items()
	for _, arenaid in pairs(ids) do
		self:init_arena(arenaid)
	end
end

function ArenaManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function ArenaManager:init_arena(arenaid)
	local mem_pk_values = MemPkValues.new(string.format("tb_arena_deskids:%s", arenaid), "number", true)
	if not mem_pk_values:exists_item() then
		local ids = mem_desk_admin:get_pk_by_fk({arenaid=arenaid})
		mem_pk_values:add_item(ids)
	end
	local ids = mem_pk_values:get_items()
	self._arena_deskids[arenaid] = ids
	self._arena_onlines[arenaid] = 0
end

function ArenaManager:get_onlines(arenaid)
	if arenaid == nil then
		return self._arena_onlines
	else
		return self._arena_onlines[arenaid]
	end
end

function ArenaManager:set_onlines(arenaid, onlines)
	self._arena_onlines[arenaid] = onlines
end

function ArenaManager:get_desks(arenaid)
	return self._arena_deskids[arenaid]
end

function ArenaManager:add_desk(arenaid, deskid)
	table.insert(self._arena_deskids[arenaid], deskid)
end

function ArenaManager:del_desk(arenaid, deskid)
	local arena_desk = self._arena_deskids[arenaid]
	local is_in = false
	local i = 1
	for _, d_id in pairs(arena_desk) do
		if deskid == d_id then
			is_in = true
			break
		end
		i = i + 1
	end
	if is_in then
		table.remove(arena_desk, i)
	end
end

return ArenaManager

