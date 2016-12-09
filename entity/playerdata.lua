local PlayerData = class("PlayerData")

function PlayerData:ctor(playerid, player_obj)
	self._playerid = playerid
	self._data = {}
	if player_obj ~= nil then
		self._data[PLAYER_DATA["BASE_INFO"]] = player_obj
	end
end

function PlayerData:get_playerid()
	return self._playerid
end

function PlayerData:get_player_obj()
	return get_data_by_path(PLAYER_DATA["BASE_INFO"], self._data)
end

function PlayerData:set_player_obj(player_obj)
	if self:get_player_obj() == nil then
		fill_data_by_path(PLAYER_DATA["BASE_INFO"], self._data, player_obj)
	end
end

function PlayerData:get_data()
	return self._data
end

return PlayerData

