local MemAdmin = require "memadmin"

mem_user_admin = MemAdmin.new("tb_user", "id")
mem_player_admin = MemAdmin.new("tb_player", "playerid")

mem_deskplayer_admin = MemAdmin.new("tb_desk_player", "id")
mem_desk_admin = MemAdmin.new("tb_desk", "deskid")

mem_arena_admin = MemAdmin.new("tb_arena_template", "arenaid")

