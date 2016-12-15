local DeskDataManager = class("DeskDataManager")

function DeskDataManager:ctor()
	self._all_desk_data = {}
end

function DeskDataManager:get_instance()
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

function DeskDataManager:add_desk_data(desk_data)
	local deskid = desk_data:get_deskid()
	if not self:has_desk_data(deskid) then
		self._all_desk_data[deskid] = desk_data
	end
end

function DeskDataManager:has_desk_data(deskid)
	return self._all_desk_data[deskid] ~= nil
end

function DeskDataManager:get_desk_data(deskid)
	return self._all_desk_data[deskid]
end

function DeskDataManager:del_desk_data_by_id(deskid)
	self._all_desk_data[deskid] = nil
end

function DeskDataManager:del_desk_data(desk_data)
	self:del_desk_data_by_id(desk_data:get_deskid())
end

function DeskDataManager:get_all_desk_data()
	return self._all_desk_data
end

return DeskDataManager

