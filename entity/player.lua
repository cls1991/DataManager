local MemObj = require "memobj"
local Player = class("Player", MemObj)

function Player:ctor(playerid, tbname)
	if not tbname then
		tbname = "tb_player"
	end
    local name = string.format("%s:%s", tbname, playerid)
    Player.super.ctor(self, name, "playerid")
end

function Player:get_playerid()
    return self:get("playerid")
end

function Player:get_username()
	return self:get("username")
end

function Player:set_username(username)
    self:set("username", username)
end

function Player:get_player_data()
    return self:get_data()
end

return Player

