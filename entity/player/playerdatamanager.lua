local PlayerDataManager = class("PlayerDataManager")

function PlayerDataManager:ctor()
	self._all_player_data = {}
end

function PlayerDataManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function PlayerDataManager:add_player_data(player_data)
	local playerid = player_data:get_playerid()
	if not self:has_player_data(playerid) then
		self._all_player_data[playerid] = player_data
	end
end

function PlayerDataManager:has_player_data(playerid)
	return self._all_player_data[playerid] ~= nil
end

function PlayerDataManager:get_player_data(playerid)
	return self._all_player_data[playerid]
end

function PlayerDataManager:del_player_data_by_id(playerid)
	if self:has_player_data(playerid) then
		self._all_player_data[playerid] = nil
	end
end

function PlayerDataManager:del_player_data(player_data)
	self:del_player_data_by_id(player_data:get_playerid())
end

function PlayerDataManager:get_all_player_data()
	return self._all_player_data
end

return PlayerDataManager

