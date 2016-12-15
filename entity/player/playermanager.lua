local PlayerManager = class("PlayerManager")
local PlayerDataManager = require "playerdatamanager"
local PlayerData = require "playerdata"
local Player = require "player"
local print_r = require "print_r"

function PlayerManager:ctor()
end

function PlayerManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function PlayerManager:get_player(playerid)
	local pd_instance = PlayerDataManager:get_instance()
	local player_data = pd_instance:get_player_data(playerid)
	if player_data then
		return player_data:get_player_obj()
	end
	local player = Player.new(playerid)
	local p_data = player:get_player_data()
	if not table.empty(p_data) then
		player_data = pd_instance:get_player_data(playerid)
		player_data:set_player_obj(player)
		return player
	else
		pd_instance:del_player_data_by_id(playerid)
	end
	return nil
end

function PlayerManager:add_player(player)
	local playerid = player:get_playerid()
	local has_data = PlayerDataManager:get_instance():has_player_data(playerid)
	if not has_data then
		local player_data = PlayerData.new(playerid, player)
		PlayerDataManager:get_instance():add_player_data(player_data)
	end
end

function PlayerDataManager:create_player(username)
	local player_dict = {
		username = username,
        nickname = username,
        signature = "",
        sex = 1,
        elixir = 0,
        diamond = 0,
        lottery = 0,
        charm = 0,
        money = 300,
        deskid = 0,
        is_ai = 0
	}
	local mem_obj = mem_player_admin:create(player_dict)
	if mem_obj == nil then
		return nil
	end
	local mem_key = mem_obj:get_primary_keys()
	local player = Player.new(mem_key)
	self:add_player(player)
	return player
end

function PlayerManager:del_player_by_id(playerid)
	PlayerDataManager:get_instance():del_player_data_by_id(playerid)
end

function PlayerManager:del_player(player)
	self:del_player_by_id(player:get_playerid())
end

function PlayerManager:get_all_players()
	return PlayerDataManager:get_instance():get_all_player_data()
end

return PlayerManager

