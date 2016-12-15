local DeskManager = class("DeskManager")
local Desk = require "desk"
local MemPkValues = require "mempkvalues"
local DeskPlayer = require "deskplayer"
local DeskDataManager = require "deskdatamanager"
local print_r = require "print_r"

function DeskManager:ctor()
	self._dpk = MemPkValues.new("tb_desk_all_ids", "number", false)
	if not self._dpk:exists_item() then
		local ids = mem_desk_admin:get_pk_by_fk({})
        self._dpk:add_item(ids)
	end
	for _, deskid in pairs(self._dpk:get_items()) do
		self:init_desk(deskid)
	end
end

function DeskManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function DeskManager:init_desk(deskid)
	local dpm = DeskDataManager:get_instance()
	local desk_data = dpm:get_desk_data(deskid)
	if desk_data == nil then
		local desk = Desk.new(deskid)
		if not table.empty(desk:get_desk_data()) then
			desk_data = dpm:get_desk_data(deskid)
			desk_data:set_desk_obj(desk)
			local desk_player_ids = desk:get_desk_players()
			local paths = DESK_DATA["PLAYERS"]
			local data = get_data_by_path(paths, desk_data:get_data())
			if  data == nil then
				fill_data_by_path(paths, desk_data:get_data(), {})
				data = get_data_by_path(paths, desk_data:get_data())
			end
			for _, desk_player_id in pairs(desk_player_ids) do
				data[desk_player_id] = DeskPlayer.new(desk_player_id)
			end
		else
			dpm:del_desk_data_by_id(deskid)
		end
	else
		local desk = desk_data:get_desk_obj()
		local desk_player_ids = desk:get_desk_players()
		local paths = DESK_DATA["PLAYERS"]
		local data = get_data_by_path(paths, desk_data:get_data())
		if  data == nil then
			fill_data_by_path(paths, desk_data:get_data(), {})
			data = get_data_by_path(paths, desk_data:get_data())
		end
		for _, desk_player_id in pairs(desk_player_ids) do
			data[desk_player_id] = DeskPlayer.new(desk_player_id)
		end
	end
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
        kcard="",
        create_time=os.date("%Y-%m-%d %H:%M:%S")
	}
    local mem_obj = mem_desk_admin:create(desk_dict)
    local mem_key = mem_obj:get_primary_keys()
    local desk = Desk.new(mem_key)
    local desk_data = desk:get_desk_data()
	if not table.empty(desk_data) then
		self:init_desk(mem_key)
		local dpm = DeskDataManager:get_instance()
		local desk_data = dpm:get_desk_data(mem_key)
		local paths = DESK_DATA["PLAYERS"]
		local data = get_data_by_path(paths, desk_data:get_data())
		self._dpk:add_item({mem_key})
		return desk
	end
	return nil
end

function DeskManager:get_desk(deskid)
	local desk_data = DeskDataManager:get_instance():get_desk_data(deskid)
	if desk_data ~= nil then
		return desk_data:get_desk_obj()
	end
	return nil
end

function DeskManager:del_desk_by_id(deskid)
	local desk_players = self:get_desk_all_players(deskid)
	for _, desk_player in pairs(desk_players) do
		desk_player:delete()
	end
	DeskDataManager:get_instance().del_desk_data_by_id(deskid)
	self._dpk:remove_item(deskid)
end

function DeskManager:del_desk(desk)
	self:del_desk_by_id(desk:get_deskid())
end

function DeskManager:get_all_desks()
	local result = {}
	local ddm = DeskDataManager:get_instance()
	for _, deskid in pairs(self._dpk:get_items()) do
		local desk_data = ddm:get_desk_data(deskid)
		if desk_data ~= nil then
			table.insert(result, desk_data:get_desk_obj())
		end
	end
	return result
end

function DeskManager:create_desk_player(deskid, playerid, position)
	local desk_player = self:get_desk_player(deskid, playerid)
	if desk_player ~= nil then
		return desk_player
	end
	local desk_player_dict = {
        deskid=deskid,
        playerid=playerid,
        position=position,
 		hand="",
        status=0,
        score=0
	}
    local mem_obj = mem_deskplayer_admin:create(desk_player_dict)
    local mem_key = mem_obj:get_primary_keys()
    desk_player = DeskPlayer.new(mem_key)
    local desk_player_data = desk_player:get_desk_player_data()
	if not table.empty(desk_player_data) then
		self:add_desk_player(desk_player)
		return desk_player
	end
	return nil
end

function DeskManager:add_desk_player(desk_player_obj)
	local deskid = desk_player_obj:get_deskid()
	local ddm = DeskDataManager:get_instance()
	local desk_data = ddm:get_desk_data(deskid)
	local desk = desk_data:get_desk_obj()
	desk:add_desk_player(desk_player_obj:get_key())
	local paths = DESK_DATA["PLAYERS"]
	local data = get_data_by_path(paths, desk_data:get_data())
	data[desk_player_obj:get_key()] = desk_player_obj
end

function DeskManager:del_desk_player(desk_player_obj)
	local deskid = desk_player_obj:get_deskid()
	local ddm = DeskDataManager:get_instance()
	local desk_data = ddm:get_desk_data(deskid)
	local desk = desk_data:get_desk_obj()
	local paths = DESK_DATA["PLAYERS"]
	local data = get_data_by_path(paths, desk_data:get_data())
	if data[desk_player_obj:get_key()] ~= nil then
		desk:del_desk_player(desk_player_obj:get_key())
		data[desk_player_obj:get_key()]:delete()
		data[desk_player_obj:get_key()] = nil
	end
end

function DeskManager:get_desk_player(deskid, playerid)
	local ddm = DeskDataManager:get_instance()
	local desk_data = ddm:get_desk_data(deskid)
	local paths = DESK_DATA["PLAYERS"]
	local data = get_data_by_path(paths, desk_data:get_data())
	for _, desk_player in pairs(data) do
		if playerid == desk_player:get_playerid() then
			return desk_player
		end
	end
	return nil
end

function DeskManager:get_desk_all_players(deskid)
	local result = {}
	local ddm = DeskDataManager:get_instance()
	local desk_data = ddm:get_desk_data(deskid)
	local paths = DESK_DATA["PLAYERS"]
	local data = get_data_by_path(paths, desk_data:get_data())
	for _, desk_player in pairs(data) do
		if not table.empty(desk_player) then
			table.insert(result, desk_player)
		end
	end
	return result
end

return DeskManager

