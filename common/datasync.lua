local skynet = require "skynet"
require "skynet.manager"
local print_r = require "print_r"
local MemObj = require "memobj"

local t_update = {}
local t_delete = {}
local CMD = {}

function CMD.start()
end

function CMD.stop()
end

local function data_sync(queue_id)
    -- data op queue
    local redis_queue_key = skynet.getenv("data_queue")
    while true do
        local item = skynet.call("redispool", "lua", "rpop", redis_queue_key)
        if item then
            local op_data = load(item)()
            local mem_obj = MemObj.new(op_data["name"], op_data["pk"])
            local mem_data = mem_obj:get_data()
            print_r(mem_data)
            if op_data["op"] == "update" then
                local need_execute = true
                for name, time in pairs(t_update) do
                    if op_data["name"] == name and op_data["time"] <= time then
                        need_execute = false
                        break
                    end
                end
                for name, _ in pairs(t_delete) do
                    if op_data["name"] == name then
                        need_execute = false
                        break
                    end
                end
                if need_execute then
                    mem_obj:push_to_db()
                    t_update[op_data["name"]] = skynet.time()
                end
            elseif op_data["op"] == "delete" then
                local need_execute = true
                for name, _ in pairs(t_delete) do
                    if op_data["name"] == name then
                        need_execute = false
                        break
                    end
                end
                if need_execute then
                    mem_obj:del_from_db()
                    t_delete[op_data["name"]] = skynet.time()
                end
            else
                skynet.error(string.fotmat("op %s not exist", op_data["op"]))
            end
        else
            t_update = {}
            t_delete = {}
            skynet.error("no data in queue")
        end
        skynet.sleep(500)
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd], string.format("%s not found", cmd))
        skynet.retpack(f(...))
    end)
    skynet.fork(data_sync)
    skynet.register(SERVICE_NAME)
end)

