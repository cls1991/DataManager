local MemObj = require "memobj"
local DeskPlayer = class("DeskPlayer", MemObj)

function DeskPlayer:ctor(key, tbname)
    if not tbname then
        tbname = "tb_desk_player"
    end
    local name = string.format("%s:%s", tbname, key)
    DeskPlayer.super.ctor(self, name, "id")
end

function DeskPlayer:get_playerid()
    return self:get("playerid")
end

function DeskPlayer:get_deskid()
    return self:get("deskid")
end

function DeskPlayer:get_hand()
	return self:get("hand")
end

function DeskPlayer:set_hand(hand)
	self:set("hand", hand)
end

function DeskPlayer:get_desk_player_data()
    return self:get_data()
end

return DeskPlayer

