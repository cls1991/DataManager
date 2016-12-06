local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string
local print_r = require "print_r"
local player = require "player"

local mode = ...

if mode == "agent" then
    local REQUEST = {}

    -- http request分发器, 简单实现
    -- 后期需要url格式验证
    local function request_dispatch(path, query)
        if path ~= "/" then
            return ""
        else
            local cmd = tonumber(query["cmd"])
            local f = assert(REQUEST[COMMAND_HANDLER_MAP[cmd]])
            return f(query)
        end
    end

    local function response(id, ...)
        local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
        if not ok then
            -- if err == sockethelper.socket_error , that means socket closed.
            skynet.error(string.format("fd = %d, %s", id, err))
        end
    end

    skynet.start(function()
        skynet.dispatch("lua", function (_,_,id)
            socket.start(id)
            -- limit request body size to 8192 (you can pass nil to unlimit)
            local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
            if code then
                if code ~= 200 then
                    response(id, code)
                else
                    local path, query = urllib.parse(url)
                    local q = {}
                    if query then
                        q = urllib.parse_query(query)
                    end
                    local result = request_dispatch(path, q)
                    response(id, code, result)
                end
            else
                if url == sockethelper.socket_error then
                    skynet.error("socket closed")
                else
                    skynet.error(url)
                end
            end
            socket.close(id)
        end)
    end)

else

    skynet.start(function()
        local agent = {}
        for i= 1, 20 do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        end
        -- test player
        local p = player.new(145)
        local data = p:get_player_data()
        print_r(data)
        p:set_username("cls1991")
        p:save()
        local data2 = p:get_player_data()
        print_r(data2)

        local balance = 1
        local id = socket.listen("0.0.0.0", 10000)
        skynet.error("Listen web port 10000")
        socket.start(id , function(id, addr)
            skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
            skynet.send(agent[balance], "lua", id)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)
    end)
end
