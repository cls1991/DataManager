local DeskData = class("DeskData")

function DeskData:ctor(deskid, desk_obj)
	self._deskid = deskid
	self._data = {}
	if desk_obj ~= nil then
		fill_data_by_path(DESK_DATA["BASE_INFO"], self._data, desk_obj)
	end
end

function DeskData:get_deskid()
	return self._deskid
end

function DeskData:get_desk_obj()
	return  get_data_by_path(DESK_DATA["BASE_INFO"], self._data)
end

function DeskData:set_desk_obj(desk_obj)
	if self:get_desk_obj() == nil then
		fill_data_by_path(DESK_DATA["BASE_INFO"], self._data, desk_obj)
	end
end

function DeskData:get_data()
	return self._data
end

return DeskData

