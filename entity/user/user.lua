local MemObj = require "memobj"
local User = class("User", MemObj)

function User:ctor(uid, table_name)
	local table_name = table_name or "tb_user"
	local name = string.format("%s:%s", table_name, uid)
	User.super.ctor(self, name, "id")
end

function User:get_key()
	return self:get_primary_keys()
end

function User:get_username()
	return self:get("username")
end

function User:get_password()
	return self:get("password")
end

function User:get_email()
	return self:get("eamil")
end

function User:get_register_time()
	return self:get("register_time")
end

function User:get_is_enable()
	return self:get("is_enable")
end

function User:get_user_data()
	return self:get_data()
end

return User

