local MemObj = require "memobj"
local DeskPlayer = class("DeskPlayer", MemObj)

function DeskPlayer:ctor(key, table_name)
    local table_name = table_name or "tb_desk_player"
    local name = string.format("%s:%s", table_name, key)
    DeskPlayer.super.ctor(self, name, "id")
end

function DeskPlayer:get_key()
    return self:get_primary_keys()
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

function DeskPlayer:get_position()
	return self:get("position")
end

function DeskPlayer:set_position(position)
	self:set("position", position)
end

function DeskPlayer:get_status()
	return self:get("status")
end

function DeskPlayer:set_status(status)
	self:set("status", status)
end

function DeskPlayer:get_score()
    return self:get("score")
end

function DeskPlayer:set_score(score)
    self:set("score", score)
end

function DeskPlayer:get_desk_player_data()
    return self:get_data()
end

return DeskPlayer

