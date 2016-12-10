local MemObj = require "memobj"
local Player = class("Player", MemObj)
local PlayerData = require "playerdata"
local PlayerDataManager = require "playerdatamanager"

function Player:ctor(playerid, init_local, table_name)
    if table_name == nil then
        table_name = "tb_player"
    end
    local name = string.format("%s:%s", table_name, playerid)
    Player.super.ctor(self, name, "playerid")
    local init_local = init_local or true
    if init_local then
    	-- local player_data = PlayerData.new(playerid)
    	-- PlayerDataManager:get_instance():add_player_data(player_data)
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

