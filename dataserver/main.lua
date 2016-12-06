local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("debug_console", 8000)
    local mysqlpool = skynet.uniqueservice("mysqlpool")
    skynet.call(mysqlpool, "lua", "start")
    local redispool = skynet.uniqueservice("redispool")
    skynet.call(redispool, "lua", "start")
    skynet.uniqueservice "webservice"
end)
