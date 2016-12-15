local CacheBase = require "cachebase"
local CacheManager = class("CacheManager")

function CacheManager:ctor()
	self._cache_server = nil
	self._cache_arena = nil
end

function CacheManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function CacheManager:init()
	self._cache_server = CacheBase.new("sid", "tb_server")
	self._cache_server:cache_data()
	self._cache_arena = CacheBase.new("arenaid", "tb_arena_template")
	self._cache_arena:cache_data()
end

function CacheManager:get_cache_handle(handle_name)
	local handle_name = handle_name or "server"
	if handle_name == "server" then
		return self._cache_server
	elseif handle_name == "arena" then
		return self._cache_arena
	else
		return nil
	end
end

return CacheManager

