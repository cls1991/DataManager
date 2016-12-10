local MemObj = require "memobj"
local Desk = class("Desk", MemObj)

function Desk:ctor(deskid, table_name)
	if table_name == nil then
		table_name = "tb_desk"
	end
	local name = string.format("%s:%s", table_name, deskid)
	Desk.super.ctor(self, name, "deskid")
end

function Desk:get_deskid()
	return self:get("deskid")
end

function Desk:get_arenaid()
	return self:get("arenaid")
end

function Desk:get_players()
	return self:get("players")
end

function Desk:set_players(players)
	self:set("players", players)
end

function Desk:get_master()
	return self:get("master")
end

function Desk:set_master(master)
	self:set("master", master)
end

function Desk:get_winner()
	return self:get("winner")
end

function Desk:set_winner(winner)
	self:set("winner", winner)
end

function Desk:get_status()
	return self:get("status")
end

function Desk:set_status(status)
	self:set("status", status)
end

function Desk:get_cards()
	return self:get("cards")
end

function Desk:set_cards(cards)
	self:set("cards", cards)
end

function Desk:get_rate()
	return self:get("rate")
end

function Desk:set_rate(rate)
	self:set("rate", rate)
end

function Desk:get_turn()
	return self:get("turn")
end

function Desk:set_turn(turn)
	self:set("turn", turn)
end

function Desk:get_kcard()
	return self:get("kcard")
end

function Desk:set_kcard(kcard)
	self:set("kcard", kcard)
end

function Desk:get_desk_data()
	return self:get_data()
end

return Desk

