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
	local is_in = false
	for playerid, _ in pairs(self._all_player_data) do
		if player_data:get_playerid() == playerid then
			is_in = true
			break
		end
	end
	if not is_in then
		self._all_player_data[player_data:get_playerid()] = player_data
	end
end

function PlayerDataManager:has_player_data(playerid)
	for pid, _ in pairs(self._all_player_data) do
		if playerid == pid then
			return true
		end
	end
	return false
end

function PlayerDataManager:get_player_data(playerid)
	for pid, _ in pairs(self._all_player_data) do
		if playerid == pid then
			return self._all_player_data[playerid]
		end
	end
	return nil
end

function PlayerDataManager:del_player_data_by_id(playerid)
	local is_in = false
	local i = 1
	for pid, _ in pairs(self._all_player_data) do
		if pid == playerid then
			is_in = true
			break
		end
		i = i + 1
	end
	if is_in then
		table.remove(self._all_player_data, i)
	end
end

function PlayerDataManager:del_player_data(player_data)
	self:del_player_data_by_id(player_data:get_playerid())
end

function PlayerDataManager:get_all_player_data()
	return self._all_player_data
end

return PlayerDataManager

