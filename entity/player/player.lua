local MemObj = require "memobj"
local Player = class("Player", MemObj)
local PlayerData = require "playerdata"
local PlayerDataManager = require "playerdatamanager"

function Player:ctor(playerid, init_local, table_name)
    local table_name = table_name or "tb_player"
    local name = string.format("%s:%s", table_name, playerid)
    Player.super.ctor(self, name, "playerid")
    local init_local = init_local or true
    if init_local then
    	local player_data = PlayerData.new(playerid, self)
    	PlayerDataManager:get_instance():add_player_data(player_data)
    end
end

function Player:get_playerid()
    return self:get("playerid")
end

function Player:get_username()
    return self:get("username")
end

function Player:get_nickname()
    return self:get("nickname")
end

function Player:set_nickname(nickname)
    self:set("nickname", nickname)
end

function Player:get_signature()
    return self:get("signature")
end

function Player:set_signature(signature)
    self:set("signature", signature)
end

function Player:get_money()
    return self:get("money")
end

function Player:set_money(money)
    self:set("money", money)
end

function Player:get_sex()
    return self:get("sex")
end

function Player:set_sex(sex)
    self:set("sex", sex)
end

function Player:get_is_ai()
    return self:get("is_ai")
end

function Player:get_deskid()
    return self:get("deskid")
end

function Player:set_deskid(deskid)
    self:set("deskid", deskid)
end

function Player:get_elixir()
    return self:get("elixir")
end

function Player:set_elixir(elixir)
    self:set("elixir", elixir)
end

function Player:get_diamond()
    return self:get("diamond")
end

function Player:set_diamond(diamond)
    self:set("diamond", diamond)
end

function Player:get_lottery()
    return self:get("lottery")
end

function Player:set_lottery(lottery)
    self:set("lottery", lottery)
end

function Player:get_charm()
    return self:get("charm")
end

function Player:set_charm(charm)
    self:set("charm", charm)
end

function Player:get_player_data()
    return self:get_data()
end

return Player

