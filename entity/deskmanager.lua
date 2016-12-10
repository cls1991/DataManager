local DeskManager = class("DeskManager")
local Desk = require "desk"
local MemPkValues = require "mempkvalues"
local print_r = require "print_r"

function DeskManager:ctor()
	self._all_desk = {}
	local mem_pk_values = MemPkValues.new("tb_desk_all_ids", "number", false)
	if not mem_pk_values:exists_item() then
		local ids = mem_desk_admin:get_pk_by_fk({})
        mem_pk_values:add_item(ids)
	end
	local ids = mem_desk_admin:get_items()
	self._deskids = ids
	for _, deskid in pairs(ids) do
		local desk = Desk.new(deskid)
		local desk_data = desk:get_desk_data()
		if not table.empty(desk_data) then
			self._all_desk[deskid] = desk
		end
	end
end

function DeskManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function DeskManager:create_desk(arenaid)
	local desk_dict = {
        arenaid=arenaid,
        players="",
        master=0,
        winner=0,
        status=0,
        cards="",
        rate=0,
        turn=0,
        kcard=""
	}
    local mem_obj = mem_desk_admin:create(desk_dict)
    local mem_key = mem_obj:get_primary_keys()
    local desk = Desk.new(mem_key)
    local desk_data = desk:get_desk_data()
	if not table.empty(desk_data) then
		local mem_pk_values = MemPkValues.new(tb_desk_all_ids, "number", false)
		mem_pk_values:add_item({mem_key})
	end
	return desk
end

function DeskManager:get_desk(deskid)
	for d_id, _ in pairs(self._all_desk) do
		if deskid == d_id then
			return self._all_desk[deskid]
		end
	end
	return nil
end

function DeskManager:add_desk(desk)
	local is_in = false
	for d_id, _ in pairs(self._all_desk) do
		if desk:get_deskid() == d_id then
			is_in = true
			break
		end
	end
	if not is_in then
		self._all_desk[desk:get_deskid()] = desk
	end
end

function DeskManager:del_desk_by_id(deskid)
	local is_in = false
	local i = 1
	for d_id, _ in pairs(self._all_desk) do
		if deskid == d_id then
			is_in = true
			break
		end
		i = i + 1
	end
	if is_in then
		table.remove(self._all_desk, i)
	end
end

function DeskManager:del_desk(desk)
	self:del_desk_by_id(desk:get_deskid())
end

function DeskManager:get_all_desk()
	return self._all_desk
end

return DeskManager

