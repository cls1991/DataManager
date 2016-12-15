local MemObj = require "memobj"
local MemPkValues = require "mempkvalues"
local DeskData = require "deskdata"
local DeskDataManager = require "deskdatamanager"
local print_r = require "print_r"
local Desk = class("Desk", MemObj)

function Desk:ctor(deskid, table_name)
	local table_name = table_name or "tb_desk"
	local name = string.format("%s:%s", table_name, deskid)
	Desk.super.ctor(self, name, "deskid")
	local desk_data = DeskData.new(deskid, self)
	DeskDataManager:get_instance():add_desk_data(desk_data)

	local key = string.format("%s:%s", name, "deskplayers")
	self._deskplayers = MemPkValues.new(key, "number", false)
	if not self._deskplayers:exists_item() then
        local ids = mem_deskplayer_admin:get_pk_by_fk({deskid=deskid})
        self._deskplayers:add_item(ids)
    end
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

function Desk:get_create_time()
	return self:get("create_time")
end

function Desk:get_desk_data()
	return self:get_data()
end

function Desk:add_desk_player(desk_player_id)
	self._deskplayers:add_item({desk_player_id})
end

function Desk:del_desk_player(desk_player_id)
	self._deskplayers:remove_item(desk_player_id)
end

function Desk:get_desk_players()
	return self._deskplayers:get_items()
end

return Desk

