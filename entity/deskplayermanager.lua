local DeskPlayerManager = class("DeskPlayerManager")
local DeskPlayer = require "deskplayer"
local PlayerDataManager = require "playerdatamanager"
local MemPkValues = require "mempkvalues"
local print_r = require "print_r"

function DeskPlayerManager:ctor()
end

function DeskPlayerManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function DeskPlayerManager:create_desk_player(deskid, playerid)
	local mem_dict = {
        playerid=playerid,
        deskid=deskid,
        hand=""
	}
    local mem_obj = mem_deskplayer_admin:create(mem_dict)
    local mem_key = mem_obj:get_primary_keys()
    local desk_player = DeskPlayer.new(mem_key)
    local dp_data = desk_player:get_desk_player_data()
	if not table.empty(dp_data) then
		local player_data = PlayerDataManager:get_instance():get_player_data(playerid)
		local paths = string.format("%s,%s", PLAYER_DATA["BASE_INFO"], PLAYER_DATA["PLAYER_DESK"])
		fill_data_by_path(paths, player_data:get_data(), desk_player)
		local player = player_data:get_player_obj()
		local key = string.format("%s:%s", player:get_name(), "deskplayer")
		local mem_pk_values = MemPkValues.new(key, "number", true)
		mem_pk_values:add_item({mem_key})
	end
	return desk_player
end

function DeskPlayerManager:init_desk_player(playerid)
	local player_data = PlayerDataManager:get_instance():get_player_data(playerid)
	local paths = string.format("%s,%s", PLAYER_DATA["BASE_INFO"], PLAYER_DATA["PLAYER_DESK"])
	local desk_player = get_data_by_path(paths, player_data:get_data())
	if desk_player then
		return
	end
	local player = player_data:get_player_obj()
	local key = string.format("%s:%s", player:get_name(), "deskplayer")
	local mem_pk_values = MemPkValues.new(key, "number", true)
	if not mem_pk_values:exists_item() then
        local ids = mem_deskplayer_admin:get_pk_by_fk({playerid=playerid})
        mem_pk_values:add_item(ids)
    end
    local ids = mem_pk_values:get_items()
    if table.empty(ids) then
    	return
    end
   	desk_player = DeskPlayer.new(ids[1])
   	local dp_data = desk_player:get_desk_player_data()
   	if not table.empty(dp_data) then
   		fill_data_by_path(paths, player_data:get_data(), desk_player)
   	end
end

function DeskPlayerManager:get_desk_player(playerid)
	local player_data = PlayerDataManager:get_instance():get_player_data(playerid)
	local paths = string.format("%s,%s", PLAYER_DATA["BASE_INFO"], PLAYER_DATA["PLAYER_DESK"])
	return get_data_by_path(paths, player_data:get_data())
end

function DeskPlayerManager:del_desk_player_by_id(playerid)
	local player_data = PlayerDataManager:get_instance():get_player_data(playerid)
	local paths = string.format("%s,%s", PLAYER_DATA["BASE_INFO"], PLAYER_DATA["PLAYER_DESK"])
	fill_data_by_path(paths, player_data:get_data(), {})
end

function DeskPlayerManager:del_desk_player(desk_player)
	self:del_desk_player_by_id(desk_player:get_playerid())
end

return DeskPlayerManager

