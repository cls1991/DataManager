local skynet = require "skynet"
local dbname = skynet.getenv("mysql_db")
local schema = {}

function get_primary_key(tbname)
	local sql = "select k.column_name " ..
    "from information_schema.table_constraints t " ..
    "join information_schema.key_column_usage k " ..
    "using (constraint_name,table_schema,table_name) " ..
    "where t.constraint_type = 'PRIMARY KEY' " ..
    "and t.table_schema= '".. dbname .. "'" ..
    "and t.table_name = '" .. tbname .. "'"
    local t = skynet.call("mysqlpool", "lua", "execute",sql)
    return t[1]["column_name"]
end

function get_fields(tbname)
	local sql = string.format("select column_name from information_schema.columns where table_schema = '%s' and table_name = '%s'", dbname, tbname)
    local rs = skynet.call("mysqlpool", "lua", "execute", sql)
    local fields = {}
    for _, row in pairs(rs) do
        table.insert(fields, row["column_name"])
    end
    return fields
end

function get_field_type(field)
    local sql = string.format("select data_type from information_schema.columns where table_schema='%s' and table_name='%s' and column_name='%s'",
    dbname, tbname, field)
    local rs = skynet.call("mysqlpool", "lua", "execute", sql)
    return rs[1]["data_type"]
end

local function load_schema_data(tbname)
    schema[tbname]["pk"] = get_primary_key(dbname, tbname)
    local fields = get_fields(dbname, tbname)
    for _, field in pairs(fields) do
        local field_type = get_field_type(tbname, field)
        if field_type == "char" 
            or field_type == "varchar"
            or field_type == "tinytext"
            or field_type == "text"
            or field_type == "mediumtext"
            or field_type == "longtext" then
            schema[tbname]["fields"][field] = "string"
        else
            schema[tbname]["fields"][field] = "number"
        end
    end
end

function get_schema_data(tbname)
	local schema_data = schema[tbname]
	if not schema_data then
		schema_data = load_schema_data(dbname, tbname)
	end
	return schema_data
end

function get_maxkey(tbname)
    local pk = schema[tbname]["pk"]
    local sql = string.format("select max(%s) as maxkey from %s", pk, tbname)
    local result = skynet.call("mysqlpool", "lua", "execute", sql)
    if #result > 0 and not table.empty(result[1]) then
        skynet.call("redispool", "lua", "set", tbname .. ":" .. pk, result[1]["maxkey"])
    end
end


function format_item(key, value)
    local sql = ""
    if value == nil then
        sql = sql .. key .. "=" .. "null"
    elseif type(value) == "string" then
        sql = sql .. key .. "=" .. "'" .. value .. "'"
    end
    return sql
end

function format_condition(props)
    if props == nil then
        return ""
    end
    local con = {}
    for key, value in pairs(props) do
        if value == nil then
            props[key] = "null"
        elseif type(value) == "string" then
            props[key] = "'" .. value .. "'"
        end
        table.insert(con, key.."="..props[key])
    end
    return table.concat(con, " and ")
end

function format_update_str(props)
    if props == nil then
        return ""
    end
    local con = {}
    for key, value in pairs(props) do
        if value == nil then
            props[key] = "null"
        elseif type(value) == "string" then
            props[key] = "'" .. value .. "'"
        end
        table.insert(con, key.."="..props[key])
    end
    return table.concat(con, ",")
end

function construct_insert_str(tbname, props)
    local t_key = table.indices(props)
    local t_value = table.values(props)
    for key, value in pairs(t_value) do
        if value == nil then
            t_value[key] = "null"
        elseif type(value) == "string" then
            t_value[key] = "'" .. value .. "'"
        end
    end
    local sql = string.format("insert into `%s` (%s) values (%s)", tbname, table.concat(t_key, ","), table.concat(t_value, ","))
    return sql
end

function construct_update_str(tbname, props, pres)
    local pro = format_update_str(props)
    local pre = format_condition(pres)
    local sql = string.format("update `%s` set %s where %s", tbname, pro, pre)
    return sql
end

function construct_query_str(tbname, pres)
    local pre = format_condition(pres)
    local str = ""
    if pre ~= "" then
        sql = string.format("select * from `%s` where %s", tbname, pre)
    else
        sql = string.format("select * from `%s`", tbname)
    end
    return sql
end

function construct_delete_str(tbname, pres)
    local pre = format_condition(pres)
    local str = ""
    if pre ~= "" then
        sql = string.format("delete from `%s` where %s", tbname, pre)
    else
        sql = string.format("delete from `%s`", tbname)
    end
    return sql
end

