local MemObj = require "memobj"
local Player = class("Player", MemObj)
local PlayerData = require "playerdata"
local PlayerDataManager = require "playerdatamanager"

function Player:ctor(playerid, init_local, tbname)
    if tbname == nil then
        tbname = "tb_player"
    end
    local name = string.format("%s:%s", tbname, playerid)
    Player.super.ctor(self, name, "playerid")
    if init_local == nil then
    	init_local = true
    end
    self._init_local = init_local
    if self._init_local then
    	-- lcoal player_data = PlayerData.new(playerid)
    	-- PlayerDataManager.get_instance():add_player_data(player_data)
    end
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

