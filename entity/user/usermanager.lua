local skynet = require "skynet"
local User = require "user"
local UserManager = class("UserManager")

function UserManager:ctor()
	self._users = {}
	self._map = {}
end

function UserManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function UserManager:get_user(username)
	local uid = self._map[username]
	if uid == nil then
		local key = string.format("%s:%s", "tb_user", username)
		uid = skynet.call("redispool", "lua", "get", key)
		if uid == nil then
			local ret = mem_user_admin:get_pk_by_fk({username=username})
			if not table.empty(ret) then
				uid = ret[1]
			end
			if uid ~= nil then
				skynet.call("redispool", "lua", "set", key, uid)
			end
		end
	end
	if uid == nil then
		return nil
	end
	local user = self._users[uid]
	if user == nil then
		user = User.new(uid)
		self:add_user(user)
	end
	return user
end

function UserManager:create_user(username, password, email)
	local user_dict = {
		username=username,
		password=password,
		email=email,
		register_time=os.date("%Y-%m-%d %H:%M:%S"),
		is_enable=1
	}
	local mem_obj = mem_user_admin:create(user_dict)
	if mem_obj == nil then
		return nil
	end
	local mem_key = mem_obj:get_primary_keys()
	local user = User.new(mem_key)
	self:add_user(user)
	local key = string.format("%s:%s", "tb_user", username)
	skynet.call("redispool", "lua", "set", key, mem_key)
	return user
end

function UserManager:add_user(user)
	local uid = user:get_key()
	if self._users[uid] ~= nil then
		return
	end
	self._users[uid] = user
	self._map[user:get_username()] = uid
end

function UserManager:del_user_by_username(username)
	local uid = self._map[username]
	if uid == nil then
		return
	end
	self._users[uid] = nil
	self._map[username] = nil
end

function UserManager:del_user(user)
	self:del_user_by_username(user:get_username())
end

return UserManager

