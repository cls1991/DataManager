function fill_data_by_path(paths, target_table, value)
	local tmp_paths = string.split(paths, ",")
	if #tmp_paths > 1 then
		local tmp_table = target_table
		for i=1, #tmp_paths-1 do
			local is_in = false
			for key, _ in pairs(tmp_table) do
				if tmp_paths[i] == key then
					is_in = true
					break
				end
			end
			if not is_in then
				tmp_table[tmp_paths[i]] = {}
			end
			tmp_table = tmp_table[tmp_paths[i]]
		end
		tmp_table[tmp_paths[#tmp_paths]] = value
	else
		target_table[paths] = value
	end
end

function get_data_by_path(paths, source_table)
	local tmp_paths = string.split(paths, ",")
	if #tmp_paths > 1 then
		local tmp_table = source_table
		for i=1, #tmp_paths-1 do
			local is_in = false
			for key, _ in pairs(tmp_table) do
				if tmp_paths[i] == key then
					is_in = true
					break
				end
			end
			if not is_in then
				return nil
			end
			tmp_table = tmp_table[tmp_paths[i]]
		end
		return tmp_table[tmp_paths[#tmp_paths]]
	else
		return source_table[paths]
	end
end

