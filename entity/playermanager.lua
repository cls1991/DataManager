local PlayerManager = class("PlayerManager")
local PlayerDataManager = require "playerdatamanager"
local PlayerData = require "playerdata"

function PlayerManager:ctor()
end

function PlayerManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function PlayerManager:get_player(playerid)
	for pid, player in pairs(self._players) do
		if playerid == pid then
			return player
		end
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

function PlayerManager:del_player_by_id(playerid)
	PlayerDataManager.get_instance():del_player_data_by_id(playerid)
end

function PlayerManager:del_player(player)
	self:del_player_by_id(player:get_playerid())
end

function PlayerManager:get_all_players()
	return PlayerDataManager:get_instance():get_all_player_data()
end

return PlayerManager

